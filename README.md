# SEMAG - Azure Functions Timer Trigger

[![CI - Build and Test](https://github.com/USER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/USER/REPO/actions/workflows/ci.yml)
[![CD - Deploy to Azure](https://github.com/USER/REPO/actions/workflows/deploy.yml/badge.svg)](https://github.com/USER/REPO/actions/workflows/deploy.yml)
[![codecov](https://codecov.io/gh/USER/REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/USER/REPO)

A serverless Azure Functions application with TypeScript that runs a timer trigger every minute.

## 🚀 Features

- ⏰ Timer trigger function that runs every minute
- 🏗️ Infrastructure as Code with Azure Bicep
- 🔄 Complete CI/CD pipeline with GitHub Actions
- 🧪 Unit testing with Jest
- 📊 Code coverage reporting
- 🏥 Health checks and branch protection
- 🐳 Containerized development environment

## 🛠️ Tech Stack

- **Runtime**: Node.js 18.x
- **Language**: TypeScript
- **Cloud**: Azure Functions (Consumption Plan)
- **IaC**: Azure Bicep
- **CI/CD**: GitHub Actions
- **Testing**: Jest
- **Package Manager**: Yarn

## 📁 Project Structure

```
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── infra/                  # Azure Bicep infrastructure templates
├── src/
│   ├── functions/          # Azure Functions
│   └── index.ts           # App configuration
├── tests/                  # Unit tests
├── azure.yaml             # Azure Developer CLI config
├── host.json              # Functions host configuration
└── local.settings.json    # Local development settings
```

## 🏃‍♂️ Getting Started

### Prerequisites

- Node.js 18.x or later
- Azure Functions Core Tools
- Azure CLI (for deployment)
- Yarn package manager

### Local Development

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd SEMAG
   ```

2. **Install dependencies**

   ```bash
   yarn install
   ```

3. **Start local development**

   ```bash
   yarn start:dev
   ```

   This will start both Azurite (storage emulator) and the Functions runtime.

4. **Run tests**
   ```bash
   yarn test
   yarn test:coverage
   ```

## 🚀 Deployment

The application uses GitHub Actions for automated deployment:

### Automatic Deployment

- **Main branch**: Automatically deploys to Azure on push
- **Feature branches**: Run tests and health checks on PR

### Manual Deployment

Trigger manual deployment via GitHub Actions:

1. Go to Actions tab in your repository
2. Select "CD - Deploy to Azure" workflow
3. Click "Run workflow"

## 🧪 Testing

- **Unit Tests**: `yarn test`
- **Coverage Report**: `yarn test:coverage`
- **Health Check**: `yarn health-check`
- **Linting**: `yarn lint`

## 📊 CI/CD Pipeline

### Continuous Integration (CI)

- ✅ Dependency installation
- ✅ Linting and code quality checks
- ✅ Unit testing with coverage
- ✅ Build verification
- ✅ Branch health checks

### Continuous Deployment (CD)

- ✅ Azure login with OIDC
- ✅ Infrastructure deployment (Bicep)
- ✅ Application deployment
- ✅ Post-deployment verification

## 🏗️ Infrastructure

The application creates these Azure resources:

- **Function App** (Consumption plan)
- **Storage Account** (for function state)
- **Application Insights** (monitoring)
- **Log Analytics Workspace** (logging)
- **App Service Plan** (Dynamic/Y1 SKU)

## 🔧 Environment Variables

| Variable                   | Description               | Default        |
| -------------------------- | ------------------------- | -------------- |
| `FUNCTIONS_WORKER_RUNTIME` | Functions runtime         | `node`         |
| `AzureWebJobsStorage`      | Storage connection string | Auto-generated |

## 📈 Monitoring

- **Application Insights**: Performance and error monitoring
- **Log Analytics**: Centralized logging
- **GitHub Actions**: Build and deployment status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`yarn test`)
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
