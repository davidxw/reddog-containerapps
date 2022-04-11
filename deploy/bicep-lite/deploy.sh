# Linux/Mac only
export RG="reddog-lite"
export LOCATION="eastus"

az group create -n $RG -l $LOCATION

az deployment group create -n reddog -g $RG -f ./main.bicep
