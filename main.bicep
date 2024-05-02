param location string = resourceGroup().location
param adminUsername string
@secure()
param adminPassword string

var nsgName = 'nsg-jumpbox'
var vnetName = 'vnet-aoai-private'
var vmName = 'jumpbox'
var strgAddYourDataName = 'strgrag${uniqueString(resourceGroup().id)}'
var aiSearchName = 'aisearch${uniqueString(resourceGroup().id)}'
var aoaiName = 'aoai${uniqueString(resourceGroup().id)}'

module nsgJumpbox './modules/nsg.bicep' = {
  name: 'nsg-jumpbox-module'
  params: {
    nsgName: nsgName
    location: location
    securityRules: loadJsonContent('./modules/rules/vmSecurityRules.json')
  }
}

module vnetJumpbox './modules/vnet.bicep' = {
  name: 'vnet-jumpbox-module'
  params: {
    vnetName: vnetName
    location: location
    nsgId: nsgJumpbox.outputs.nsgId
  }
}

module jumpbox './modules/vm.bicep' = {
  name: 'jumpbox-module'
  params: {
    vmName: vmName
    location: location
    vmSubnetId: vnetJumpbox.outputs.jumpboxSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module strgAddYourData './modules/storage.bicep' = {
  name: 'strg-addyourdata-module'
  params: {
    strgAcctName: strgAddYourDataName
    location: location
    containerName: 'documents'
  }
}

module peStrgAddYourData './modules/private-endpoint.bicep' = {
  name: 'pe-strg-module'
  params: {
    location: location
    pvtDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
    vnetId: vnetJumpbox.outputs.vnetId
    peName: 'pe-strgrag'
    pvtLinkServiceId: strgAddYourData.outputs.strgAcctId
    groupIds: [
      'blob'
    ]
    peSubnetId: vnetJumpbox.outputs.peSubnetId
  }
}

module aiservices './modules/aiservices.bicep' = {
  name: 'aiservices-module'
  params: {
    location: location
    aiSearchName: aiSearchName
    aoaiName: aoaiName
    // aiSearchSku: 'basic'
    aiSearchSku: 'standard2'
    aoaiSku: 'S0'
  }
}

module peAiSearch './modules/private-endpoint.bicep' = {
  name: 'pe-aisearch-module'
  params: {
    location: location
    pvtDnsZoneName: 'privatelink.search.windows.net'
    vnetId: vnetJumpbox.outputs.vnetId
    peName: 'pe-aisearch'
    pvtLinkServiceId: aiservices.outputs.aiSearchId
    groupIds: [
      'searchService'
    ]
    peSubnetId: vnetJumpbox.outputs.peSubnetId
  }
}

module peAoai './modules/private-endpoint.bicep' = {
  name: 'pe-aoai-module'
  params: {
    location: location
    pvtDnsZoneName: 'privatelink.openai.azure.com'
    vnetId: vnetJumpbox.outputs.vnetId
    peName: 'pe-aoai'
    pvtLinkServiceId: aiservices.outputs.aoaiId
    groupIds: [
      'account'
    ]
    peSubnetId: vnetJumpbox.outputs.peSubnetId
  }
}

module sharedPrivateLink './modules/shared-private-link.bicep' = {
  name: 'shared-pe-module'
  params: {
    aiSearchName: aiSearchName
    strgId: strgAddYourData.outputs.strgAcctId
    aoaiId: aiservices.outputs.aoaiId
  }
}

module roleAssignment './modules/role-assignment-rag.bicep' = {
  name: 'role-assignment-module'
  params: {
    pidAoai: aiservices.outputs.aoaiPrincipalId
    pidAiSearch: aiservices.outputs.aiSearchPrincipalId
    strgAddYourDataName: strgAddYourDataName
    aiSearchName: aiSearchName
    aoaiName: aoaiName
  }
}
