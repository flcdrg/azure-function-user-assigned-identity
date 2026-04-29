param hostingPlanName string
param location string

resource hostingPlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    // name: 'FC1'
    // tier: 'FlexConsumption'
  }
  kind: 'functionapp'
  properties: {
    reserved: true
  }
}

output hostingPlanId string = hostingPlan.id
