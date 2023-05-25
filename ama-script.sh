
randomstring=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
echo $randomstring
location=eastus
rgname="amarg$randomstring"
defrgname="amadefrg$randomstring"
storagename="amastorage$randomstring"
amaname="ama$randomstring"
amadisplayname="Managed Data Share App $randomstring"
containername=appcontainer

zipfile=datashareapp.zip

admingroup="AMA Admins Group"
zip $zipfile createUiDefinition.json mainTemplate.json

# create resource group if not exists
if [ $(az group exists --name $rgname) = false ]; then
    az group create --name $rgname --location $location
fi

az storage account create \
    --name $storagename \
    --resource-group $rgname \
    --location $location \
    --sku Standard_LRS \
    --kind StorageV2

az storage container create \
    --account-name $storagename \
    --name $containername \
    --public-access blob

az storage blob upload \
    --account-name $storagename \
    --container-name $containername \
    --name "$zipfile" \
    --file "$zipfile" \
    --overwrite

if [ $(az group exists --name $defrgname) = false ]; then
    az group create --name $defrgname --location $location
fi

groupid=$(az ad group show --group "$admingroup" --query id --output tsv)
ownerid=$(az role definition list --name Owner --query [].name --output tsv)

blob=$(az storage blob url --account-name $storagename  --container-name $containername --name $zipfile --output tsv)

az managedapp definition create \
  --name $amaname \
  --location $location \
  --resource-group $defrgname \
  --lock-level ReadOnly \
  --display-name "$amadisplayname" \
  --description "$amadisplayname" \
  --authorizations "$groupid:$ownerid" \
  --package-file-uri "$blob"