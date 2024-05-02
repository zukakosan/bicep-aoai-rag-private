param location string
param pvtDnsZoneName string
param vnetId string
param peName string
param pvtLinkServiceId string
param groupIds array
param peSubnetId string


resource pvtDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: pvtDnsZoneName
  location: 'global'
  properties: {}
}

resource pvtDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: pvtDnsZone
  name: '${pvtDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pe 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: peName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${peName}-conn'
        properties: {
          privateLinkServiceId: pvtLinkServiceId
          groupIds: groupIds
        }
      }
    ]
    subnet: {
      id: peSubnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: pe
  name: 'dnsGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: pvtDnsZone.id
        }
      }
    ]
  }
}
