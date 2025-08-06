# 🚀 Azure Deployment Setup Guide

This guide will help you set up the complete CI/CD pipeline for your Azure Functions app.

## 📋 Prerequisites

- ✅ Azure CLI installed (`az --version`)
- ✅ GitHub CLI installed (`gh --version`)
- ✅ Repository created and code pushed to GitHub
- ✅ Azure subscription access

## 🏗️ Step-by-Step Setup

### Step 1: Authenticate with Azure

```bash
az login
az account list --output table
az account set --subscription "your-subscription-id"
```

### Step 2: Create GitHub Environment

```bash
# Replace with your repository info
export GITHUB_ORG="Rachit9971"
export GITHUB_REPO="SEMAG"

# Create dev environment in GitHub
gh api --method PUT -H "Accept: application/vnd.github+json" \
  repos/$GITHUB_ORG/$GITHUB_REPO/environments/dev
```

### Step 3: Create Service Principal for Azure Deployment

```bash
# Get your subscription ID
export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $AZURE_SUBSCRIPTION_ID"

# Create service principal with contributor access
az ad sp create-for-rbac --name "semag-github-actions" \
  --role Contributor \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID"

# Get the service principal info
export SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name "semag-github-actions" --query "[0].appId" -o tsv)
export AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)

echo "Service Principal ID: $SERVICE_PRINCIPAL_ID"
echo "Tenant ID: $AZURE_TENANT_ID"
```

### Step 4: Add User Access Administrator Role

```bash
# Grant User Access Administrator role for resource management
az role assignment create \
  --assignee $SERVICE_PRINCIPAL_ID \
  --role "User Access Administrator" \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID"
```

### Step 5: Configure Federated Identity for GitHub Actions

```bash
# Create federated credential for GitHub Actions OIDC
az ad app federated-credential create \
  --id $SERVICE_PRINCIPAL_ID \
  --parameters '{
    "name": "github-federated",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Step 6: Set GitHub Secrets

```bash
# Set required secrets in GitHub (dev environment)
gh secret set AZURE_CLIENT_ID --body $SERVICE_PRINCIPAL_ID --env dev
gh secret set AZURE_TENANT_ID --body $AZURE_TENANT_ID --env dev
gh secret set AZURE_SUBSCRIPTION_ID --body $AZURE_SUBSCRIPTION_ID --env dev

echo "✅ All secrets configured successfully!"
```

### Step 7: Test the Deployment

```bash
# Trigger the deployment workflow
gh workflow run deploy.yml
```

## 🔧 Manual Deployment (Alternative)

If you want to deploy manually first:

```bash
# Set environment variables
export AZURE_ENV_NAME="dev-semag-$(date +%s | tail -c 6)"
export AZURE_LOCATION="eastus"

# Deploy infrastructure
az deployment sub create \
  --location $AZURE_LOCATION \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters environmentName=$AZURE_ENV_NAME location=$AZURE_LOCATION \
  --name "semag-infra-$(date +%s)"

# Get the function app name
FUNCTION_APP_NAME=$(az deployment sub show \
  --name $(az deployment sub list --query "[0].name" -o tsv) \
  --query "properties.outputs.FUNCTION_APP_NAME.value" -o tsv)

echo "Function App created: $FUNCTION_APP_NAME"

# Build and deploy the function
yarn build
cd dist
func azure functionapp publish $FUNCTION_APP_NAME --typescript
```

## 🎯 Verification

### Check Deployment Status
```bash
# Check GitHub Actions
gh workflow list
gh run list --workflow=deploy.yml

# Check Azure resources
az resource list --tag azd-env-name=$AZURE_ENV_NAME --output table
```

### Monitor Function Execution
```bash
# View function logs
az functionapp log tail --name $FUNCTION_APP_NAME --resource-group rg-$AZURE_ENV_NAME
```

### Test Timer Function
Your timer function runs every minute. Check the logs to see:
- "Timer function processed request."
- "HELLO HELLO HELLO HELLO HELLO HELLO"
- "Timer function completed after 5 seconds."

## 🎉 What You've Built

- **🔄 CI/CD Pipeline**: Automated testing, building, and deployment
- **🏗️ Infrastructure as Code**: Azure Bicep templates for reproducible deployments
- **🧪 Testing Suite**: Jest unit tests with coverage reporting
- **📊 Monitoring**: Application Insights and Log Analytics
- **🔐 Security**: OIDC authentication, no secrets in workflows
- **⏰ Timer Function**: Runs every minute with proper error handling

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure service principal has Contributor and User Access Administrator roles
2. **Deployment Fails**: Check parameter file values and Azure resource quotas
3. **Function Not Triggering**: Verify AzureWebJobsStorage connection string
4. **GitHub Actions Failing**: Check environment secrets are properly configured

### Debugging Commands

```bash
# Check service principal permissions
az role assignment list --assignee $SERVICE_PRINCIPAL_ID --output table

# Check Azure resource quotas
az vm list-usage --location eastus --output table

# Test GitHub CLI authentication
gh auth status
```

## 📚 Next Steps

1. **Add more functions**: Create HTTP triggers, blob triggers, etc.
2. **Environment promotion**: Set up staging and production environments
3. **Monitoring alerts**: Configure Application Insights alerts
4. **Load testing**: Use the included load testing setup
5. **Security scanning**: Add dependency vulnerability scans

## 🔗 Useful Links

- [Repository](https://github.com/Rachit9971/SEMAG)
- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [GitHub Actions Azure Integration](https://docs.github.com/actions/deployment/deploying-to-azure)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
