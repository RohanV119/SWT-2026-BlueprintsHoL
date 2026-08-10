# Account Creation

> Generated: 2026-08-10 14:52:52
> Blueprint: account-creation

---

This workflow guides you through creating a new Snowflake account within your organization. It's a repeatable workflow designed to be run once for each account you need to provision.

Starting from your Organization Account, you'll define the account's purpose based on your multi-account strategy (domain-based, environment-based, or both), configure technical parameters, and execute the account creation. You'll then set up the new account with security controls (network policies, authentication, SCIM/SAML), establish emergency access procedures, and configure cost management (budgets, resource monitors, and cost allocation tags).

By the end of this workflow, you'll have a fully configured Snowflake account that:
- Follows your organization's naming conventions
- Has access to shared governance objects from your Organization Account
- Is secured with appropriate network and authentication policies
- Includes break-glass emergency access procedures
- Has budget monitoring and resource controls in place
- Is properly tagged for cost allocation and chargeback reporting

**Prerequisites**: This workflow assumes you have an existing Snowflake Organization Account. While designed to work with the Platform Foundation workflow, it can also run independently if you provide the required configuration values.

---

## Table of Contents

- [Task 1: Account Provisioning](#task-1-account-provisioning)
  - [Step 1.1: Confirm Account Strategy](#step-11-confirm-account-strategy)
  - [Step 1.2: Define Account Purpose - Domain](#step-12-define-account-purpose-domain)
  - [Step 1.3: Define Account Purpose - Environment](#step-13-define-account-purpose-environment)
  - [Step 1.4: Define Account Purpose - Domain + Environment](#step-14-define-account-purpose-domain-environment)
  - [Step 1.5: Configure Account Parameters](#step-15-configure-account-parameters)
  - [Step 1.6: Create Account](#step-16-create-account)
  - [Step 1.7: Create Infrastructure Database Replica](#step-17-create-infrastructure-database-replica)
- [Task 2: Account Security & Identity](#task-2-account-security-identity)
  - [Step 2.1: Select Security Configuration Approach](#step-21-select-security-configuration-approach)
  - [Step 2.2: Configure Account SCIM Integration](#step-22-configure-account-scim-integration)
  - [Step 2.3: Create Account Administrators](#step-23-create-account-administrators)
  - [Step 2.4: Configure Account SAML/SSO](#step-24-configure-account-samlsso)
  - [Step 2.5: Create Account Break-Glass Emergency Access](#step-25-create-account-break-glass-emergency-access)
  - [Step 2.6: Configure Account Custom Network Rules](#step-26-configure-account-custom-network-rules)
  - [Step 2.7: Configure Network Rules and Policies](#step-27-configure-network-rules-and-policies)
  - [Step 2.8: Apply Organization Network Configuration](#step-28-apply-organization-network-configuration)
  - [Step 2.9: Configure Account Authentication Policies](#step-29-configure-account-authentication-policies)
  - [Step 2.10: Enable Account Multi-Factor Authentication](#step-210-enable-account-multi-factor-authentication)
- [Task 3: Account Cost Management](#task-3-account-cost-management)
  - [Step 3.1: Configure Account Budget](#step-31-configure-account-budget)
  - [Step 3.2: Configure Account Resource Monitor](#step-32-configure-account-resource-monitor)
  - [Step 3.3: Apply Cost Allocation Tags](#step-33-apply-cost-allocation-tags)
- [Task 4: Account Observability](#task-4-account-observability)
  - [Step 4.1: Configure Telemetry Parameters](#step-41-configure-telemetry-parameters)

---


# Task 1: Account Provisioning

**Summary:** Define the new account's purpose (domain, environment, description), configure account parameters (edition, region, initial administrator), create the account in your Snowflake organization, and establish access to shared infrastructure objects.

**Prerequisites:**
- **Personas:** Platform Administrator, Cloud Team, Security Team
- **Role Requirements:** ORGADMIN role access in the Organization Account
- **External Requirements:** Platform Foundation workflow completed with Multi-Account strategy (recommended), Infrastructure Database Sharing configured (Step 1.8 of Platform Foundation)

<details>
<summary>Task Overview (click to expand)</summary>

# Account Provisioning

## Summary
Define the new account's purpose (domain, environment, description), configure
account parameters (edition, region, initial administrator), create the account
in your Snowflake organization, and establish access to shared infrastructure objects.

## External Requirements
- Platform Foundation workflow completed with Multi-Account strategy (recommended)
- Infrastructure Database Sharing configured (Step 1.8 of Platform Foundation)

## Personas
- Platform Administrator
- Cloud Team
- Security Team

## Role Requirements
- ORGADMIN role access in the Organization Account

## Details
This is a **repeatable workflow** — run it once for each account you need to create.

## Steps in This Task

| Step | Title | Purpose | Conditional |
|------|-------|---------|-------------|
| 1.0 | Confirm Account Strategy | Confirm or set the multi-account strategy (org-level) | Always shown |
| 1.1a | Define Account Purpose (Domain-based) | Select domain, description | Domain-based strategy only |
| 1.1b | Define Account Purpose (Environment-based) | Select environment, description | Environment-based strategy only |
| 1.1c | Define Account Purpose (Domain + Environment) | Select domain, environment, description | Domain + Environment strategy only |
| 1.2 | Configure Account Parameters | Set edition, region, and initial administrator | Always shown |
| 1.3 | Create Account | Execute the account creation from the Organization Account | Always shown |
| 1.4 | Consume Infrastructure Share | Create database from shared governance objects in the new account | Always shown |

**Notes:**
- Step 1.0 captures the account strategy at the organization level. If you completed Platform Foundation or a previous Account Creation run, the value will be pre-populated.
- Only one of the Step 1.1 variants will be displayed based on the account strategy.

**Note on Platform Foundation:**
While this workflow can run independently, it's designed to work with the Platform Foundation workflow. If Platform Foundation was completed, the following values are inherited:
- Organization name and account prefix
- Domain and environment options
- Naming conventions (component order, required components)
- Infrastructure share name
- Account strategy (captured in Step 1.0)

If Platform Foundation was not completed, Step 1.0 will capture the account strategy, and you'll need to provide other values manually.

## Account Execution Context

| Steps | Execute From |
|-------|--------------|
| 1.0 - 1.3 | **Organization Account** (where you create accounts) |
| 1.4 | **New Account** (log into the newly created account) |

**Important:** After Step 1.3, you must log into the newly created account to continue with Step 1.4.

## Time Estimate

- **Define purpose and parameters:** 5-10 minutes
- **Create account:** 2-5 minutes
- **Consume infrastructure share:** 2-5 minutes
- **Total:** 10-20 minutes

## Key Decisions

| Decision | Who Should Decide | Impact |
|----------|-------------------|--------|
| Account Name | Platform/Cloud Team | Permanent identifier; follows naming conventions |
| Domain & Environment | Business/Platform Team | Determines cost allocation and governance |
| Edition | Platform/Finance Team | Feature availability and cost |
| Cloud Region | Platform/Compliance Team | Data residency, latency, disaster recovery |
| Initial Administrator | Security/Platform Team | First person with ACCOUNTADMIN access |

## Deliverables

Upon completing this task, you will have:
- ✅ A new Snowflake account created in your organization
- ✅ Account named according to Platform Foundation conventions
- ✅ Initial administrator with ACCOUNTADMIN role
- ✅ Access to shared governance objects (tags, views) from Organization Account

## More Information

* [CREATE ACCOUNT](https://docs.snowflake.com/en/sql-reference/sql/create-account) — SQL command reference
* [Managing Accounts in an Organization](https://docs.snowflake.com/en/user-guide/organizations-manage-accounts) — Account lifecycle management
* [Introduction to Secure Data Sharing](https://docs.snowflake.com/en/user-guide/data-sharing-intro) — Understanding shared databases
* [Snowflake Editions](https://docs.snowflake.com/en/user-guide/intro-editions) — Feature comparison
* [Supported Cloud Regions](https://docs.snowflake.com/en/user-guide/intro-regions) — Available regions

</details>

---


## Step 1.1: Confirm Account Strategy

## Account Strategy Confirmation

### Your Selection

| Setting | Value |
|---------|-------|
| **Account Strategy** | Single Account |

### Domain + Environment Strategy

Your organization uses a **domain + environment** multi-account approach:

- Each account represents a specific **domain-environment combination**
- This provides maximum isolation between both domains and environments
- You will select both the **domain** and **environment** for this account

**Account Structure Example:**
```
Organization
├── Sales-Dev Account
├── Sales-Test Account
├── Sales-Prod Account
├── Finance-Dev Account
├── Finance-Test Account
├── Finance-Prod Account
└── ...
```

### Organization-Level Setting

This answer has been saved at the organization level. All future runs of the Account Creation workflow will use this same strategy, ensuring consistency across your organization.

---


## Step 1.2: Define Account Purpose - Domain

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `account_domain`
>
> Provide values for the above variables to render this step.

---


## Step 1.3: Define Account Purpose - Environment

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `account_environment`
>
> Provide values for the above variables to render this step.

---


## Step 1.4: Define Account Purpose - Domain + Environment

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `account_domain`
>
> Provide values for the above variables to render this step.

---


## Step 1.5: Configure Account Parameters

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 1.6: Create Account

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 1.7: Create Infrastructure Database Replica

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `infrastructure_replication_group`
>
> Provide values for the above variables to render this step.

---


# Task 2: Account Security & Identity

**Summary:** Configure user provisioning (SCIM or manual), establish administrator access, set up network rules and policies, configure authentication policies, create break-glass emergency access, and enable multi-factor authentication.

**Prerequisites:**
- **Personas:** Security Administrator, Platform Administrator, Network Team
- **Role Requirements:** ACCOUNTADMIN role access, Logged into the new account
- **External Requirements:** Account created and accessible (Task 1 completed), Infrastructure share consumed, Identity Provider selection (Okta, Azure, None), SAML/SSO configuration preference, Network policy IP ranges

<details>
<summary>Task Overview (click to expand)</summary>

# Account Security & Identity

## Summary
Configure user provisioning (SCIM or manual), establish administrator access,
set up network rules and policies, configure authentication policies,
create break-glass emergency access, and enable multi-factor authentication.

## External Requirements
- Account created and accessible (Task 1 completed)
- Infrastructure share consumed
- Identity Provider selection (Okta, Azure, None)
- SAML/SSO configuration preference
- Network policy IP ranges

## Personas
- Security Administrator
- Platform Administrator
- Network Team

## Role Requirements
- ACCOUNTADMIN role access
- Logged into the new account

## Details
## Steps in This Task

| Step | Title | Purpose | Conditional |
|------|-------|---------|-------------|
| 2.1 | Select Security Configuration Approach | Choose to use org configuration or custom | Always shown |
| 2.2 | Configure SCIM Integration | Set up automated user provisioning | If SCIM provider selected |
| 2.3 | Create Account Administrators | Assign admin roles for this account | Always shown |
| 2.4 | Configure SAML/SSO | Enable federated authentication | If SAML selected |
| 2.5 | Create Break-Glass Emergency Access | Establish emergency access | Always shown |
| 2.6 | Apply Organization Network Configuration | Use shared network rules | If using org config |
| 2.6 | Configure Custom Network Rules | Create custom network rules | If using custom config |
| 2.7 | Configure Authentication Policies | Define auth requirements by user type | Always shown |
| 2.8 | Enable Multi-Factor Authentication | Guide MFA enrollment | Always shown |

**Note:** Only one of Step 2.6a or 2.6b will be displayed based on your security configuration approach.

**From Platform Foundation (inherited):**
- Identity Provider selection (Okta, Azure, None)
- SAML/SSO configuration preference
- Network policy IP ranges (can be reused)
- Authentication policy settings

## Account Execution Context

All steps in this task should be executed from the **newly created account**.

| Steps | Execute From |
|-------|--------------|
| 2.1 - 2.8 | **New Account** (the account you just created) |

## Time Estimate

- **Security approach selection:** 2-5 minutes
- **SCIM configuration (if applicable):** 5-10 minutes
- **Administrator setup:** 5-10 minutes
- **Network policies:** 5-10 minutes
- **Authentication policies:** 5-10 minutes
- **Break-glass setup:** 5-10 minutes
- **MFA enablement:** 2-5 minutes
- **Total:** 30-60 minutes

## Key Decisions

| Decision | Who Should Decide | Impact |
|----------|-------------------|--------|
| Use org security config or new | Security/Platform Team | Consistency vs flexibility |
| Account-specific administrators | Security/HR | Who has privileged access to this account |
| Network restrictions | Security/Network Team | Access control scope |
| Authentication requirements | Security Team | User experience vs security |
| Break-glass access | Security Team | Emergency access procedures |

## Configuration Approach

**Option 1: Use Organization Configuration**
- Reuses the same settings established in Platform Foundation
- Ensures consistency across all accounts
- Recommended for most accounts

**Option 2: Configure Custom**
- Allows account-specific security settings
- Useful for accounts with unique requirements
- Requires additional configuration questions

**Note:** Even when using organization configuration, you still need to:
- Create the SCIM integration (account-level object)
- Create a network POLICY referencing shared network RULES
- Set up break-glass access for THIS account
- Configure administrators for THIS account

**Shared Network Rules:** When using organization configuration, the network rules from Platform Foundation are shared via the Infrastructure database. You only need to create a network policy in this account that references those shared rules.

## Deliverables

Upon completing this task, you will have:
- ✅ User provisioning configured (SCIM or manual)
- ✅ Administrator users with ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, USERADMIN roles
- ✅ Network rules and policies restricting access to allowed IPs
- ✅ Authentication policies defining login requirements
- ✅ Break-glass emergency access account
- ✅ MFA enabled for privileged users

## More Information

* [SCIM Overview](https://docs.snowflake.com/en/user-guide/scim) — Automated user provisioning
* [SAML/SSO Configuration](https://docs.snowflake.com/en/user-guide/admin-security-fed-auth) — Federated authentication
* [Network Policies](https://docs.snowflake.com/en/user-guide/network-policies) — IP allowlisting
* [Authentication Policies](https://docs.snowflake.com/en/user-guide/authentication-policies) — Auth requirements
* [MFA Best Practices](https://docs.snowflake.com/en/user-guide/security-mfa) — Multi-factor authentication

</details>

---


## Step 2.1: Select Security Configuration Approach

## Security Configuration Approach

### Your Selections

| Setting | Value |
|---------|-------|
| **Configuration Approach** | Use Organization Configuration |
| **SAML/SSO** | Yes - Configure SAML for this account |

### Platform Foundation Settings (Reference)

These are the settings from your Platform Foundation setup:

| Setting | Platform Foundation Value |
|---------|--------------------------|
| **Identity Provider** | Okta |
| **SAML/SSO Configured** | Yes - Configure SAML now |

### Using Organization Configuration

You've chosen to use the same security settings established in Platform Foundation:
- **Identity Provider**: Okta
- **Network Rules**: Same IP ranges as Organization Account
- **Authentication Policies**: Same requirements as Organization Account

The following steps will create these configurations in this account using the organization's standard values.

### SAML/SSO Configuration

A dedicated step will guide you through SAML configuration for this account. You'll need:
- IdP metadata (certificate, SSO URL, issuer)
- Application registration in your IdP for this Snowflake account

---


## Step 2.2: Configure Account SCIM Integration

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 2.3: Create Account Administrators

## Account Administrators

### Administrator List

The following users will be configured as administrators for this account:

| Login Name | Admin Role | Email | Name |
|------------|------------|-------|------|

### Role Distribution

| Role | Count | Users |
|------|-------|-------|
| ACCOUNTADMIN | 0 | - |
| SECURITYADMIN | 0 | - |
| SYSADMIN | 0 | - |
| USERADMIN | 0 | - |

### SCIM Note

These users should already exist in Snowflake via SCIM provisioning. If a user hasn't synced yet:
1. Verify the user is assigned to the Snowflake application in your IdP
2. Wait for the next sync cycle (or trigger a manual sync)
3. Check `SHOW USERS;` to confirm the user exists

---


## Step 2.4: Configure Account SAML/SSO

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 2.5: Create Account Break-Glass Emergency Access

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 2.6: Configure Account Custom Network Rules

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

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


## Step 2.8: Apply Organization Network Configuration

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 2.9: Configure Account Authentication Policies

## Authentication Policies Configuration

### Inherited Values

These values are inherited from Platform Foundation. Any changes apply only to this account.

| Setting | Value | Source |
|---------|-------|--------|
| **Human Authentication** | SAML (SSO), Password with MFA | Platform Foundation (editable) |
| **MFA Method** | TOTP (Authenticator Apps), Passkey (FIDO2/WebAuthn) | Platform Foundation (editable) |
| **Service Authentication** | OAuth, Key Pair | Platform Foundation (editable) |
| **Account-Level Enforcement** | Yes - Apply default policy to all users | Platform Foundation (editable) |

### Policy Summary

| User Type | Policy Name | Authentication Methods |
|-----------|-------------|------------------------|
| **Human Users** | `human_user_auth_policy` | SAML (SSO), Password with MFA |
| **Service Accounts** | `service_account_auth_policy` | OAuth, Key Pair |
| **Break-Glass** | `breakglass_auth_policy` | Password Only |

### Human User Authentication Policy
- Authentication: SAML or Password
- MFA: TOTP (Authenticator Apps), Passkey (FIDO2/WebAuthn) (for password logins)
- Users can choose SSO or password + MFA

### Service Account Authentication Policy
- Authentication: OAuth or key-pair
- Flexibility for different integration types

### Policy Application
**Account-Level Enforcement: Enabled**
- The human user authentication policy applies to all users by default
- Break-glass accounts must have their own policy explicitly assigned
- Service accounts should have the service policy explicitly assigned

### Important Notes

- Break-glass accounts have their own policy allowing password-only access
- Admin users should use the human authentication policy
- Apply service policy only to designated service accounts

---


## Step 2.10: Enable Account Multi-Factor Authentication

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


# Task 3: Account Cost Management

**Summary:** Configure an account-level budget with spending limits and alerts, set up a resource monitor for active cost control, and apply domain and environment tags for cost allocation and FinOps reporting.

**Prerequisites:**
- **Personas:** FinOps Team, Platform Administrator, Finance Team
- **Role Requirements:** ACCOUNTADMIN role access
- **External Requirements:** Security & Identity Configuration complete (Task 2), Infrastructure share consumed (access to governance objects), Knowledge of expected credit consumption for this account, List of stakeholders to receive budget alerts

<details>
<summary>Task Overview (click to expand)</summary>

# Account Cost Management

## Summary
Configure an account-level budget with spending limits and alerts, set up a
resource monitor for active cost control, and apply domain and environment
tags for cost allocation and FinOps reporting.

## External Requirements
- Security & Identity Configuration complete (Task 2)
- Infrastructure share consumed (access to governance objects)
- Knowledge of expected credit consumption for this account
- List of stakeholders to receive budget alerts

## Personas
- FinOps Team
- Platform Administrator
- Finance Team

## Role Requirements
- ACCOUNTADMIN role access

## Details
## Steps in This Task

| Step | Title | Purpose |
|------|-------|---------|
| 3.1 | Configure Account Budget | Set spending limits and email alerts |
| 3.2 | Configure Account Resource Monitor | Active cost control with suspend/notify actions |
| 3.3 | Apply Cost Allocation Tags | Tag account resources for FinOps reporting |

**From Platform Foundation (inherited):**
- Tag framework (DOMAIN, ENVIRONMENT tags with allowed values)
- FinOps strategy decisions

## Account Execution Context

All steps in this task should be executed from the **newly created account**.

| Steps | Execute From |
|-------|--------------|
| 3.1 - 3.3 | **New Account** (the account you created) |

## Time Estimate

- **Budget configuration:** 5-10 minutes
- **Resource monitor setup:** 5-10 minutes
- **Tag application:** 5-10 minutes
- **Total:** 15-30 minutes

## Key Decisions

| Decision | Who Should Decide | Impact |
|----------|-------------------|--------|
| Monthly credit limit | Finance/Platform Team | Budget ceiling for this account |
| Alert thresholds | Platform Team | When stakeholders are notified |
| Resource monitor action | Platform Team | Whether to suspend or just notify at limit |
| Tag values | Business/Platform Team | Cost attribution in reports |

## Relationship to Platform Foundation

The Platform Foundation workflow established:
- **Tag framework**: DOMAIN, ENVIRONMENT, and other tags with allowed values
- **Account-level budget**: For the Organization Account
- **Account-level resource monitor**: For the Organization Account

This task configures the same elements for THIS account:
- Apply tags to this account's resources
- Set budget specific to this account's expected usage
- Configure resource monitor for this account's credit limit

## Deliverables

Upon completing this task, you will have:
- ✅ Account budget configured with monthly limit and email alerts
- ✅ Account resource monitor with threshold-based actions
- ✅ Domain and environment tags applied for cost reporting
- ✅ Account ready for use with full cost visibility

## More Information

* [Budgets Overview](https://docs.snowflake.com/en/user-guide/budgets) — Credit monitoring and alerts
* [Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors) — Active cost control
* [Object Tagging](https://docs.snowflake.com/en/user-guide/object-tagging) — Tag-based governance
* [Attributing Costs with Tags](https://docs.snowflake.com/en/user-guide/cost-attributing) — FinOps reporting

</details>

---


## Step 3.1: Configure Account Budget

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 3.2: Configure Account Resource Monitor

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `new_account_name`
>
> Provide values for the above variables to render this step.

---


## Step 3.3: Apply Cost Allocation Tags

> **SKIPPED:** This step could not be rendered due to missing answers.
>
> **Null/empty answers:** `account_domain`
>
> Provide values for the above variables to render this step.

---


# Task 4: Account Observability

**Summary:** Configure account-level telemetry parameters to enable logging, metrics, and tracing for stored procedures, UDFs, and handler code in the newly created account.

**Prerequisites:**
- **Personas:** Platform Administrator, SRE / Observability Team
- **Role Requirements:** ACCOUNTADMIN role access
- **External Requirements:** Security & Identity Configuration complete (Task 2)

<details>
<summary>Task Overview (click to expand)</summary>

# Account Observability

## Summary
Configure account-level telemetry parameters to enable logging, metrics,
and tracing for stored procedures, UDFs, and handler code in the newly
created account.

## External Requirements
- Security & Identity Configuration complete (Task 2)

## Personas
- Platform Administrator
- SRE / Observability Team

## Role Requirements
- ACCOUNTADMIN role access

## Details
This task configures observability for the newly created account by setting
the event table and account-level telemetry parameters. The `EVENT_TABLE`
parameter has no default value, so this task explicitly sets it to
`SNOWFLAKE.TELEMETRY.EVENTS` (which exists in every Snowflake account) to
ensure telemetry data is collected. If all telemetry parameters are set to
their disabled values, the event table is not activated.

## Steps in This Task

| Step | Title | Purpose |
|------|-------|---------|
| 4.1 | Configure Telemetry Parameters | Set EVENT_TABLE, LOG_LEVEL, METRIC_LEVEL, TRACE_LEVEL, and SQL_TRACE_QUERY_TEXT |

## Account Execution Context

All steps in this task should be executed from the **newly created account**.

| Steps | Execute From |
|-------|--------------|
| 4.1 | **New Account** (the account you created) |

## Time Estimate

- **Telemetry configuration:** 5-10 minutes

## Key Decisions

| Decision | Who Should Decide | Impact |
|----------|-------------------|--------|
| Log level | Platform/SRE Team | Verbosity vs. storage cost; INFO recommended for production, consider `DEBUG` for dev, etc. |
| Metric collection | Platform/SRE Team | ALL enables execution metrics; no performance impact |
| Trace level | Platform/SRE Team | ALWAYS captures spans; requires LOG_LEVEL not OFF |
| SQL text capture | Platform/Security Team | Useful for debugging but may expose sensitive SQL |

## Relationship to Platform Foundation

The Platform Foundation workflow established observability for the
Organization Account. This task configures the same telemetry parameters
independently for THIS account. Settings are not inherited — you may choose
different values based on the account's purpose (e.g., more verbose logging
for development accounts).

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
