CONFIG_FILE=$1

GROUP="$(jq -r ".group_name" $CONFIG_FILE)"
LOC="$(jq -r ".location" $CONFIG_FILE)"

readarray -t VMS < <(jq -c '.VM[]' $CONFIG_FILE)
for VM in ${VMS[@]}; do
    VM_NAME="$(jq -r ".name" <<< $VM )"
    echo $VM_NAME
    az vm create \
        --name $VM_NAME \
        --resource-group $GROUP \
        --vnet-name "$(jq -r ".network.name" $CONFIG_FILE)" \
        --subnet "$(jq -r ".subnet" <<< $VM)" \
        --nsg "" \
        --private-ip-address "$(jq -r ".private_ip" <<< $VM)" \
        --public-ip-address "$(jq -r ".public_ip" <<< $VM)"\
        --image Ubuntu2204 \
        --admin-username "azureuser"

    readarray -t SERVICES < <(jq -c '.services[]' <<< $VM)
    for SERVICE in ${SERVICES[@]}; do
        SERVICE_NAME=$(jq -r ".name" <<< $SERVICE)
        ENV_STRING=''
        readarray -t ENV_VARIABLES < <(jq -rc '.env[]' $SERVICE_NAME/commands.json)
        for ENV_VARIABLE in ${ENV_VARIABLES[@]}; do
            ENV_VALUE=$(jq -r ".env[\"$ENV_VARIABLE\"]" <<< $SERVICE)
            if [ "$ENV_VALUE" = "null" ] ; then
                echo "Missing env $ENV_VARIABLE in $SERVICE_NAME"
                exit 1
            fi
            ENV_STRING="$ENV_STRING$ENV_VARIABLE=\"$ENV_VALUE\" "
        done
        echo $ENV_STRING

        ./execute_commands.sh "$SERVICE_NAME"  \
        "$(az vm show -d -g $GROUP -n $VM_NAME --query publicIps -o tsv)" "azureuser" \
        "$ENV_STRING"
        
        done
    #freeing temp_ip. takes a long time
    if  [ "$(jq -r ".public_ip" <<< $VM)" = "temp_ip" ] ; then
        az network nic ip-config update \
            --name "ipconfig${VM_NAME}" \
            --resource-group $GROUP \
            --nic-name "${VM_NAME}VMNic" \
            --remove "PublicIpAddress"
    fi
done