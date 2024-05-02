param location string = 'japaneast'
param suffix string = 'zukako'
param tagValues object = {
  owner: 'zukako'
  environment: 'dev'
  project: 'aoai'
}

param adminUsername string = 'AzureAdmin'
@secure()
param adminPassword string

param aiSearchSku string = 'basic'

var vmSecurityRules = loadJsonContent('./vmSecurityRules.json')
var jumpboxVmName = 'jumpbox-win'

resource nsgVmSubnet 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-vm-subnet'
  location: location
  properties: {
    securityRules: vmSecurityRules
  }
}

resource VNet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-aoai-private'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-vm'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'subnet-pe'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

// API Ver 変える
resource pipJumpBox 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: '${jumpboxVmName}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nicJumpBox 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${jumpboxVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: filter(VNet.properties.subnets, s => s.name == 'subnet-vm')[0].id
          }
          publicIPAddress: {
            id: pipJumpBox.id
          }
        }
      }
    ]
  }
}

// API Ver 変える
resource winVmjumpBox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: jumpboxVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v4'
    }
    osProfile: {
      computerName: jumpboxVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-g2'
        version: 'latest'
      }
      osDisk: {
        name: '${jumpboxVmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicJumpBox.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: strgAcctDiag.properties.primaryEndpoints.blob
      }
    }
  }
}

resource strgAcctDiag 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'strgdiag${uniqueString(resourceGroup().id)}'
  tags:{
    owner: tagValues.owner
  }
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource strgAcctAoai 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'strgrag${uniqueString(resourceGroup().id)}'
  tags:{
    owner: tagValues.owner
  }
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource blobServiceAoai 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: strgAcctAoai
  name: 'default'
  properties: {}
}

resource ctnrAoai 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: blobServiceAoai
  name: 'documents'
  properties: {}
}

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: 'aisearch${suffix}'
  tags:{
    owner: tagValues.owner
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

// var pvtDnsZoneRag = 'privatelink.blob.${environment().suffixes.storage}'

resource pvtDnsZoneBlobRag 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  properties: {}
}

resource pvtDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: pvtDnsZoneBlobRag
  name: '${pvtDnsZoneBlobRag.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: VNet.id
    }
  }
}

resource peBlobRag 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'pe-strgrag'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-strgrag-conn'
        properties: {
          privateLinkServiceId: strgAcctAoai.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: filter(VNet.properties.subnets, s => s.name == 'subnet-pe')[0].id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: peBlobRag
  name: 'dnsGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: pvtDnsZoneBlobRag.id
        }
      }
    ]
  }
}

// AOAI
resource aoai 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: 'aoai${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    publicNetworkAccess: 'Disabled'
    networkAcls:{}
  }
}
