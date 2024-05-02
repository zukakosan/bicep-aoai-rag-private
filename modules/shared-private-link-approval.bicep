param strgName string
param privateLinkName string

resource strg 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: strgName
}

resource sharedPrivateLinkApproval 'Microsoft.Storage/storageAccounts/privateEndpointConnections@2023-01-01' = {
  name: privateLinkName
  parent: strg
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      // actionRequired: 'string'
      description: 'approve shared private link request'
      status: 'Approved'
    }
  }
}
