az group create --name lab3 --location switzerlandnorth

az aks create --resource-group lab3 --name lab3-aks --node-count 2 -s Standard_D2_v2 --generate-ssh-keys

az aks get-credentials --resource-group lab3 --name lab3-aks