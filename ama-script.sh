

zipfile=datashareapp.zip

zip $zipfile createUiDefinition.json mainTemplate.json

# az group create --name amarepository --location eastus

az storage account create \
    --name amarepostorageaccount \
    --resource-group amarepository \
    --location eastus \
    --sku Standard_LRS \
    --kind StorageV2

az storage container create \
    --account-name amarepostorageaccount \
    --name appcontainer \
    --public-access blob

az storage blob upload \
    --account-name amarepostorageaccount \
    --container-name appcontainer \
    --name "$zipfile" \
    --file "$zipfile" \
    --overwrite

az group create --name amadefinition --location eastus

groupid=$(az ad group show --group "AMA Admin Demo Group" --query id --output tsv)
ownerid=$(az role definition list --name Owner --query [].name --output tsv)




blob=$(az storage blob url --account-name amarepostorageaccount --container-name appcontainer --name $zipfile --output tsv)

az managedapp definition create \
  --name "extractmanagedapp" \
  --location "eastus" \
  --resource-group amadefinition \
  --lock-level ReadOnly \
  --display-name "Extract Managed Data Share App" \
  --description "Data Share Solutions for Extract Customers" \
  --authorizations "$groupid:$ownerid" \
  --package-file-uri "$blob"