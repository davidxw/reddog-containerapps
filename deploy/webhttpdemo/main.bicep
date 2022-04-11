param location string = resourceGroup().location
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'demo-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'cae-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'log-${uniqueSuffix}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: containerAppsEnvName
  location: location
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource webhttpTest 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'webhttptest'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    template: {
      containers: [
        {
          name: 'webhttptest'
          image: 'docker.io/davidxw/webtest:latest'
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
    configuration: {
       ingress: {
         external: true
         targetPort: 80
       }
    }
  }
}

resource aspnetsample 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'aspnetsample'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    template: {
      containers: [
        {
          name: 'aspnetsample'
          image: 'mcr.microsoft.com/dotnet/samples:aspnetapp'
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
    configuration: {
       ingress: {
         external: false
         targetPort: 80
       }
    }
  }
}
