param location string
param strgAcctName string
param containerName string

resource strgAcct 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: strgAcctName
  tags:{
  }
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: strgAcct
  name: 'default'
  properties: {}
}

resource ctnrAoai 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: blobService
  name: containerName
  properties: {}
}

output strgAcctId string = strgAcct.id
output strgAcctName string = strgAcct.name

