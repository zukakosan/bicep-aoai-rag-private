param location string
param securityRules object[]
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: securityRules
  }
}

output nsgId string = nsg.id
