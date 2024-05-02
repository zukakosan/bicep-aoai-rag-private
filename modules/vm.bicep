param location string
param vmName string
param vmSubnetId string
param adminUsername string
@secure()
param adminPassword string


resource pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: '${vmName}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetId
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

// API Ver 変える
resource winVmjumpBox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v4'
    }
    osProfile: {
      computerName: vmName
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
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    // diagnosticsProfile: {
    //   bootDiagnostics: {
    //     enabled: true
    //     storageUri: strgAcctDiag.properties.primaryEndpoints.blob
    //   }
    // }
  }
}
