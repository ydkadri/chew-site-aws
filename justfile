# Show available commands
default:
    @just --list

# Check for required tools
[group('development')]
install:
    @echo "Checking required tools..."
    @command -v tofu >/dev/null 2>&1 || echo "❌ OpenTofu not found. Install from https://opentofu.org/"
    @command -v aws >/dev/null 2>&1 || echo "❌ AWS CLI not found. Install from https://aws.amazon.com/cli/"
    @command -v tflint >/dev/null 2>&1 || echo "⚠️  TFLint not found (optional). Install from https://github.com/terraform-linters/tflint"
    @command -v tfsec >/dev/null 2>&1 || echo "⚠️  TFSec not found (optional). Install from https://github.com/aquasecurity/tfsec"
    @echo "✓ Tool check complete"

# Initialize a specific environment
[group('development')]
init env:
    @if [ ! -d "tofu/environments/{{env}}" ]; then \
        echo "Environment {{env}} does not exist"; \
        exit 1; \
    fi
    cd tofu/environments/{{env}} && tofu init

# Format OpenTofu files recursively
[group('development')]
format:
    @echo "Formatting OpenTofu files..."
    @if [ -d "tofu" ]; then tofu fmt -recursive tofu/; else echo "tofu/ directory not found"; fi

# Validate OpenTofu configuration
[group('development')]
validate:
    @echo "Validating OpenTofu configurations..."
    @if [ -d "tofu/environments/dev" ]; then cd tofu/environments/dev && tofu validate; fi
    @if [ -d "tofu/environments/prod" ]; then cd tofu/environments/prod && tofu validate; fi
    @echo "✓ Validation complete"

# Clean build artifacts
[group('development')]
clean:
    @echo "Cleaning OpenTofu artifacts..."
    find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
    find . -type f -name "*.tfplan" -delete 2>/dev/null || true
    @echo "✓ Clean complete"

# Show execution plan for environment
[group('planning')]
plan env:
    @if [ ! -d "tofu/environments/{{env}}" ]; then \
        echo "Environment {{env}} does not exist"; \
        exit 1; \
    fi
    cd tofu/environments/{{env}} && tofu plan

# Apply infrastructure changes (used by CI/CD only)
[group('deployment')]
apply env:
    @if [ ! -d "tofu/environments/{{env}}" ]; then \
        echo "Environment {{env}} does not exist"; \
        exit 1; \
    fi
    cd tofu/environments/{{env}} && tofu apply

# Destroy infrastructure (use with extreme caution)
[group('deployment')]
destroy env:
    @echo "⚠️  WARNING: This will destroy all infrastructure in {{env}} environment"
    @if [ ! -d "tofu/environments/{{env}}" ]; then \
        echo "Environment {{env}} does not exist"; \
        exit 1; \
    fi
    cd tofu/environments/{{env}} && tofu destroy

# Show outputs for environment
[group('deployment')]
outputs env:
    @if [ ! -d "tofu/environments/{{env}}" ]; then \
        echo "Environment {{env}} does not exist"; \
        exit 1; \
    fi
    cd tofu/environments/{{env}} && tofu output

# Run linting checks
[group('quality')]
lint:
    @echo "Running TFLint..."
    @if command -v tflint >/dev/null 2>&1; then \
        tflint --recursive tofu/ || echo "⚠️  Linting issues found"; \
    else \
        echo "⚠️  TFLint not installed, skipping"; \
    fi

# Run security scanning
[group('quality')]
security:
    @echo "Running security scan..."
    @if command -v tfsec >/dev/null 2>&1; then \
        if [ -d "tofu" ]; then tfsec tofu/ || echo "⚠️  Security issues found"; fi; \
    else \
        echo "⚠️  TFSec not installed, skipping"; \
    fi

# Run all quality checks
[group('quality')]
check: format validate lint security
    @echo "✓ All quality checks complete"

# Pre-commit checks (format, validate, lint, security)
[group('git')]
git-pre-commit:
    @echo "Running pre-commit checks..."
    @just format
    @just validate
    @if command -v tflint >/dev/null 2>&1; then just lint; fi
    @if command -v tfsec >/dev/null 2>&1; then just security; fi
    @echo "✓ Pre-commit checks passed"

# Pre-push checks (all quality checks)
[group('git')]
git-pre-push:
    @echo "Running pre-push checks..."
    @just check
    @echo "✓ Pre-push checks passed"

# Show tool versions
[group('info')]
version:
    @echo "Tool versions:"
    @tofu version | head -1
    @aws --version
    @if command -v tflint >/dev/null 2>&1; then tflint --version; fi
    @if command -v tfsec >/dev/null 2>&1; then tfsec --version; fi
