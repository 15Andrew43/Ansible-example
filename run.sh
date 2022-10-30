#!/bin/bash


PARAMS=""
EXTRA_VARS=""

ROLE=site

if [ -z $ROLE ]
then
    echo "No role supplied, use command: export ROLE=XXXXX"
    exit 1
fi

echo "========================================================="
echo ""
echo "Start ansible v$(ansible --version) for:"
echo "    Role: $ROLE"




ENVIRONMENT=dev

if [ -z $ENVIRONMENT ]
then
    echo "No environment supplied, use command: export ENVIRONMENT=XXXXX"
    exit 1
fi




STATE=restarted

if [ ! -z "$STATE" ]
then
   echo "    With state: $STATE"
   PARAMS="$PARAMS --extra-vars state=$STATE"
fi

# if [ ! -z "$RECREATE" ]
# then
#    echo "    With RECREATE: $RECREATE"
#    PARAMS="$PARAMS --extra-vars recreate=$RECREATE"
# fi


if [ "$DEBUG" == "true" ]
then
   echo "    Debug: $DEBUG"
   PARAMS="$PARAMS -vvvv"
fi

if [ ! -z "$EXTRA_PARAMS" ]
then
   echo "    Extra params: $EXTRA_PARAMS"
   PARAMS="$PARAMS $EXTRA_PARAMS"
fi

echo ""
echo "    EXEC string:"
echo "        ansible-playbook --inventory=environments/${ENVIRONMENT} playbooks/$ROLE.yml $PARAMS"
echo ""
echo "========================================================="
echo ""

ansible-playbook --inventory=environments/${ENVIRONMENT} playbooks/$ROLE.yml $PARAMS
