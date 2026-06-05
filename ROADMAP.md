# Roadmap

This document outlines the development roadmap for the chew-site-aws infrastructure project.

## In Progress

- Initial project setup and documentation
- Repository structure and OpenTofu configuration layout
- AWS account setup and IAM configuration
- GitHub Actions CI/CD workflows (plan and release)

## Planned - v0.1.0 (MVP)

### Environments
- **Dev environment**: Development and testing infrastructure
- **Prod environment**: Production e-commerce site
- **Note**: Staging environment deferred (see Future Enhancements)

### Core Infrastructure
- **VPC Configuration**: Virtual Private Cloud with public and private subnets across multiple availability zones
- **Security Groups**: Network security rules for web traffic and infrastructure components
- **S3 Bucket**: Static website hosting with appropriate bucket policies and versioning

### Content Delivery
- **CloudFront Distribution**: CDN configuration with custom domain support
- **SSL/TLS Certificates**: ACM certificate provisioning and validation
- **Route53 DNS**: Domain registration and DNS record management

### Infrastructure as Code
- OpenTofu modules for reusable components
- Variable definitions for environment-specific configuration
- State management configuration

## Future Enhancements

### Deployment Automation
- CI/CD pipeline integration (GitHub Actions or similar)
- Automated infrastructure testing and validation
- Deployment approval workflows
- Automated SSL certificate renewal

### Observability
- CloudWatch monitoring and alerting
- Access logging and analysis
- Performance metrics and dashboards
- Cost tracking and alerts

### Optimisation
- CloudFront caching strategies
- S3 lifecycle policies for cost reduction
- Reserved capacity planning
- Performance benchmarking

### Reliability
- Backup and disaster recovery procedures
- Infrastructure state backup strategy
- Rollback mechanisms
- High availability configuration review

### Multi-Environment Support
- **Staging Environment**: Add when third-party integration testing becomes necessary
  - **Triggers for adding staging:**
    - Payment gateway integration (testing production-like flows without affecting live transactions)
    - Shipping API integration (testing carrier APIs with production-like data)
    - Inventory management system integration (testing sync without affecting live inventory)
    - Marketing/analytics platform integration (testing tracking without polluting production data)
    - External CRM/ERP integration testing
    - Need for stakeholder/QA review in production-like environment before releases
  - **Staging infrastructure:** Near-identical to production (same services, scaled down where possible)
  - **Cost consideration:** ~2x current infrastructure costs when staging is added
- Environment-specific variable files
- Workspace management strategy
- Environment promotion workflows (dev → staging → prod)

### Security Hardening
- WAF (Web Application Firewall) integration
- DDoS protection configuration
- Security audit logging
- Compliance scanning and reporting

---

*This roadmap is subject to change based on project requirements and priorities.*
