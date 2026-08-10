-- ============================================================
-- RENDERED JOURNEY: Data Product Setup
-- Generated: 2026-08-10 14:43:07
-- Blueprint: data-product-setup
-- Language: sql
-- ============================================================


-- ============================================================================
-- TASK 1: Data Product Planning
-- Summary: Select the target Snowflake account for deployment, define the data product's name, domain, environment, and SCIM configuration, plan zone structure and schemas, and define warehouse requirements for different workloads.
-- Personas: Data Team, Platform Team, Data Architecture Team
-- Role Requirements: SYSADMIN role access in the target account
-- External Requirements: Platform Foundation Setup completed, Target account exists and is accessible
-- ============================================================================


-- ------------------------------------------------------------
-- Step 1.1: Select Target Account
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"select-target-account"}';

-- ============================================================================
-- TARGET ACCOUNT SELECTION
-- ============================================================================
-- Account Strategy: Single Account
-- Target Account: FINTECHCORP
-- ============================================================================
-- This step captures target account information for planning purposes.
-- No SQL is executed in this step.
-- ============================================================================

/*
TARGET ACCOUNT SELECTED
=======================

Account: FINTECHCORP
Strategy: Single Account

NEXT STEPS:
1. Ensure you can connect to FINTECHCORP
2. Verify SYSADMIN role access
3. Proceed to Define Data Product Identity (Step 1.2)

CONNECTION VERIFICATION (run in target account):
*/

-- Verify account access (run this in FINTECHCORP)
SELECT CURRENT_ACCOUNT() AS current_account,
       CURRENT_ROLE() AS current_role,
       CURRENT_USER() AS current_user;

-- Verify SYSADMIN access
USE ROLE SYSADMIN;
SELECT 'SYSADMIN access verified' AS status;


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.2: Define Data Product Identity
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"define-data-product-identity"}';

-- ============================================================================
-- DATA PRODUCT IDENTITY
-- ============================================================================
-- Data Product: core
-- Domain: payments
-- Environment: prod
-- SCIM Prefix: OKTA
-- Account Strategy: Single Account
-- ============================================================================
-- This step captures identity information for planning purposes.
-- No SQL is executed in this step.
-- ============================================================================

/*
DATA PRODUCT IDENTITY DEFINED
=============================

Core Identity:
- Name: core
- Domain: payments
- Environment: prod
- Description: Core payments data product. Card transactions, bank transfers, settlements and the merchant and customer records they reference. Serves regulatory reporting, settlement reconciliation, and fraud and risk modelling.

SCIM Configuration:
- SCIM Enabled: Yes
- SCIM Prefix: OKTA
- Role Owner: OKTA_PROVISIONER
- User Assignment: Via identity provider groups

Naming Components (based on Single Account):
- Full pattern: <domain>_<dataproduct>_<zone>_<env>
- Example: PAYMENTS_CORE_RAW_PROD

Core Roles to be Created:
- CORE_ADMIN  (owns infrastructure)
- CORE_CREATE (creates objects)
- CORE_WRITE  (modifies data)
- CORE_RBAC   (owns access roles)
- CORE_READ   (read-only access)

Cost Allocation Tags:
- DOMAIN = 'PAYMENTS'
- ENVIRONMENT = 'PROD'
- DATAPRODUCT = 'CORE'
*/

-- ============================================================================
-- VERIFICATION: Check SCIM Configuration (optional)
-- ============================================================================
-- Run these queries to verify your SCIM setup before proceeding

-- Verify SCIM provisioner role exists
SHOW ROLES LIKE 'OKTA_PROVISIONER';

-- Check SCIM security integration
SHOW SECURITY INTEGRATIONS LIKE '%OKTA%';


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.3: Configure Zone Structure
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"configure-zone-structure"}';

-- ============================================================================
-- ZONE STRUCTURE CONFIGURATION
-- ============================================================================
-- Data Product: core
-- Zones: RAW, CURATED, ANALYTICS
-- ============================================================================
-- This step captures zone structure for planning purposes.
-- Databases are created in Task 2, Step 2.2.
-- ============================================================================

/*
ZONE STRUCTURE DEFINED
======================

Data Product: core
Number of Zones: 3

Databases to be Created:
- PAYMENTS_CORE_RAW_PROD
- PAYMENTS_CORE_CURATED_PROD
- PAYMENTS_CORE_ANALYTICS_PROD

Zone Details:
1. RAW
   - Purpose: Untransformed source data from the payment gateway, card networks, core banking and the merchant portal. Restricted access - contains unmasked cardholder and bank account data.
   - Time Travel: 30 days
   - Database Roles: DB_R, DB_W, DB_C
2. CURATED
   - Purpose: Conformed, deduplicated and masked payment entities. The system of record for downstream consumers.
   - Time Travel: 30 days
   - Database Roles: DB_R, DB_W, DB_C
3. ANALYTICS
   - Purpose: Aggregates, reporting models and feature tables for risk and fraud modelling.
   - Time Travel: 30 days
   - Database Roles: DB_R, DB_W, DB_C

Tags Applied to Each Database:
- DOMAIN = 'PAYMENTS'
- ENVIRONMENT = 'PROD'
- DATAPRODUCT = 'CORE'
- ZONE = '<zone_name>'
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.4: Plan Schema Organization
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"plan-schema-organization"}';

-- ============================================================================
-- SCHEMA ORGANIZATION PLANNING
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- This step captures schema structure for planning purposes.
-- Schemas are created in Task 2, Step 2.3.
-- ============================================================================

/*
SCHEMA ORGANIZATION DEFINED
===========================

Data Product: core

RAW Zone Schemas:
  - CARD_TRANSACTIONS
    - SC_R_CARD_TRANSACTIONS (Read)
    - SC_W_CARD_TRANSACTIONS (Write)
    - SC_C_CARD_TRANSACTIONS (Create)
  - BANK_TRANSFERS
    - SC_R_BANK_TRANSFERS (Read)
    - SC_W_BANK_TRANSFERS (Write)
    - SC_C_BANK_TRANSFERS (Create)
  - MERCHANTS
    - SC_R_MERCHANTS (Read)
    - SC_W_MERCHANTS (Write)
    - SC_C_MERCHANTS (Create)
  - CUSTOMERS
    - SC_R_CUSTOMERS (Read)
    - SC_W_CUSTOMERS (Write)
    - SC_C_CUSTOMERS (Create)
  - LEDGER_ENTRIES
    - SC_R_LEDGER_ENTRIES (Read)
    - SC_W_LEDGER_ENTRIES (Write)
    - SC_C_LEDGER_ENTRIES (Create)
  - GATEWAY_EVENTS
    - SC_R_GATEWAY_EVENTS (Read)
    - SC_W_GATEWAY_EVENTS (Write)
    - SC_C_GATEWAY_EVENTS (Create)

CURATED Zone Schemas:
  - TRANSACTIONS
    - SC_R_TRANSACTIONS (Read)
    - SC_W_TRANSACTIONS (Write)
    - SC_C_TRANSACTIONS (Create)
  - SETTLEMENTS
    - SC_R_SETTLEMENTS (Read)
    - SC_W_SETTLEMENTS (Write)
    - SC_C_SETTLEMENTS (Create)
  - MERCHANTS
    - SC_R_MERCHANTS (Read)
    - SC_W_MERCHANTS (Write)
    - SC_C_MERCHANTS (Create)
  - CUSTOMERS
    - SC_R_CUSTOMERS (Read)
    - SC_W_CUSTOMERS (Write)
    - SC_C_CUSTOMERS (Create)
  - CHARGEBACKS
    - SC_R_CHARGEBACKS (Read)
    - SC_W_CHARGEBACKS (Write)
    - SC_C_CHARGEBACKS (Create)
  - LEDGER
    - SC_R_LEDGER (Read)
    - SC_W_LEDGER (Write)
    - SC_C_LEDGER (Create)

ANALYTICS Zone Schemas:
  - REVENUE
    - SC_R_REVENUE (Read)
    - SC_W_REVENUE (Write)
    - SC_C_REVENUE (Create)
  - SETTLEMENT_RECONCILIATION
    - SC_R_SETTLEMENT_RECONCILIATION (Read)
    - SC_W_SETTLEMENT_RECONCILIATION (Write)
    - SC_C_SETTLEMENT_RECONCILIATION (Create)
  - FRAUD_FEATURES
    - SC_R_FRAUD_FEATURES (Read)
    - SC_W_FRAUD_FEATURES (Write)
    - SC_C_FRAUD_FEATURES (Create)
  - MERCHANT_PERFORMANCE
    - SC_R_MERCHANT_PERFORMANCE (Read)
    - SC_W_MERCHANT_PERFORMANCE (Write)
    - SC_C_MERCHANT_PERFORMANCE (Create)
  - REGULATORY_REPORTING
    - SC_R_REGULATORY_REPORTING (Read)
    - SC_W_REGULATORY_REPORTING (Write)
    - SC_C_REGULATORY_REPORTING (Create)

Schema Properties:
- All schemas: WITH MANAGED ACCESS
- Schema owner: CORE_ADMIN
- Access role owner: CORE_RBAC

Database Role Hierarchy:
- SC_R_* (Schema Read) → DB_R (Database Read)
- SC_W_* (Schema Write) → DB_W (Database Write)
- SC_C_* (Schema Create) → DB_C (Database Create)

Account Role Connections:
- DB_R → CORE_READ
- DB_W → CORE_WRITE
- DB_C → CORE_CREATE
*/

-- ============================================================================
-- PREVIEW: Schema Creation SQL (generated in Step 2.3)
-- ============================================================================

/*
Example schema creation pattern:

USE ROLE IDENTIFIER($afrAdmin);
USE DATABASE IDENTIFIER($dbNm);

-- Create schema with managed access
CREATE SCHEMA IF NOT EXISTS IDENTIFIER($scNm) WITH MANAGED ACCESS;

-- Create schema access roles
CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($sarR);  -- SC_R_<schema>
CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($sarW);  -- SC_W_<schema>
CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($sarC);  -- SC_C_<schema>

-- Grant privileges to schema roles
GRANT USAGE ON SCHEMA <schema> TO DATABASE ROLE SC_R_<schema>;
GRANT SELECT ON ALL TABLES IN SCHEMA <schema> TO DATABASE ROLE SC_R_<schema>;
GRANT SELECT ON FUTURE TABLES IN SCHEMA <schema> TO DATABASE ROLE SC_R_<schema>;
-- ... additional grants per role

-- Establish role hierarchy
GRANT DATABASE ROLE SC_R_<schema> TO DATABASE ROLE SC_W_<schema>;
GRANT DATABASE ROLE SC_W_<schema> TO DATABASE ROLE SC_C_<schema>;

-- Roll up to database level
GRANT DATABASE ROLE SC_R_<schema> TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_<schema> TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_<schema> TO DATABASE ROLE DB_C;

-- Transfer ownership to RBAC role
GRANT OWNERSHIP ON DATABASE ROLE SC_R_<schema> TO ROLE CORE_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_<schema> TO ROLE CORE_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_<schema> TO ROLE CORE_RBAC COPY CURRENT GRANTS;
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.5: Plan Warehouse Requirements
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"plan-warehouse-requirements"}';

-- ============================================================================
-- WAREHOUSE REQUIREMENTS PLANNING
-- ============================================================================
-- Data Product: core
-- Number of Warehouses: 4
-- ============================================================================
-- This step captures warehouse requirements for planning purposes.
-- Warehouses are created in Task 3, Step 3.1.
-- ============================================================================

/*
WAREHOUSE REQUIREMENTS DEFINED
==============================

Data Product: core

Warehouses to be Created:

1. PAYMENTS_CORE_PROD_LOAD
   - Workload: LOAD
   - Size: SMALL
   - Query Timeout: 60 minutes
   - Comment: Ingestion warehouse for payments core prod. Short auto-suspend because loads are bursty.
   - Access Role: _WH_U_PAYMENTS_CORE_PROD_LOAD

2. PAYMENTS_CORE_PROD_TRANSFORM
   - Workload: TRANSFORM
   - Size: MEDIUM
   - Query Timeout: 120 minutes
   - Comment: Scheduled transformation warehouse for payments core prod.
   - Access Role: _WH_U_PAYMENTS_CORE_PROD_TRANSFORM

3. PAYMENTS_CORE_PROD_REPORT
   - Workload: REPORT
   - Size: SMALL
   - Query Timeout: 30 minutes
   - Comment: BI and ad hoc query warehouse for the analytics team. Multi-cluster for concurrency, short timeout to catch runaway queries.
   - Access Role: _WH_U_PAYMENTS_CORE_PROD_REPORT

4. PAYMENTS_CORE_PROD_SCIENCE
   - Workload: SCIENCE
   - Size: LARGE
   - Query Timeout: 240 minutes
   - Comment: Feature engineering and model training warehouse for the data science team.
   - Access Role: _WH_U_PAYMENTS_CORE_PROD_SCIENCE

Warehouse Properties:
- Auto Suspend: 60 seconds
- Auto Resume: TRUE
- Initially Suspended: TRUE
- Owner: CORE_ADMIN
- Access Role Owner: CORE_RBAC

Tags Applied:
- DOMAIN = 'PAYMENTS'
- ENVIRONMENT = 'PROD'
- DATAPRODUCT = 'CORE'
- WORKLOAD = '<workload_type>'
*/

-- ============================================================================
-- PREVIEW: Warehouse Creation SQL (generated in Step 3.1)
-- ============================================================================

/*
Example warehouse creation pattern:

USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($whNm) WITH
  WAREHOUSE_SIZE                = $whSize
  INITIALLY_SUSPENDED           = TRUE
  AUTO_RESUME                   = TRUE
  AUTO_SUSPEND                  = 60
  STATEMENT_TIMEOUT_IN_SECONDS  = $queryTimeoutSec
  WITH TAG (IDENTIFIER($dpDomainTag) = $beNm) 
  COMMENT                       = $whComment;

-- Transfer ownership to delegated admin
GRANT OWNERSHIP ON WAREHOUSE IDENTIFIER($whNm) TO ROLE IDENTIFIER($afrAdmin);

-- Create warehouse access role
USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS IDENTIFIER($warU) WITH TAG (IDENTIFIER($dpDomainTag) = $beNm);

-- Grant warehouse privileges to access role
USE ROLE SECURITYADMIN;
GRANT MONITOR, USAGE ON WAREHOUSE IDENTIFIER($whNm) TO ROLE IDENTIFIER($warU);

-- Transfer ownership of access role to RBAC admin
GRANT OWNERSHIP ON ROLE IDENTIFIER($warU) TO ROLE IDENTIFIER($afrRbac) COPY CURRENT GRANTS;
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 2: Core Roles & Database Setup
-- Summary: Create the foundational infrastructure for your data product including five core account-level roles, databases for each zone with database-level access roles, schemas with schema-level access roles, and complete role hierarchy.
-- Personas: Platform Administrator, Data Architect, Security Administrator
-- Role Requirements: USERADMIN role, SYSADMIN role, SECURITYADMIN role
-- External Requirements: Task 1 (Data Product Planning) completed, Target account accessible, data_product_name, data_product_domain, data_product_environment from Task 1, scim_prefix, data_zones, schema_configuration from Task 1
-- ============================================================================


-- ------------------------------------------------------------
-- Step 2.1: Create Data Product Core Roles
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-data-product-core-roles"}';

-- ============================================================================
-- CREATE DATA PRODUCT CORE ROLES
-- ============================================================================
-- Data Product: core
-- Domain: payments
-- Environment: prod
-- SCIM Prefix: OKTA
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: USERADMIN
-- ============================================================================

-- Derive the role owner based on SCIM configuration

-- Derive the data product prefix for object names

-- Get the domain tag reference

USE ROLE USERADMIN;

-- ============================================================================
-- STEP 1: CREATE CORE ACCOUNT ROLES
-- ============================================================================
-- These roles provide the functional hierarchy for the data product.
-- Role naming follows the pattern: <prefix>_<function>

-- ADMIN Role - Full administrative control
-- Owns all infrastructure: databases, schemas, warehouses
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_ADMIN
  WITH TAG (INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS')
  COMMENT = 'Admin role for core data product - owns infrastructure';

-- CREATE Role - Object creation and delegated administration
-- Can create objects and manage grants within the data product
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_CREATE
  WITH TAG (INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS')
  COMMENT = 'Create role for core data product - creates objects';

-- WRITE Role - Data modification privileges
-- Can execute DML (INSERT, UPDATE, DELETE) on all objects
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_WRITE
  WITH TAG (INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS')
  COMMENT = 'Write role for core data product - modifies data';

-- RBAC Role - Access role ownership
-- Owns database access roles for delegated governance
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_RBAC
  WITH TAG (INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS')
  COMMENT = 'RBAC role for core data product - owns access roles';

-- READ Role - Read-only access
-- Can query all data in the data product
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_READ
  WITH TAG (INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS')
  COMMENT = 'Read role for core data product - read-only access';

-- ============================================================================
-- STEP 2: TRANSFER OWNERSHIP TO SCIM/USERADMIN
-- ============================================================================
-- Ownership transfer enables identity provider management (SCIM) or 
-- standard Snowflake administration (USERADMIN)

GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_ADMIN  TO ROLE OKTA_PROVISIONER COPY CURRENT GRANTS;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_CREATE TO ROLE OKTA_PROVISIONER COPY CURRENT GRANTS;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_WRITE  TO ROLE OKTA_PROVISIONER COPY CURRENT GRANTS;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_RBAC   TO ROLE OKTA_PROVISIONER COPY CURRENT GRANTS;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_READ   TO ROLE OKTA_PROVISIONER COPY CURRENT GRANTS;

-- ============================================================================
-- STEP 3: ESTABLISH ROLE HIERARCHY
-- ============================================================================
-- CREATE and RBAC roles roll up to ADMIN
-- ADMIN rolls up to SYSADMIN for central administration

-- CREATE role inherits to ADMIN
GRANT ROLE PAYMENTS_CORE_PROD_CREATE TO ROLE PAYMENTS_CORE_PROD_ADMIN;

-- RBAC role inherits to ADMIN
GRANT ROLE PAYMENTS_CORE_PROD_RBAC TO ROLE PAYMENTS_CORE_PROD_ADMIN;

-- ADMIN role inherits to SYSADMIN (central administration)
GRANT ROLE PAYMENTS_CORE_PROD_ADMIN TO ROLE SYSADMIN;

-- ============================================================================
-- STEP 4: GRANT ACCOUNT ACCESS ROLES TO CREATE ROLE
-- ============================================================================
-- These roles provide account-level privileges needed for data product operations.
-- Note: These roles must exist in the account (created in Account Creation workflow)

-- Grant account access roles to CREATE role
-- If roles don't exist, these statements will fail - that's expected if 
-- account access roles weren't created in this account

GRANT ROLE _AR_EXEC_TASK TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE _AR_VIEW_AUSG TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE _AR_APPLY_DDM TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE _AR_APPLY_RAP TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE _AR_APPLY_TAG TO ROLE PAYMENTS_CORE_PROD_CREATE;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show created roles
SHOW ROLES LIKE '%PAYMENTS_CORE_PROD%';

-- Verify role hierarchy
SHOW GRANTS OF ROLE PAYMENTS_CORE_PROD_ADMIN;
SHOW GRANTS OF ROLE PAYMENTS_CORE_PROD_CREATE;
SHOW GRANTS OF ROLE PAYMENTS_CORE_PROD_RBAC;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_ADMIN;

/*
CORE ROLES CREATED
==================

Roles created for core data product:

1. PAYMENTS_CORE_PROD_ADMIN
   - Purpose: Owns infrastructure (databases, schemas, warehouses)
   - Inherits: CREATE, RBAC roles
   - Granted to: SYSADMIN

2. PAYMENTS_CORE_PROD_CREATE
   - Purpose: Creates objects, manages grants
   - Receives: _AR_EXEC_TASK, _AR_VIEW_AUSG, _AR_APPLY_DDM, _AR_APPLY_RAP, _AR_APPLY_TAG
   - Granted to: ADMIN

3. PAYMENTS_CORE_PROD_WRITE
   - Purpose: Modifies data (DML operations)
   - Granted to: (connected in later steps via database roles)

4. PAYMENTS_CORE_PROD_RBAC
   - Purpose: Owns database access roles
   - Granted to: ADMIN

5. PAYMENTS_CORE_PROD_READ
   - Purpose: Read-only access
   - Granted to: (connected in later steps via database roles)

Role Owner: OKTA_PROVISIONER
SCIM Management: Enabled (OKTA)

NEXT STEPS:
- Step 2.2: Create Databases (with DB_R, DB_W, DB_C database roles)
- Step 2.3: Create Schemas (with SC_R, SC_W, SC_C database roles)
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.2: Create Databases
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-databases"}';

-- ============================================================================
-- CREATE DATABASES
-- ============================================================================
-- Data Product: core
-- Zones: RAW, CURATED, ANALYTICS
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: SYSADMIN (for database creation)
-- ============================================================================

-- Derive the data product prefix for object names

-- Tag references

-- ============================================================================
-- CREATE DATABASES FOR EACH ZONE
-- ============================================================================


-- ----------------------------------------------------------------------------
-- DATABASE: PAYMENTS_CORE_PROD_RAW
-- Zone: RAW
-- Time Travel: 30 days
-- ----------------------------------------------------------------------------

-- Step 1: Create database as SYSADMIN
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS PAYMENTS_CORE_PROD_RAW
  DATA_RETENTION_TIME_IN_DAYS = 30
  WITH TAG (
    INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS',
    INFRA.GOVERNANCE.ENVIRONMENT = 'PROD',
    INFRA.GOVERNANCE.DATAPRODUCT = 'CORE',
    INFRA.GOVERNANCE.ZONE = 'RAW'
  )
  COMMENT = 'core data product - RAW zone (Untransformed source data from the payment gateway, card networks, core banking and the merchant portal. Restricted access - contains unmasked cardholder and bank account data.)';

-- Remove default PUBLIC schema (not needed)
DROP SCHEMA IF EXISTS PAYMENTS_CORE_PROD_RAW.PUBLIC;

-- Step 2: Transfer ownership to delegated admin
GRANT OWNERSHIP ON DATABASE PAYMENTS_CORE_PROD_RAW TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;

-- Step 3: Create database-level access roles (as database owner)
USE ROLE PAYMENTS_CORE_PROD_ADMIN;
USE DATABASE PAYMENTS_CORE_PROD_RAW;

-- Database Read Role
CREATE DATABASE ROLE IF NOT EXISTS DB_R
  COMMENT = 'Database read access for PAYMENTS_CORE_PROD_RAW';

-- Database Write Role  
CREATE DATABASE ROLE IF NOT EXISTS DB_W
  COMMENT = 'Database write access for PAYMENTS_CORE_PROD_RAW';

-- Database Create Role
CREATE DATABASE ROLE IF NOT EXISTS DB_C
  COMMENT = 'Database create access for PAYMENTS_CORE_PROD_RAW';

-- Step 4: Transfer database role ownership to RBAC role
-- Note: Database role hierarchy (DB_C ← DB_W ← DB_R) is NOT established here.
-- Inheritance is handled at the schema level (SC_C ← SC_W ← SC_R), which then
-- rolls up to the database roles, avoiding redundant privilege chains.
GRANT OWNERSHIP ON DATABASE ROLE DB_R TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE DB_W TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE DB_C TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Step 5: Grant database roles to account roles
-- This connects account-level roles to database-level access
GRANT DATABASE ROLE DB_R TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT DATABASE ROLE DB_W TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT DATABASE ROLE DB_C TO ROLE PAYMENTS_CORE_PROD_CREATE;



-- ----------------------------------------------------------------------------
-- DATABASE: PAYMENTS_CORE_PROD_CURATED
-- Zone: CURATED
-- Time Travel: 30 days
-- ----------------------------------------------------------------------------

-- Step 1: Create database as SYSADMIN
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS PAYMENTS_CORE_PROD_CURATED
  DATA_RETENTION_TIME_IN_DAYS = 30
  WITH TAG (
    INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS',
    INFRA.GOVERNANCE.ENVIRONMENT = 'PROD',
    INFRA.GOVERNANCE.DATAPRODUCT = 'CORE',
    INFRA.GOVERNANCE.ZONE = 'CURATED'
  )
  COMMENT = 'core data product - CURATED zone (Conformed, deduplicated and masked payment entities. The system of record for downstream consumers.)';

-- Remove default PUBLIC schema (not needed)
DROP SCHEMA IF EXISTS PAYMENTS_CORE_PROD_CURATED.PUBLIC;

-- Step 2: Transfer ownership to delegated admin
GRANT OWNERSHIP ON DATABASE PAYMENTS_CORE_PROD_CURATED TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;

-- Step 3: Create database-level access roles (as database owner)
USE ROLE PAYMENTS_CORE_PROD_ADMIN;
USE DATABASE PAYMENTS_CORE_PROD_CURATED;

-- Database Read Role
CREATE DATABASE ROLE IF NOT EXISTS DB_R
  COMMENT = 'Database read access for PAYMENTS_CORE_PROD_CURATED';

-- Database Write Role  
CREATE DATABASE ROLE IF NOT EXISTS DB_W
  COMMENT = 'Database write access for PAYMENTS_CORE_PROD_CURATED';

-- Database Create Role
CREATE DATABASE ROLE IF NOT EXISTS DB_C
  COMMENT = 'Database create access for PAYMENTS_CORE_PROD_CURATED';

-- Step 4: Transfer database role ownership to RBAC role
-- Note: Database role hierarchy (DB_C ← DB_W ← DB_R) is NOT established here.
-- Inheritance is handled at the schema level (SC_C ← SC_W ← SC_R), which then
-- rolls up to the database roles, avoiding redundant privilege chains.
GRANT OWNERSHIP ON DATABASE ROLE DB_R TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE DB_W TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE DB_C TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Step 5: Grant database roles to account roles
-- This connects account-level roles to database-level access
GRANT DATABASE ROLE DB_R TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT DATABASE ROLE DB_W TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT DATABASE ROLE DB_C TO ROLE PAYMENTS_CORE_PROD_CREATE;



-- ----------------------------------------------------------------------------
-- DATABASE: PAYMENTS_CORE_PROD_ANALYTICS
-- Zone: ANALYTICS
-- Time Travel: 30 days
-- ----------------------------------------------------------------------------

-- Step 1: Create database as SYSADMIN
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS PAYMENTS_CORE_PROD_ANALYTICS
  DATA_RETENTION_TIME_IN_DAYS = 30
  WITH TAG (
    INFRA.GOVERNANCE.DOMAIN = 'PAYMENTS',
    INFRA.GOVERNANCE.ENVIRONMENT = 'PROD',
    INFRA.GOVERNANCE.DATAPRODUCT = 'CORE',
    INFRA.GOVERNANCE.ZONE = 'ANALYTICS'
  )
  COMMENT = 'core data product - ANALYTICS zone (Aggregates, reporting models and feature tables for risk and fraud modelling.)';

-- Remove default PUBLIC schema (not needed)
DROP SCHEMA IF EXISTS PAYMENTS_CORE_PROD_ANALYTICS.PUBLIC;

-- Step 2: Transfer ownership to delegated admin
GRANT OWNERSHIP ON DATABASE PAYMENTS_CORE_PROD_ANALYTICS TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;

-- Step 3: Create database-level access roles (as database owner)
USE ROLE PAYMENTS_CORE_PROD_ADMIN;
USE DATABASE PAYMENTS_CORE_PROD_ANALYTICS;

-- Database Read Role
CREATE DATABASE ROLE IF NOT EXISTS DB_R
  COMMENT = 'Database read access for PAYMENTS_CORE_PROD_ANALYTICS';

-- Database Write Role  
CREATE DATABASE ROLE IF NOT EXISTS DB_W
  COMMENT = 'Database write access for PAYMENTS_CORE_PROD_ANALYTICS';

-- Database Create Role
CREATE DATABASE ROLE IF NOT EXISTS DB_C
  COMMENT = 'Database create access for PAYMENTS_CORE_PROD_ANALYTICS';

-- Step 4: Transfer database role ownership to RBAC role
-- Note: Database role hierarchy (DB_C ← DB_W ← DB_R) is NOT established here.
-- Inheritance is handled at the schema level (SC_C ← SC_W ← SC_R), which then
-- rolls up to the database roles, avoiding redundant privilege chains.
GRANT OWNERSHIP ON DATABASE ROLE DB_R TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE DB_W TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE DB_C TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Step 5: Grant database roles to account roles
-- This connects account-level roles to database-level access
GRANT DATABASE ROLE DB_R TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT DATABASE ROLE DB_W TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT DATABASE ROLE DB_C TO ROLE PAYMENTS_CORE_PROD_CREATE;



-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show created databases
SHOW DATABASES LIKE '%PAYMENTS_CORE_PROD%';

-- Show database roles for each database

SHOW DATABASE ROLES IN DATABASE PAYMENTS_CORE_PROD_RAW;

SHOW DATABASE ROLES IN DATABASE PAYMENTS_CORE_PROD_CURATED;

SHOW DATABASE ROLES IN DATABASE PAYMENTS_CORE_PROD_ANALYTICS;


-- Verify database role grants

SELECT 
  'PAYMENTS_CORE_PROD_RAW' AS database_name,
  grantee_name,
  role AS granted_role
FROM TABLE(PAYMENTS_CORE_PROD_RAW.INFORMATION_SCHEMA.DATABASE_ROLE_GRANTS())
ORDER BY grantee_name;

SELECT 
  'PAYMENTS_CORE_PROD_CURATED' AS database_name,
  grantee_name,
  role AS granted_role
FROM TABLE(PAYMENTS_CORE_PROD_CURATED.INFORMATION_SCHEMA.DATABASE_ROLE_GRANTS())
ORDER BY grantee_name;

SELECT 
  'PAYMENTS_CORE_PROD_ANALYTICS' AS database_name,
  grantee_name,
  role AS granted_role
FROM TABLE(PAYMENTS_CORE_PROD_ANALYTICS.INFORMATION_SCHEMA.DATABASE_ROLE_GRANTS())
ORDER BY grantee_name;


/*
DATABASES CREATED
=================

Created 3 database(s) for core data product:

1. PAYMENTS_CORE_PROD_RAW
   - Zone: RAW
   - Purpose: Untransformed source data from the payment gateway, card networks, core banking and the merchant portal. Restricted access - contains unmasked cardholder and bank account data.
   - Time Travel: 30 days
   - Owner: PAYMENTS_CORE_PROD_ADMIN
   - Database Roles:
     - DB_R (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_READ)
     - DB_W (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_WRITE)
     - DB_C (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_CREATE)

2. PAYMENTS_CORE_PROD_CURATED
   - Zone: CURATED
   - Purpose: Conformed, deduplicated and masked payment entities. The system of record for downstream consumers.
   - Time Travel: 30 days
   - Owner: PAYMENTS_CORE_PROD_ADMIN
   - Database Roles:
     - DB_R (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_READ)
     - DB_W (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_WRITE)
     - DB_C (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_CREATE)

3. PAYMENTS_CORE_PROD_ANALYTICS
   - Zone: ANALYTICS
   - Purpose: Aggregates, reporting models and feature tables for risk and fraud modelling.
   - Time Travel: 30 days
   - Owner: PAYMENTS_CORE_PROD_ADMIN
   - Database Roles:
     - DB_R (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_READ)
     - DB_W (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_WRITE)
     - DB_C (owned by PAYMENTS_CORE_PROD_RBAC, granted to PAYMENTS_CORE_PROD_CREATE)

NEXT STEPS:
- Step 2.3: Create Schemas (with SC_R, SC_W, SC_C database roles)
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.3: Create Schemas
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-schemas"}';

-- ============================================================================
-- CREATE SCHEMAS
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: CORE_ADMIN (delegated admin)
-- ============================================================================

-- Derive the data product prefix for object names

-- Use the delegated admin role (owns the databases)
USE ROLE PAYMENTS_CORE_PROD_ADMIN;

-- ============================================================================
-- CREATE SCHEMAS FOR EACH ZONE
-- ============================================================================


-- ----------------------------------------------------------------------------
-- DATABASE: PAYMENTS_CORE_PROD_RAW (RAW Zone)
-- ----------------------------------------------------------------------------

USE DATABASE PAYMENTS_CORE_PROD_RAW;



-- ============================================================================
-- SCHEMA: CARD_TRANSACTIONS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS CARD_TRANSACTIONS WITH MANAGED ACCESS
  COMMENT = 'CARD_TRANSACTIONS schema in RAW zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_CARD_TRANSACTIONS
  COMMENT = 'Read access to CARD_TRANSACTIONS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_CARD_TRANSACTIONS
  COMMENT = 'Write access to CARD_TRANSACTIONS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_CARD_TRANSACTIONS
  COMMENT = 'Create access to CARD_TRANSACTIONS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_RAW TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_R_CARD_TRANSACTIONS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE VIEW ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE STREAM ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE FUNCTION ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE PROCEDURE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE SEQUENCE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE TASK ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE FILE FORMAT ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE STAGE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE PIPE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE STREAMLIT ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE ALERT ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE TAG ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE MASKING POLICY ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_CARD_TRANSACTIONS TO DATABASE ROLE SC_W_CARD_TRANSACTIONS;
GRANT DATABASE ROLE SC_W_CARD_TRANSACTIONS TO DATABASE ROLE SC_C_CARD_TRANSACTIONS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_CARD_TRANSACTIONS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_CARD_TRANSACTIONS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_CARD_TRANSACTIONS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_CARD_TRANSACTIONS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_CARD_TRANSACTIONS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_CARD_TRANSACTIONS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: BANK_TRANSFERS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS BANK_TRANSFERS WITH MANAGED ACCESS
  COMMENT = 'BANK_TRANSFERS schema in RAW zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_BANK_TRANSFERS
  COMMENT = 'Read access to BANK_TRANSFERS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_BANK_TRANSFERS
  COMMENT = 'Write access to BANK_TRANSFERS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_BANK_TRANSFERS
  COMMENT = 'Create access to BANK_TRANSFERS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_RAW TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_R_BANK_TRANSFERS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE VIEW ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE STREAM ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE FUNCTION ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE PROCEDURE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE SEQUENCE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE TASK ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE FILE FORMAT ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE STAGE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE PIPE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE STREAMLIT ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE ALERT ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE TAG ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE MASKING POLICY ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_BANK_TRANSFERS TO DATABASE ROLE SC_W_BANK_TRANSFERS;
GRANT DATABASE ROLE SC_W_BANK_TRANSFERS TO DATABASE ROLE SC_C_BANK_TRANSFERS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_BANK_TRANSFERS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_BANK_TRANSFERS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_BANK_TRANSFERS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_BANK_TRANSFERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_BANK_TRANSFERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_BANK_TRANSFERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: MERCHANTS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS MERCHANTS WITH MANAGED ACCESS
  COMMENT = 'MERCHANTS schema in RAW zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_MERCHANTS
  COMMENT = 'Read access to MERCHANTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_MERCHANTS
  COMMENT = 'Write access to MERCHANTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_MERCHANTS
  COMMENT = 'Create access to MERCHANTS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_RAW TO DATABASE ROLE SC_R_MERCHANTS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE VIEW ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE STREAM ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE FUNCTION ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE PROCEDURE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE SEQUENCE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE TASK ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE FILE FORMAT ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE STAGE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE PIPE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE STREAMLIT ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE ALERT ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE TAG ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE MASKING POLICY ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT DATABASE ROLE SC_W_MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_MERCHANTS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_MERCHANTS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_MERCHANTS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_MERCHANTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_MERCHANTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_MERCHANTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: CUSTOMERS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS CUSTOMERS WITH MANAGED ACCESS
  COMMENT = 'CUSTOMERS schema in RAW zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_CUSTOMERS
  COMMENT = 'Read access to CUSTOMERS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_CUSTOMERS
  COMMENT = 'Write access to CUSTOMERS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_CUSTOMERS
  COMMENT = 'Create access to CUSTOMERS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_RAW TO DATABASE ROLE SC_R_CUSTOMERS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE VIEW ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE STREAM ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE FUNCTION ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE PROCEDURE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE SEQUENCE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE TASK ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE FILE FORMAT ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE STAGE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE PIPE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE STREAMLIT ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE ALERT ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE TAG ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE MASKING POLICY ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT DATABASE ROLE SC_W_CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_CUSTOMERS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_CUSTOMERS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_CUSTOMERS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_CUSTOMERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_CUSTOMERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_CUSTOMERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: LEDGER_ENTRIES
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS LEDGER_ENTRIES WITH MANAGED ACCESS
  COMMENT = 'LEDGER_ENTRIES schema in RAW zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_LEDGER_ENTRIES
  COMMENT = 'Read access to LEDGER_ENTRIES schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_LEDGER_ENTRIES
  COMMENT = 'Write access to LEDGER_ENTRIES schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_LEDGER_ENTRIES
  COMMENT = 'Create access to LEDGER_ENTRIES schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_RAW TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT SELECT ON FUTURE TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_R_LEDGER_ENTRIES;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE VIEW ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE STREAM ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE FUNCTION ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE PROCEDURE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE SEQUENCE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE TASK ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE FILE FORMAT ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE STAGE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE EXTERNAL TABLE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE PIPE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE DYNAMIC TABLE ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE STREAMLIT ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE ALERT ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE TAG ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE MASKING POLICY ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_LEDGER_ENTRIES TO DATABASE ROLE SC_W_LEDGER_ENTRIES;
GRANT DATABASE ROLE SC_W_LEDGER_ENTRIES TO DATABASE ROLE SC_C_LEDGER_ENTRIES;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_LEDGER_ENTRIES TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_LEDGER_ENTRIES TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_LEDGER_ENTRIES TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_LEDGER_ENTRIES TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_LEDGER_ENTRIES TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_LEDGER_ENTRIES TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: GATEWAY_EVENTS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS GATEWAY_EVENTS WITH MANAGED ACCESS
  COMMENT = 'GATEWAY_EVENTS schema in RAW zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_GATEWAY_EVENTS
  COMMENT = 'Read access to GATEWAY_EVENTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_GATEWAY_EVENTS
  COMMENT = 'Write access to GATEWAY_EVENTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_GATEWAY_EVENTS
  COMMENT = 'Create access to GATEWAY_EVENTS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_RAW TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_R_GATEWAY_EVENTS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE VIEW ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE STREAM ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE FUNCTION ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE PROCEDURE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE SEQUENCE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE TASK ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE FILE FORMAT ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE STAGE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE PIPE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE STREAMLIT ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE ALERT ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE TAG ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE MASKING POLICY ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_GATEWAY_EVENTS TO DATABASE ROLE SC_W_GATEWAY_EVENTS;
GRANT DATABASE ROLE SC_W_GATEWAY_EVENTS TO DATABASE ROLE SC_C_GATEWAY_EVENTS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_GATEWAY_EVENTS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_GATEWAY_EVENTS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_GATEWAY_EVENTS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_GATEWAY_EVENTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_GATEWAY_EVENTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_GATEWAY_EVENTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;




-- ----------------------------------------------------------------------------
-- DATABASE: PAYMENTS_CORE_PROD_CURATED (CURATED Zone)
-- ----------------------------------------------------------------------------

USE DATABASE PAYMENTS_CORE_PROD_CURATED;



-- ============================================================================
-- SCHEMA: TRANSACTIONS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS TRANSACTIONS WITH MANAGED ACCESS
  COMMENT = 'TRANSACTIONS schema in CURATED zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_TRANSACTIONS
  COMMENT = 'Read access to TRANSACTIONS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_TRANSACTIONS
  COMMENT = 'Write access to TRANSACTIONS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_TRANSACTIONS
  COMMENT = 'Create access to TRANSACTIONS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_CURATED TO DATABASE ROLE SC_R_TRANSACTIONS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_R_TRANSACTIONS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE VIEW ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE STREAM ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE FUNCTION ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE PROCEDURE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE SEQUENCE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE TASK ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE FILE FORMAT ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE STAGE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE PIPE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE STREAMLIT ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE ALERT ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE TAG ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE MASKING POLICY ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_TRANSACTIONS TO DATABASE ROLE SC_W_TRANSACTIONS;
GRANT DATABASE ROLE SC_W_TRANSACTIONS TO DATABASE ROLE SC_C_TRANSACTIONS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_TRANSACTIONS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_TRANSACTIONS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_TRANSACTIONS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_TRANSACTIONS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_TRANSACTIONS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_TRANSACTIONS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: SETTLEMENTS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS SETTLEMENTS WITH MANAGED ACCESS
  COMMENT = 'SETTLEMENTS schema in CURATED zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_SETTLEMENTS
  COMMENT = 'Read access to SETTLEMENTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_SETTLEMENTS
  COMMENT = 'Write access to SETTLEMENTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_SETTLEMENTS
  COMMENT = 'Create access to SETTLEMENTS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_CURATED TO DATABASE ROLE SC_R_SETTLEMENTS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_R_SETTLEMENTS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE VIEW ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE STREAM ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE FUNCTION ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE PROCEDURE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE SEQUENCE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE TASK ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE FILE FORMAT ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE STAGE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE PIPE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE STREAMLIT ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE ALERT ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE TAG ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE MASKING POLICY ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_SETTLEMENTS TO DATABASE ROLE SC_W_SETTLEMENTS;
GRANT DATABASE ROLE SC_W_SETTLEMENTS TO DATABASE ROLE SC_C_SETTLEMENTS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_SETTLEMENTS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_SETTLEMENTS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_SETTLEMENTS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_SETTLEMENTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_SETTLEMENTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_SETTLEMENTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: MERCHANTS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS MERCHANTS WITH MANAGED ACCESS
  COMMENT = 'MERCHANTS schema in CURATED zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_MERCHANTS
  COMMENT = 'Read access to MERCHANTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_MERCHANTS
  COMMENT = 'Write access to MERCHANTS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_MERCHANTS
  COMMENT = 'Create access to MERCHANTS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_CURATED TO DATABASE ROLE SC_R_MERCHANTS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_R_MERCHANTS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE VIEW ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE STREAM ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE FUNCTION ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE PROCEDURE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE SEQUENCE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE TASK ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE FILE FORMAT ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE STAGE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE PIPE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE STREAMLIT ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE ALERT ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE TAG ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE MASKING POLICY ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_MERCHANTS TO DATABASE ROLE SC_W_MERCHANTS;
GRANT DATABASE ROLE SC_W_MERCHANTS TO DATABASE ROLE SC_C_MERCHANTS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_MERCHANTS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_MERCHANTS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_MERCHANTS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_MERCHANTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_MERCHANTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_MERCHANTS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: CUSTOMERS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS CUSTOMERS WITH MANAGED ACCESS
  COMMENT = 'CUSTOMERS schema in CURATED zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_CUSTOMERS
  COMMENT = 'Read access to CUSTOMERS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_CUSTOMERS
  COMMENT = 'Write access to CUSTOMERS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_CUSTOMERS
  COMMENT = 'Create access to CUSTOMERS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_CURATED TO DATABASE ROLE SC_R_CUSTOMERS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_R_CUSTOMERS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE VIEW ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE STREAM ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE FUNCTION ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE PROCEDURE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE SEQUENCE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE TASK ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE FILE FORMAT ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE STAGE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE PIPE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE STREAMLIT ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE ALERT ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE TAG ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE MASKING POLICY ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_CUSTOMERS TO DATABASE ROLE SC_W_CUSTOMERS;
GRANT DATABASE ROLE SC_W_CUSTOMERS TO DATABASE ROLE SC_C_CUSTOMERS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_CUSTOMERS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_CUSTOMERS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_CUSTOMERS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_CUSTOMERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_CUSTOMERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_CUSTOMERS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: CHARGEBACKS
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS CHARGEBACKS WITH MANAGED ACCESS
  COMMENT = 'CHARGEBACKS schema in CURATED zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_CHARGEBACKS
  COMMENT = 'Read access to CHARGEBACKS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_CHARGEBACKS
  COMMENT = 'Write access to CHARGEBACKS schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_CHARGEBACKS
  COMMENT = 'Create access to CHARGEBACKS schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_CURATED TO DATABASE ROLE SC_R_CHARGEBACKS;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT SELECT ON FUTURE TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_R_CHARGEBACKS;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE VIEW ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE STREAM ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE FUNCTION ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE PROCEDURE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE SEQUENCE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE TASK ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE FILE FORMAT ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE STAGE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE EXTERNAL TABLE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE PIPE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE DYNAMIC TABLE ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE STREAMLIT ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE ALERT ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE TAG ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE MASKING POLICY ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_CHARGEBACKS TO DATABASE ROLE SC_W_CHARGEBACKS;
GRANT DATABASE ROLE SC_W_CHARGEBACKS TO DATABASE ROLE SC_C_CHARGEBACKS;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_CHARGEBACKS TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_CHARGEBACKS TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_CHARGEBACKS TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_CHARGEBACKS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_CHARGEBACKS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_CHARGEBACKS TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: LEDGER
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS LEDGER WITH MANAGED ACCESS
  COMMENT = 'LEDGER schema in CURATED zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_LEDGER
  COMMENT = 'Read access to LEDGER schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_LEDGER
  COMMENT = 'Write access to LEDGER schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_LEDGER
  COMMENT = 'Create access to LEDGER schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_CURATED TO DATABASE ROLE SC_R_LEDGER;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA LEDGER TO DATABASE ROLE SC_R_LEDGER;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA LEDGER TO DATABASE ROLE SC_W_LEDGER;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE VIEW ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE STREAM ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE FUNCTION ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE PROCEDURE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE SEQUENCE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE TASK ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE FILE FORMAT ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE STAGE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE EXTERNAL TABLE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE PIPE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE DYNAMIC TABLE ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE STREAMLIT ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE ALERT ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE TAG ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE MASKING POLICY ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA LEDGER TO DATABASE ROLE SC_C_LEDGER;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_LEDGER TO DATABASE ROLE SC_W_LEDGER;
GRANT DATABASE ROLE SC_W_LEDGER TO DATABASE ROLE SC_C_LEDGER;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_LEDGER TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_LEDGER TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_LEDGER TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_LEDGER TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_LEDGER TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_LEDGER TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;




-- ----------------------------------------------------------------------------
-- DATABASE: PAYMENTS_CORE_PROD_ANALYTICS (ANALYTICS Zone)
-- ----------------------------------------------------------------------------

USE DATABASE PAYMENTS_CORE_PROD_ANALYTICS;



-- ============================================================================
-- SCHEMA: REVENUE
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS REVENUE WITH MANAGED ACCESS
  COMMENT = 'REVENUE schema in ANALYTICS zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_REVENUE
  COMMENT = 'Read access to REVENUE schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_REVENUE
  COMMENT = 'Write access to REVENUE schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_REVENUE
  COMMENT = 'Create access to REVENUE schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_ANALYTICS TO DATABASE ROLE SC_R_REVENUE;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA REVENUE TO DATABASE ROLE SC_R_REVENUE;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA REVENUE TO DATABASE ROLE SC_W_REVENUE;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE VIEW ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE STREAM ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE FUNCTION ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE PROCEDURE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE SEQUENCE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE TASK ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE FILE FORMAT ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE STAGE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE EXTERNAL TABLE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE PIPE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE DYNAMIC TABLE ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE STREAMLIT ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE ALERT ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE TAG ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE MASKING POLICY ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA REVENUE TO DATABASE ROLE SC_C_REVENUE;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_REVENUE TO DATABASE ROLE SC_W_REVENUE;
GRANT DATABASE ROLE SC_W_REVENUE TO DATABASE ROLE SC_C_REVENUE;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_REVENUE TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_REVENUE TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_REVENUE TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_REVENUE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_REVENUE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_REVENUE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: SETTLEMENT_RECONCILIATION
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS SETTLEMENT_RECONCILIATION WITH MANAGED ACCESS
  COMMENT = 'SETTLEMENT_RECONCILIATION schema in ANALYTICS zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_SETTLEMENT_RECONCILIATION
  COMMENT = 'Read access to SETTLEMENT_RECONCILIATION schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_SETTLEMENT_RECONCILIATION
  COMMENT = 'Write access to SETTLEMENT_RECONCILIATION schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_SETTLEMENT_RECONCILIATION
  COMMENT = 'Create access to SETTLEMENT_RECONCILIATION schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_ANALYTICS TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE VIEW ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE STREAM ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE FUNCTION ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE PROCEDURE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE SEQUENCE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE TASK ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE FILE FORMAT ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE STAGE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE EXTERNAL TABLE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE PIPE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE DYNAMIC TABLE ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE STREAMLIT ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE ALERT ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE TAG ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE MASKING POLICY ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION;
GRANT DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION TO DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_SETTLEMENT_RECONCILIATION TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_SETTLEMENT_RECONCILIATION TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_SETTLEMENT_RECONCILIATION TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: FRAUD_FEATURES
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS FRAUD_FEATURES WITH MANAGED ACCESS
  COMMENT = 'FRAUD_FEATURES schema in ANALYTICS zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_FRAUD_FEATURES
  COMMENT = 'Read access to FRAUD_FEATURES schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_FRAUD_FEATURES
  COMMENT = 'Write access to FRAUD_FEATURES schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_FRAUD_FEATURES
  COMMENT = 'Create access to FRAUD_FEATURES schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_ANALYTICS TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT SELECT ON FUTURE TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_R_FRAUD_FEATURES;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE VIEW ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE STREAM ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE FUNCTION ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE PROCEDURE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE SEQUENCE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE TASK ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE FILE FORMAT ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE STAGE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE EXTERNAL TABLE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE PIPE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE DYNAMIC TABLE ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE STREAMLIT ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE ALERT ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE TAG ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE MASKING POLICY ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_FRAUD_FEATURES TO DATABASE ROLE SC_W_FRAUD_FEATURES;
GRANT DATABASE ROLE SC_W_FRAUD_FEATURES TO DATABASE ROLE SC_C_FRAUD_FEATURES;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_FRAUD_FEATURES TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_FRAUD_FEATURES TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_FRAUD_FEATURES TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_FRAUD_FEATURES TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_FRAUD_FEATURES TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_FRAUD_FEATURES TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: MERCHANT_PERFORMANCE
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS MERCHANT_PERFORMANCE WITH MANAGED ACCESS
  COMMENT = 'MERCHANT_PERFORMANCE schema in ANALYTICS zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_MERCHANT_PERFORMANCE
  COMMENT = 'Read access to MERCHANT_PERFORMANCE schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_MERCHANT_PERFORMANCE
  COMMENT = 'Write access to MERCHANT_PERFORMANCE schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_MERCHANT_PERFORMANCE
  COMMENT = 'Create access to MERCHANT_PERFORMANCE schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_ANALYTICS TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_R_MERCHANT_PERFORMANCE;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE VIEW ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE STREAM ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE FUNCTION ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE PROCEDURE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE SEQUENCE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE TASK ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE FILE FORMAT ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE STAGE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE EXTERNAL TABLE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE PIPE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE DYNAMIC TABLE ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE STREAMLIT ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE ALERT ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE TAG ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE MASKING POLICY ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_MERCHANT_PERFORMANCE TO DATABASE ROLE SC_W_MERCHANT_PERFORMANCE;
GRANT DATABASE ROLE SC_W_MERCHANT_PERFORMANCE TO DATABASE ROLE SC_C_MERCHANT_PERFORMANCE;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_MERCHANT_PERFORMANCE TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_MERCHANT_PERFORMANCE TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_MERCHANT_PERFORMANCE TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_MERCHANT_PERFORMANCE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_MERCHANT_PERFORMANCE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_MERCHANT_PERFORMANCE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- SCHEMA: REGULATORY_REPORTING
-- ============================================================================

-- Step 1: Create schema with managed access
CREATE SCHEMA IF NOT EXISTS REGULATORY_REPORTING WITH MANAGED ACCESS
  COMMENT = 'REGULATORY_REPORTING schema in ANALYTICS zone for core';

-- Step 2: Create schema access database roles
CREATE DATABASE ROLE IF NOT EXISTS SC_R_REGULATORY_REPORTING
  COMMENT = 'Read access to REGULATORY_REPORTING schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_W_REGULATORY_REPORTING
  COMMENT = 'Write access to REGULATORY_REPORTING schema';

CREATE DATABASE ROLE IF NOT EXISTS SC_C_REGULATORY_REPORTING
  COMMENT = 'Create access to REGULATORY_REPORTING schema';

-- ============================================================================
-- SC_R (READ) PRIVILEGES
-- ============================================================================
-- Read-only access to all data objects in the schema

-- Schema usage
GRANT USAGE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT MONITOR ON DATABASE PAYMENTS_CORE_PROD_ANALYTICS TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- Tables (current and future)
GRANT SELECT ON ALL TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT SELECT ON FUTURE TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- Views (current and future)
GRANT SELECT ON ALL VIEWS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- External Tables (current and future)
GRANT SELECT ON ALL EXTERNAL TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT SELECT ON FUTURE EXTERNAL TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- Dynamic Tables (current and future)
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- Materialized Views (current and future)
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- Functions (current and future)
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_R_REGULATORY_REPORTING;

-- ============================================================================
-- SC_W (WRITE) PRIVILEGES
-- ============================================================================
-- Data modification privileges (DML and operational)

-- Tables - DML
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Streams
GRANT SELECT ON ALL STREAMS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Procedures
GRANT USAGE ON ALL PROCEDURES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT USAGE ON FUTURE SEQUENCES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Tasks
GRANT MONITOR, OPERATE ON ALL TASKS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT MONITOR, OPERATE ON FUTURE TASKS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- File Formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Stages
GRANT USAGE, READ, WRITE ON ALL STAGES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT USAGE, READ, WRITE ON FUTURE STAGES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Dynamic Tables (operational)
GRANT MONITOR, OPERATE ON ALL DYNAMIC TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT MONITOR, OPERATE ON FUTURE DYNAMIC TABLES IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- Alerts
GRANT MONITOR, OPERATE ON ALL ALERTS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT MONITOR, OPERATE ON FUTURE ALERTS IN SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;

-- ============================================================================
-- SC_C (CREATE) PRIVILEGES
-- ============================================================================
-- Object creation privileges

GRANT CREATE TABLE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE VIEW ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE STREAM ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE FUNCTION ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE PROCEDURE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE SEQUENCE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE TASK ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE FILE FORMAT ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE STAGE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE EXTERNAL TABLE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE PIPE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE DYNAMIC TABLE ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE STREAMLIT ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE ALERT ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE TAG ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE MASKING POLICY ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;
GRANT CREATE ROW ACCESS POLICY ON SCHEMA REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;

-- ============================================================================
-- ESTABLISH SCHEMA ROLE HIERARCHY
-- ============================================================================
-- SC_C ← SC_W ← SC_R (CREATE inherits WRITE inherits READ)

GRANT DATABASE ROLE SC_R_REGULATORY_REPORTING TO DATABASE ROLE SC_W_REGULATORY_REPORTING;
GRANT DATABASE ROLE SC_W_REGULATORY_REPORTING TO DATABASE ROLE SC_C_REGULATORY_REPORTING;

-- ============================================================================
-- CONNECT TO DATABASE-LEVEL ROLES
-- ============================================================================

GRANT DATABASE ROLE SC_R_REGULATORY_REPORTING TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE SC_W_REGULATORY_REPORTING TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE SC_C_REGULATORY_REPORTING TO DATABASE ROLE DB_C;

-- ============================================================================
-- TRANSFER OWNERSHIP TO RBAC ROLE
-- ============================================================================

GRANT OWNERSHIP ON DATABASE ROLE SC_R_REGULATORY_REPORTING TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_W_REGULATORY_REPORTING TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE ROLE SC_C_REGULATORY_REPORTING TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;




-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show all schemas

SHOW SCHEMAS IN DATABASE PAYMENTS_CORE_PROD_RAW;

SHOW SCHEMAS IN DATABASE PAYMENTS_CORE_PROD_CURATED;

SHOW SCHEMAS IN DATABASE PAYMENTS_CORE_PROD_ANALYTICS;


-- Show all database roles

SHOW DATABASE ROLES IN DATABASE PAYMENTS_CORE_PROD_RAW;

SHOW DATABASE ROLES IN DATABASE PAYMENTS_CORE_PROD_CURATED;

SHOW DATABASE ROLES IN DATABASE PAYMENTS_CORE_PROD_ANALYTICS;


/*
SCHEMAS CREATED
===============

Created schemas for core data product:

RAW Zone (PAYMENTS_CORE_PROD_RAW):
  - CARD_TRANSACTIONS
    - SC_R_CARD_TRANSACTIONS (read)
    - SC_W_CARD_TRANSACTIONS (write)
    - SC_C_CARD_TRANSACTIONS (create)
  - BANK_TRANSFERS
    - SC_R_BANK_TRANSFERS (read)
    - SC_W_BANK_TRANSFERS (write)
    - SC_C_BANK_TRANSFERS (create)
  - MERCHANTS
    - SC_R_MERCHANTS (read)
    - SC_W_MERCHANTS (write)
    - SC_C_MERCHANTS (create)
  - CUSTOMERS
    - SC_R_CUSTOMERS (read)
    - SC_W_CUSTOMERS (write)
    - SC_C_CUSTOMERS (create)
  - LEDGER_ENTRIES
    - SC_R_LEDGER_ENTRIES (read)
    - SC_W_LEDGER_ENTRIES (write)
    - SC_C_LEDGER_ENTRIES (create)
  - GATEWAY_EVENTS
    - SC_R_GATEWAY_EVENTS (read)
    - SC_W_GATEWAY_EVENTS (write)
    - SC_C_GATEWAY_EVENTS (create)

CURATED Zone (PAYMENTS_CORE_PROD_CURATED):
  - TRANSACTIONS
    - SC_R_TRANSACTIONS (read)
    - SC_W_TRANSACTIONS (write)
    - SC_C_TRANSACTIONS (create)
  - SETTLEMENTS
    - SC_R_SETTLEMENTS (read)
    - SC_W_SETTLEMENTS (write)
    - SC_C_SETTLEMENTS (create)
  - MERCHANTS
    - SC_R_MERCHANTS (read)
    - SC_W_MERCHANTS (write)
    - SC_C_MERCHANTS (create)
  - CUSTOMERS
    - SC_R_CUSTOMERS (read)
    - SC_W_CUSTOMERS (write)
    - SC_C_CUSTOMERS (create)
  - CHARGEBACKS
    - SC_R_CHARGEBACKS (read)
    - SC_W_CHARGEBACKS (write)
    - SC_C_CHARGEBACKS (create)
  - LEDGER
    - SC_R_LEDGER (read)
    - SC_W_LEDGER (write)
    - SC_C_LEDGER (create)

ANALYTICS Zone (PAYMENTS_CORE_PROD_ANALYTICS):
  - REVENUE
    - SC_R_REVENUE (read)
    - SC_W_REVENUE (write)
    - SC_C_REVENUE (create)
  - SETTLEMENT_RECONCILIATION
    - SC_R_SETTLEMENT_RECONCILIATION (read)
    - SC_W_SETTLEMENT_RECONCILIATION (write)
    - SC_C_SETTLEMENT_RECONCILIATION (create)
  - FRAUD_FEATURES
    - SC_R_FRAUD_FEATURES (read)
    - SC_W_FRAUD_FEATURES (write)
    - SC_C_FRAUD_FEATURES (create)
  - MERCHANT_PERFORMANCE
    - SC_R_MERCHANT_PERFORMANCE (read)
    - SC_W_MERCHANT_PERFORMANCE (write)
    - SC_C_MERCHANT_PERFORMANCE (create)
  - REGULATORY_REPORTING
    - SC_R_REGULATORY_REPORTING (read)
    - SC_W_REGULATORY_REPORTING (write)
    - SC_C_REGULATORY_REPORTING (create)

Schema Role Ownership: PAYMENTS_CORE_PROD_RBAC

Role Hierarchy:
- SC_R_* → DB_R → PAYMENTS_CORE_PROD_READ
- SC_W_* → DB_W → PAYMENTS_CORE_PROD_WRITE
- SC_C_* → DB_C → PAYMENTS_CORE_PROD_CREATE

NEXT STEPS:
- Task 3: Warehouse & Access Configuration
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 3: Warehouse & Access Configuration
-- Summary: Create warehouses for each workload type, create warehouse access roles for controlled compute access, transfer ownership to admin roles, and wire the complete role hierarchy connecting account roles to warehouse access.
-- Personas: Platform Administrator, Data Team
-- Role Requirements: SYSADMIN role, USERADMIN role, SECURITYADMIN role
-- External Requirements: Task 2 (Core Roles & Database Setup) completed, warehouse_definitions from Task 1, Core roles created (ADMIN, CREATE, WRITE, RBAC, READ), Databases and schemas with database roles
-- ============================================================================


-- ------------------------------------------------------------
-- Step 3.1: Create Warehouses
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-warehouses"}';

-- ============================================================================
-- CREATE WAREHOUSES
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: CORE_CREATE (has CREATE WAREHOUSE privilege)
-- ============================================================================

-- Derive the data product prefix for object names

-- Use the CREATE role (has CREATE WAREHOUSE privilege)
USE ROLE PAYMENTS_CORE_PROD_CREATE;

-- ============================================================================
-- CREATE WAREHOUSES
-- ============================================================================


-- ----------------------------------------------------------------------------
-- WAREHOUSE: PAYMENTS_CORE_PROD_WH_LOAD
-- ----------------------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_LOAD
  WITH
    WAREHOUSE_SIZE = 'SMALL'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2
    SCALING_POLICY = 'STANDARD'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    COMMENT = 'LOAD warehouse for core data product';

-- Apply governance tags
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD SET TAG
    INFRA.GOVERNANCE.DOMAIN = 'payments',
    INFRA.GOVERNANCE.ENVIRONMENT = 'prod',
    INFRA.GOVERNANCE.DATAPRODUCT = 'core',
    INFRA.GOVERNANCE.WORKLOAD = 'LOAD';



-- ----------------------------------------------------------------------------
-- WAREHOUSE: PAYMENTS_CORE_PROD_WH_TRANSFORM
-- ----------------------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_TRANSFORM
  WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    COMMENT = 'TRANSFORM warehouse for core data product';

-- Apply governance tags
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM SET TAG
    INFRA.GOVERNANCE.DOMAIN = 'payments',
    INFRA.GOVERNANCE.ENVIRONMENT = 'prod',
    INFRA.GOVERNANCE.DATAPRODUCT = 'core',
    INFRA.GOVERNANCE.WORKLOAD = 'TRANSFORM';



-- ----------------------------------------------------------------------------
-- WAREHOUSE: PAYMENTS_CORE_PROD_WH_REPORT
-- ----------------------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_REPORT
  WITH
    WAREHOUSE_SIZE = 'SMALL'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'STANDARD'
    AUTO_SUSPEND = 120
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    COMMENT = 'REPORT warehouse for core data product';

-- Apply governance tags
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT SET TAG
    INFRA.GOVERNANCE.DOMAIN = 'payments',
    INFRA.GOVERNANCE.ENVIRONMENT = 'prod',
    INFRA.GOVERNANCE.DATAPRODUCT = 'core',
    INFRA.GOVERNANCE.WORKLOAD = 'REPORT';



-- ----------------------------------------------------------------------------
-- WAREHOUSE: PAYMENTS_CORE_PROD_WH_SCIENCE
-- ----------------------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_SCIENCE
  WITH
    WAREHOUSE_SIZE = 'LARGE'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    ENABLE_QUERY_ACCELERATION = FALSE
    COMMENT = 'SCIENCE warehouse for core data product';

-- Apply governance tags
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE SET TAG
    INFRA.GOVERNANCE.DOMAIN = 'payments',
    INFRA.GOVERNANCE.ENVIRONMENT = 'prod',
    INFRA.GOVERNANCE.DATAPRODUCT = 'core',
    INFRA.GOVERNANCE.WORKLOAD = 'SCIENCE';



-- ============================================================================
-- TRANSFER OWNERSHIP TO ADMIN
-- ============================================================================

-- Switch to SECURITYADMIN to perform ownership transfer
USE ROLE SECURITYADMIN;


GRANT OWNERSHIP ON WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;

GRANT OWNERSHIP ON WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;

GRANT OWNERSHIP ON WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;

GRANT OWNERSHIP ON WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE TO ROLE PAYMENTS_CORE_PROD_ADMIN COPY CURRENT GRANTS;


-- ============================================================================
-- VERIFICATION
-- ============================================================================

USE ROLE PAYMENTS_CORE_PROD_ADMIN;

-- Show all warehouses
SHOW WAREHOUSES LIKE 'PAYMENTS_CORE_PROD_WH_%';

-- Verify tags are applied

SELECT SYSTEM$GET_TAG('INFRA.GOVERNANCE.DATAPRODUCT', 'PAYMENTS_CORE_PROD_WH_LOAD', 'WAREHOUSE') AS tag_value;

SELECT SYSTEM$GET_TAG('INFRA.GOVERNANCE.DATAPRODUCT', 'PAYMENTS_CORE_PROD_WH_TRANSFORM', 'WAREHOUSE') AS tag_value;

SELECT SYSTEM$GET_TAG('INFRA.GOVERNANCE.DATAPRODUCT', 'PAYMENTS_CORE_PROD_WH_REPORT', 'WAREHOUSE') AS tag_value;

SELECT SYSTEM$GET_TAG('INFRA.GOVERNANCE.DATAPRODUCT', 'PAYMENTS_CORE_PROD_WH_SCIENCE', 'WAREHOUSE') AS tag_value;


/*
WAREHOUSES CREATED
==================

Created 4 warehouse(s) for core data product:
  1. PAYMENTS_CORE_PROD_WH_LOAD
     Size: SMALL
     Clusters: 1-2
     Auto-suspend: 60s
  2. PAYMENTS_CORE_PROD_WH_TRANSFORM
     Size: MEDIUM
     Clusters: 1-3
     Auto-suspend: 300s
  3. PAYMENTS_CORE_PROD_WH_REPORT
     Size: SMALL
     Clusters: 1-3
     Auto-suspend: 120s
  4. PAYMENTS_CORE_PROD_WH_SCIENCE
     Size: LARGE
     Clusters: 1-1
     Auto-suspend: 300s

Warehouse Ownership: PAYMENTS_CORE_PROD_ADMIN

NEXT STEPS:
- Step 3.2: Create warehouse access roles
- Step 3.3: Wire up role hierarchy
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.2: Create Warehouse Access Roles
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-warehouse-access-roles"}';

-- ============================================================================
-- CREATE WAREHOUSE ACCESS ROLES
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: SECURITYADMIN (to create and grant roles)
-- ============================================================================

-- Derive the data product prefix for object names

USE ROLE SECURITYADMIN;

-- ============================================================================
-- CREATE WAREHOUSE ACCESS ROLES
-- ============================================================================


-- ----------------------------------------------------------------------------
-- ACCESS ROLE: PAYMENTS_CORE_PROD_WH_U_LOAD
-- For warehouse: PAYMENTS_CORE_PROD_WH_LOAD
-- ----------------------------------------------------------------------------

-- Create access role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_U_LOAD
  COMMENT = 'Usage access to PAYMENTS_CORE_PROD_WH_LOAD warehouse';

-- Grant warehouse privileges
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD TO ROLE PAYMENTS_CORE_PROD_WH_U_LOAD;
GRANT MONITOR ON WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD TO ROLE PAYMENTS_CORE_PROD_WH_U_LOAD;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD TO ROLE PAYMENTS_CORE_PROD_WH_U_LOAD;

-- Transfer ownership to RBAC role for delegated administration
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ----------------------------------------------------------------------------
-- ACCESS ROLE: PAYMENTS_CORE_PROD_WH_U_TRANSFORM
-- For warehouse: PAYMENTS_CORE_PROD_WH_TRANSFORM
-- ----------------------------------------------------------------------------

-- Create access role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_U_TRANSFORM
  COMMENT = 'Usage access to PAYMENTS_CORE_PROD_WH_TRANSFORM warehouse';

-- Grant warehouse privileges
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM;
GRANT MONITOR ON WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM;

-- Transfer ownership to RBAC role for delegated administration
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ----------------------------------------------------------------------------
-- ACCESS ROLE: PAYMENTS_CORE_PROD_WH_U_REPORT
-- For warehouse: PAYMENTS_CORE_PROD_WH_REPORT
-- ----------------------------------------------------------------------------

-- Create access role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_U_REPORT
  COMMENT = 'Usage access to PAYMENTS_CORE_PROD_WH_REPORT warehouse';

-- Grant warehouse privileges
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT TO ROLE PAYMENTS_CORE_PROD_WH_U_REPORT;
GRANT MONITOR ON WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT TO ROLE PAYMENTS_CORE_PROD_WH_U_REPORT;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT TO ROLE PAYMENTS_CORE_PROD_WH_U_REPORT;

-- Transfer ownership to RBAC role for delegated administration
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ----------------------------------------------------------------------------
-- ACCESS ROLE: PAYMENTS_CORE_PROD_WH_U_SCIENCE
-- For warehouse: PAYMENTS_CORE_PROD_WH_SCIENCE
-- ----------------------------------------------------------------------------

-- Create access role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_WH_U_SCIENCE
  COMMENT = 'Usage access to PAYMENTS_CORE_PROD_WH_SCIENCE warehouse';

-- Grant warehouse privileges
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE TO ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE;
GRANT MONITOR ON WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE TO ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE TO ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE;

-- Transfer ownership to RBAC role for delegated administration
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- GRANT ACCESS ROLES TO CORE ROLES
-- ============================================================================
-- All core roles get access to all warehouses by default
-- This can be customized based on requirements



-- Grant PAYMENTS_CORE_PROD_WH_U_LOAD to core roles
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_ADMIN;



-- Grant PAYMENTS_CORE_PROD_WH_U_TRANSFORM to core roles
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_ADMIN;



-- Grant PAYMENTS_CORE_PROD_WH_U_REPORT to core roles
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_ADMIN;



-- Grant PAYMENTS_CORE_PROD_WH_U_SCIENCE to core roles
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_ADMIN;



-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show all warehouse access roles
SHOW ROLES LIKE 'PAYMENTS_CORE_PROD_WH_U_%';

-- Verify grants

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_WH_U_LOAD;

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM;

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_WH_U_REPORT;

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE;


/*
WAREHOUSE ACCESS ROLES CREATED
==============================

Created 4 warehouse access role(s):
  1. PAYMENTS_CORE_PROD_WH_U_LOAD
     - USAGE on PAYMENTS_CORE_PROD_WH_LOAD
     - MONITOR on PAYMENTS_CORE_PROD_WH_LOAD
     - OPERATE on PAYMENTS_CORE_PROD_WH_LOAD
  2. PAYMENTS_CORE_PROD_WH_U_TRANSFORM
     - USAGE on PAYMENTS_CORE_PROD_WH_TRANSFORM
     - MONITOR on PAYMENTS_CORE_PROD_WH_TRANSFORM
     - OPERATE on PAYMENTS_CORE_PROD_WH_TRANSFORM
  3. PAYMENTS_CORE_PROD_WH_U_REPORT
     - USAGE on PAYMENTS_CORE_PROD_WH_REPORT
     - MONITOR on PAYMENTS_CORE_PROD_WH_REPORT
     - OPERATE on PAYMENTS_CORE_PROD_WH_REPORT
  4. PAYMENTS_CORE_PROD_WH_U_SCIENCE
     - USAGE on PAYMENTS_CORE_PROD_WH_SCIENCE
     - MONITOR on PAYMENTS_CORE_PROD_WH_SCIENCE
     - OPERATE on PAYMENTS_CORE_PROD_WH_SCIENCE

All access roles granted to core roles (READ, WRITE, CREATE, ADMIN).

Ownership: PAYMENTS_CORE_PROD_RBAC

NEXT STEPS:
- Step 3.3: Transfer ownership and wire hierarchy
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.3: Transfer Ownership & Wire Hierarchy
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"transfer-ownership-wire-hierarchy"}';

-- ============================================================================
-- TRANSFER OWNERSHIP & WIRE HIERARCHY
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: SECURITYADMIN (to manage role grants)
-- ============================================================================

-- Derive the data product prefix for object names

USE ROLE SECURITYADMIN;

-- ============================================================================
-- ESTABLISH CORE ROLE HIERARCHY
-- ============================================================================
-- READ ← WRITE ← CREATE ← ADMIN
--                         ↓
--                       RBAC

-- Wire the core role hierarchy
GRANT ROLE PAYMENTS_CORE_PROD_READ TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT ROLE PAYMENTS_CORE_PROD_WRITE TO ROLE PAYMENTS_CORE_PROD_CREATE;
GRANT ROLE PAYMENTS_CORE_PROD_CREATE TO ROLE PAYMENTS_CORE_PROD_ADMIN;

-- RBAC role can manage other roles
GRANT ROLE PAYMENTS_CORE_PROD_READ TO ROLE PAYMENTS_CORE_PROD_RBAC;
GRANT ROLE PAYMENTS_CORE_PROD_WRITE TO ROLE PAYMENTS_CORE_PROD_RBAC;
GRANT ROLE PAYMENTS_CORE_PROD_CREATE TO ROLE PAYMENTS_CORE_PROD_RBAC;
GRANT ROLE PAYMENTS_CORE_PROD_RBAC TO ROLE PAYMENTS_CORE_PROD_ADMIN;

-- ============================================================================
-- GRANT DATABASE ROLES TO ACCOUNT ROLES
-- ============================================================================


-- RAW Zone Database Roles
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_RAW.DB_R TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_RAW.DB_W TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_RAW.DB_C TO ROLE PAYMENTS_CORE_PROD_CREATE;



-- CURATED Zone Database Roles
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_CURATED.DB_R TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_CURATED.DB_W TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_CURATED.DB_C TO ROLE PAYMENTS_CORE_PROD_CREATE;



-- ANALYTICS Zone Database Roles
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.DB_R TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.DB_W TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.DB_C TO ROLE PAYMENTS_CORE_PROD_CREATE;



-- ============================================================================
-- CREATE ACCOUNT ACCESS ROLES
-- ============================================================================
-- These roles grant specific account-level privileges for advanced operations

-- Execute Task privilege (required for task execution)
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_AR_EXEC_TASK
  COMMENT = 'Execute task privilege for core';
GRANT EXECUTE TASK ON ACCOUNT TO ROLE PAYMENTS_CORE_PROD_AR_EXEC_TASK;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_AR_EXEC_TASK TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- View Account Usage privilege
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_AR_VIEW_AUSG
  COMMENT = 'View account usage privilege for core';
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE PAYMENTS_CORE_PROD_AR_VIEW_AUSG;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_AR_VIEW_AUSG TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Apply Data Masking Policy privilege
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_AR_APPLY_DDM
  COMMENT = 'Apply masking policy privilege for core';
GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE PAYMENTS_CORE_PROD_AR_APPLY_DDM;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_AR_APPLY_DDM TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Apply Row Access Policy privilege
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_AR_APPLY_RAP
  COMMENT = 'Apply row access policy privilege for core';
GRANT APPLY ROW ACCESS POLICY ON ACCOUNT TO ROLE PAYMENTS_CORE_PROD_AR_APPLY_RAP;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_AR_APPLY_RAP TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Apply Tag privilege
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_AR_APPLY_TAG
  COMMENT = 'Apply tag privilege for core';
GRANT APPLY TAG ON ACCOUNT TO ROLE PAYMENTS_CORE_PROD_AR_APPLY_TAG;
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_AR_APPLY_TAG TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;

-- Grant account access roles to ADMIN
GRANT ROLE PAYMENTS_CORE_PROD_AR_EXEC_TASK TO ROLE PAYMENTS_CORE_PROD_ADMIN;
GRANT ROLE PAYMENTS_CORE_PROD_AR_VIEW_AUSG TO ROLE PAYMENTS_CORE_PROD_ADMIN;
GRANT ROLE PAYMENTS_CORE_PROD_AR_APPLY_DDM TO ROLE PAYMENTS_CORE_PROD_ADMIN;
GRANT ROLE PAYMENTS_CORE_PROD_AR_APPLY_RAP TO ROLE PAYMENTS_CORE_PROD_ADMIN;
GRANT ROLE PAYMENTS_CORE_PROD_AR_APPLY_TAG TO ROLE PAYMENTS_CORE_PROD_ADMIN;

-- ============================================================================
-- CONNECT TO SCIM PROVISIONER (if configured)
-- ============================================================================

-- Grant ADMIN role to SCIM provisioner for user assignment
GRANT ROLE PAYMENTS_CORE_PROD_ADMIN TO ROLE OKTA_PROVISIONER;

-- The SCIM provisioner can then assign users to the data product roles

-- ============================================================================
-- CONNECT TO SYSADMIN (if required)
-- ============================================================================

-- Optional: Grant ADMIN role to SYSADMIN for centralized administration
-- Uncomment if you want SYSADMIN to manage this data product
-- GRANT ROLE PAYMENTS_CORE_PROD_ADMIN TO ROLE SYSADMIN;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show role hierarchy
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_READ;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_WRITE;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CREATE;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_ADMIN;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_RBAC;

-- Show account access roles
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_AR_EXEC_TASK;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_AR_VIEW_AUSG;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_AR_APPLY_DDM;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_AR_APPLY_RAP;
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_AR_APPLY_TAG;

/*
ROLE HIERARCHY WIRED
====================

Core Role Hierarchy:
  PAYMENTS_CORE_PROD_READ
      ↑
  PAYMENTS_CORE_PROD_WRITE
      ↑
  PAYMENTS_CORE_PROD_CREATE
      ↑
  PAYMENTS_CORE_PROD_ADMIN
      ↑
  OKTA_PROVISIONER

RBAC Role:
  PAYMENTS_CORE_PROD_RBAC → Can grant READ, WRITE, CREATE
      ↑
  PAYMENTS_CORE_PROD_ADMIN

Database Role Connections:
  - PAYMENTS_CORE_PROD_RAW.DB_R → PAYMENTS_CORE_PROD_READ
  - PAYMENTS_CORE_PROD_RAW.DB_W → PAYMENTS_CORE_PROD_WRITE
  - PAYMENTS_CORE_PROD_RAW.DB_C → PAYMENTS_CORE_PROD_CREATE
  - PAYMENTS_CORE_PROD_CURATED.DB_R → PAYMENTS_CORE_PROD_READ
  - PAYMENTS_CORE_PROD_CURATED.DB_W → PAYMENTS_CORE_PROD_WRITE
  - PAYMENTS_CORE_PROD_CURATED.DB_C → PAYMENTS_CORE_PROD_CREATE
  - PAYMENTS_CORE_PROD_ANALYTICS.DB_R → PAYMENTS_CORE_PROD_READ
  - PAYMENTS_CORE_PROD_ANALYTICS.DB_W → PAYMENTS_CORE_PROD_WRITE
  - PAYMENTS_CORE_PROD_ANALYTICS.DB_C → PAYMENTS_CORE_PROD_CREATE

Account Access Roles:
  - PAYMENTS_CORE_PROD_AR_EXEC_TASK → ADMIN
  - PAYMENTS_CORE_PROD_AR_VIEW_AUSG → ADMIN
  - PAYMENTS_CORE_PROD_AR_APPLY_DDM → ADMIN
  - PAYMENTS_CORE_PROD_AR_APPLY_RAP → ADMIN
  - PAYMENTS_CORE_PROD_AR_APPLY_TAG → ADMIN

NEXT STEPS:
- Task 4: Custom Role Configuration (optional)
- Task 5: Resource Management (optional)
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 4: Consumer Access
-- Summary: Enable external consumers to access your data product by creating purpose-specific consumer access roles that provide granular, SCIM-manageable access for end users who need only specific data zones.
-- Personas: Data Product Owner, Security Administrator, Identity Team
-- Role Requirements: USERADMIN role (or SCIM provisioner role if using SCIM)
-- External Requirements: Task 3 completed (all infrastructure in place), Knowledge of consumer groups and their data needs, SCIM prefix configured (if using SCIM)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 4.1: Create Custom Read Roles
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-custom-read-roles"}';

-- ============================================================================
-- CREATE CUSTOM READ ROLES
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: CORE_RBAC (owns access roles)
-- ============================================================================

-- Derive the data product prefix for object names

USE ROLE SECURITYADMIN;

-- ============================================================================
-- CREATE CUSTOM READ ROLES
-- ============================================================================


-- ----------------------------------------------------------------------------
-- ROLE: PAYMENTS_CORE_PROD_CUSTOM_ANALYST
-- Description: Analytics team. Reporting models and aggregates only, no raw or unmasked data.
-- ----------------------------------------------------------------------------

-- Create the custom role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_CUSTOM_ANALYST
  COMMENT = 'Analytics team. Reporting models and aggregates only, no raw or unmasked data.';

-- Grant schema access
-- Grant full read access to ANALYTICS zone
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.DB_R TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;

-- Transfer ownership to RBAC role
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ----------------------------------------------------------------------------
-- ROLE: PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST
-- Description: Data science team. Curated entities plus analytics feature tables for model development.
-- ----------------------------------------------------------------------------

-- Create the custom role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST
  COMMENT = 'Data science team. Curated entities plus analytics feature tables for model development.';

-- Grant schema access
-- Grant full read access to CURATED zone
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_CURATED.DB_R TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;
-- Grant full read access to ANALYTICS zone
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.DB_R TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;

-- Transfer ownership to RBAC role
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ----------------------------------------------------------------------------
-- ROLE: PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR
-- Description: Compliance and external audit. Regulatory reporting and settlement reconciliation only.
-- ----------------------------------------------------------------------------

-- Create the custom role
CREATE ROLE IF NOT EXISTS PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR
  COMMENT = 'Compliance and external audit. Regulatory reporting and settlement reconciliation only.';

-- Grant schema access
-- Grant read access to ANALYTICS.REGULATORY_REPORTING
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.SC_R_REGULATORY_REPORTING TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;
-- Grant read access to ANALYTICS.SETTLEMENT_RECONCILIATION
GRANT DATABASE ROLE PAYMENTS_CORE_PROD_ANALYTICS.SC_R_SETTLEMENT_RECONCILIATION TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;

-- Transfer ownership to RBAC role
GRANT OWNERSHIP ON ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR TO ROLE PAYMENTS_CORE_PROD_RBAC COPY CURRENT GRANTS;



-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show all custom roles
SHOW ROLES LIKE 'PAYMENTS_CORE_PROD_CUSTOM_%';


-- Show grants for PAYMENTS_CORE_PROD_CUSTOM_ANALYST
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;

-- Show grants for PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;

-- Show grants for PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR
SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;


/*
CUSTOM READ ROLES
=================
Created 3 custom read role(s):
  1. PAYMENTS_CORE_PROD_CUSTOM_ANALYST
     Description: Analytics team. Reporting models and aggregates only, no raw or unmasked data.
     Access: analytics
  2. PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST
     Description: Data science team. Curated entities plus analytics feature tables for model development.
     Access: curated, analytics
  3. PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR
     Description: Compliance and external audit. Regulatory reporting and settlement reconciliation only.
     Access: analytics.regulatory_reporting, analytics.settlement_reconciliation

Ownership: PAYMENTS_CORE_PROD_RBAC

NEXT STEPS:
- Step 4.2: Grant database access to custom roles
- Assign warehouse access to custom roles as needed
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 4.2: Grant Database Access to Roles
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"grant-database-access-to-roles"}';

-- ============================================================================
-- GRANT DATABASE ACCESS TO ROLES
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: CORE_RBAC (to manage access grants)
-- ============================================================================

-- Derive the data product prefix for object names

USE ROLE PAYMENTS_CORE_PROD_RBAC;

-- ============================================================================
-- GRANT WAREHOUSE ACCESS TO CUSTOM ROLES
-- ============================================================================

-- Custom roles need warehouse access to execute queries
-- Grant the most appropriate warehouse for each custom role's use case



-- Grant default warehouse access to PAYMENTS_CORE_PROD_CUSTOM_ANALYST
-- Adjust based on workload requirements

-- Uncomment to grant LOAD warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;

-- Uncomment to grant TRANSFORM warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;

-- Uncomment to grant REPORT warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;

-- Uncomment to grant SCIENCE warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;




-- Grant default warehouse access to PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST
-- Adjust based on workload requirements

-- Uncomment to grant LOAD warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;

-- Uncomment to grant TRANSFORM warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;

-- Uncomment to grant REPORT warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;

-- Uncomment to grant SCIENCE warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;




-- Grant default warehouse access to PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR
-- Adjust based on workload requirements

-- Uncomment to grant LOAD warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_LOAD TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;

-- Uncomment to grant TRANSFORM warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_TRANSFORM TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;

-- Uncomment to grant REPORT warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_REPORT TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;

-- Uncomment to grant SCIENCE warehouse:
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_SCIENCE TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;




-- ============================================================================
-- CROSS-DATA PRODUCT ACCESS (Optional)
-- ============================================================================
-- Use this pattern to grant access to roles from other data products
-- 
-- Example: Grant read access to another data product's role
-- USE ROLE PAYMENTS_CORE_PROD_RBAC;
-- GRANT DATABASE ROLE PAYMENTS_CORE_PROD_GOLD.DB_R TO ROLE <other_prefix>_READ;
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_ANALYTICS TO ROLE <other_prefix>_READ;

-- ============================================================================
-- SERVICE ACCOUNT ACCESS (Optional)
-- ============================================================================
-- Use this pattern to grant access to service accounts
--
-- Example: Grant read access to an ETL service account role
-- USE ROLE PAYMENTS_CORE_PROD_RBAC;
-- GRANT ROLE PAYMENTS_CORE_PROD_READ TO ROLE SVC_ETL;
-- GRANT ROLE PAYMENTS_CORE_PROD_WH_U_ETL TO ROLE SVC_ETL;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify custom role grants

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CUSTOM_ANALYST;

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST;

SHOW GRANTS TO ROLE PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR;


/*
DATABASE ACCESS GRANTS
======================

Core Roles (configured in Step 3.3):
  - PAYMENTS_CORE_PROD_READ → DB_R all zones + all warehouses
  - PAYMENTS_CORE_PROD_WRITE → DB_W all zones + all warehouses
  - PAYMENTS_CORE_PROD_CREATE → DB_C all zones + all warehouses
  - PAYMENTS_CORE_PROD_ADMIN → Full ownership

Custom Roles (warehouse grants may need to be enabled):
  - PAYMENTS_CORE_PROD_CUSTOM_ANALYST
  - PAYMENTS_CORE_PROD_CUSTOM_DATA_SCIENTIST
  - PAYMENTS_CORE_PROD_CUSTOM_COMPLIANCE_AUDITOR

To grant additional access:
  1. Use role PAYMENTS_CORE_PROD_RBAC
  2. GRANT ROLE <access_role> TO ROLE <target_role>;

NEXT STEPS:
- Task 5: Resource Management (optional)
- Assign users to roles via SCIM or direct grants
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 5: Data Product Cost Management
-- Summary: Establish cost controls for your data product through Snowflake resource monitors that track credit consumption and can trigger alerts or suspend warehouses when thresholds are reached.
-- Personas: FinOps Team, Platform Administrator
-- Role Requirements: ACCOUNTADMIN role access (required for resource monitors)
-- External Requirements: Warehouses created (Task 3), Understanding of expected credit consumption
-- ============================================================================


-- ------------------------------------------------------------
-- Step 5.1: Create Resource Monitors
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"create-resource-monitors"}';

-- ============================================================================
-- CREATE RESOURCE MONITORS
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: ACCOUNTADMIN (to create resource monitors)
-- ============================================================================

-- Derive the data product prefix for object names

-- Resource monitors require ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CREATE RESOURCE MONITOR
-- ============================================================================

CREATE RESOURCE MONITOR IF NOT EXISTS PAYMENTS_CORE_PROD_MONITOR
  WITH
    CREDIT_QUOTA = 1800
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    -- Notification thresholds
    TRIGGERS
      ON 50 PERCENT DO NOTIFY
      ON 75 PERCENT DO NOTIFY
      ON 90 PERCENT DO NOTIFY
      ON 100 PERCENT DO SUSPEND;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify resource monitor
SHOW RESOURCE MONITORS LIKE 'PAYMENTS_CORE_PROD_MONITOR';

/*
RESOURCE MONITOR CREATED
========================

Monitor: PAYMENTS_CORE_PROD_MONITOR
Credit Quota: 1800 credits
Frequency: MONTHLY

Thresholds:
  - 50% → Notify
  - 75% → Notify
  - 90% → Notify
  - 100% → Suspend

NEXT STEPS:
- Step 5.2: Assign monitor to warehouses
- Step 5.3: Configure alert notifications
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 5.2: Assign Monitors to Warehouses
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"assign-monitors-to-warehouses"}';

-- ============================================================================
-- ASSIGN MONITORS TO WAREHOUSES
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: ACCOUNTADMIN (to assign resource monitors)
-- ============================================================================

-- Derive the data product prefix for object names

-- Resource monitor assignments require ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- ASSIGN RESOURCE MONITOR TO WAREHOUSES
-- ============================================================================


-- Assign monitor to PAYMENTS_CORE_PROD_WH_LOAD
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD SET RESOURCE_MONITOR = PAYMENTS_CORE_PROD_MONITOR;



-- Assign monitor to PAYMENTS_CORE_PROD_WH_TRANSFORM
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM SET RESOURCE_MONITOR = PAYMENTS_CORE_PROD_MONITOR;



-- Assign monitor to PAYMENTS_CORE_PROD_WH_REPORT
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT SET RESOURCE_MONITOR = PAYMENTS_CORE_PROD_MONITOR;



-- Assign monitor to PAYMENTS_CORE_PROD_WH_SCIENCE
ALTER WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE SET RESOURCE_MONITOR = PAYMENTS_CORE_PROD_MONITOR;



-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show all warehouses with their resource monitors
SHOW WAREHOUSES LIKE 'PAYMENTS_CORE_PROD_WH_%';

-- Verify monitor assignments
SELECT 
    "name" AS warehouse_name,
    "resource_monitor" AS assigned_monitor,
    "size" AS warehouse_size,
    "state" AS warehouse_state
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "resource_monitor" = 'PAYMENTS_CORE_PROD_MONITOR';

-- Check monitor status
SHOW RESOURCE MONITORS LIKE 'PAYMENTS_CORE_PROD_MONITOR';

/*
MONITORS ASSIGNED
=================

Resource Monitor: PAYMENTS_CORE_PROD_MONITOR

Assigned to warehouses:
  - PAYMENTS_CORE_PROD_WH_LOAD
  - PAYMENTS_CORE_PROD_WH_TRANSFORM
  - PAYMENTS_CORE_PROD_WH_REPORT
  - PAYMENTS_CORE_PROD_WH_SCIENCE

Total warehouses: 4

All warehouse credits will count toward the 1800 credit quota.

NEXT STEPS:
- Step 5.3: Configure alert notifications
- Monitor usage in ACCOUNT_USAGE.RESOURCE_MONITORS
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 5.3: Configure Alert Notifications
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_824228eb","step":"configure-alert-notifications"}';

-- ============================================================================
-- CONFIGURE ALERT NOTIFICATIONS
-- ============================================================================
-- Data Product: core
-- ============================================================================
-- EXECUTE FROM: Primary Account
-- REQUIRED ROLE: ACCOUNTADMIN (to manage notification integrations)
-- ============================================================================

-- Derive the data product prefix for object names

-- Notification configuration requires ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CREATE NOTIFICATION INTEGRATION (Email)
-- ============================================================================

CREATE NOTIFICATION INTEGRATION IF NOT EXISTS PAYMENTS_CORE_PROD_NOTIFY_EMAIL
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('alex@fintechcorp.com')
  COMMENT = 'Email notifications for core data product';

-- ============================================================================
-- CREATE ALERT FOR RESOURCE MONITOR
-- ============================================================================

-- Switch to a role that can create alerts
USE ROLE PAYMENTS_CORE_PROD_ADMIN;

-- Create an alert schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS PAYMENTS_CORE_PROD_RAW.ALERTS;

-- Create alert to notify on resource monitor status
CREATE OR REPLACE ALERT PAYMENTS_CORE_PROD_RAW.ALERTS.RESOURCE_MONITOR_ALERT
  WAREHOUSE = PAYMENTS_CORE_PROD_WH_LOAD
  SCHEDULE = 'USING CRON 0 * * * * UTC'
  IF (EXISTS (
    SELECT 1 
    FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
    WHERE NAME = 'PAYMENTS_CORE_PROD_MONITOR'
      AND USED_CREDITS / NULLIF(CREDIT_QUOTA, 0) >= 0.75
      AND END_TIME IS NULL
  ))
  THEN
    CALL SYSTEM$SEND_EMAIL(
      'PAYMENTS_CORE_PROD_NOTIFY_EMAIL',
      'alex@fintechcorp.com',
      'core Resource Monitor Alert',
      'Resource monitor PAYMENTS_CORE_PROD_MONITOR has exceeded 75% of credit quota. Current usage requires attention.'
    );

-- Enable the alert
ALTER ALERT PAYMENTS_CORE_PROD_RAW.ALERTS.RESOURCE_MONITOR_ALERT RESUME;

-- Grant execute alert permission (required for alert to run)
USE ROLE SECURITYADMIN;
GRANT EXECUTE ALERT ON ACCOUNT TO ROLE PAYMENTS_CORE_PROD_ADMIN;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show notification integration
SHOW NOTIFICATION INTEGRATIONS LIKE 'PAYMENTS_CORE_PROD_NOTIFY%';

-- Show alerts
SHOW ALERTS LIKE '%RESOURCE_MONITOR%' IN SCHEMA PAYMENTS_CORE_PROD_RAW.ALERTS;

/*
ALERT NOTIFICATIONS CONFIGURED
==============================
Email Integration: PAYMENTS_CORE_PROD_NOTIFY_EMAIL
Recipient: alex@fintechcorp.com

Alert: PAYMENTS_CORE_PROD_RAW.ALERTS.RESOURCE_MONITOR_ALERT
Schedule: Every hour
Condition: Resource monitor >= 75% usage

DATA PRODUCT DEPLOYMENT COMPLETE!
=================================

Your core data product is now fully configured with:

✓ Core RBAC Roles (ADMIN, CREATE, WRITE, RBAC, READ)
✓ Databases for each zone (raw, curated, analytics)
✓ Schemas with database roles (SC_R, SC_W, SC_C)
✓ Warehouses with access roles
✓ Role hierarchy wired
✓ Resource monitoring (1800 credits/MONTHLY)
✓ Alert notifications to alex@fintechcorp.com
✓ SCIM integration via OKTA_PROVISIONER

NEXT STEPS:
- Assign users to data product roles
- Start creating tables and loading data
- Monitor usage in Snowsight or ACCOUNT_USAGE views
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;
