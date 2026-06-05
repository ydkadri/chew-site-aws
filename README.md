# chew-site-aws

OpenTofu infrastructure for deploying and managing the Chew website on AWS. This project provides Infrastructure as Code (IaC) for hosting a static or dynamic website with AWS services.

## Overview

This repository contains OpenTofu configurations to provision and manage AWS infrastructure for website hosting, including networking, compute, storage, and related services. The infrastructure is designed to be scalable, secure, and maintainable across multiple environments.

## Prerequisites

Before you begin, ensure you have the following installed:

- **[OpenTofu](https://opentofu.org/)** (>= 1.6.0) - Open-source Terraform alternative
- **[AWS CLI](https://aws.amazon.com/cli/)** (>= 2.0) - AWS command-line interface
- **[just](https://just.systems/)** (optional but recommended) - Command runner for project tasks
- **AWS Account** with appropriate permissions to create resources

### AWS Credentials

Configure your AWS credentials using one of the following methods:

```bash
# Option 1: AWS CLI configuration
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ca-central-1"

# Option 3: AWS SSO
aws sso login --profile your-profile
```

## Quick Start

### 1. Clone and Initialise

```bash
# Clone the repository
git clone <repository-url>
cd chew-site-aws

# Initialise OpenTofu (downloads providers and modules)
tofu init
```

### 2. Plan Infrastructure Changes

```bash
# Preview what changes will be made
tofu plan
```

### 3. Apply Infrastructure

```bash
# Apply the infrastructure changes
tofu apply
```

When prompted, review the planned changes and type `yes` to proceed.

### 4. View Outputs

```bash
# Display infrastructure outputs (URLs, resource IDs, etc.)
tofu output
```

## Project Structure

```
chew-site-aws/
├── tofu/                    # OpenTofu configuration files
│   ├── modules/            # Reusable infrastructure modules
│   │   ├── networking/     # VPC, subnets, routing
│   │   ├── compute/        # EC2, ECS, Lambda
│   │   ├── storage/        # S3, EFS, databases
│   │   └── cdn/            # CloudFront, Route53
│   ├── environments/       # Environment-specific configurations
│   │   ├── dev/           # Development environment
│   │   ├── staging/       # Staging environment
│   │   └── prod/          # Production environment
│   └── shared/            # Shared configurations
│       ├── providers.tf   # AWS provider configuration
│       └── versions.tf    # OpenTofu version constraints
├── tests/                 # Infrastructure tests
│   ├── unit/             # Validation and linting
│   └── integration/      # Deployment tests
├── docs/                  # Documentation
│   ├── user-journey/     # Operational workflows
│   ├── interface/        # Module APIs and outputs
│   ├── architecture/     # Design and decisions
│   └── development/      # Development guides
├── scripts/              # Helper scripts
├── justfile              # Task runner configuration
├── .env.example          # Environment variable template
└── README.md             # This file
```

## Common Commands

This project uses [just](https://just.systems/) as a task runner. If you have `just` installed, you can use these convenient commands:

```bash
# Show all available commands
just --list

# Initialise all environments
just init

# Initialise a specific environment
just init-env dev

# Run all quality checks
just check

# Format OpenTofu code
just format

# Validate configurations
just validate

# Run tests
just test

# Plan changes for an environment
just plan dev

# Apply changes to an environment
just apply dev

# View outputs for an environment
just outputs dev

# Show state for an environment
just state dev

# Destroy infrastructure (use with caution!)
just destroy dev
```

See the `justfile` for the complete list of available commands and their implementation.

### Without `just`

If you prefer not to use `just`, you can run OpenTofu commands directly:

```bash
# Initialise
cd tofu/environments/dev
tofu init

# Plan
tofu plan

# Apply
tofu apply

# Show outputs
tofu output

# Destroy
tofu destroy
```

## Development Workflow

### Making Infrastructure Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/add-cloudfront-distribution
   ```

2. **Make changes to the OpenTofu configuration**
   ```bash
   # Edit relevant .tf files in tofu/modules/ or tofu/environments/
   vim tofu/modules/cdn/main.tf
   ```

3. **Format and validate**
   ```bash
   just format
   just validate
   ```

4. **Test in development environment**
   ```bash
   just plan dev
   just apply dev
   ```

5. **Run tests**
   ```bash
   just test
   ```

6. **Commit and push**
   ```bash
   git add .
   git commit -m "Add CloudFront distribution for improved caching"
   git push origin feature/add-cloudfront-distribution
   ```

7. **Create a pull request**
   - Review the plan output
   - Ensure tests pass
   - Request peer review

### Environment Progression

Changes should flow through environments in this order:

```
dev → staging → prod
```

1. Test thoroughly in `dev`
2. Deploy to `staging` for pre-production validation
3. Deploy to `prod` only after staging approval

## State Management

### Remote State

OpenTofu state files contain sensitive information and should **never** be committed to version control. This project uses remote state storage:

- **Backend**: AWS S3 with DynamoDB for state locking
- **Encryption**: State files are encrypted at rest
- **Versioning**: S3 versioning enabled for state recovery

State configuration is in `tofu/environments/*/backend.tf`.

### State Security

- State files may contain sensitive data (passwords, keys, etc.)
- Access to the S3 state bucket should be restricted via IAM policies
- Enable S3 bucket logging to audit state access
- Use state locking to prevent concurrent modifications

## Security Notes

### Credentials

- **Never commit AWS credentials** to version control
- Use `.env` files (listed in `.gitignore`) for local credentials
- Use IAM roles with least privilege for production deployments
- Rotate access keys regularly

### Secrets Management

- Use **AWS Secrets Manager** or **Systems Manager Parameter Store** for sensitive values
- Reference secrets in OpenTofu using data sources, not hardcoded values
- Mark sensitive outputs with `sensitive = true`

### Access Control

- Use IAM roles and policies to control resource access
- Enable CloudTrail for audit logging
- Configure VPC security groups with minimal required access
- Use private subnets for backend resources

### Compliance

- Review security group rules regularly
- Enable encryption at rest for all data stores (S3, RDS, EBS)
- Enable encryption in transit (HTTPS, TLS)
- Implement backup and disaster recovery procedures

## Troubleshooting

### Common Issues

**Issue**: `Error: error configuring Terraform AWS Provider: no valid credential sources`

**Solution**: Ensure AWS credentials are configured correctly (see Prerequisites)

---

**Issue**: `Error: Error locking state: Error acquiring the state lock`

**Solution**: Another process may be running. Wait for it to complete or [force unlock](https://opentofu.org/docs/cli/commands/force-unlock/) if necessary (use with caution)

---

**Issue**: `Error: Provider produced inconsistent final plan`

**Solution**: Run `tofu plan` again. If persistent, check for provider version conflicts in `versions.tf`

---

For additional help:
- Check the [OpenTofu documentation](https://opentofu.org/docs/)
- Review AWS service-specific documentation
- Consult the `docs/` directory for detailed guides

## Contributing

Please read `docs/development/contributing.md` for details on our development process and how to submit pull requests.

## Documentation

Detailed documentation is available in the `docs/` directory:

- **[Deployment Guide](docs/user-journey/deployment.md)** - Step-by-step deployment instructions
- **[Architecture Overview](docs/architecture/overview.md)** - Infrastructure design and components
- **[Module APIs](docs/interface/module-apis.md)** - Module inputs and outputs
- **[Development Setup](docs/development/setup.md)** - Setting up your development environment

## Licence

[Specify your licence here]

## Support

For issues, questions, or contributions:
- Open an issue in this repository
- Contact the infrastructure team
- See `docs/user-journey/troubleshooting.md` for common solutions
