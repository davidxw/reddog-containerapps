# Linux/Mac only
export RG="containerappdemo2"
export LOCATION="eastus"

az group create -n $RG -l $LOCATION

az deployment group create -n $RG -g $RG -f ./main.bicep
