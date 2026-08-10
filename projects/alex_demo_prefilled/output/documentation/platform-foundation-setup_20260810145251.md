# Platform Foundation Setup

> Generated: 2026-08-10 14:52:51
> Blueprint: platform-foundation-setup

---

The Platform Foundation Setup workflow establishes the core infrastructure and security controls for your Snowflake environment. This workflow guides you through critical architectural decisions, account configuration, administrative access setup, security policies, and cost management controls. By completing this workflow, you'll have a well-architected, secure, and cost-controlled Snowflake platform ready for data product deployment.

---

## Table of Contents

- [Task 1: Platform Foundation](#task-1-platform-foundation)
  - [Step 1.1: Determine Account Strategy](#step-11-determine-account-strategy)
  - [Step 1.2: Configure Organization Name for Connectivity](#step-12-configure-organization-name-for-connectivity)
  - [Step 1.3: Enable Organization Account](#step-13-enable-organization-account)
  - [Step 1.4: Create Organization Account](#step-14-create-organization-account)
  - [Step 1.5: Create Infrastructure Database](#step-15-create-infrastructure-database)
  - [Step 1.6: Define Domains, Environments, and Object Naming Conventions](#step-16-define-domains-environments-and-object-naming-conventions)
  - [Step 1.7: Configure Infrastructure Database Replication](#step-17-configure-infrastructure-database-replication)
- [Task 2: Platform Security & Identity](#task-2-platform-security-identity)
  - [Step 2.1: Select Identity Management Approach](#step-21-select-identity-management-approach)
  - [Step 2.2: Configure SCIM Integration](#step-22-configure-scim-integration)
  - [Step 2.3: Provision Account Administrators](#step-23-provision-account-administrators)
  - [Step 2.4: Create Organization Account Administrators](#step-24-create-organization-account-administrators)
  - [Step 2.5: Configure SAML/SSO](#step-25-configure-samlsso)
  - [Step 2.6: Create Break-Glass Emergency Access](#step-26-create-break-glass-emergency-access)
  - [Step 2.7: Configure Network Rules and Policies](#step-27-configure-network-rules-and-policies)
  - [Step 2.8: Configure Authentication Policies](#step-28-configure-authentication-policies)
  - [Step 2.9: Enable Multi-Factor Authentication](#step-29-enable-multi-factor-authentication)
- [Task 3: Platform Cost Management](#task-3-platform-cost-management)
  - [Step 3.1: Enable Spending Budgets](#step-31-enable-spending-budgets)
  - [Step 3.2: Configure Spending Budgets](#step-32-configure-spending-budgets)
  - [Step 3.3: Enable Resource Monitors](#step-33-enable-resource-monitors)
  - [Step 3.4: Configure Resource Monitors](#step-34-configure-resource-monitors)
  - [Step 3.5: Enable Cost Allocation Tags](#step-35-enable-cost-allocation-tags)
  - [Step 3.6: Configure Cost Allocation Tags](#step-36-configure-cost-allocation-tags)
- [Task 4: Platform Observability](#task-4-platform-observability)
  - [Step 4.1: Configure Telemetry Parameters](#step-41-configure-telemetry-parameters)

---


# Task 1: Platform Foundation

**Summary:** Define your account strategy, configure account identifiers, set up centralized management, create shared infrastructure, and organize your platform with domains, environments, FinOps tags, and naming conventions.

**Prerequisites:**
- **Personas:** Platform Administrator, Cloud/Infrastructure Team
- **Role Requirements:** ORGADMIN or ACCOUNTADMIN privileges, Enterprise Edition or higher for Organization Account features
- **External Requirements:** Snowflake account (trial or provisioned), Organization information (org name from account URL)

<details>
<summary>Task Overview (click to expand)</summary>

# Platform Foundation

## Summary
Define your account strategy, configure account identifiers, set up centralized management,
create shared infrastructure, and organize your platform with domains, environments,
FinOps tags, and naming conventions.

## External Requirements
- Snowflake account (trial or provisioned)
- Organization information (org name from account URL)

## Personas
- Platform Administrator
- Cloud/Infrastructure Team

## Role Requirements
- ORGADMIN or ACCOUNTADMIN privileges
- Enterprise Edition or higher for Organization Account features

## Details
## **Steps in This Task**

| Step | Title | Purpose |
| :---- | :---- | :---- |
| 1.1 | Determine Account Strategy | Choose between single or multi-account architectures |
| 1.2 | Configure Organization Name for Connectivity | Define how account URLs and identifiers are structured |
| 1.3 | Configure Organization Account | Decide whether to create a centralized management account |
| 1.4 | Create Organization Account | Provision the Organization Account (conditional—only if enabled in 1.3) |
| 1.5 | Create Infrastructure Database | Set up centralized metadata and governance storage |
| 1.6 | Define Domains, Environments & Naming Conventions | Establish domains, environments, FinOps tags, and account and object naming standards |
| 1.7 | Configure Infrastructure Database Sharing | Enable cross-account access to governance objects (multi-account only) |

### Network Policy for PAT Authentication (Trial Accounts)

If you are using a **trial account** and plan to authenticate using a **Programmatic Access Token (PAT)**, you must first create a network policy. Trial accounts require this for PAT authentication to work.

**Before running this blueprint with PAT authentication:**

1. Log into Snowsight manually using your username/password
2. Create a network policy allowing your IP address:

```sql
USE ROLE ACCOUNTADMIN;

-- Create network policy (replace YOUR_PUBLIC_IP with your actual IP address)
CREATE NETWORK POLICY allow_deployment_policy
  ALLOWED_IP_LIST = ('YOUR_PUBLIC_IP/32')
  COMMENT = 'Allow deployment from specific IP for PAT authentication';

-- Apply to your user (replace YOUR_USERNAME with your username)
ALTER USER YOUR_USERNAME SET NETWORK_POLICY = allow_deployment_policy;
```

3. Generate a PAT for your user in Snowsight (User Menu → Profile → Personal Access Tokens)
4. Configure the connection in `~/.snowflake/connections.toml`

**Note:** This requirement is specific to trial accounts. Production accounts provisioned by Snowflake typically do not have this restriction.

## **Account Execution Context**

Understanding where SQL commands are executed is critical:

| Steps | Account Context |
| :---- | :---- |
| 1.1 - 1.4 | Your **initial/trial account** - where you start |
| 1.5 - 1.7 | **Organization Account** (if created) OR initial account (if no org account) |

**Important**: If you create an Organization Account, you must **log into it** after it has been created. All remaining steps in the workflow will be executed from the Organization Account.

If you choose not to create an Organization Account, all steps are executed in your initial account.

## **Time Estimate**

This task typically takes **30-45 minutes** to complete, depending on the complexity of your organization's requirements and the level of discussion needed for strategic decisions.

## **Key Decisions**

Several questions in this task have long-term implications:

1. **Account Strategy**: Changing from single to multi-account (or vice versa) after implementation is a significant undertaking  
2. **Naming Conventions**: Object names are difficult to change after data is loaded and applications are connected  
3. **Domain/Environment Structure**: These become the foundation for access control, cost allocation, and data organization

Take time to involve relevant stakeholders when making these decisions.

## **Deliverables**

Upon completion, you will have:

* A documented account strategy with clear rationale  
* Configured (or documented) Organization Account settings  
* Infrastructure database with governance schema for platform-wide objects  
* Defined list of domains and environments with corresponding FinOps tags  
* Documented naming convention standards for databases, warehouses, and roles  
* Infrastructure database share configured for cross-account access (multi-account only)

## **More Information**

* [Snowflake Organizations](https://docs.snowflake.com/en/user-guide/organizations) — Overview of organization structure  
* [Organization Accounts](https://docs.snowflake.com/en/user-guide/organization-accounts) — Centralized management capabilities  
* [Account Identifiers](https://docs.snowflake.com/en/user-guide/admin-account-identifier) — Understanding account URLs  
* [Snowflake Editions](https://docs.snowflake.com/en/user-guide/intro-editions) — Feature comparison across editions  
* [Introduction to Secure Data Sharing](https://docs.snowflake.com/en/user-guide/data-sharing-intro) — Cross-account data access

</details>

---


## Step 1.1: Determine Account Strategy

# Determine Account Strategy

## Overview

This section captures the foundational account strategy decision for our Snowflake data platform. This decision determines how workloads are organized, security boundaries are established, and costs are allocated across the organization.

## Decision Summary

| Decision | Selection |
|----------|-----------|
| **Account Strategy** | Single Account |
| **Primary Isolation** | Logical (Database/Schema) |
| **Complexity Level** | Low |

## Strategy Details
### Single Account Strategy

We have selected a **Single Account** strategy for our Snowflake deployment. In this model, all data environments (Dev, Test, Prod) and business domains will exist within one Snowflake account.

**Rationale:**
- Centralized data team manages all data assets and security
- Simplest possible administration with a "single pane of glass" for monitoring
- Developer agility is prioritized, including the ability to use Zero-Copy Cloning
- Cost allocation needs can be handled by tagging resources rather than separate invoices

| Characteristic | Value |
|----------------|-------|
| Primary Data Isolation | Logical (Database/Schema) |
| Cost Tracking | Requires Tagging |
| SDLC Data Sharing | Zero Copy Cloning |
| Complexity | Low |

**Considerations:**
- Lower isolation means changes in non-production environments could theoretically impact production resource limits
- Single security boundary for all data
- Organization Account is recommended for future-proofing

---


## Step 1.2: Configure Organization Name for Connectivity

# Configure Organization Name for Connectivity

## Overview

This section documents how the organization name is configured in Snowflake Account Identifiers. Account Identifiers are critical components of URLs and programmatic connections to Snowflake. 

**⚠️ Important:** Once your organization name is in use with users and systems securely connecting to Snowflake using your Account Identifiers and URLs, it is difficult to change the organization name in all the places that would require the change. For this reason, we strongly encourage customers to plan ahead and ensure that their Organization Name meets their future connectivity needs up front.

## Decision Summary

| Configuration | Value |
|---------------|-------|
| **Organization Name** | `FINTECHCORP` |

## Account Identifier Structure

Your Snowflake Account Identifiers will follow this pattern:

**URL Structure:**
```

https://FINTECHCORP-<account_name>.snowflakecomputing.com

```

**Example URLs:**
| Account Purpose | Account Name | Full URL |
|-----------------|--------------|----------|
| Production | `prod` | `https://FINTECHCORP-prod.snowflakecomputing.com` |
| Development | `dev` | `https://FINTECHCORP-dev.snowflakecomputing.com` |
| Organization Account | `org` | `https://FINTECHCORP-org.snowflakecomputing.com` |
| Finance Domain | `finance` | `https://FINTECHCORP-finance.snowflakecomputing.com` |

## Connectivity Reference

All users and systems connecting to Snowflake will use these Account Identifiers:

| Connection Method | Format |
|-------------------|--------|
| Web UI Access | `https://FINTECHCORP-<account_name>.snowflakecomputing.com` |
| Snowflake CLI / SnowSQL | `FINTECHCORP-<account_name>` |
| Drivers & Connectors | Account identifier: `FINTECHCORP-<account_name>` |
| Third-party Integrations | Use account identifier in partner tool configuration |

---


## Step 1.3: Enable Organization Account

| Configuration | Value |
|---------------|-------|
| **Create Organization Account** | No |

## Organization Account: Not Enabled

We have decided **not to create an Organization Account** at this time.

**Implications:**
- Single-account deployment without centralized management features
- Organization-level features are not available
- Can be enabled later if you select or upgrade to Snowflake edition Enterprise or higher

**Next Step:** You will skip the Create Organization Account step and continue to the next configuration step.

## Key Terminology

| Term | Definition |
|------|------------|
| Organization | A Snowflake object that links accounts owned by your business entity |
| Organization Name | Your Snowflake business entity identifier (e.g., `ACME` or `XY12345`) |
| Organization Account | A special account type with ORGADMIN privileges for managing other accounts |
| Organization Account Name | The name you assign to your Organization Account (configured in the next step if enabled) |

---


## Step 1.4: Create Organization Account

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `org_account_edition`
>
> Provide values for the above variables to render this step.

---


## Step 1.5: Create Infrastructure Database

# Create Infrastructure Database

## Overview

This section documents the configuration for the centralized Infrastructure Database. This database serves as the primary repository for platform-wide objects including governance policies, network rules, and tags.

## Decision Summary

| Parameter | Value |
|-----------|-------|
| **Database Name** | `INFRA` |
| **Governance Schema** | `GOVERNANCE` |
| **Managed Access** | Enabled |

## Database Configuration

**Purpose:** Central hub database for metadata, security, and administrative objects that apply across the organization.

**Ownership:** Platform Team (identified by domain prefix in naming convention)

### Schema Structure

| Schema Name | Purpose | Managed Access |
|-------------|---------|----------------|
| `GOVERNANCE` | Governance policies, tags, and security objects | ✅ Yes |

### Naming Convention Rationale

| Component | Value | Purpose |
|-----------|-------|---------|
| Domain | `PLAT` (or platform identifier) | Identifies central platform team ownership |
| Data Product | `INFRA` (or infrastructure identifier) | Indicates infrastructure/administrative purpose |

## Objects to be Created in Later Steps

The `GOVERNANCE` schema will be used to store objects created in subsequent workflow steps, for example:

| Object Type | Purpose |
|-------------|---------|
| Tags | FinOps tags for cost allocation (DOMAIN, ENVIRONMENT, DATAPRODUCT, etc.) |
| Network Rules | IP allowlisting and network security policies |
| Stored Procedures | Administrative and maintenance procedures |
| Views | Governance and audit views |
| Tables | Configuration and metadata tables |

## Deployment Considerations
**Single Account Deployment:**
- The Infrastructure Database resides in the single account
- All objects are directly accessible to authorized roles
- No cross-account sharing required

## Access Control

| Role | Access Level | Purpose |
|------|--------------|---------|
| SYSADMIN | OWNERSHIP | Full control of database and objects |
| SECURITYADMIN | USAGE, CREATE | Manage security-related objects |
| ACCOUNTADMIN | FULL | Administrative access |
| Platform Roles | USAGE | Access to shared governance objects |

## Verification

After creation, verify the Infrastructure Database:

```sql
-- Verify database exists
SHOW DATABASES LIKE 'INFRA';

-- Verify schema with Managed Access
SHOW SCHEMAS IN DATABASE INFRA;

-- Confirm Managed Access is enabled
SELECT * FROM INFRA.INFORMATION_SCHEMA.SCHEMATA 
WHERE SCHEMA_NAME = 'GOVERNANCE';
```

---


## Step 1.6: Define Domains, Environments, and Object Naming Conventions

# Define Domains, Environments & Naming Conventions

## Overview

This section defines the domains (business units/entities), environments (Software Development Lifecycle (SDLC) stages), and naming conventions that will structure our Snowflake platform. These definitions serve as the foundation for account names, database names, warehouse names, role names, and FinOps tagging.

## Decision Summary

| Decision | Selection |
|----------|-----------|
| **Account Strategy** | Single Account |
| **Domains** | `PAYMENTS`, `RISK`, `LEDGER`, `CUSTOMER`, `COMPLIANCE` |
| **Environments** | `DEV`, `STG`, `PROD` |
| **Component Order** | `<domain>_<dataproduct>_<env>` |

## Domains

Domains represent logical groupings of business functions, data, or ownership. They define boundaries for governance, cost allocation, and data stewardship.

| Domain Abbreviation | Description |
|---------------------|-------------|
| `PAYMENTS` | |
| `RISK` | |
| `LEDGER` | |
| `CUSTOMER` | |
| `COMPLIANCE` | |
**Usage:** Domains will appear in **database object names** (databases, warehouses, roles).

## Environments

Environments represent stages in the Software Development Lifecycle (SDLC), used to isolate data and application development based on maturity and stability.

| Environment Abbreviation | Stage |
|--------------------------|-------|
| `DEV` | |
| `STG` | |
| `PROD` | |
**Usage:** Environments will appear in **database object names** (databases, warehouses, roles).

## Naming Convention

**Selected Component Order:** `<domain>_<dataproduct>_<env>`
Objects will be named with **Domain first, then Data Product, then Environment**.
- Clusters objects by business domain first
- Groups data products within each domain
- Environment is the final differentiator

**Component Inclusion (based on Single Account):**
- Domain: ✅ Included in object names
- Environment: ✅ Included in object names

### Example Names

Based on the **Single Account** strategy with component order `<domain>_<dataproduct>_<env>`:
| Object Type | Example Name | Components |
|-------------|--------------|------------|
| Database | `PAYMENTS_ANALYTICS_PROD_RAW` | Domain, DataProduct, Env, Zone |
| Warehouse | `PAYMENTS_ANALYTICS_PROD_TRANSFORM` | Domain, DataProduct, Env, Workload |
| Role | `PAYMENTS_ANALYTICS_PROD_READ` | Domain, DataProduct, Env, Function |

## Tags Created

The following tags will be created in the `INFRA.GOVERNANCE` schema:

| Tag Name | Allowed Values | Purpose |
|----------|----------------|---------|
| `DOMAIN` | `PAYMENTS`, `RISK`, `LEDGER`, `CUSTOMER`, `COMPLIANCE` | Business unit for cost allocation |
| `ENVIRONMENT` | `DEV`, `STG`, `PROD` | SDLC stage for cost allocation |
| `DATAPRODUCT` | (Any value) | Data product identifier |
| `WORKLOAD` | (Any value) | Warehouse workload type |
| `ZONE` | (Any value) | Database data zone |
| `DATA_CLASSIFICATION` | (Any value) | Data sensitivity level |

**Why create all six tags now?**

We create DATAPRODUCT, WORKLOAD, ZONE, and DATA_CLASSIFICATION tags in this step—even though you're only defining values for DOMAIN and ENVIRONMENT—to ensure:

- **Immediate availability** — Tags are ready for use when you create data products in subsequent workflows
- **Centralized governance** — All FinOps tags are stored together in the Governance schema
- **Naming alignment** — Object naming components align directly with tags for consistent cost reporting

> **Note:** DOMAIN and ENVIRONMENT tags have restricted allowed values based on your selections above. The other tags accept any value, allowing flexibility when defining data products, warehouses, and databases in later workflows.

---


## Step 1.7: Configure Infrastructure Database Replication

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `infrastructure_replication_group`
>
> Provide values for the above variables to render this step.

---


# Task 2: Platform Security & Identity

**Summary:** Configure user provisioning via SCIM or manual management, provision platform administrators, configure single sign-on, create emergency access, implement network security, define authentication policies, and enable multi-factor authentication.

**Prerequisites:**
- **Personas:** Security Administrator, Identity Team, Platform Administrator
- **Role Requirements:** ACCOUNTADMIN privileges, Logged into Organization Account (if created) or primary account
- **External Requirements:** Task 1 (Platform Foundation) completed, Identity Provider Access (Okta, Azure AD, etc.), Network Information (corporate IP ranges, VPN endpoints, cloud service IPs), Administrator Details (names and email addresses)

<details>
<summary>Task Overview (click to expand)</summary>

# Platform Security & Identity

## Summary
Configure user provisioning via SCIM or manual management, provision platform
administrators, configure single sign-on, create emergency access, implement
network security, define authentication policies, and enable multi-factor authentication.

## External Requirements
- Task 1 (Platform Foundation) completed
- Identity Provider Access (Okta, Azure AD, etc.)
- Network Information (corporate IP ranges, VPN endpoints, cloud service IPs)
- Administrator Details (names and email addresses)

## Personas
- Security Administrator
- Identity Team
- Platform Administrator

## Role Requirements
- ACCOUNTADMIN privileges
- Logged into Organization Account (if created) or primary account

## Details
## Steps in This Task

| Step | Title | Purpose |
|------|-------|---------|
| 2.1 | Configure SCIM Integration | Set up automated user provisioning from your IdP (or choose manual management) |
| 2.2 | Provision/Create Account Administrators | Assign ACCOUNTADMIN and other admin roles (method varies based on 2.1) |
| 2.3 | Configure SAML/SSO | Enable federated authentication (optional) |
| 2.4 | Create Break-Glass Access | Establish emergency access account |
| 2.5 | Configure Network Policies | Set up IP allowlisting and network rules |
| 2.6 | Configure Authentication Policies | Define auth requirements by user type |
| 2.7 | Enable Multi-Factor Authentication | Guide MFA enrollment for users |

**Note on administrator provisioning:** Based on your choice in Configure SCIM Integration:
- **If using SCIM:** You'll provision administrators by granting roles to SCIM-provisioned users
- **If using manual management:** You'll create administrator users directly in Snowflake

**Note on SAML/SSO:** SAML/SSO configuration is optional. In Configure SCIM Integration, you'll choose whether to configure SAML now or later. If you skip SAML, users will authenticate with password + MFA.

**⚠️ All Task 2 steps configure the account you are currently logged into.**

## Time Estimate

This task typically takes **45-60 minutes** to complete. Additional time may be required for:

- IdP configuration (performed outside Snowflake)
- Coordination with your identity/security team
- Network policy testing and validation

## Key Decisions

Several questions in this task have security implications:

1. **SCIM Provisioner Role**: Determines what the IdP can manage in Snowflake
2. **Administrator Assignments**: ACCOUNTADMIN grants full account control - limit to 2-3 trusted individuals
3. **Break-Glass Credentials**: Must be securely stored and access documented
4. **Network Policies**: Overly restrictive policies can lock out legitimate users
5. **Authentication Policies**: Balance security with usability

Involve your security team when making these decisions.

## Deliverables

Upon completion, you will have:

- User provisioning configured (SCIM integration or manual management approach documented)
- Initial administrators provisioned with appropriate roles
- SAML/SSO configured for federated authentication (if using an IdP)
- Break-glass emergency access account created and documented
- Network policies configured for IP allowlisting
- Authentication policies defined for different user types
- MFA enrollment guidance distributed to administrators

## Security Best Practices

This task implements several security best practices:

| Practice | Implementation |
|----------|----------------|
| **Least Privilege** | Separate admin roles (ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, USERADMIN) |
| **Centralized Identity** | SCIM + SAML for single source of truth (or documented manual process) |
| **Emergency Access** | Break-glass account with restricted network policy |
| **Defense in Depth** | Layered authentication + network + MFA policies |
| **Audit Trail** | All authentication attempts logged |

## More Information

- [SCIM Provisioning](https://docs.snowflake.com/en/user-guide/scim)
- [SAML/SSO Configuration](https://docs.snowflake.com/en/user-guide/admin-security-fed-auth)
- [Network Policies](https://docs.snowflake.com/en/user-guide/network-policies)
- [Authentication Policies](https://docs.snowflake.com/en/user-guide/authentication-policies)
- [Multi-Factor Authentication](https://docs.snowflake.com/en/user-guide/ui-mfa)

</details>

---


## Step 2.1: Select Identity Management Approach

## Identity Management Approach

### Your Selections

| Setting | Value |
|---------|-------|
| **User Provisioning** | Okta |
| **SAML/SSO** | Yes - Configure SAML now |

### SCIM Integration Selected: Okta

You have chosen automated user provisioning via SCIM. This means:
- Users will be automatically created when added to your IdP
- Users will be automatically disabled when removed from your IdP
- Centralized identity management from your IdP

**What's next:**
- The Configure SCIM Integration step will guide you through setting up the SCIM connection
- The Provision Account Administrators step will help you assign admin roles to SCIM-provisioned users

### SAML/SSO Configuration

You will configure SAML/SSO in a dedicated step. This enables:
- Users can log in using their IdP credentials (single sign-on)
- Centralized authentication control from your IdP
- Seamless user experience without separate Snowflake passwords

---


## Step 2.2: Configure SCIM Integration

## SCIM Integration Configuration

### Configuration Summary

| Setting | Value |
|---------|-------|
| **Identity Provider** | Okta |
| **Integration Name** | `OKTA_SCIM_INTEGRATION` |
| **Provisioner Role** | `OKTA_PROVISIONER` |

### SCIM Network Policy

No SCIM network policy will be created. The SCIM bearer token provides sufficient authentication. For Okta, this is the recommended approach — their outbound IP addresses change over time, making static IP lists difficult to maintain reliably.

### SCIM Endpoint URL

Configure your IdP with this endpoint URL:

`https://fintechcorp-fintechcorp.snowflakecomputing.com/scim/v2/`

### What Happens After Running the SQL

1. A SCIM provisioner role (`OKTA_PROVISIONER`) will be created
2. A network policy for SCIM access will be created
3. The SCIM security integration will be created
4. A SCIM token will be generated - **copy this to your IdP configuration**

### Security Considerations

- The SCIM token is sensitive - store it securely in your IdP
- The network policy restricts SCIM access to only your IdP's IP addresses
- Users provisioned via SCIM will have `LOGIN_NAME` set to their IdP username
- Deprovisioning in the IdP will disable (not delete) users in Snowflake

### IdP Configuration Steps
**In Okta:**
1. Add the Snowflake application from the Okta Application Catalog
2. Configure SCIM provisioning in the app settings
3. Enter the SCIM endpoint URL and token from the SQL output
4. Enable provisioning features (Create, Update, Deactivate)
5. Assign users/groups to the Snowflake application

See: [SCIM with Okta](https://docs.snowflake.com/en/user-guide/scim-okta)

---


## Step 2.3: Provision Account Administrators

# Provision Account Administrators

## Overview

This section documents the administrator role assignments for your Snowflake account. These users are provisioned through SCIM from your Identity Provider.

## Administrator Assignments

| Login Name | Role |
|------------|------|
| `alex@fintechcorp.com` | ACCOUNTADMIN |

## Role Summary

| Role | Users |
|------|-------|
| ACCOUNTADMIN | `alex@fintechcorp.com` |
| SECURITYADMIN |  |
| SYSADMIN |  |
| USERADMIN |  |

## Important Notes

### SCIM Provisioning Flow

1. Users must first be provisioned through SCIM from your Identity Provider
2. SCIM creates the user accounts in Snowflake
3. The SQL commands below grant roles to the provisioned users
4. Run the SQL **after** users have been provisioned via SCIM

### Best Practices Applied

- **Minimum of 2 ACCOUNTADMIN users**: Prevents lockout scenarios
- **Role separation**: Different roles for different responsibilities
- **Named accounts**: Individual accountability through named users
- **SCIM integration**: Automated provisioning and deprovisioning

---


## Step 2.4: Create Organization Account Administrators

# Create Account Administrators

## Overview

This section documents the administrators being created for your Snowflake account. Since SCIM is not configured, users are being created directly in Snowflake.

## Administrators to be Created

| Username | Email | Name | Role |
|----------|-------|------|------|

## Role Summary

| Role | Users |
|------|-------|
| ACCOUNTADMIN |  |
| SECURITYADMIN |  |
| SYSADMIN |  |
| USERADMIN |  |

## Important Notes

### Manual User Management

Since you've chosen manual user management:
- Users must be created and maintained directly in Snowflake
- User deprovisioning must be done manually when employees leave
- Consider implementing a regular access review process
- Password resets must be handled through Snowflake

### Initial Password Security

- All users are created with a temporary password
- Users **must change their password** on first login
- The initial password should be communicated securely to each user
- Consider using a secure password sharing tool or in-person communication

### Best Practices Applied

- **Minimum of 2 ACCOUNTADMIN users**: Prevents lockout scenarios
- **Named accounts**: Individual accountability through named users
- **Password change required**: Enforces secure initial access
- **Role separation**: Different roles for different responsibilities

---


## Step 2.5: Configure SAML/SSO

# Configure SAML/SSO

## Overview

This section documents the SAML Single Sign-On configuration for federated authentication between your Identity Provider and Snowflake.

## Configuration Summary

| Setting | Value |
|---------|-------|
| **Integration Name** | `OKTA_SSO` |
| **Identity Provider** | Okta |
| **SSO URL** | `https://fintechcorp.okta.com/app/REPLACE_WITH_OKTA_APP_ID/sso/saml` |
| **Issuer/Entity ID** | `http://www.okta.com/REPLACE_WITH_OKTA_ENTITY_ID` |
| **Login Page Button** | Yes |

## SAML Authentication Flow

1. User navigates to Snowflake login page
2. User clicks "Log in using SSO" (or is redirected automatically)
3. User is redirected to Okta for authentication
4. After successful authentication, IdP sends SAML assertion to Snowflake
5. Snowflake validates the assertion and creates a session

## IdP Configuration Requirements

Configure your Identity Provider with the following Snowflake details:

| Setting | Value |
|---------|-------|
| **ACS URL** | `https://fintechcorp-fintechcorp.snowflakecomputing.com/fed/login` |
| **Entity ID** | `https://fintechcorp-fintechcorp.snowflakecomputing.com` |
| **Name ID Format** | `urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress` |
| **Name ID Value** | User's email address |

## Attribute Mapping

The following SAML attributes should be mapped in your IdP:

| SAML Attribute | Source |
|----------------|--------|
| `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress` | User email |
| `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname` | First name |
| `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname` | Last name |

## Security Considerations

- SAML assertions are signed by your IdP and verified by Snowflake
- Users are matched by email address (must match SCIM-provisioned users)
- Session duration is controlled by Snowflake session policies
- MFA should be enforced at the IdP level for enhanced security

---


## Step 2.6: Create Break-Glass Emergency Access

# Create Break-Glass Emergency Access

## Overview

This section documents the break-glass emergency access configuration for your Snowflake account. These accounts provide a way to access Snowflake when SSO/SAML is unavailable.

## Break-Glass Accounts

| Username | Email | Network Restricted |
|----------|-------|--------------------|
| `BREAKGLASS_ADMIN` | alex@fintechcorp.com | Yes |

## Account Details

### BREAKGLASS_ADMIN

| Setting | Value |
|---------|-------|
| **Username** | `BREAKGLASS_ADMIN` |
| **Email** | `alex@fintechcorp.com` |
| **Authentication** | Password + OTP (one-time passcode) |
| **MFA Method** | Pre-generated OTPs (stored securely) |
| **Client Restriction** | Web UI only |
| **Allowed IPs** | `10.0.0.0/8` |

## One-Time Passcode (OTP) Workflow

Snowflake supports pre-generated one-time passcodes (OTPs) specifically designed for break-glass scenarios. These OTPs:
- Are generated in advance and stored securely
- Serve as the MFA second factor (after password)
- Are single-use — each OTP is invalidated after authentication
- Do not require an authenticator app or device at login time

### ⚠️ IMPORTANT: Capturing OTPs

When you run the SQL in this step, the `ALTER USER ... ADD MFA METHOD OTP` command will output the generated OTPs. **You must capture these immediately** — they cannot be retrieved later!

**Before running the SQL:**
1. Have your password vault or secure storage ready
2. Be prepared to copy the OTP output for each break-glass user
3. Run the SQL in sections, not all at once, so you can capture each user's OTPs

### OTP Storage Requirements

Store the following for each break-glass account:
- Username
- Password (after changing from initial password)  
- All generated OTPs (10 per user)
- Account URL: `https://fintechcorp-fintechcorp.snowflakecomputing.com`

### OTP Regeneration

OTPs should be regenerated:
- After any OTP is used (even for testing)
- Periodically (quarterly recommended)
- If there's any suspicion of compromise

To regenerate OTPs (invalidates all previous OTPs):
```sql
ALTER USER <username> ADD MFA METHOD OTP COUNT = 10;
```

## Emergency Access Procedure

### When to Use

- Identity Provider is down or unreachable
- SSO certificate has expired
- SAML configuration is broken
- You need to fix SSO/SAML issues

### How to Use

1. Retrieve the password AND next unused OTP from secure storage
2. Navigate directly to: `https://fintechcorp-fintechcorp.snowflakecomputing.com`
3. Select "Sign in using Snowflake" (not SSO)
4. Enter the break-glass username and password
5. When prompted for MFA, enter the OTP
6. Fix the issue that required break-glass access
7. Log out immediately after
8. Mark the OTP as used (it's now invalidated)
9. Document the incident
10. Consider regenerating OTPs if supply is low

## Security Considerations

- **MFA Required**: Break-glass accounts require password + OTP for security
- **Pre-generated OTPs**: No authenticator app needed at login time
- **Auditing**: All break-glass logins are logged and should be reviewed
- **Limited Scope**: Only use for emergency recovery, not routine operations
- **Testing**: Test the break-glass procedure periodically (quarterly recommended)
  - Note: Any OTP used for testing is invalidated

---


## Step 2.7: Configure Network Rules and Policies

# Configure Network Rules and Policies

## Overview

This section documents the network access controls for your Snowflake account. These policies restrict which IP addresses can connect to Snowflake.

## Network Policy Configuration

| Setting | Value |
|---------|-------|
| **Rules Location** | `INFRA.GOVERNANCE` |
| **Account-Level Policy** | Yes - Apply to all users by default |
| **Allowed Network Rules** | 1 rule(s) configured |

## Allowed Network Rules

The following network rules define which IP addresses can access Snowflake:

| Rule Name | CIDR Blocks |
|-----------|-------------|
| `CORPORATE_NETWORK` | `10.0.0.0/8` |

## Policy Application
**Account-Level Enforcement**: The network policy will be applied to all users in the account. Users connecting from IPs not in the allow list will be blocked.

**Exceptions:**
- Break-glass accounts have their own network policy
- SCIM integration has its own network policy

## Security Considerations

- Network policies are evaluated at connection time
- IP changes during a session don't terminate the session
- VPN users should always connect through corporate VPN
- Cloud services may need static IPs or VPN connectivity
- Regularly review and update allowed IP lists

---


## Step 2.8: Configure Authentication Policies

# Configure Authentication Policies

## Overview

This section documents the authentication policies for your Snowflake account. These policies define how different types of users must authenticate.

## Authentication Policy Summary

| User Type | Policy Name | Authentication Methods | MFA |
|-----------|-------------|------------------------|-----|
| Human Users | `human_user_auth_policy` | SAML (SSO), Password with MFA | TOTP (Authenticator Apps), Passkey (FIDO2/WebAuthn) |
| Service Accounts | `service_account_auth_policy` | OAuth, Key Pair | Not Required |
| Break-Glass | `breakglass_auth_policy` | Password Only | Disabled |

## Policy Details

### Human User Authentication Policy

| Setting | Value |
|---------|-------|
| **Policy Name** | `human_user_auth_policy` |
| **Authentication Methods** | SAML (SSO), Password with MFA |
| **MFA Methods** | TOTP (Authenticator Apps), Passkey (FIDO2/WebAuthn) |
| **Client Types** | All (UI, Drivers, SnowSQL) |
| **Account-Level** | Yes - Apply default policy to all users |
Users can authenticate via SSO or with password + MFA. SSO is recommended for security.

### Service Account Authentication Policy

| Setting | Value |
|---------|-------|
| **Policy Name** | `service_account_auth_policy` |
| **Authentication Methods** | OAuth, Key Pair |
| **MFA Methods** | None (not applicable for services) |
| **Client Types** | Drivers only (no UI access) |
| **Password** | Disabled |

Service accounts cannot use password authentication or access the web UI. This prevents misuse of service credentials.

### Break-Glass Authentication Policy

| Setting | Value |
|---------|-------|
| **Policy Name** | `breakglass_auth_policy` |
| **Authentication Methods** | Password Only |
| **MFA Methods** | None (uses OTP workflow) |
| **Client Types** | UI Only |
| **Purpose** | Emergency access when SSO is down |

The break-glass account has a special policy that allows password-only authentication for emergency scenarios.

## Policy Application
The human user authentication policy will be applied at the account level:
- All users must comply with the policy by default
- Break-glass accounts have an explicit override
- Service accounts should have the service policy explicitly assigned

## Security Best Practices Applied

- **No password for service accounts**: Prevents credential theft and simplifies rotation
- **MFA required for password auth**: Adds second factor for human users
- **Break-glass is exception-based**: Special policy only for emergency access
- **Principle of least privilege**: Each user type gets appropriate authentication methods

---


## Step 2.9: Enable Multi-Factor Authentication

# Enable Multi-Factor Authentication

## Overview

This section provides guidance for enabling and enforcing Multi-Factor Authentication (MFA) for users in your Snowflake account.

## MFA Configuration Summary

| Setting | Value |
|---------|-------|
| **Enforcement Timeline** | Immediately - Require MFA now |
| **Preferred Method** | Passkey (Security Keys/Biometrics) |
| **Support Contact** | alex@fintechcorp.com |

## User Communication Template

Use the following template to communicate MFA requirements to your users:

---

**Subject: Action Required: Enable MFA for Snowflake Access**

Dear Snowflake User,

As part of our security enhancements, Multi-Factor Authentication (MFA) is now required for accessing Snowflake.

**Timeline:** Immediately - Require MFA now

**What You Need to Do:**
1. Ensure you have a FIDO2-compatible device:
   - Hardware security key (YubiKey, Titan)
   - Laptop with fingerprint reader
   - Phone with biometric capability

2. Log into Snowflake: `https://fintechcorp-fintechcorp.snowflakecomputing.com`

3. Go to your profile (click your name in the bottom left)

4. Select "Security" → "Multi-factor Authentication"

5. Click "Enroll" and select "Passkey"

6. Follow the prompts to register your device

**Need Help?**
Contact: alex@fintechcorp.com

Thank you for helping keep our data secure!

---

## MFA Enrollment Status

After users have been given time to enroll, verify MFA status with the following query:

```sql
-- Check MFA enrollment status for admin users
SELECT 
  name,
  login_name,
  email,
  has_mfa,
  CASE 
    WHEN has_mfa = TRUE THEN 'Enrolled'
    ELSE 'Not Enrolled'
  END as mfa_status
FROM snowflake.account_usage.users
WHERE deleted_on IS NULL
  AND name IN (
    'alex@fintechcorp.com'
  )
ORDER BY has_mfa, name;
```

## Users Requiring MFA Enrollment

Based on your configuration, the following administrative users should enroll in MFA:

| User | Role | MFA Required By |
|------|------|-----------------|
| `alex@fintechcorp.com` | ACCOUNTADMIN | Immediately - Require MFA now |

## Task Summary: Security & Identity Configuration

This completes the **Security & Identity Configuration** task of the Platform Foundation Setup workflow. The following has been configured:

| Step | Configuration | Status |
|------|---------------|--------|
| 2.1 | SCIM Integration | Okta |
| 2.2 | Account Administrators | 1 admin users provisioned |
| 2.3 | SAML/SSO | `OKTA_SSO` |
| 2.4 | Break-Glass Access | 1 break-glass account(s) |
| 2.5 | Network Policies | Yes - Apply to all users by default |
| 2.6 | Authentication Policies | SAML (SSO), Password with MFA |
| 2.7 | MFA Enforcement | Immediately - Require MFA now |

## Next Steps

1. Send the MFA communication to all administrative users
2. Monitor MFA enrollment using the verification query
3. Follow up with users who haven't enrolled before the deadline
4. Test SSO and MFA login flows
5. Validate break-glass access still works
6. Proceed to the Cost Management task

---


# Task 3: Platform Cost Management

**Summary:** Set up Snowflake's native budget feature for automated spending alerts, configure account-level resource monitors with hard limits, extend the tagging framework with cost center and ownership tracking, and create cost reporting views.

**Prerequisites:**
- **Personas:** FinOps Team, Finance Team, Platform Administrator
- **Role Requirements:** ACCOUNTADMIN role access
- **External Requirements:** Task 1 (Platform Foundation) completed, Task 2 (Security & Identity Configuration) completed, Estimated monthly credit budget from finance team, List of cost centers for chargeback (if applicable)

<details>
<summary>Task Overview (click to expand)</summary>

# Platform Cost Management

## Summary
Set up Snowflake's native budget feature for automated spending alerts,
configure account-level resource monitors with hard limits, extend the tagging
framework with cost center and ownership tracking, and create cost reporting views.

## External Requirements
- Task 1 (Platform Foundation) completed
- Task 2 (Security & Identity Configuration) completed
- Estimated monthly credit budget from finance team
- List of cost centers for chargeback (if applicable)

## Personas
- FinOps Team
- Finance Team
- Platform Administrator

## Role Requirements
- ACCOUNTADMIN role access

## Details
This task builds on the infrastructure created in Task 1 (Account Strategy & Nomenclature) and should be executed after Task 2 (Security & Identity Configuration).

**Account Context:** All steps in this task should be executed in your Organization Account (if created in the Create Organization Account step) or your primary account.

## Steps in This Task

| Step | Title | Purpose |
|------|-------|---------|
| 3.1 | Enable Spending Budgets | Decide whether to use Snowflake's native budget feature |
| 3.2 | Configure Spending Budgets | Set monthly limits and notification preferences |
| 3.3 | Enable Resource Monitors | Decide whether to implement account-level resource monitors |
| 3.4 | Configure Resource Monitors | Set credit limits and suspension actions |
| 3.5 | Enable Cost Allocation Tags | Decide whether to add cost-focused tags |
| 3.6 | Configure Cost Allocation Tags | Create additional tags and cost reporting views |

**Note on conditional steps:**
- Configure Spending Budgets is shown only if you enable budgets in Enable Spending Budgets
- Configure Resource Monitors is shown only if you enable resource monitors in Enable Resource Monitors
- Configure Cost Allocation Tags is shown only if you enable additional cost tags in Enable Cost Allocation Tags

## Time Estimate

- **Quick Path** (budgets only): 15-20 minutes
- **Standard Path** (budgets + resource monitors): 25-35 minutes
- **Full Path** (all features): 35-45 minutes

## Key Decisions

### 1. Spending Budgets
**Decision:** Whether to enable Snowflake's native budget feature
**Stakeholders:** FinOps team, Finance, Platform team
**Recommendation:** Enable budgets for all environments. They provide valuable early warning of spending trends with no risk of disruption.

### 2. Resource Monitors
**Decision:** Whether to implement hard credit limits that suspend warehouses
**Stakeholders:** Platform team, Finance, Business stakeholders
**Recommendation:** Enable for production environments to prevent unexpected cost overruns. Consider the impact on users if warehouses are suspended.

### 3. Cost Allocation Tags
**Decision:** Which additional tags to implement beyond the core tags from Task 1
**Stakeholders:** FinOps team, Finance, Department leads
**Recommendation:** At minimum, add `cost_center` and `owner` tags for chargeback and accountability.

## Budgets vs Resource Monitors

Understanding the difference is critical:

| Feature | Budgets | Resource Monitors |
|---------|---------|-------------------|
| **Purpose** | Alerting & awareness | Active cost control |
| **Action** | Send notifications | Can suspend warehouses |
| **Limit Type** | Soft (can exceed) | Hard (enforced) |
| **Forecasting** | Time-series prediction | Simple threshold |
| **User Impact** | None | May interrupt work |
| **Best For** | Planning & monitoring | Cost protection |

**Recommendation:** Use both! Budgets for early warning, resource monitors as a safety net.

## Cost Allocation Strategy

This task extends the tagging framework established in Task 1:

**Core Tags (from Task 1):**
- `domain` - Business unit (e.g., Finance, Marketing)
- `environment` - SDLC stage (e.g., Dev, Prod)
- `dataproduct` - Data product identifier
- `workload` - Workload type (Ingest, Transform, BI, etc.)
- `zone` - Data zone (Raw, Curated, Consumption, etc.)

**Additional Tags (this task):**
- `cost_center` - Accounting cost center code
- `owner` - Team or individual responsible
- `project` - Specific project or initiative
- `application` - Application or system name

## Deliverables

Upon completing this task, you will have:

1. **If budgets enabled:**
   - Account-level spending budget configured
   - Notification recipients set up
   - Budget refresh interval configured

2. **If resource monitors enabled:**
   - Account-level resource monitor protecting all warehouses
   - Credit limit with notification thresholds
   - Suspension action configured

3. **If cost tags enabled:**
   - Additional tags in governance schema
   - Cost reporting views created
   - Infrastructure database tagged

4. **Documentation:**
   - Configuration summary in dynamic content
   - SQL code for all configurations
   - Cost reporting queries

## What's Next

After completing Cost Management, you've finished the **Platform Foundation Setup** workflow. Your Snowflake environment now has:

- ✅ Account strategy and nomenclature defined
- ✅ Security and identity configured
- ✅ Cost management in place

**Next Workflow:** Proceed to **Data Product Configuration** to set up individual data products with:
- Databases and schemas
- Warehouses sized for workloads
- Warehouse-level resource monitors
- Functional and access roles
- Tag application to resources

## More Information

* [Monitor credit usage with budgets](https://docs.snowflake.com/en/user-guide/budgets)
* [Working with Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors)
* [Attributing Costs using Tags](https://docs.snowflake.com/en/user-guide/cost-attributing)
* [Cost Management Best Practices](https://docs.snowflake.com/en/user-guide/cost-understanding)

</details>

---


## Step 3.1: Enable Spending Budgets


## Snowflake Native Budgets Enabled

You've chosen to use Snowflake's native budget feature for cost control and monitoring.

### Snowflake Budget Features

Snowflake's built-in budget functionality provides:

1. **Account Budget**: Monitor spending for all credit usage in your account
2. **Custom Budgets**: Create budgets for specific groups of objects (future capability)
3. **Time-Series Forecasting**: Daily alerts when spending is projected to exceed limits
4. **Multiple Notification Methods**: Email, webhooks, or cloud service queues
5. **Monthly Spending Limits**: Expressed in Snowflake credits

### Budget vs Resource Monitors

| Feature | Budgets (this step) | Resource Monitors (Enable Resource Monitors step) |
|---------|---------------------|------------------------------|
| **Purpose** | Alerting & awareness | Active cost control |
| **Action** | Send notifications | Can suspend warehouses |
| **Flexibility** | Can exceed budget | Hard limit enforced |
| **Forecasting** | Time-series prediction | Simple threshold |
| **Best For** | Planning & monitoring | Cost protection |

---


## Step 3.2: Configure Spending Budgets

## Snowflake Budget Configuration

You're configuring Snowflake's native account budget for automated spending monitoring and alerts.

### Budget Details

| Setting | Value |
|---------|-------|
| **Monthly Spending Limit** | 3000 credits |
| **Notification Threshold** | 75% (alerts when projected spending > 2250 credits) |
| **Notification Method** | Email |
| **Alert Recipients** | `alex@fintechcorp.com` |
| **Refresh Interval** | 1 hour (frequent monitoring) |

### How Snowflake Budgets Work

1. **Monthly Time Interval**: Budget resets at 12:00 AM UTC on the 1st of each month
2. **Time-Series Forecasting**: Snowflake analyzes spending patterns to predict end-of-month consumption
3. **Threshold-Based Alerts**: You'll receive email notifications when projected spending exceeds 75% of your 3000 credit limit
4. **Informational Only**: Budgets send alerts but don't stop services (use Resource Monitors for that)

### Email Notification Recipients

Budget alerts will be sent to:
- `alex@fintechcorp.com`

### What Happens When Budget Threshold is Exceeded?

**Important:** Snowflake budgets are **informational only**.

| What Happens | What Does NOT Happen |
|--------------|----------------------|
| ✅ Email notifications sent | ❌ Services NOT suspended |
| ✅ Spending data tracked | ❌ Warehouses continue running |

**For Hard Limits:** Configure Resource Monitors in the Configure Resource Monitors step.

---

### Upgrading to Webhook Notifications (Optional)

If you later want to receive budget alerts in Slack, Microsoft Teams, or PagerDuty instead of email, you can modify your budget configuration:

**Step 1: Create a Notification Integration**

```sql
-- For Slack
CREATE OR REPLACE NOTIFICATION INTEGRATION budget_slack_integration
  TYPE = WEBHOOK
  ENABLED = TRUE
  WEBHOOK_URL = '<YOUR_SLACK_WEBHOOK_URL>'
  WEBHOOK_BODY_TEMPLATE = '{"text": "Snowflake Budget Alert: <SNOWFLAKE_WEBHOOK_MESSAGE>"}'
  COMMENT = 'Slack webhook for budget notifications';

-- For Microsoft Teams
CREATE OR REPLACE NOTIFICATION INTEGRATION budget_teams_integration
  TYPE = WEBHOOK
  ENABLED = TRUE
  WEBHOOK_URL = '<YOUR_TEAMS_WEBHOOK_URL>'
  WEBHOOK_BODY_TEMPLATE = '{"text": "Snowflake Budget Alert: <SNOWFLAKE_WEBHOOK_MESSAGE>"}'
  COMMENT = 'Teams webhook for budget notifications';
```

**Step 2: Link Integration to Budget**

```sql
-- Add the notification integration to your budget
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!ADD_NOTIFICATION_INTEGRATION('budget_slack_integration');
```

**How to get webhook URLs:**

| Platform | Steps |
|----------|-------|
| **Slack** | Workspace Settings → Apps → Incoming Webhooks → Create new webhook |
| **Teams** | Channel → ⋯ → Connectors → Incoming Webhook → Configure |
| **PagerDuty** | Services → Integrations → Events API v2 |

**More Information:**
- [Notifications for budgets](https://docs.snowflake.com/en/user-guide/budgets/notifications)
- [CREATE NOTIFICATION INTEGRATION](https://docs.snowflake.com/en/sql-reference/sql/create-notification-integration)

---


## Step 3.3: Enable Resource Monitors


## Account Resource Monitor Enabled

You've chosen to configure an account-level resource monitor for active cost protection.

### What is an Account Resource Monitor?

An **account-level resource monitor** protects your entire Snowflake account by:

- Tracking **all credit consumption** across the account
- Sending **notifications** at warning thresholds
- **Suspending all warehouses** when the limit is reached
- Providing **real-time protection** against runaway costs

### How Budgets and Resource Monitors Work Together

These tools are **complementary**, not alternatives:

| Feature | Budgets | Resource Monitors |
|---------|---------|-------------------|
| **Alerting Type** | Predictive (forecasting) | Actual (real-time) |
| **Available Actions** | Notify only | Notify, Suspend, Suspend Immediate |
| **Threshold Support** | Single threshold | Multiple thresholds (tiered) |
| **Best For** | Early warning | Hard limits |

**Recommended Combined Strategy:**

| Tool | Threshold | Action | Purpose |
|------|-----------|--------|---------|
| **Budget** | 75% | Notify | Early warning based on forecast |
| **Resource Monitor** | 75% | Notify | Real-time warning |
| **Resource Monitor** | 90% | Notify | Final warning |
| **Resource Monitor** | 100% | Suspend | Stop spending |

This tiered approach gives you:
1. **Early awareness** from budget forecasting
2. **Multiple warning points** as you approach limits
3. **Hard stop** to prevent overspending

### Trigger Actions Explained

| Action | What Happens | When to Use |
|--------|--------------|-------------|
| **NOTIFY** | Sends email to ACCOUNTADMIN users | Warning thresholds (75%, 90%) |
| **SUSPEND** | Blocks new queries, lets running queries finish, then suspends | Default for 100% threshold |
| **SUSPEND_IMMEDIATE** | Terminates all queries immediately | Only if immediate stop is critical |

---


## Step 3.4: Configure Resource Monitors

## Account Resource Monitor Configuration

### Configuration Summary

| Setting | Value |
|---------|-------|
| **Monitor Name** | `account_resource_monitor` |
| **Credit Limit** | 3000 credits |
| **Action at Limit** | Suspend After Current Queries |
| **Reset Frequency** | Monthly |
| **Scope** | Account-wide (all warehouses) |

### How the Monitor Works

**Suspend After Current Queries Selected**

When the credit limit is reached, warehouses will be **suspended after current queries complete**.

| Impact | Description |
|--------|-------------|
| Running queries | ✅ Complete normally |
| New queries | ❌ Blocked |
| Warehouses | ❌ Suspended after current work |

### Alert Thresholds (Tiered Protection)

| Credit Level | Percentage | Action | Purpose |
|--------------|------------|--------|---------|
| 2250 credits | 75% | Notify | Early warning |
| 2700 credits | 90% | Notify | Final warning |
| 3000 credits | 100% | Suspend After Current Queries | Limit enforcement |

### How Budgets + Resource Monitors Work Together

| Tool | Alert Type | When It Fires | Action |
|------|------------|---------------|--------|
| **Budget** | Predictive | When *projected* to exceed threshold | Notify only |
| **Resource Monitor** | Actual | When *actually* reaching threshold | Notify or Suspend |

**Example Timeline:**
1. Day 10: Budget forecasts you'll hit 75% → Alert sent (early warning based on trend)
2. Day 18: Resource monitor hits 75% actual usage → Alert sent (real-time confirmation)
3. Day 24: Resource monitor hits 90% → Alert sent (final warning)
4. Day 28: Resource monitor hits 100% → Suspend After Current Queries

### Emergency Procedures

If the resource monitor suspends warehouses unexpectedly:

1. **Assess Situation**: Determine why limit was reached
2. **Increase Limit**: `ALTER RESOURCE MONITOR account_resource_monitor SET CREDIT_QUOTA = <new_limit>;`
3. **Resume Warehouses**: Manually resume suspended warehouses
4. **Investigate**: Identify cause of high usage

---


## Step 3.5: Enable Cost Allocation Tags


## Additional Cost Allocation Tags: Enabled

You've chosen to extend your tagging framework. In the **next step**, you'll select which additional tags to create.

### Existing Tags (from Task 1)

These tags were created in `INFRA.GOVERNANCE`:

| Tag | Purpose |
|-----|---------|
| `domain` | Business unit |
| `environment` | SDLC stage |
| `dataproduct` | Data product ID |
| `workload` | Workload type |
| `zone` | Data zone |
| `data_classification` | Data sensitivity level |

### Available Additional Tags (configured in next step)

In the next step, you'll choose from:

| Tag | Purpose | Options |
|-----|---------|---------|
| `owner` | Responsible party | All options |
| `cost_center` | Accounting code | Essential, All |
| `project` | Initiative name | All only |
| `application` | System name | All only |

**Next Step:** Configure Cost Allocation Tags — select which additional tags to create.

---


## Step 3.6: Configure Cost Allocation Tags

## Cost Allocation Tags Configuration

### Configuration Summary

**Additional Tags:** Cost Center, Owner, Project
**Enforcement:** Yes (all resources)

### Complete Tag Framework

After this step, you'll have the following tags:

**Core Tags (from Task 1):**

| Tag | Purpose |
|-----|---------|
| `domain` | Business unit |
| `environment` | SDLC stage |
| `dataproduct` | Data product ID |
| `workload` | Workload type |
| `zone` | Data zone |
| `data_classification` | Data sensitivity level |

**Additional Tags (this step):**

| Tag | Purpose |
|-----|---------|
| `cost_center` | Accounting code |
| `owner` | Responsible party |
| `project` | Initiative name |

### Applying Tags to Resources

After creating tags, apply them to resources:

```sql
ALTER WAREHOUSE my_warehouse SET TAG 
  domain = 'FINANCE',
  environment = 'PROD',
  owner = 'Data Team';
```

## **Task 3 Summary: Cost Management**

| Step | Configuration | Status |
| :---- | :---- | :---- |
| 3.1 | Spending Budgets | Enabled |
| |  |  |
| 3.2 | Budget Amount | 3000 credits/month |
| |  |  |
| 3.3 | Resource Monitors | Enabled |
| |  |  |
| 3.4 | Monitor Limit | 3000 credits |
| |  |  |
| 3.5 | Cost Allocation Tags | Extended |
| 3.6 | Additional Tags | Cost Center, Owner, Project |

---


# Task 4: Platform Observability

**Summary:** Configure account-level telemetry parameters to enable logging, metrics, and tracing for stored procedures, UDFs, and handler code in the Organization Account.

**Prerequisites:**
- **Personas:** Platform Administrator, SRE / Observability Team
- **Role Requirements:** ACCOUNTADMIN role access
- **External Requirements:** Task 1 (Platform Foundation) completed, Task 2 (Security & Identity Configuration) completed

<details>
<summary>Task Overview (click to expand)</summary>

# Platform Observability

## Summary
Configure account-level telemetry parameters to enable logging, metrics,
and tracing for stored procedures, UDFs, and handler code in the
Organization Account.

## External Requirements
- Task 1 (Platform Foundation) completed
- Task 2 (Security & Identity Configuration) completed

## Personas
- Platform Administrator
- SRE / Observability Team

## Role Requirements
- ACCOUNTADMIN role access

## Details
This task configures observability for your Organization Account by setting
the event table and account-level telemetry parameters. The `EVENT_TABLE`
parameter has no default value, so this task explicitly sets it to
`SNOWFLAKE.TELEMETRY.EVENTS` (which exists in every Snowflake account) to
ensure telemetry data is collected. If all telemetry parameters are set to
their disabled values, the event table is not activated.

**Account Context:** All steps in this task should be executed in your
Organization Account (if created in the Create Organization Account step)
or your primary account.

## Steps in This Task

| Step | Title | Purpose |
|------|-------|---------|
| 4.1 | Configure Telemetry Parameters | Set EVENT_TABLE, LOG_LEVEL, METRIC_LEVEL, TRACE_LEVEL, and SQL_TRACE_QUERY_TEXT |

## Time Estimate

- **Telemetry configuration:** 5-10 minutes

## Key Decisions

| Decision | Who Should Decide | Impact |
|----------|-------------------|--------|
| Log level | Platform/SRE Team | Verbosity vs. storage cost; INFO recommended for production |
| Metric collection | Platform/SRE Team | ALL enables execution metrics; no performance impact |
| Trace level | Platform/SRE Team | ALWAYS captures spans; requires LOG_LEVEL not OFF |
| SQL text capture | Platform/Security Team | Useful for debugging but may expose sensitive SQL |

## Parameter Reference

| Parameter | Recommended (Production) | Recommended (Development) |
|-----------|--------------------------|---------------------------|
| LOG_LEVEL | INFO | DEBUG |
| METRIC_LEVEL | ALL | ALL |
| TRACE_LEVEL | ALWAYS | ALWAYS |
| SQL_TRACE_QUERY_TEXT | OFF | ON |

## Deliverables

Upon completing this task, you will have:
- ✅ Event table set to SNOWFLAKE.TELEMETRY.EVENTS (unless all telemetry is disabled)
- ✅ Account-level logging configured for handler code
- ✅ Execution metrics collection configured
- ✅ Trace spans configured for observability
- ✅ Telemetry parameters verified via SHOW PARAMETERS

## More Information

* [Logging, Tracing, and Metrics](https://docs.snowflake.com/en/developer-guide/logging-tracing/logging-tracing-overview) — Overview of Snowflake observability
* [LOG_LEVEL Parameter](https://docs.snowflake.com/en/sql-reference/parameters#log-level) — Log level configuration
* [METRIC_LEVEL Parameter](https://docs.snowflake.com/en/sql-reference/parameters#label-metric-level) — Metric collection
* [TRACE_LEVEL Parameter](https://docs.snowflake.com/en/sql-reference/parameters#trace-level) — Trace span capture
* [Event Table](https://docs.snowflake.com/en/developer-guide/logging-tracing/event-table-setting-up) — Event table setup

</details>

---


## Step 4.1: Configure Telemetry Parameters



## Telemetry Configuration Summary

| Parameter | Value |
|-----------|-------|
| Event Table | `SNOWFLAKE.TELEMETRY.EVENTS` |
| Log Level | `INFO` |
| Metric Level | `ALL` |
| Trace Level | `ON_EVENT` |
| SQL Trace Query Text | `OFF` |

### What Will Be Captured
- **Logs**: Messages at `INFO` severity and above from handler code
- **Metrics**: Execution metrics (CPU, memory, duration) from handler code
- **Traces**: Execution spans with start/end timestamps, status, and query context
- **SQL Text**: SQL statements will not be included in trace data


---
