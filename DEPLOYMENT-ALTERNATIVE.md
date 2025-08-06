# 🚨 Service Principal Creation Issue - Alternative Setup

Your Azure account doesn't have permissions to create service principals automatically. This is common in corporate environments. Here are your options:

## 🎯 Option 1: Request Service Principal from Admin (Recommended)

Ask your Azure administrator to create a service principal with these details:

### Service Principal Requirements:

- **Name**: `semag-github-actions`
- **Roles**:
  - `Contributor` on subscription `da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9`
  - `User Access Administrator` on subscription `da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9`
- **Authentication**: Federated Identity (OIDC)
- **Subject**: `repo:Rachit9971/SEMAG:environment:dev`

### Admin Commands:

```bash
# Create service principal
az ad sp create-for-rbac --name "semag-github-actions" \
  --role Contributor \
  --scopes "/subscriptions/da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9"

# Add User Access Administrator role
SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name "semag-github-actions" --query "[0].appId" -o tsv)
az role assignment create \
  --assignee $SERVICE_PRINCIPAL_ID \
  --role "User Access Administrator" \
  --scope "/subscriptions/da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9"

# Create federated credential
az ad app federated-credential create \
  --id $SERVICE_PRINCIPAL_ID \
  --parameters '{
    "name": "github-federated",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:Rachit9971/SEMAG:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Once Admin Provides the Service Principal:

```bash
# Set GitHub secrets (replace with actual values from admin)
gh secret set AZURE_CLIENT_ID --body "YOUR_SERVICE_PRINCIPAL_ID" --env dev
gh secret set AZURE_TENANT_ID --body "5581c9a8-168b-45f0-abd4-d375da99bf9f" --env dev
gh secret set AZURE_SUBSCRIPTION_ID --body "da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9" --env dev
```

## 🎯 Option 2: Use Azure Portal (Manual Setup)

1. **Go to Azure Portal** → Azure Active Directory → App registrations
2. **Create new registration**:
   - Name: `semag-github-actions`
   - Account types: Single tenant
3. **Add Federated Credential**:
   - Scenario: GitHub Actions
   - Organization: `Rachit9971`
   - Repository: `SEMAG`
   - Environment: `dev`
4. **Assign Roles** (Subscriptions → Access Control):
   - Add `Contributor` role
   - Add `User Access Administrator` role
5. **Copy Values**:
   - Application (client) ID
   - Directory (tenant) ID
   - Subscription ID

## 🎯 Option 3: Deploy Using Your Account (Simple)

Since we have the infrastructure ready, you can deploy manually:

```bash
# Login and set subscription
az login
az account set --subscription "da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9"

# Deploy infrastructure manually
export AZURE_ENV_NAME="dev-semag-$(date +%s | tail -c 6)"
export AZURE_LOCATION="eastus"

az deployment sub create \
  --location $AZURE_LOCATION \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters environmentName=$AZURE_ENV_NAME location=$AZURE_LOCATION \
  --name "semag-infra-$(date +%s)"

# Get function app name
FUNCTION_APP_NAME=$(az deployment sub show \
  --name $(az deployment sub list --query "[0].name" -o tsv) \
  --query "properties.outputs.FUNCTION_APP_NAME.value" -o tsv)

echo "Function App: $FUNCTION_APP_NAME"

# Build and deploy function
yarn build
cd dist
func azure functionapp publish $FUNCTION_APP_NAME --typescript
```

## 🔧 What's Already Configured

✅ **GitHub Repository**: https://github.com/Rachit9971/SEMAG
✅ **GitHub Environment**: `dev` environment created
✅ **CI/CD Workflows**: Ready to run once secrets are configured
✅ **Infrastructure Code**: Bicep templates ready
✅ **Application Code**: Timer function with tests

## 🚀 Test Your Setup

Once you have the service principal configured, test the deployment:

```bash
# Manual workflow trigger
gh workflow run deploy.yml

# Check status
gh run list --workflow=deploy.yml
```

## 📞 Need Help?

If you need assistance, provide your admin with:

- Repository URL: https://github.com/Rachit9971/SEMAG
- Subscription ID: `da45eee1-dcbc-4d10-8d8c-dfe8ef3f71e9`
- Tenant ID: `5581c9a8-168b-45f0-abd4-d375da99bf9f`
- Required roles: Contributor + User Access Administrator

The CI/CD pipeline is complete and ready - just need the service principal configured! 🎉
