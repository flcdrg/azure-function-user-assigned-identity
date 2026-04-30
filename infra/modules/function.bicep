param functionAppName string
param location string
param hostingPlanId string
param storageAccountName string
//param applicationInsightsName string
param functionAppRuntimeVersion string = '10.0'
param userAssignedIdentityName string

// resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
//   name: applicationInsightsName
// }

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userAssignedIdentityName
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites?WT.mc_id=DOP-MVP-5001655
resource functionApp 'Microsoft.Web/sites@2025-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }

  properties: {
    serverFarmId: hostingPlanId
    reserved: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'AzureWebJobsStorage__credential'
          value: 'managedidentity'
        }
        {
          name: 'AzureWebJobsStorage__managedIdentityClientId'
          value: userAssignedIdentity.properties.clientId
        }
        // {
        //   name: 'WEBSITE_CONTENTSHARE'
        //   value: toLower(functionAppName)
        // }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        // {
        //   name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        //   value: appInsights.properties.InstrumentationKey
        // }
        // {
        //   name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        //   value: appInsights.properties.ConnectionString
        // }
      ]

      minTlsVersion: '1.2'
      linuxFxVersion: 'DOTNET-ISOLATED|${functionAppRuntimeVersion}'
      alwaysOn: false
      localMySqlEnabled: false
      netFrameworkVersion: 'v4.6'
      ftpsState: 'Disabled'
      http20Enabled: true
    }
    httpsOnly: true
  }
}
