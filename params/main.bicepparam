using '../main.bicep'

param adminUsername = 'AzureAdmin'
param adminPassword = readEnvironmentVariable('ADMIN_PASSWORD')
