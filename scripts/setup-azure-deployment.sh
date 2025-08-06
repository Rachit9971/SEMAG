#!/bin/bash

# 🚀 SEMAG - Azure Functions Deployment Setup
# This script automates the CI/CD pipeline setup for Azure Functions

set -e  # Exit on any error

echo "🚀 Starting SEMAG Azure Functions Deployment Setup..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository configuration
GITHUB_ORG="Rachit9971"
GITHUB_REPO="SEMAG"

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found. Please install it first.${NC}"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not found. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed!${NC}"

# Azure authentication
echo -e "${BLUE}🔐 Checking Azure authentication...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Please login:${NC}"
    az login
fi

# Get subscription ID
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)

echo -e "${GREEN}✅ Azure Subscription: $AZURE_SUBSCRIPTION_ID${NC}"
echo -e "${GREEN}✅ Azure Tenant: $AZURE_TENANT_ID${NC}"

# Create GitHub environment
echo -e "${BLUE}🏗️  Creating GitHub environment...${NC}"
gh api --method PUT -H "Accept: application/vnd.github+json" \
  repos/$GITHUB_ORG/$GITHUB_REPO/environments/dev || echo -e "${YELLOW}⚠️  Environment may already exist${NC}"

echo -e "${GREEN}✅ GitHub environment created/verified!${NC}"

# Create service principal
echo -e "${BLUE}🔑 Creating Azure service principal...${NC}"

# Check if service principal already exists
SP_EXISTS=$(az ad sp list --display-name "semag-github-actions" --query "[0].appId" -o tsv)

if [ -n "$SP_EXISTS" ]; then
    echo -e "${YELLOW}⚠️  Service principal already exists. Using existing one...${NC}"
    SERVICE_PRINCIPAL_ID=$SP_EXISTS
else
    echo -e "${BLUE}Creating new service principal...${NC}"
    SP_OUTPUT=$(az ad sp create-for-rbac --name "semag-github-actions" \
        --role Contributor \
        --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
        --json-auth)
    
    SERVICE_PRINCIPAL_ID=$(echo $SP_OUTPUT | jq -r '.clientId')
fi

echo -e "${GREEN}✅ Service Principal ID: $SERVICE_PRINCIPAL_ID${NC}"

# Add User Access Administrator role
echo -e "${BLUE}🎯 Adding User Access Administrator role...${NC}"
az role assignment create \
    --assignee $SERVICE_PRINCIPAL_ID \
    --role "User Access Administrator" \
    --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID" || echo -e "${YELLOW}⚠️  Role may already exist${NC}"

echo -e "${GREEN}✅ Role assignments configured!${NC}"

# Create federated credential
echo -e "${BLUE}🔗 Configuring OIDC federated identity...${NC}"
az ad app federated-credential create \
    --id $SERVICE_PRINCIPAL_ID \
    --parameters "{
        \"name\": \"github-federated\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:environment:dev\",
        \"audiences\": [\"api://AzureADTokenExchange\"]
    }" 2>/dev/null || echo -e "${YELLOW}⚠️  Federated credential may already exist${NC}"

echo -e "${GREEN}✅ OIDC federated identity configured!${NC}"

# Set GitHub secrets
echo -e "${BLUE}🔒 Setting GitHub repository secrets...${NC}"

gh secret set AZURE_CLIENT_ID --body "$SERVICE_PRINCIPAL_ID" --env dev
gh secret set AZURE_TENANT_ID --body "$AZURE_TENANT_ID" --env dev  
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID" --env dev

echo -e "${GREEN}✅ GitHub secrets configured successfully!${NC}"

# Summary
echo ""
echo -e "${GREEN}🎉 SETUP COMPLETE! 🎉${NC}"
echo "================================"
echo -e "${BLUE}📋 Configuration Summary:${NC}"
echo -e "   Repository: ${GITHUB_ORG}/${GITHUB_REPO}"
echo -e "   Subscription ID: ${AZURE_SUBSCRIPTION_ID}"
echo -e "   Service Principal: ${SERVICE_PRINCIPAL_ID}"
echo -e "   Environment: dev"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo "1. Push code changes to trigger GitHub Actions"
echo "2. Monitor deployment: gh workflow run deploy.yml"
echo "3. Check logs: gh run list --workflow=deploy.yml"
echo ""
echo -e "${BLUE}📊 Monitor your function:${NC}"
echo "- Timer runs every minute"
echo "- Check Application Insights for metrics"
echo "- View logs in Azure portal"
echo ""
echo -e "${GREEN}✨ Happy deploying! ✨${NC}"
