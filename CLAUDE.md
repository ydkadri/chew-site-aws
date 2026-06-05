# CLAUDE.md

## Project Context

**chew-site-aws** is a personal infrastructure-as-code project for deploying and managing a website on AWS using OpenTofu (open-source Terraform fork).

- **Purpose**: Infrastructure as Code for AWS website hosting
- **Tech Stack**: OpenTofu, AWS
- **CI/CD**: GitHub Actions
- **Repository**: git@github.com:ydkadri/chew-site-aws.git
- **Current Version**: 0.1.0

## Critical Infrastructure Rules

1. **Never commit state files**: `.tfstate`, `.tfstate.backup`, or `.terraform/` directories
2. **Never commit secrets**: `.env`, `terraform.tfvars` with credentials, AWS keys, or any sensitive data
3. **Always validate before pushing**: Run `just check` before pushing changes
4. **Test in isolation**: Always test modules in isolation before deploying to environments
5. **Plan before apply**: Always review `tofu plan` output before applying changes
6. **Environment separation**: Never apply dev configurations to prod environments
7. **State locking**: Ensure state locking is enabled to prevent concurrent modifications
8. **Immutable infrastructure**: Prefer replacing resources over modifying them in place
9. **Tag everything**: All AWS resources must have appropriate tags (environment, project, managed-by)
10. **Document decisions**: Record significant infrastructure decisions in ADRs

## Version Management

- **Versioning Scheme**: Semantic versioning (MAJOR.MINOR.PATCH)
- **Current Version**: 0.1.0
- **Version Triggers**:
  - MAJOR: Breaking changes to module interfaces, major architectural changes
  - MINOR: New modules, new environments, backward-compatible enhancements
  - PATCH: Bug fixes, documentation updates, minor corrections
- **Tagging**: Tag releases in git as `v0.1.0`, `v0.2.0`, etc.
- **Version Location**: Tracked in this file and CHANGELOG.md

## Pre-Commit Requirements

Run `just git-pre-commit` before every commit. This executes:

1. **Format code**: `tofu fmt -recursive tofu/` - Auto-format all OpenTofu files
2. **Validate syntax**: `tofu validate` - Ensure configurations are syntactically valid
3. **Lint code**: `tflint --recursive tofu/` - Check for errors and best practices
4. **Security scan**: `tfsec tofu/` or `trivy config tofu/` - Scan for security vulnerabilities
5. **Documentation**: `terraform-docs` - Ensure module documentation is up to date
6. **Secrets detection**: Check for accidentally committed secrets or credentials
7. **CHANGELOG.md**: Updated with changes (for feature work)

**Never commit**:
- `.tfstate` or `.tfstate.backup` files
- `.terraform/` directories
- `.env` files or `terraform.tfvars` with secrets
- AWS credentials, access keys, or tokens
- Any sensitive configuration or data

## Pre-Push Requirements

Run `just git-pre-push` before pushing branches. This executes:

1. All pre-commit checks (implied)
2. **Unit tests**: Validate all modules pass basic checks
3. **Policy validation**: Ensure infrastructure complies with defined policies
4. **Plan validation**: Generate and review plans for affected environments
5. **Module tests**: Run module-specific tests (if configured)
6. **Cost estimation**: Review infrastructure costs (if Infracost configured)
7. **Version verification**: Ensure version bump is documented (for releases)

## Testing Standards

### Test Levels

1. **Validation Tests** (Fast, pre-commit)
   - `tofu validate` - Syntax and configuration validity
   - `tflint` - Linting and best practices
   - `tfsec` or `checkov` - Security and compliance

2. **Unit Tests** (Fast, pre-push)
   - Test individual modules in isolation
   - Mock AWS API calls or use localstack
   - Verify module inputs, outputs, and logic

3. **Integration Tests** (Slow, CI only)
   - Deploy to test environment
   - Verify full stack functionality
   - Automatic cleanup after tests

4. **Policy Tests** (Fast, pre-push)
   - Validate against organisational policies
   - Check cost constraints
   - Verify required tags and encryption

### Coverage Requirements

- All modules must have unit tests
- Critical infrastructure paths require integration tests
- All environments must pass validation tests
- Security-critical resources need compliance scanning

### Test Structure

```
tests/
├── unit/
│   ├── vpc/
│   ├── compute/
│   └── storage/
└── integration/
    ├── test_full_stack.py
    └── test_networking.py
```

## Security Practices

### Secrets Management

- **Never hardcode credentials**: Use environment variables or AWS Secrets Manager
- **Local secrets**: Use `pass` (Unix password manager) for local credential storage
  ```bash
  pass insert aws/chew-site/access-key
  export AWS_ACCESS_KEY_ID=$(pass show aws/chew-site/access-key)
  ```
- **.env files**: Use for local development, never commit (add to `.gitignore`)
- **.env.example**: Provide template showing required variables without values
- **Sensitive variables**: Define in `variables.tf` with no defaults, pass via `TF_VAR_*`
- **Production secrets**: Use AWS Secrets Manager or Parameter Store
- **Pre-commit hooks**: Must scan for secrets before allowing commits

### State File Management

- **Remote state**: Store state in S3 with encryption enabled
- **State locking**: Use DynamoDB for state locking
- **Never commit state**: Add `.tfstate*` to `.gitignore`
- **State access**: Restrict S3 bucket access via IAM policies
- **State backups**: Enable S3 versioning for state bucket

### AWS Credentials

- **Profile-based**: Use AWS profiles, never embed credentials
  ```bash
  export AWS_PROFILE=chew-site
  ```
- **Temporary credentials**: Prefer temporary session tokens
- **Least privilege**: Use minimal IAM permissions required
- **MFA required**: Enable MFA for production deployments

## Common Justfile Commands

### Development
- `just install` - Install dependencies (OpenTofu, tflint, terraform-docs)
- `just init` - Initialise all environments
- `just init-env dev` - Initialise specific environment
- `just clean` - Clean `.terraform/` directories and lock files

### Testing
- `just test` - Run validation, formatting checks, and linting
- `just test-integration` - Run integration tests (terratest/kitchen)
- `just validate` - Validate all environment configurations
- `just lint` - Run tflint and check module documentation

### Deployment
- `just plan dev` - Generate plan for environment (dev/staging/prod)
- `just apply dev` - Apply changes to environment
- `just destroy dev` - Destroy infrastructure (use with caution)
- `just outputs dev` - Show outputs for environment
- `just state dev` - List resources in state for environment

### Quality
- `just format` - Auto-format all OpenTofu code
- `just check` - Run all quality checks (format, lint, validate, test)
- `just security` - Run security scans (tfsec, checkov)
- `just cost dev` - Estimate infrastructure costs (if Infracost configured)
- `just docs` - Generate module documentation

### Git Hooks
- `just git-pre-commit` - Pre-commit checks (format, lint, validate)
- `just git-pre-push` - Pre-push checks (all quality checks + tests)

## Git Workflow

### Branch Naming

- `feature/description` - New infrastructure components or enhancements
- `fix/description` - Infrastructure bug fixes
- `patch/description` - Minor corrections or typos
- `docs/description` - Documentation-only changes

Branch names should be descriptive and explain what the branch does.

### Commit Conventions

**Format**:
```
Brief summary under 70 characters

Detailed explanation focusing on why this change was made,
not what changed (the diff shows that).

Fixes #123
Closes #456
```

**During draft PR**:
- Use `git commit --fixup=<commit>` for review feedback
- Keeps changes visible for incremental review

**Before marking ready**:
- Run `git rebase -i --autosquash main` to clean history
- Each commit should be a logical, complete unit
- Tests should pass for each commit

## Feature Implementation Workflow

### Phase 1: Align on Approach
1. Discuss infrastructure requirements
2. Write user journey doc (e.g., "Deploy VPC with public/private subnets")
3. **CHECKPOINT 1**: Push draft PR with user journey

### Phase 2: Design Interface
1. Write interface documentation (module inputs/outputs, CLI commands)
2. Include usage examples
3. **CHECKPOINT 2**: Push interface docs to PR

### Phase 3: Plan Implementation
1. Create implementation plan in ROADMAP.md
2. List GitHub issues this resolves
3. Define commit structure and review milestones
4. **CHECKPOINT 3**: Push plan for agreement

### Phase 4: Implement Incrementally
1. Write tests first for modules
2. Implement infrastructure code
3. Use `git commit --fixup=<commit>` during draft
4. Push at planned milestones
5. Keep PR in DRAFT status

### Phase 5: Finalise
1. Run `just check` - all quality checks must pass
2. Update CHANGELOG.md
3. Update README.md if needed
4. Version bump (get confirmation first)
5. Rebase with `git rebase -i --autosquash main`
6. Verify GitHub issue references in PR
7. Mark PR ready for review

## Documentation

### Required Documentation
- `README.md` - Project overview, setup, deployment instructions
- `CHANGELOG.md` - Infrastructure changes and version history
- `ROADMAP.md` - High-level feature planning and milestones
- `docs/user-journeys/` - How to deploy and manage infrastructure
- `docs/interface/` - Module interfaces, CLI commands, workflows
- `docs/adr/` - Architectural Decision Records
- `docs/architecture/` - System design and network diagrams

### Module Documentation
Each module must include:
- `README.md` with terraform-docs generated content
- Input variables with descriptions
- Output values with descriptions
- Usage examples
- Requirements (providers, versions)

## Quick Reference

**Common Operations**:
```bash
# Format and validate
just format
just validate

# Test changes
just test
just check

# Deploy to dev
just plan dev
just apply dev

# View resources
just outputs dev
just state dev

# Security scan
just security

# Clean up
just destroy dev
```

**Emergency Commands**:
```bash
# Unlock state (if locked after crash)
cd tofu/environments/dev && tofu force-unlock <LOCK_ID>

# Import existing resource
cd tofu/environments/dev && tofu import <RESOURCE> <AWS_ID>

# View plan without applying
just plan prod > plan.txt
```

---

**Last Updated**: 2026-06-05  
**Version**: 0.1.0
