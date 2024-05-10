LOG_DIR="$(date +"%Y-%m-%dT%H:%M:%S")"
mkdir -p log/$LOG_DIR
LOG_FILE_NAME="log/$LOG_DIR/azure.log"

CONFIG_FILE=$1

GROUP="$(jq -r ".group_name" $CONFIG_FILE)"
LOC="$(jq -r ".location" $CONFIG_FILE)"

function check_azure_out() {
    echo $AZURE_OUT >> $LOG_FILE_NAME
    PROVISIONING_STATE=$(jq -r "$1.provisioningState" <<< $AZURE_OUT 2>/dev/null)
    POWER_STATE=$(jq -r "$1.powerState" <<< $AZURE_OUT 2>/dev/null)
    if [ "$PROVISIONING_STATE" == "Succeeded" ] || [ "$POWER_STATE" == "VM running" ]
    then
        echo "OK"
    else
        echo "ERROR"
        echo $AZURE_OUT
        exit 1
    fi
}

if  [ $(az group exists -n $GROUP) = true ] ; then
    az group delete -n $GROUP --force-deletion-types Microsoft.Compute/virtualMachines -y
fi

echo -n "Creating resource group... "
AZURE_OUT=$(az group create --name $GROUP --location $LOC 2>>$LOG_FILE_NAME)
check_azure_out ".properties"

echo -n "Creating network... "
AZURE_OUT=$(az network vnet create\
    --name "$(jq -r ".network.name" $CONFIG_FILE)" \
    --resource-group $GROUP \
    --address-prefix "$(jq -r ".network.prefix" $CONFIG_FILE)" \
    2>&1 --only-show-errors)
check_azure_out ".newVNet"

readarray -t NSGS < <(jq -c '.nsgs[]' $CONFIG_FILE)
for NSG in ${NSGS[@]}; do
    NSG_NAME="$(jq -r ".name" <<< $NSG)"
    echo -n "Creating network security group $NSG_NAME... "
    AZURE_OUT=$(az network nsg create \
        --name $NSG_NAME \
        --resource-group $GROUP 2>>$LOG_FILE_NAME)
    check_azure_out ".NewNSG"
    readarray -t RULES < <(jq -c '.rules[]' <<< $NSG)
    for RULE in ${RULES[@]}; do
        RULE_NAME=$(jq -r ".name" <<< $RULE)
        echo -n "Creating rule $RULE_NAME in $NSG_NAME... "
        AZURE_OUT=$(az network nsg rule create \
            --name "$RULE_NAME" \
            --nsg-name $NSG_NAME \
            --priority "$(jq -r ".priority" <<< $RULE)" \
            --direction "$(jq -r ".direction" <<< $RULE)" \
            --access allow \
            --destination-address-prefixes "$(jq -r ".destination_address_prefixes" <<< $RULE)" \
            --destination-port-ranges "$(jq -r ".destination_port_ranges" <<< $RULE)" \
            --source-address-prefixes "$(jq -r ".source_address_prefixes" <<< $RULE)" \
            --source-port-ranges "$(jq -r ".source_port_ranges" <<< $RULE)" \
            --resource-group $GROUP \
            --protocol Tcp \
            2>&1 --only-show-errors)
        check_azure_out
    done
done

readarray -t SUBNETS < <(jq -c '.network.subnets[]' $CONFIG_FILE)
for SUBNET in ${SUBNETS[@]}; do
    SUBNET_NAME=$(jq -r ".name" <<< $SUBNET )
    echo -n "Creating subnet $SUBNET_NAME... "
    AZURE_OUT=$(az network vnet subnet create \
        --name "$SUBNET_NAME"\
        --resource-group $GROUP \
        --vnet-name "$(jq -r ".network.name" $CONFIG_FILE)" \
        --address-prefixes "$(jq -r ".prefix" <<< $SUBNET)" \
        --nsg "$(jq -r ".nsg" <<< $SUBNET)" \
        2>&1 --only-show-errors)
    check_azure_out
done

readarray -t IPS < <(jq -c '.public_ips[]' $CONFIG_FILE)
for IP in ${IPS[@]}; do
    IP_NAME=$(jq -r ".name" <<< $IP )
    echo -n "Creating public ip $IP_NAME... "
    AZURE_OUT=$(az network public-ip create -g $GROUP -n "$(jq -r ".name" <<< $IP )" --only-show-errors 2>&1)
    check_azure_out ".publicIp"
done

readarray -t VMS < <(jq -c '.VM[]' $CONFIG_FILE)
for VM in ${VMS[@]}; do
    VM_NAME="$(jq -r ".name" <<< $VM )"
    VM_SIZE="$(jq -r ".size" <<< $VM )"
    if [ "$VM_SIZE" == "null" ]; then
        VM_SIZE="Standard_DS1_v2"
    fi
    echo "-- Virtual machine $VM_NAME"
    echo -n "Creating VM... "
    AZURE_OUT=$(az vm create \
        --name $VM_NAME \
        --size $VM_SIZE \
        --resource-group $GROUP \
        --vnet-name "$(jq -r ".network.name" $CONFIG_FILE)" \
        --subnet "$(jq -r ".subnet" <<< $VM)" \
        --nsg "" \
        --private-ip-address "$(jq -r ".private_ip" <<< $VM)" \
        --public-ip-address "$(jq -r ".public_ip" <<< $VM)"\
        --image Ubuntu2204 \
        --admin-username "azureuser" \
        2>&1 --only-show-errors)
    check_azure_out

    sleep 10s
    readarray -t SERVICES < <(jq -c '.services[]' <<< $VM)
    for SERVICE in ${SERVICES[@]}; do
        SERVICE_NAME=$(jq -r ".name" <<< $SERVICE)
        echo "---- Service $SERVICE_NAME"
        ENV_STRING=''
        readarray -t ENV_VARIABLES < <(jq -rc '.env[]' commands/$SERVICE_NAME/commands.json)
        for ENV_VARIABLE in ${ENV_VARIABLES[@]}; do
            if [ "$ENV_VARIABLE" == "PUBLIC_IP" ]; then
                ENV_VALUE=$(az vm show -d -g $GROUP -n $VM_NAME --query publicIps -o tsv)
            else
                ENV_VALUE=$(jq -r ".env[\"$ENV_VARIABLE\"]" <<< $SERVICE)
            fi
            if [ "$ENV_VALUE" = "null" ] ; then
                echo "Missing env $ENV_VARIABLE in $SERVICE_NAME"
                exit 1
            fi
            ENV_STRING="$ENV_STRING$ENV_VARIABLE=\"$ENV_VALUE\" "
        done

        ./execute_commands.sh "$SERVICE_NAME"  \
        "$(az vm show -d -g $GROUP -n $VM_NAME --query publicIps -o tsv)" "azureuser" \
        "$LOG_DIR" \
        "$ENV_STRING"

        if [ "$?" != "0" ]; then
            exit 1
        fi
        done
    #freeing temp_ip. takes a long time
    if  [ "$(jq -r ".public_ip" <<< $VM)" = "temp_ip" ] ; then
        echo -n "Freeing temporary ip for VM... "
        AZURE_OUT=$(az network nic ip-config update \
            --name "ipconfig${VM_NAME}" \
            --resource-group $GROUP \
            --nic-name "${VM_NAME}VMNic" \
            --remove "PublicIpAddress" \
            2>&1 --only-show-errors)
        check_azure_out
    fi
done

#closing ssh connection
readarray -t NSGS < <(jq -c '.nsgs[]' $CONFIG_FILE)
for NSG in ${NSGS[@]}; do
    NSG_NAME="$(jq -r ".name" <<< $NSG)"
    echo -n "Closing ssh connection for $NSG_NAME... "
    az network nsg rule delete \
        --resource-group  $GROUP \
        --nsg-name "$(jq -r ".name" <<< $NSG)" \
        --name ssh \
        2>&1 --only-show-errors
    if [ "$?" == "0" ]; then
        echo "OK"
    else
        echo "ERROR $?"
    fi
done

PUBLIC_IP=$(az vm show -d -g $GROUP -n "frontend" --query publicIps -o tsv)
echo "The app is available at http://$PUBLIC_IP"

