SERVICE_NAME=$1
SSH_ADDRESS=$2
SSH_USER=$3
LOG_DIR=$4
ENV_STRING=$5

eval $ENV_STRING

mkdir -p log/$LOG_DIR

LOG_FILE_NAME="log/$LOG_DIR/$SERVICE_NAME.log"

echo "Configuring $SERVICE_NAME with environment $ENV_STRING" >> $LOG_FILE_NAME

readarray -t COMMANDS < <(jq -c '.commands[]' commands/$SERVICE_NAME/commands.json)
for ((i = 0; i < ${#COMMANDS[@]}; i++))
do
    COMMAND=${COMMANDS[$i]}
    MESSAGE=$(jq -r ".message" <<< $COMMAND )
    COMMAND_STRING=$(jq -r ".command" <<< $COMMAND )
    SCRIPT=$(jq -r ".script" <<< $COMMAND )
    PARAM_STRING=''
    PARAMS=$(jq -r ".params" <<< $COMMAND)
    if [ "$PARAMS" != "null" ]
    then
        readarray -t PARAMS < <(jq -rc '.params[]' <<< $COMMAND)
        for PARAM in ${PARAMS[@]}; do
            PARAM_STRING="$PARAM_STRING\"${!PARAM}\" "
        done
    fi
    echo -n "$MESSAGE... "
    if [ "$COMMAND_STRING" != "null" ] ; then
        ssh -o "StrictHostKeyChecking no" $SSH_USER@$SSH_ADDRESS "$COMMAND_STRING" > log/latest.log 2>&1
    else
        ssh -o "StrictHostKeyChecking no" $SSH_USER@$SSH_ADDRESS 'bash -s' < commands/$SERVICE_NAME/$SCRIPT $PARAM_STRING > log/latest.log 2>&1
    fi
    ERROR_CODE=$?
    echo "$MESSAGE" >> $LOG_FILE_NAME
    cat log/latest.log >> $LOG_FILE_NAME
    if [ "$ERROR_CODE" == "0" ]
    then
        echo "OK"
    else
        echo "ERROR $ERROR_CODE"
        cat log/latest.log
        exit 1
    fi

done
