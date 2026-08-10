# Data Product Setup

> Generated: 2026-08-10 14:43:10
> Blueprint: data-product-setup

---

This repeatable workflow guides you through configuring a complete data product in Snowflake. A Data Product is a self-contained, governed unit of data with clear ownership, dedicated resources, and well-defined access controls.

**What You Will Create:**
- **Core Roles**: ADMIN, CREATE, WRITE, RBAC, READ roles with proper hierarchy
- **Databases**: Zone-based databases (RAW, TRANSFORM, CURATED)
- **Schemas**: Organized by source system or subject area within each zone
- **Database Roles**: Granular access control (DB_R, DB_W, DB_C, SC_R, SC_W, SC_C)
- **Warehouses**: Workload-specific compute (INGEST, TRANSFORM, QUERY, BI)
- **Resource Monitors**: Credit quotas and alerts for cost management

**Key Features:**
- Supports both SCIM and non-SCIM deployments
- Flexible zone structure (medallion architecture)
- Tag-based governance and cost allocation
- Delegated administration through RBAC role

Run this workflow once for each data product you need to deploy.


---

## Table of Contents

- [Task 1: Data Product Planning](#task-1-data-product-planning)
  - [Step 1.1: Select Target Account](#step-11-select-target-account)
  - [Step 1.2: Define Data Product Identity](#step-12-define-data-product-identity)
  - [Step 1.3: Configure Zone Structure](#step-13-configure-zone-structure)
  - [Step 1.4: Plan Schema Organization](#step-14-plan-schema-organization)
  - [Step 1.5: Plan Warehouse Requirements](#step-15-plan-warehouse-requirements)
- [Task 2: Core Roles & Database Setup](#task-2-core-roles-database-setup)
  - [Step 2.1: Create Data Product Core Roles](#step-21-create-data-product-core-roles)
  - [Step 2.2: Create Databases](#step-22-create-databases)
  - [Step 2.3: Create Schemas](#step-23-create-schemas)
- [Task 3: Warehouse & Access Configuration](#task-3-warehouse-access-configuration)
  - [Step 3.1: Create Warehouses](#step-31-create-warehouses)
  - [Step 3.2: Create Warehouse Access Roles](#step-32-create-warehouse-access-roles)
  - [Step 3.3: Transfer Ownership & Wire Hierarchy](#step-33-transfer-ownership-wire-hierarchy)
- [Task 4: Consumer Access](#task-4-consumer-access)
  - [Step 4.1: Create Custom Read Roles](#step-41-create-custom-read-roles)
  - [Step 4.2: Grant Database Access to Roles](#step-42-grant-database-access-to-roles)
- [Task 5: Data Product Cost Management](#task-5-data-product-cost-management)
  - [Step 5.1: Create Resource Monitors](#step-51-create-resource-monitors)
  - [Step 5.2: Assign Monitors to Warehouses](#step-52-assign-monitors-to-warehouses)
  - [Step 5.3: Configure Alert Notifications](#step-53-configure-alert-notifications)

---


# Task 1: Data Product Planning

**Summary:** Select the target Snowflake account for deployment, define the data product's name, domain, environment, and SCIM configuration, plan zone structure and schemas, and define warehouse requirements for different workloads.

**Prerequisites:**
- **Personas:** Data Team, Platform Team, Data Architecture Team
- **Role Requirements:** SYSADMIN role access in the target account
- **External Requirements:** Platform Foundation Setup completed, Target account exists and is accessible

<details>
<summary>Task Overview (click to expand)</summary>

# Data Product Planning

## Summary
Select the target Snowflake account for deployment, define the data product's name,
domain, environment, and SCIM configuration, plan zone structure and schemas,
and define warehouse requirements for different workloads.

## External Requirements
- Platform Foundation Setup completed
- Target account exists and is accessible

## Personas
- Data Team
- Platform Team
- Data Architecture Team

## Role Requirements
- SYSADMIN role access in the target account

## Details
This is a **repeatable workflow** — run it once for each data product you need to configure.

## **What is a Data Product?**

A **Data Product** is a self-contained, governed unit of data with clear ownership, dedicated resources, and well-defined access controls. Instead of a monolithic data warehouse with unclear ownership, data products organize data by business domain with:

- **Own databases** organized by processing stage (raw → transformed → curated)
- **Own compute** (warehouses) sized for specific workloads
- **Own access controls** with delegated administration
- **Clear team ownership** and cost accountability

## **Steps in This Task**

| Step | Title | Purpose | Conditional |
|------|-------|---------|-------------|
| 1.1 | Select Target Account | Identify which account to deploy to | Multi-account strategies only |
| 1.2 | Define Data Product Identity | Name, domain, environment, SCIM prefix | Always shown |
| 1.3 | Configure Zone Structure | Define data zones (raw, curated, pub) | Always shown |
| 1.4 | Plan Schema Organization | Define schemas within each zone | Always shown |
| 1.5 | Plan Warehouse Requirements | Define compute resources and workload types | Always shown |

**From Platform Foundation (inherited):**
- `account_strategy` — Single or multi-account approach
- `domain_list` — Available business domains
- `environment_list` — Available SDLC environments
- `platform_database_name` — Infrastructure database name
- `governance_name` — Governance schema name

## **Key Decisions**

| Decision | Who Should Decide | Impact |
|----------|-------------------|--------|
| Target Account | Platform Team | Where resources are created |
| Data Product Name | Data Team/Platform Team | Permanent identifier in all object names |
| Domain Assignment | Business/Platform Team | Cost allocation and governance |
| Environment | Platform Team | Determines isolation level |
| SCIM Prefix | Platform/Security Team | Role ownership and user assignment method |
| Zone Structure | Data Architecture Team | Data flow and organization |
| Warehouse Sizing | Platform/Data Team | Performance and cost |

## **Deliverables**

Upon completing this task, you will have:
- ✅ Target account identified and documented
- ✅ Data product identity defined (name, domain, environment)
- ✅ SCIM configuration determined (prefix or NONE)
- ✅ Zone structure planned
- ✅ Schemas organized by zone and purpose
- ✅ Warehouse requirements defined by workload type

## **More Information**

* [Snowflake Object Hierarchy](https://docs.snowflake.com/en/user-guide/databases) — Database and schema concepts
* [Database Design Best Practices](https://docs.snowflake.com/en/user-guide/databases-best-practices) — Database organization
* [Warehouse Considerations](https://docs.snowflake.com/en/user-guide/warehouses-considerations) — Sizing and configuration
* [SCIM Provisioning](https://docs.snowflake.com/en/user-guide/scim) — Identity provider integration

</details>

---


## Step 1.1: Select Target Account

## Target Account Selection

### Selected Account

| Property | Value |
|----------|-------|
| **Target Account** | FINTECHCORP |
| **Account Strategy** | Single Account |

### Implied Naming Components

### Connection Information

To execute SQL in subsequent steps, connect to:
- **Account**: `FINTECHCORP`
- **Required Role**: SYSADMIN (for object creation)
- **Connection URL**: `https://<org>-fintechcorp.snowflakecomputing.com`

> **Important:** Ensure you have SYSADMIN access to this account before proceeding.


---


## Step 1.2: Define Data Product Identity

## Data Product Identity

### Core Identity

| Property | Value |
|----------|-------|
| **Data Product Name** | core |
| **Domain** | PAYMENTS |
| **Environment** | DEV |
| **Description** | Development environment for the core payments data product. Used by the data engineering team to build and test pipelines against masked or synthetic payment data. |

### SCIM Configuration
| Property | Value |
|----------|-------|
| **SCIM Enabled** | Yes |
| **SCIM Prefix** | OKTA |
| **Role Owner** | OKTA_PROVISIONER |
| **User Assignment** | Via identity provider groups |

> **Note:** Roles created for this data product will be owned by `OKTA_PROVISIONER`. Custom read roles should be assigned to users via your identity provider (OKTA) group mappings.

### Derived Role Owner

Based on your SCIM configuration:

```
Owner Role: OKTA_PROVISIONER
  └── CORE_ADMIN
  └── CORE_CREATE
  └── CORE_WRITE
  └── CORE_RBAC
  └── CORE_READ
```

### Cost Allocation Tags

The following tags will be applied to all resources:

| Tag | Value |
|-----|-------|
| `DOMAIN` | PAYMENTS |
| `ENVIRONMENT` | DEV |
| `DATAPRODUCT` | CORE |


---


## Step 1.3: Configure Zone Structure

## Zone Structure

### Configured Zones

This data product will have **3** database(s):

| Zone | Database Name | Purpose | Time Travel |
|------|---------------|---------|-------------|
| RAW | `PAYMENTS_CORE_RAW_DEV` | Development copy of raw payment source data. Masked or synthetic only - production cardholder data must not land here. | 1 days |
| CURATED | `PAYMENTS_CORE_CURATED_DEV` | Development curated payment entities. | 1 days |
| ANALYTICS | `PAYMENTS_CORE_ANALYTICS_DEV` | Development reporting models and feature tables. | 1 days |

### Zone Progression

```
RAW (Development copy of raw payment source data. Masked or synthetic only - production cardholder data must not land here.)
  └── CURATED (Development curated payment entities.)
  └── ANALYTICS (Development reporting models and feature tables.)
```

### Database Roles per Zone

Each database will have three database roles for access control:

| Database Role | Purpose | Grants |
|---------------|---------|--------|
| `DB_R` | Read access to all schemas | SELECT on tables/views |
| `DB_W` | Write access to all schemas | INSERT, UPDATE, DELETE |
| `DB_C` | Create access to all schemas | CREATE objects |

**Note:** Database roles aggregate schema-level roles but do not have their own inheritance chain. Role inheritance is established at the schema level, then schema roles are granted to database roles:

```
Database Level:     DB_C           DB_W            DB_R
                      ↑               ↑               ↑
Schema Level:    SC_C_<schema> ← SC_W_<schema> ← SC_R_<schema>
```

This means CREATE inherits WRITE inherits READ at the schema level, then each schema role rolls up to its corresponding database role.


---


## Step 1.4: Plan Schema Organization

## Schema Organization

### Schemas by Zone

#### RAW Zone

| Schema | Database Role (Read) | Database Role (Write) | Database Role (Create) |
|--------|---------------------|----------------------|------------------------|
| `CARD_TRANSACTIONS` | `SC_R_CARD_TRANSACTIONS` | `SC_W_CARD_TRANSACTIONS` | `SC_C_CARD_TRANSACTIONS` |
| `BANK_TRANSFERS` | `SC_R_BANK_TRANSFERS` | `SC_W_BANK_TRANSFERS` | `SC_C_BANK_TRANSFERS` |
| `MERCHANTS` | `SC_R_MERCHANTS` | `SC_W_MERCHANTS` | `SC_C_MERCHANTS` |
| `CUSTOMERS` | `SC_R_CUSTOMERS` | `SC_W_CUSTOMERS` | `SC_C_CUSTOMERS` |
| `LEDGER_ENTRIES` | `SC_R_LEDGER_ENTRIES` | `SC_W_LEDGER_ENTRIES` | `SC_C_LEDGER_ENTRIES` |
| `GATEWAY_EVENTS` | `SC_R_GATEWAY_EVENTS` | `SC_W_GATEWAY_EVENTS` | `SC_C_GATEWAY_EVENTS` |

#### CURATED Zone

| Schema | Database Role (Read) | Database Role (Write) | Database Role (Create) |
|--------|---------------------|----------------------|------------------------|
| `TRANSACTIONS` | `SC_R_TRANSACTIONS` | `SC_W_TRANSACTIONS` | `SC_C_TRANSACTIONS` |
| `SETTLEMENTS` | `SC_R_SETTLEMENTS` | `SC_W_SETTLEMENTS` | `SC_C_SETTLEMENTS` |
| `MERCHANTS` | `SC_R_MERCHANTS` | `SC_W_MERCHANTS` | `SC_C_MERCHANTS` |
| `CUSTOMERS` | `SC_R_CUSTOMERS` | `SC_W_CUSTOMERS` | `SC_C_CUSTOMERS` |
| `CHARGEBACKS` | `SC_R_CHARGEBACKS` | `SC_W_CHARGEBACKS` | `SC_C_CHARGEBACKS` |
| `LEDGER` | `SC_R_LEDGER` | `SC_W_LEDGER` | `SC_C_LEDGER` |

#### ANALYTICS Zone

| Schema | Database Role (Read) | Database Role (Write) | Database Role (Create) |
|--------|---------------------|----------------------|------------------------|
| `REVENUE` | `SC_R_REVENUE` | `SC_W_REVENUE` | `SC_C_REVENUE` |
| `SETTLEMENT_RECONCILIATION` | `SC_R_SETTLEMENT_RECONCILIATION` | `SC_W_SETTLEMENT_RECONCILIATION` | `SC_C_SETTLEMENT_RECONCILIATION` |
| `FRAUD_FEATURES` | `SC_R_FRAUD_FEATURES` | `SC_W_FRAUD_FEATURES` | `SC_C_FRAUD_FEATURES` |
| `MERCHANT_PERFORMANCE` | `SC_R_MERCHANT_PERFORMANCE` | `SC_W_MERCHANT_PERFORMANCE` | `SC_C_MERCHANT_PERFORMANCE` |
| `REGULATORY_REPORTING` | `SC_R_REGULATORY_REPORTING` | `SC_W_REGULATORY_REPORTING` | `SC_C_REGULATORY_REPORTING` |

### Total Objects to Create

| Object Type | Count |
|-------------|-------|
| **Databases** | 3 |
| **Schemas** | 0 |
| **Schema Access Roles** | 0 |

### Access Control Hierarchy

Each schema's database roles inherit up to the database level:

```
Database: CORE_<ZONE>
├── DB_R (Database Read)
│
│
│
│   ├── SC_R_CARD_TRANSACTIONS
│
│   ├── SC_R_BANK_TRANSFERS
│
│   ├── SC_R_MERCHANTS
│
│   ├── SC_R_CUSTOMERS
│
│   ├── SC_R_LEDGER_ENTRIES
│
│   ├── SC_R_GATEWAY_EVENTS
│
│
│
│
│   ├── SC_R_TRANSACTIONS
│
│   ├── SC_R_SETTLEMENTS
│
│   ├── SC_R_MERCHANTS
│
│   ├── SC_R_CUSTOMERS
│
│   ├── SC_R_CHARGEBACKS
│
│   ├── SC_R_LEDGER
│
│
│
│
│   ├── SC_R_REVENUE
│
│   ├── SC_R_SETTLEMENT_RECONCILIATION
│
│   ├── SC_R_FRAUD_FEATURES
│
│   ├── SC_R_MERCHANT_PERFORMANCE
│
│   ├── SC_R_REGULATORY_REPORTING
│
│
├── DB_W (Database Write)
│
│
│
│   ├── SC_W_CARD_TRANSACTIONS
│
│   ├── SC_W_BANK_TRANSFERS
│
│   ├── SC_W_MERCHANTS
│
│   ├── SC_W_CUSTOMERS
│
│   ├── SC_W_LEDGER_ENTRIES
│
│   ├── SC_W_GATEWAY_EVENTS
│
│
│
│
│   ├── SC_W_TRANSACTIONS
│
│   ├── SC_W_SETTLEMENTS
│
│   ├── SC_W_MERCHANTS
│
│   ├── SC_W_CUSTOMERS
│
│   ├── SC_W_CHARGEBACKS
│
│   ├── SC_W_LEDGER
│
│
│
│
│   ├── SC_W_REVENUE
│
│   ├── SC_W_SETTLEMENT_RECONCILIATION
│
│   ├── SC_W_FRAUD_FEATURES
│
│   ├── SC_W_MERCHANT_PERFORMANCE
│
│   ├── SC_W_REGULATORY_REPORTING
│
│
└── DB_C (Database Create)
    ├── SC_C_CARD_TRANSACTIONS
    ├── SC_C_BANK_TRANSFERS
    ├── SC_C_MERCHANTS
    ├── SC_C_CUSTOMERS
    ├── SC_C_LEDGER_ENTRIES
    ├── SC_C_GATEWAY_EVENTS
    ├── SC_C_TRANSACTIONS
    ├── SC_C_SETTLEMENTS
    ├── SC_C_MERCHANTS
    ├── SC_C_CUSTOMERS
    ├── SC_C_CHARGEBACKS
    ├── SC_C_LEDGER
    ├── SC_C_REVENUE
    ├── SC_C_SETTLEMENT_RECONCILIATION
    ├── SC_C_FRAUD_FEATURES
    ├── SC_C_MERCHANT_PERFORMANCE
    ├── SC_C_REGULATORY_REPORTING
```

### Schema Properties

All schemas will be created with:
- **Managed Access:** `WITH MANAGED ACCESS` (centralized grant control)
- **Owner:** `CORE_ADMIN` role
- **Database Role Owner:** `CORE_RBAC` role


---


## Step 1.5: Plan Warehouse Requirements

## Warehouse Requirements

### Configured Warehouses

| Warehouse Name | Workload | Size | Timeout | Comment |
|----------------|----------|------|---------|---------|
| `PAYMENTS_CORE_DEV_LOAD` | LOAD | XSMALL | 30 min | Ingestion warehouse for payments core dev. |
| `PAYMENTS_CORE_DEV_TRANSFORM` | TRANSFORM | XSMALL | 60 min | Development and transformation warehouse for payments core dev. Multi-cluster so concurrent developers do not queue behind each other. |

### Warehouse Access Roles

Each warehouse gets an access role for USAGE and MONITOR privileges:

| Warehouse | Access Role | Grants |
|-----------|-------------|--------|
| `PAYMENTS_CORE_DEV_LOAD` | `_WH_U_PAYMENTS_CORE_DEV_LOAD` | USAGE, MONITOR |
| `PAYMENTS_CORE_DEV_TRANSFORM` | `_WH_U_PAYMENTS_CORE_DEV_TRANSFORM` | USAGE, MONITOR |

### Cost Estimation

| Size | Credits/Hour | Warehouses | Potential Credits/Hour |
|------|--------------|------------|------------------------|
| XSMALL | 1 | 1 | 1 |
| XSMALL | 1 | 1 | 1 |

> **Note:** Actual costs depend on warehouse utilization and auto-suspend settings. All warehouses are created with AUTO_SUSPEND = 60 seconds by default.

### Warehouse Properties

All warehouses will be created with:
- **Auto Suspend:** 60 seconds
- **Auto Resume:** TRUE
- **Initially Suspended:** TRUE
- **Owner:** `CORE_ADMIN` role
- **Tagged with:** DOMAIN, ENVIRONMENT, DATAPRODUCT, WORKLOAD


---


# Task 2: Core Roles & Database Setup

**Summary:** Create the foundational infrastructure for your data product including five core account-level roles, databases for each zone with database-level access roles, schemas with schema-level access roles, and complete role hierarchy.

**Prerequisites:**
- **Personas:** Platform Administrator, Data Architect, Security Administrator
- **Role Requirements:** USERADMIN role, SYSADMIN role, SECURITYADMIN role
- **External Requirements:** Task 1 (Data Product Planning) completed, Target account accessible, data_product_name, data_product_domain, data_product_environment from Task 1, scim_prefix, data_zones, schema_configuration from Task 1

<details>
<summary>Task Overview (click to expand)</summary>

# Core Roles & Database Setup

## Summary
Create the foundational infrastructure for your data product including five
core account-level roles, databases for each zone with database-level access
roles, schemas with schema-level access roles, and complete role hierarchy.

## External Requirements
- Task 1 (Data Product Planning) completed
- Target account accessible
- data_product_name, data_product_domain, data_product_environment from Task 1
- scim_prefix, data_zones, schema_configuration from Task 1

## Personas
- Platform Administrator
- Data Architect
- Security Administrator

## Role Requirements
- USERADMIN role
- SYSADMIN role
- SECURITYADMIN role

## Details
## **Understanding Snowflake Roles**

Snowflake uses **Role-Based Access Control (RBAC)**. Permissions aren't granted directly to users — instead:

1. **Privileges** are granted to **roles**
2. **Roles** are granted to **users** (or other roles)
3. **Users** inherit privileges from all their roles

## **Account Roles vs. Database Roles**

| Type | Scope | Created By | Use Case |
|------|-------|------------|----------|
| **Account Role** | Entire account | USERADMIN/SECURITYADMIN | User assignment, cross-database access |
| **Database Role** | Single database | Database owner | Delegated administration within a database |

## **Understanding Tags**

**Tags** are metadata labels you attach to Snowflake objects for FinOps, governance, and discovery:

| Tag | Applied To | Purpose |
|-----|------------|---------|
| `DOMAIN` | Roles, Databases, Warehouses | Cost allocation by business domain |
| `ENVIRONMENT` | Databases, Warehouses | Distinguish dev/test/prod |
| `DATAPRODUCT` | Databases, Warehouses | Identify owning data product |
| `ZONE` | Databases | Data processing stage (RAW, CURATED, etc.) |
| `WORKLOAD` | Warehouses | Compute purpose (INGEST, TRANSFORM, BI) |

## **Steps in This Task**

| Step | Title | Purpose |
|------|-------|---------|
| 2.1 | Create Data Product Core Roles | Create ADMIN, CREATE, WRITE, RBAC, READ account roles |
| 2.2 | Create Databases | Create zone databases with DB_R/DB_W/DB_C database roles |
| 2.3 | Create Schemas | Create schemas with SC_R/SC_W/SC_C database roles |

## **Role Architecture**

```
SYSADMIN
└── <dataproduct>_ADMIN (owns infrastructure)
    ├── <dataproduct>_CREATE (creates objects, has account access roles)
    └── <dataproduct>_RBAC (owns access roles)

Database Roles:  DB_C           DB_W            DB_R
                   ↑               ↑               ↑
Schema Roles:   SC_C_<schema> ← SC_W_<schema> ← SC_R_<schema>
```

## **Tag-Based Cost Allocation**

## **Deliverables**

Upon completing this task, you will have:
- ✅ Five core account roles created and hierarchically linked
- ✅ Account access roles granted to CREATE role
- ✅ Databases created for each zone with database roles
- ✅ Schemas created with managed access and schema roles
- ✅ Complete role hierarchy from schema → database → account level

## **More Information**

* [Access Control Overview](https://docs.snowflake.com/en/user-guide/security-access-control-overview)
* [Database Roles](https://docs.snowflake.com/en/user-guide/security-access-control-overview#database-roles)
* [Object Tagging](https://docs.snowflake.com/en/user-guide/object-tagging)

</details>

---


## Step 2.1: Create Data Product Core Roles

## Core Roles Configuration

### Roles to Create

| Role | Name | Purpose | Owner |
|------|------|---------|-------|
| **ADMIN** | `CORE_ADMIN` | Owns infrastructure (databases, schemas, warehouses) | `OKTA_PROVISIONER` |
| **CREATE** | `CORE_CREATE` | Creates objects, receives account access roles | `OKTA_PROVISIONER` |
| **WRITE** | `CORE_WRITE` | Modifies data (DML operations) | `OKTA_PROVISIONER` |
| **RBAC** | `CORE_RBAC` | Owns access roles for delegated governance | `OKTA_PROVISIONER` |
| **READ** | `CORE_READ` | Read-only access to data product | `OKTA_PROVISIONER` |

### Role Hierarchy

```
SYSADMIN
└── CORE_ADMIN
    ├── CORE_CREATE
    │   ├── _AR_EXEC_TASK (execute tasks)
    │   ├── _AR_VIEW_AUSG (view account usage)
    │   ├── _AR_APPLY_DDM (apply masking policies)
    │   ├── _AR_APPLY_RAP (apply row access policies)
    │   └── _AR_APPLY_TAG (apply tags)
    └── CORE_RBAC
```

### SCIM Configuration
| Setting | Value |
|---------|-------|
| **SCIM Enabled** | Yes |
| **SCIM Prefix** | `OKTA` |
| **Role Owner** | `OKTA_PROVISIONER` |
| **User Assignment** | Via identity provider groups |

> **Note:** After roles are created, configure your identity provider (OKTA) to map groups to these roles for automatic user assignment.

### Account Access Roles

The following account access roles will be granted to `CORE_CREATE`:

| Access Role | Purpose |
|-------------|---------|
| `_AR_EXEC_TASK` | Execute Snowflake tasks (scheduled jobs) |
| `_AR_VIEW_AUSG` | View Account Usage data for monitoring |
| `_AR_APPLY_DDM` | Apply dynamic data masking policies |
| `_AR_APPLY_RAP` | Apply row access policies |
| `_AR_APPLY_TAG` | Apply tags to objects |

> **Note:** These roles must exist in the account. If they don't exist, the grants will be skipped with warnings.


---


## Step 2.2: Create Databases

## Database Configuration

### Databases to Create

| Zone | Database Name | Time Travel | Database Roles |
|------|---------------|-------------|----------------|
| RAW | `PAYMENTS_CORE_DEV_RAW` | 1 days | DB_R, DB_W, DB_C |
| CURATED | `PAYMENTS_CORE_DEV_CURATED` | 1 days | DB_R, DB_W, DB_C |
| ANALYTICS | `PAYMENTS_CORE_DEV_ANALYTICS` | 1 days | DB_R, DB_W, DB_C |

### Database Role Hierarchy

Each database will have three database roles:

```
PAYMENTS_CORE_DEV_<ZONE>
├── DB_R (Database Read)
│   └── Inherits: All SC_R_* schema roles
├── DB_W (Database Write)
│   └── Inherits: DB_R + All SC_W_* schema roles
└── DB_C (Database Create)
    └── Inherits: DB_W + All SC_C_* schema roles
```

### Role Ownership

| Object | Owner |
|--------|-------|
| Database | `PAYMENTS_CORE_DEV_ADMIN` |
| Database Roles (DB_R, DB_W, DB_C) | `PAYMENTS_CORE_DEV_RBAC` |

### Account Role → Database Role Mapping

| Account Role | Receives | From All Databases |
|--------------|----------|-------------------|
| `PAYMENTS_CORE_DEV_READ` | `DB_R` | Read access to all zones |
| `PAYMENTS_CORE_DEV_WRITE` | `DB_W` | Write access to all zones |
| `PAYMENTS_CORE_DEV_CREATE` | `DB_C` | Create access to all zones |

### Tags Applied

Each database will be tagged with:

| Tag | Value |
|-----|-------|
| `DOMAIN` | `PAYMENTS` |
| `ENVIRONMENT` | `DEV` |
| `DATAPRODUCT` | `CORE` |
| `ZONE` | `<zone_name>` |


---


## Step 2.3: Create Schemas

## Schema Configuration

### Schemas by Zone

#### RAW Zone (`PAYMENTS_CORE_DEV_RAW`)

| Schema | SC_R (Read) | SC_W (Write) | SC_C (Create) |
|--------|-------------|--------------|---------------|
| `CARD_TRANSACTIONS` | `SC_R_CARD_TRANSACTIONS` | `SC_W_CARD_TRANSACTIONS` | `SC_C_CARD_TRANSACTIONS` |
| `BANK_TRANSFERS` | `SC_R_BANK_TRANSFERS` | `SC_W_BANK_TRANSFERS` | `SC_C_BANK_TRANSFERS` |
| `MERCHANTS` | `SC_R_MERCHANTS` | `SC_W_MERCHANTS` | `SC_C_MERCHANTS` |
| `CUSTOMERS` | `SC_R_CUSTOMERS` | `SC_W_CUSTOMERS` | `SC_C_CUSTOMERS` |
| `LEDGER_ENTRIES` | `SC_R_LEDGER_ENTRIES` | `SC_W_LEDGER_ENTRIES` | `SC_C_LEDGER_ENTRIES` |
| `GATEWAY_EVENTS` | `SC_R_GATEWAY_EVENTS` | `SC_W_GATEWAY_EVENTS` | `SC_C_GATEWAY_EVENTS` |

#### CURATED Zone (`PAYMENTS_CORE_DEV_CURATED`)

| Schema | SC_R (Read) | SC_W (Write) | SC_C (Create) |
|--------|-------------|--------------|---------------|
| `TRANSACTIONS` | `SC_R_TRANSACTIONS` | `SC_W_TRANSACTIONS` | `SC_C_TRANSACTIONS` |
| `SETTLEMENTS` | `SC_R_SETTLEMENTS` | `SC_W_SETTLEMENTS` | `SC_C_SETTLEMENTS` |
| `MERCHANTS` | `SC_R_MERCHANTS` | `SC_W_MERCHANTS` | `SC_C_MERCHANTS` |
| `CUSTOMERS` | `SC_R_CUSTOMERS` | `SC_W_CUSTOMERS` | `SC_C_CUSTOMERS` |
| `CHARGEBACKS` | `SC_R_CHARGEBACKS` | `SC_W_CHARGEBACKS` | `SC_C_CHARGEBACKS` |
| `LEDGER` | `SC_R_LEDGER` | `SC_W_LEDGER` | `SC_C_LEDGER` |

#### ANALYTICS Zone (`PAYMENTS_CORE_DEV_ANALYTICS`)

| Schema | SC_R (Read) | SC_W (Write) | SC_C (Create) |
|--------|-------------|--------------|---------------|
| `REVENUE` | `SC_R_REVENUE` | `SC_W_REVENUE` | `SC_C_REVENUE` |
| `SETTLEMENT_RECONCILIATION` | `SC_R_SETTLEMENT_RECONCILIATION` | `SC_W_SETTLEMENT_RECONCILIATION` | `SC_C_SETTLEMENT_RECONCILIATION` |
| `FRAUD_FEATURES` | `SC_R_FRAUD_FEATURES` | `SC_W_FRAUD_FEATURES` | `SC_C_FRAUD_FEATURES` |
| `MERCHANT_PERFORMANCE` | `SC_R_MERCHANT_PERFORMANCE` | `SC_W_MERCHANT_PERFORMANCE` | `SC_C_MERCHANT_PERFORMANCE` |
| `REGULATORY_REPORTING` | `SC_R_REGULATORY_REPORTING` | `SC_W_REGULATORY_REPORTING` | `SC_C_REGULATORY_REPORTING` |

### Schema Properties

All schemas will be created with:

| Property | Value |
|----------|-------|
| **Managed Access** | Yes (`WITH MANAGED ACCESS`) |
| **Owner** | `PAYMENTS_CORE_DEV_ADMIN` |
| **Database Role Owner** | `PAYMENTS_CORE_DEV_RBAC` |

### Privilege Summary

**SC_R (Read) Privileges:**
- `USAGE` on schema
- `SELECT` on tables, views, external tables, dynamic tables, materialized views
- `USAGE` on functions
- All grants include `FUTURE` for automatic inheritance

**SC_W (Write) Privileges:**
- Inherits all SC_R privileges
- `INSERT, UPDATE, DELETE, TRUNCATE` on tables
- `SELECT` on streams
- `USAGE` on procedures, sequences, file formats
- `USAGE, READ, WRITE` on stages
- `MONITOR, OPERATE` on tasks, dynamic tables, alerts

**SC_C (Create) Privileges:**
- Inherits all SC_W privileges
- `CREATE` for all object types in schema


---


# Task 3: Warehouse & Access Configuration

**Summary:** Create warehouses for each workload type, create warehouse access roles for controlled compute access, transfer ownership to admin roles, and wire the complete role hierarchy connecting account roles to warehouse access.

**Prerequisites:**
- **Personas:** Platform Administrator, Data Team
- **Role Requirements:** SYSADMIN role, USERADMIN role, SECURITYADMIN role
- **External Requirements:** Task 2 (Core Roles & Database Setup) completed, warehouse_definitions from Task 1, Core roles created (ADMIN, CREATE, WRITE, RBAC, READ), Databases and schemas with database roles

<details>
<summary>Task Overview (click to expand)</summary>

# Warehouse & Access Configuration

## Summary
Create warehouses for each workload type, create warehouse access roles for
controlled compute access, transfer ownership to admin roles, and wire the
complete role hierarchy connecting account roles to warehouse access.

## External Requirements
- Task 2 (Core Roles & Database Setup) completed
- warehouse_definitions from Task 1
- Core roles created (ADMIN, CREATE, WRITE, RBAC, READ)
- Databases and schemas with database roles

## Personas
- Platform Administrator
- Data Team

## Role Requirements
- SYSADMIN role
- USERADMIN role
- SECURITYADMIN role

## Details
## **Understanding Snowflake Warehouses**

In Snowflake, a **warehouse** is a cluster of compute resources — **not storage**. This is different from traditional databases where "warehouse" typically means a data warehouse (storage).

**Key implications:**
- **Scale independently**: Add more compute without moving data
- **Workload isolation**: Heavy ETL doesn't slow down BI dashboards
- **Pay per use**: Warehouses auto-suspend when idle
- **Multiple simultaneous**: Different teams use different warehouses on the same data

## **Warehouse Sizing**

| Size | Credits/Hour | Use Case |
|------|--------------|----------|
| X-Small | 1 | Light queries, development |
| Small | 2 | Ad-hoc analysis, small loads |
| Medium | 4 | Standard workloads |
| Large | 8 | Heavy transformations |
| X-Large | 16 | Large data processing |

## **Steps in This Task**

| Step | Title | Purpose |
|------|-------|---------|
| 3.1 | Create Warehouses | Create workload-specific warehouses with appropriate sizing |
| 3.2 | Create Warehouse Access Roles | Create `_WH_U_*` roles for warehouse usage |
| 3.3 | Transfer Ownership & Wire Hierarchy | Transfer ownership and complete role wiring |

**From Task 1:**
- `warehouse_definitions` — Warehouse specs (workload, size, timeout)

**From Task 2:**
- Core roles created (ADMIN, CREATE, WRITE, RBAC, READ)
- Databases and schemas with database roles

## **Warehouse Architecture**

```
Warehouse: <prefix>_<WORKLOAD>
├── Owner: <dataproduct>_ADMIN
├── Access Role: _WH_U_<prefix>_<WORKLOAD>
│   ├── Grants: USAGE, MONITOR
│   └── Owner: <dataproduct>_RBAC
└── Properties:
    ├── Size: (configured per workload)
    ├── Auto Suspend: 60 seconds
    └── Auto Resume: TRUE
```

## **Deliverables**

Upon completing this task, you will have:
- ✅ Warehouses created for each workload type
- ✅ Warehouse access roles created and configured
- ✅ Ownership transferred to ADMIN/RBAC roles
- ✅ Complete role hierarchy from account → database → schema → warehouse

## **More Information**

* [CREATE WAREHOUSE](https://docs.snowflake.com/en/sql-reference/sql/create-warehouse)
* [Warehouse Considerations](https://docs.snowflake.com/en/user-guide/warehouses-considerations)
* [Role Hierarchy](https://docs.snowflake.com/en/user-guide/security-access-control-overview#role-hierarchy-and-privilege-inheritance)

</details>

---


## Step 3.1: Create Warehouses

## Warehouse Configuration

### Warehouses to Create

| Warehouse | Size | Min Clusters | Max Clusters | Auto-Suspend | Access Role |
|-----------|------|--------------|--------------|--------------|-------------|
| `PAYMENTS_CORE_DEV_WH_LOAD` | XSMALL | 1 | 1 | 60s | `PAYMENTS_CORE_DEV_WH_U_LOAD` |
| `PAYMENTS_CORE_DEV_WH_TRANSFORM` | XSMALL | 1 | 2 | 60s | `PAYMENTS_CORE_DEV_WH_U_TRANSFORM` |

### Governance Tags Applied

Each warehouse will be tagged with:

| Tag | Value |
|-----|-------|
| DOMAIN | `payments` |
| ENVIRONMENT | `dev` |
| DATAPRODUCT | `core` |
| WORKLOAD | `<warehouse name>` |

### Ownership

| Property | Value |
|----------|-------|
| **Created By** | `PAYMENTS_CORE_DEV_CREATE` |
| **Final Owner** | `PAYMENTS_CORE_DEV_ADMIN` |

### Credit Estimates

| Warehouse | Credits/Hour (Idle) | Credits/Hour (Full) |
|-----------|---------------------|---------------------|
| `PAYMENTS_CORE_DEV_WH_LOAD` | 1 | 1 |
| `PAYMENTS_CORE_DEV_WH_TRANSFORM` | 1 | 2 |


---


## Step 3.2: Create Warehouse Access Roles

## Warehouse Access Roles

### Access Roles to Create

| Warehouse | Access Role | Privileges |
|-----------|-------------|------------|
| `PAYMENTS_CORE_DEV_WH_LOAD` | `PAYMENTS_CORE_DEV_WH_U_LOAD` | USAGE, MONITOR, OPERATE |
| `PAYMENTS_CORE_DEV_WH_TRANSFORM` | `PAYMENTS_CORE_DEV_WH_U_TRANSFORM` | USAGE, MONITOR, OPERATE |

### Role Properties

| Property | Value |
|----------|-------|
| **Owner** | `PAYMENTS_CORE_DEV_RBAC` |
| **Can Grant** | Any role via RBAC |

### Access Pattern

```
User → Account Role → Warehouse Access Role → Warehouse
                            ↓
                     USAGE, MONITOR, OPERATE
```

### Recommended Assignments

| Warehouse Type | Typical Users |
|----------------|---------------|
| ETL/Transform | Data Engineers, Service Accounts |
| Analytics | Data Analysts, BI Tools |
| Interactive | Ad-hoc query users |
| Production | Application service accounts |


---


## Step 3.3: Transfer Ownership & Wire Hierarchy

## Role Hierarchy Configuration

### Core Role Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                      ADMIN                                   │
│         PAYMENTS_CORE_DEV_ADMIN                                   │
│           ┌─────────┼─────────┐                              │
│           ▼         ▼         ▼                              │
│       CREATE      RBAC    Account Access                     │
│           │         │      Roles (5)                         │
│           ▼         │                                        │
│        WRITE ◄──────┤                                        │
│           │         │                                        │
│           ▼         ▼                                        │
│         READ ◄──────┘                                        │
└─────────────────────────────────────────────────────────────┘
```

### Database Role Connections

| Database | DB_R → | DB_W → | DB_C → |
|----------|--------|--------|--------|
| `PAYMENTS_CORE_DEV_RAW` | `PAYMENTS_CORE_DEV_READ` | `PAYMENTS_CORE_DEV_WRITE` | `PAYMENTS_CORE_DEV_CREATE` |
| `PAYMENTS_CORE_DEV_CURATED` | `PAYMENTS_CORE_DEV_READ` | `PAYMENTS_CORE_DEV_WRITE` | `PAYMENTS_CORE_DEV_CREATE` |
| `PAYMENTS_CORE_DEV_ANALYTICS` | `PAYMENTS_CORE_DEV_READ` | `PAYMENTS_CORE_DEV_WRITE` | `PAYMENTS_CORE_DEV_CREATE` |

### Account Access Roles

| Role | Privilege | Granted To |
|------|-----------|------------|
| `PAYMENTS_CORE_DEV_AR_EXEC_TASK` | EXECUTE TASK | `PAYMENTS_CORE_DEV_ADMIN` |
| `PAYMENTS_CORE_DEV_AR_VIEW_AUSG` | View SNOWFLAKE DB | `PAYMENTS_CORE_DEV_ADMIN` |
| `PAYMENTS_CORE_DEV_AR_APPLY_DDM` | APPLY MASKING POLICY | `PAYMENTS_CORE_DEV_ADMIN` |
| `PAYMENTS_CORE_DEV_AR_APPLY_RAP` | APPLY ROW ACCESS POLICY | `PAYMENTS_CORE_DEV_ADMIN` |
| `PAYMENTS_CORE_DEV_AR_APPLY_TAG` | APPLY TAG | `PAYMENTS_CORE_DEV_ADMIN` |

### SCIM Integration
| Connection | Target |
|------------|--------|
| `PAYMENTS_CORE_DEV_ADMIN` | → `OKTA_PROVISIONER` |

Users can be assigned to data product roles through your identity provider.

### Summary of Ownership

| Object Type | Owner |
|-------------|-------|
| Core Roles | `SECURITYADMIN` |
| Databases | `PAYMENTS_CORE_DEV_ADMIN` |
| Database Roles | `PAYMENTS_CORE_DEV_RBAC` |
| Warehouses | `PAYMENTS_CORE_DEV_ADMIN` |
| Warehouse Access Roles | `PAYMENTS_CORE_DEV_RBAC` |
| Account Access Roles | `PAYMENTS_CORE_DEV_RBAC` |


---


# Task 4: Consumer Access

**Summary:** Enable external consumers to access your data product by creating purpose-specific consumer access roles that provide granular, SCIM-manageable access for end users who need only specific data zones.

**Prerequisites:**
- **Personas:** Data Product Owner, Security Administrator, Identity Team
- **Role Requirements:** USERADMIN role (or SCIM provisioner role if using SCIM)
- **External Requirements:** Task 3 completed (all infrastructure in place), Knowledge of consumer groups and their data needs, SCIM prefix configured (if using SCIM)

<details>
<summary>Task Overview (click to expand)</summary>

# Consumer Access

## Summary
Enable external consumers to access your data product by creating purpose-specific
consumer access roles that provide granular, SCIM-manageable access for end users
who need only specific data zones.

## External Requirements
- Task 3 completed (all infrastructure in place)
- Knowledge of consumer groups and their data needs
- SCIM prefix configured (if using SCIM)

## Personas
- Data Product Owner
- Security Administrator
- Identity Team

## Role Requirements
- USERADMIN role (or SCIM provisioner role if using SCIM)

## Details
## **Why Consumer Access Roles?**

The core `<prefix>_READ` role provides read access across the entire data product - all zones, all schemas. This is typically too broad for end users who:
- Only need access to curated/published data (not raw or transformed)
- Should not see intermediate processing tables
- Need SCIM-managed role assignments for identity governance
- Require audit-friendly access patterns

Consumer access roles solve this by creating purpose-specific roles that:
- Grant access only to specific schemas (typically CURATED or PUBLISHED zones)
- Can be managed via SCIM for user assignment
- Support compliance requirements with clear purpose documentation
- Enable self-service access requests through identity governance workflows

## **Steps in This Task**

| Step | Title | Purpose |
|------|-------|---------|
| 4.1 | Create Custom Read Roles | SCIM-manageable roles for specific consumer groups |
| 4.2 | Grant Database Access to Roles | Wire consumer roles to specific database roles |

## **Consumer Role Pattern**

```
<prefix>_<stem>_<purpose>
```

| Component | Description | Example |
|-----------|-------------|---------|
| prefix | Data product prefix | `SALES_ANALYTICS_PRD` |
| stem | Subject area or consumer group | `REVENUE`, `MARKETING` |
| purpose | Access type | `RO` (Read-Only), `PI` (PII Access) |

## **Consumer Role Hierarchy**

```
Consumer Role (SCIM-managed)
└── Granted specific database roles
    └── DB_R or specific SC_R_* roles
        └── Read access to specific schemas only
```

## **SCIM Integration**

When SCIM is enabled:
- Consumer roles are owned by `<scim_prefix>_PROVISIONER`
- Users are assigned to consumer roles via SCIM (identity provider)
- No manual user grants required
- Access reviews happen in the identity provider

## **What You'll Create**

| Object Type | Naming Pattern | Owner | Purpose |
|-------------|----------------|-------|---------|
| Consumer Roles | `<prefix>_<stem>_<purpose>` | `<scim_prefix>_PROVISIONER` or `USERADMIN` | End-user access |
| Role Grants | Database role → Consumer role | N/A | Wire access |

## **More Information**

* [Database Roles](https://docs.snowflake.com/en/user-guide/security-access-control-database-roles)
* [SCIM Provisioning](https://docs.snowflake.com/en/user-guide/admin-security-fed-auth-overview)

</details>

---


## Step 4.1: Create Custom Read Roles

## Custom Read Roles Configuration

### Roles to Create

| Role | Description | Schema Access |
|------|-------------|---------------|
| `PAYMENTS_CORE_DEV_CUSTOM_DEVELOPER` | Data engineering. Read access across all dev zones for pipeline development and debugging. | raw, curated, analytics |

### Detailed Access Matrix

#### PAYMENTS_CORE_DEV_CUSTOM_DEVELOPER

**Description:** Data engineering. Read access across all dev zones for pipeline development and debugging.

**Schema Grants:**
- `RAW` (full zone access) → `DB_R`
- `CURATED` (full zone access) → `DB_R`
- `ANALYTICS` (full zone access) → `DB_R`

### Role Properties

| Property | Value |
|----------|-------|
| **Owner** | `PAYMENTS_CORE_DEV_RBAC` |
| **Granted To** | As needed |
| **Warehouse Access** | Must grant separately |


---


## Step 4.2: Grant Database Access to Roles

## Database Access Summary

### Core Role Access (Already Configured)

| Role | Database Access | Warehouse Access |
|------|-----------------|------------------|
| `PAYMENTS_CORE_DEV_READ` | DB_R (all zones) | All warehouses |
| `PAYMENTS_CORE_DEV_WRITE` | DB_W (all zones) | All warehouses |
| `PAYMENTS_CORE_DEV_CREATE` | DB_C (all zones) | All warehouses |
| `PAYMENTS_CORE_DEV_ADMIN` | Full ownership | All warehouses |

### Custom Role Access Status

| Role | Data Access | Warehouse Access |
|------|-------------|------------------|
| `PAYMENTS_CORE_DEV_CUSTOM_DEVELOPER` | raw, curated, analytics | **Needs Grant** |

Custom roles require explicit warehouse grants to execute queries.

### Available Warehouse Access Roles
| `PAYMENTS_CORE_DEV_WH_U_LOAD` | USAGE on `PAYMENTS_CORE_DEV_WH_LOAD` |
| `PAYMENTS_CORE_DEV_WH_U_TRANSFORM` | USAGE on `PAYMENTS_CORE_DEV_WH_TRANSFORM` |

### Grant Warehouse Access to Custom Roles

To grant warehouse access to a custom role:

```sql
USE ROLE PAYMENTS_CORE_DEV_RBAC;
GRANT ROLE PAYMENTS_CORE_DEV_WH_U_<warehouse> TO ROLE PAYMENTS_CORE_DEV_CUSTOM_<name>;
```


---


# Task 5: Data Product Cost Management

**Summary:** Establish cost controls for your data product through Snowflake resource monitors that track credit consumption and can trigger alerts or suspend warehouses when thresholds are reached.

**Prerequisites:**
- **Personas:** FinOps Team, Platform Administrator
- **Role Requirements:** ACCOUNTADMIN role access (required for resource monitors)
- **External Requirements:** Warehouses created (Task 3), Understanding of expected credit consumption

<details>
<summary>Task Overview (click to expand)</summary>

# Data Product Cost Management

## Summary
Establish cost controls for your data product through Snowflake resource monitors
that track credit consumption and can trigger alerts or suspend warehouses when
thresholds are reached.

## External Requirements
- Warehouses created (Task 3)
- Understanding of expected credit consumption

## Personas
- FinOps Team
- Platform Administrator

## Role Requirements
- ACCOUNTADMIN role access (required for resource monitors)

## Details
## **Understanding Snowflake Credits**

Snowflake uses **consumption-based pricing**. You pay for:

| Resource | How It's Measured | Typical Cost |
|----------|-------------------|--------------|
| **Compute** | Credits per hour of warehouse runtime | Varies by contract |
| **Storage** | $ per TB per month | ~$20-40/TB/month |

**Credits** are the billing unit for compute. Credit consumption depends on warehouse size:

| Warehouse Size | Credits per Hour |
|----------------|------------------|
| X-Small | 1 |
| Small | 2 |
| Medium | 4 |
| Large | 8 |
| X-Large | 16 |

## **Why Cost Management?**

Data products can consume significant compute resources, especially during:
- Initial data loads and transformations
- Ad-hoc analytics queries
- Runaway queries or inefficient code
- Unexpected usage spikes

Resource monitors provide:
- **Visibility**: Track credit consumption per warehouse
- **Alerts**: Notify stakeholders before budgets are exceeded
- **Controls**: Automatically suspend warehouses at defined thresholds
- **Accountability**: Enable chargeback and cost allocation

## **Steps in This Task**

| Step | Title | Purpose |
|------|-------|---------|
| 5.1 | Create Resource Monitors | Define monitors with credit quotas |
| 5.2 | Assign Monitors to Warehouses | Attach monitors to data product warehouses |
| 5.3 | Configure Alert Notifications | Set up notification integrations for alerts |

## **Key Concepts**

**Resource Monitor Components**

| Component | Description |
|-----------|-------------|
| Credit Quota | Credit allowance for the period |
| Frequency | Reset interval (MONTHLY, WEEKLY, DAILY, NEVER) |
| Start Timestamp | When monitoring begins |
| Triggers | Actions at percentage thresholds |

**Trigger Actions**

| Action | Behavior | When to Use |
|--------|----------|-------------|
| NOTIFY | Send alert only | Early warning (50%, 75%) |
| SUSPEND | Stop warehouse, finish running queries | Soft limit (90%) |
| SUSPEND_IMMEDIATE | Stop warehouse, cancel all queries | Hard limit (100%) |

## **Estimating Credit Needs**

| Warehouse Size | Light Usage | Moderate Usage | Heavy Usage |
|----------------|-------------|----------------|-------------|
| X-Small | 10-30 credits/month | 30-100 | 100-300 |
| Small | 20-60 | 60-200 | 200-600 |
| Medium | 40-120 | 120-400 | 400-1200 |

Start conservative and adjust based on actual usage.

## **What You'll Create**

| Object Type | Naming Pattern | Owner | Purpose |
|-------------|----------------|-------|---------|
| Resource Monitors | `<prefix>_MONITOR` | `ACCOUNTADMIN` | Credit tracking |
| Notification Integration | `<prefix>_ALERTS` | `ACCOUNTADMIN` | Alert delivery |

**Note:** Resource monitors require ACCOUNTADMIN privileges.

## **More Information**

* [Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors)
* [CREATE RESOURCE MONITOR](https://docs.snowflake.com/en/sql-reference/sql/create-resource-monitor)
* [Notification Integrations](https://docs.snowflake.com/en/user-guide/notification-integrations)

</details>

---


## Step 5.1: Create Resource Monitors

## Resource Monitor Configuration

### Monitor Details

| Property | Value |
|----------|-------|
| **Name** | `PAYMENTS_CORE_DEV_MONITOR` |
| **Credit Quota** | 400 credits |
| **Frequency** | MONTHLY |
| **Start Time** | Immediately |

### Notification Thresholds

| Level | Threshold | Action |
|-------|-----------|--------|
| Warning | 50% | Notify |
| Alert | 75% | Notify |
| Critical | 90% | Notify |
| Limit | 100% | Suspend |

### Credit Consumption Estimate

Based on configured warehouses:

| Warehouse | Size | Max Credits/Hour | Max Credits/MONTHLY |
|-----------|------|------------------|---------------------------------------------|
| `PAYMENTS_CORE_DEV_WH_LOAD` | XSMALL | 1 | 720 |
| `PAYMENTS_CORE_DEV_WH_TRANSFORM` | XSMALL | 2 | 1440 |

### Warehouses to Monitor

The resource monitor will be assigned to:
- `PAYMENTS_CORE_DEV_WH_LOAD`
- `PAYMENTS_CORE_DEV_WH_TRANSFORM`


---


## Step 5.2: Assign Monitors to Warehouses

## Resource Monitor Assignment

### Monitor Assignment Summary

| Warehouse | Resource Monitor |
|-----------|------------------|
| `PAYMENTS_CORE_DEV_WH_LOAD` | `PAYMENTS_CORE_DEV_MONITOR` |
| `PAYMENTS_CORE_DEV_WH_TRANSFORM` | `PAYMENTS_CORE_DEV_MONITOR` |

### Quota Distribution

**Shared Quota:** 400 credits (MONTHLY)

All 2 warehouse(s) share this quota. Credit consumption is aggregated across all assigned warehouses.

### Credit Allocation

| Warehouse | Est. Credits/Hour | Recommended Max Usage |
|-----------|-------------------|----------------------|
| `PAYMENTS_CORE_DEV_WH_LOAD` | 1 | 200 |
| `PAYMENTS_CORE_DEV_WH_TRANSFORM` | 2 | 200 |

### After Assignment

Once assigned, the resource monitor will:
1. Track credit consumption from all assigned warehouses
2. Send notifications at 50%, 75%, and 90% thresholds
3. Suspend warehouses at 100% consumption


---


## Step 5.3: Configure Alert Notifications

## Alert Notification Configuration

### Notification Integration

| Property | Value |
|----------|-------|
| **Name** | `PAYMENTS_CORE_DEV_NOTIFY_EMAIL` |
| **Type** | Email |
| **Recipient** | `alex@fintechcorp.com` |

### Alert Configuration

| Property | Value |
|----------|-------|
| **Alert Name** | `RESOURCE_MONITOR_ALERT` |
| **Location** | `PAYMENTS_CORE_DEV_RAW.ALERTS` |
| **Schedule** | Every hour |
| **Warehouse** | `PAYMENTS_CORE_DEV_WH_LOAD` |
| **Condition** | Resource monitor >= 75% usage |

### Alert Triggers

When the resource monitor crosses these thresholds, you'll receive notifications:

| Threshold | Action | Via |
|-----------|--------|-----|
| 50% | Notify | Built-in (account admins) |
| 75% | Notify | Built-in + Custom alert |
| 90% | Notify | Built-in (account admins) |
| 100% | Suspend | Warehouses suspended |

---

## 🎉 Data Product Deployment Complete!

Your **core** data product is now fully configured:

| Component | Status |
|-----------|--------|
| Core Roles | ✅ Created |
| Databases | ✅ 3 zone(s) |
| Schemas | ✅ Configured per zone |
| Warehouses | ✅ 2 warehouse(s) |
| Resource Monitor | ✅ 400 credits/MONTHLY |
| Notifications | ✅ alex@fintechcorp.com |


---
