param location string
param aiSearchName string
param aiSearchSku string
param aoaiName string
param aoaiSku string

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aiSearchName
  tags:{
  }
  location: location
  sku: {
    name: aiSearchSku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'disabled'
    semanticSearch: 'free'
    networkRuleSet:{}
  }
}

resource aoai 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: aoaiName
  location: location
  sku: {
    name: aoaiSku
  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    customSubDomainName: aoaiName
    publicNetworkAccess: 'Disabled'
    networkAcls:{}
  }
}

output aiSearchId string = aiSearch.id
output aoaiId string = aoai.id
output aoaiPrincipalId string = aoai.identity.principalId
output aiSearchPrincipalId string = aiSearch.identity.principalId
