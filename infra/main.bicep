targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Name of the resource group')
param resourceGroupName string

@description('Azure Web Jobs Storage connection string')
param azureWebJobsStorage string = ''

@description('Functions Worker Runtime')
param functionsWorkerRuntime string = 'node'

// Generate a unique token for resource names
var resourceToken = uniqueString(subscription().id, location, environmentName)
var resourcePrefix = 'sem'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    'azd-env-name': environmentName
  }
}

// Deploy main resources
module main 'main-resources.bicep' = {
  name: 'main-resources'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    resourcePrefix: resourcePrefix
    azureWebJobsStorage: azureWebJobsStorage
    functionsWorkerRuntime: functionsWorkerRuntime
  }
}

// Outputs
output RESOURCE_GROUP_ID string = rg.id
output AZURE_LOCATION string = location
output ENVIRONMENT_NAME string = environmentName
output FUNCTION_APP_NAME string = main.outputs.FUNCTION_APP_NAME
output APPLICATION_INSIGHTS_CONNECTION_STRING string = main.outputs.APPLICATION_INSIGHTS_CONNECTION_STRING
output STORAGE_ACCOUNT_NAME string = main.outputs.STORAGE_ACCOUNT_NAME
