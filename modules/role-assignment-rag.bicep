param pidAoai string
param aoaiName string

param pidAiSearch string
param aiSearchName string

param strgAddYourDataName string

var aiSearchIndexContributorId = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
var aiSearchContributorId = '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
var blobContributorId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var aoaiContributorId = '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'

resource aoai 'Microsoft.CognitiveServices/accounts@2021-10-01' existing = {
  name: aoaiName
}

resource aiSearch 'Microsoft.Search/searchServices@2020-08-01' existing = {
  name: aiSearchName
}

resource strgAddYourData 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: strgAddYourDataName
}

resource aiSearchIndexContributorToAoai 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiSearch
  name: guid(pidAoai, aiSearchIndexContributorId)
  properties: {
    principalId: pidAoai
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', aiSearchIndexContributorId)
    principalType: 'ServicePrincipal'
  }
}

resource aiSearchContributorToAoai 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiSearch
  name: guid(pidAiSearch, aiSearchContributorId)
  properties: {
    principalId: pidAoai
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', aiSearchContributorId)
    principalType: 'ServicePrincipal'
  }
}

resource blobContributorToAoai 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: strgAddYourData
  name: guid(pidAoai, blobContributorId)
  properties: {
    principalId: pidAoai
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', blobContributorId)
    principalType: 'ServicePrincipal'
  }
}

resource aoaiContributorToAiSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aoai
  name: guid(pidAiSearch, aoaiContributorId)
  properties: {
    principalId: pidAiSearch
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', aoaiContributorId)
    principalType: 'ServicePrincipal'
  }
}

resource blobContributorToAiSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: strgAddYourData
  name: guid(pidAiSearch, blobContributorId)
  properties: {
    principalId: pidAiSearch
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', blobContributorId)
    principalType: 'ServicePrincipal'
  }
}
