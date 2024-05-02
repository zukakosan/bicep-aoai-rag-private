param location string
param vnetAddressPrefix string = '10.0.0.0/16'
param vnetName string
param jumpboxSubnetName string = 'subnet-jumpbox'
param subnetList array = [
  jumpboxSubnetName
  'subnet-pe'
]
param nsgId string

resource VNet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets:[ for (subnet, i) in subnetList: {
      name: subnet
      properties: {
        addressPrefix: cidrSubnet(vnetAddressPrefix, 24, i)
        networkSecurityGroup: subnet == jumpboxSubnetName ? {
          id: nsgId
        } : null
      }
    } 
    ]
  }
}

output vnetId string = VNet.id
output jumpboxSubnetId string = filter(VNet.properties.subnets, s => s.name == jumpboxSubnetName)[0].id
output peSubnetId string = filter(VNet.properties.subnets, s => s.name == 'subnet-pe')[0].id
