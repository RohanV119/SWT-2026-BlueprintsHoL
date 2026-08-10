-- ============================================================
-- RENDERED JOURNEY: Platform Foundation Setup
-- Generated: 2026-08-10 14:52:51
-- Blueprint: platform-foundation-setup
-- Language: sql
-- ============================================================


-- ============================================================================
-- TASK 1: Platform Foundation
-- Summary: Define your account strategy, configure account identifiers, set up centralized management, create shared infrastructure, and organize your platform with domains, environments, FinOps tags, and naming conventions.
-- Personas: Platform Administrator, Cloud/Infrastructure Team
-- Role Requirements: ORGADMIN or ACCOUNTADMIN privileges, Enterprise Edition or higher for Organization Account features
-- External Requirements: Snowflake account (trial or provisioned), Organization information (org name from account URL)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 1.1: Determine Account Strategy
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"determine-account-strategy"}';

-- ============================================================================
-- ACCOUNT STRATEGY VERIFICATION
-- ============================================================================
-- This script provides queries to verify and document the account strategy
-- No configuration changes are made in this step
-- ============================================================================

-- ============================================================================
-- VERIFY CURRENT ACCOUNT INFORMATION
-- ============================================================================

-- Get current account details
SELECT 
  CURRENT_ACCOUNT() AS current_account,
  CURRENT_ACCOUNT_NAME() AS account_name,
  CURRENT_ORGANIZATION_NAME() AS organization_name,
  CURRENT_REGION() AS region;

-- Check if organization is enabled
SHOW ORGANIZATION ACCOUNTS;

-- Get account edition and other details
SELECT 
  SYSTEM$GET_SNOWFLAKE_PLATFORM_INFO() AS platform_info;

-- ============================================================================
-- DOCUMENT ACCOUNT STRATEGY DECISION
-- ============================================================================
-- The following information will be recorded in the Infrastructure Database

/*
Strategy Selected: Single Account

Key Characteristics:
- Primary Isolation: Logical (Database/Schema)
- Cost Tracking: Requires Tagging
- SDLC Data Sharing: Zero Copy Cloning
- Complexity: Low
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.2: Configure Organization Name for Connectivity
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-organization-name-for-connectivity"}';

-- ============================================================================
-- ORGANIZATION NAME VERIFICATION
-- ============================================================================
-- This script verifies the organization name and account identifier structure
-- No configuration changes are made in this step
-- ============================================================================

-- ============================================================================
-- VERIFY CURRENT ORGANIZATION AND ACCOUNT
-- ============================================================================

-- Get current organization name
SELECT CURRENT_ORGANIZATION_NAME() AS organization_name;

-- Get current account name
SELECT CURRENT_ACCOUNT_NAME() AS account_name;

-- Get full account identifier
SELECT 
  CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME() AS account_identifier;

-- ============================================================================
-- VERIFY ORGANIZATION STRUCTURE
-- ============================================================================

-- List all accounts in the organization (requires ORGADMIN)
-- Run this if you have ORGADMIN privileges
-- SHOW ORGANIZATION ACCOUNTS;

-- ============================================================================
-- DOCUMENT ORGANIZATION CONFIGURATION
-- ============================================================================
-- The following information will be recorded in the Infrastructure Database

/*
Organization Configuration:
- Organization Name: FINTECHCORP
- Account Name Prefix: None
- Account Identifier Pattern: FINTECHCORP-<account_name>
*/

-- ============================================================================
-- CONNECTION STRING EXAMPLES
-- ============================================================================

/*
Web UI URL:
https://fintechcorp-<account_name>.snowflakecomputing.com

SnowSQL Connection:
snowsql -a FINTECHCORP-<account_name>

Python Connector:
account = "fintechcorp-<account_name>"
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.3: Enable Organization Account
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"enable-organization-account"}';

-- ============================================================================
-- ORGANIZATION ACCOUNT DECISION
-- ============================================================================
-- This script documents the Organization Account decision and verifies
-- prerequisites. Actual account creation is performed in the next step
-- (Create Organization Account) if enabled.
-- ============================================================================
-- ============================================================================
-- DECISION: ORGANIZATION ACCOUNT NOT ENABLED
-- ============================================================================
-- You have chosen not to create an Organization Account at this time.
-- ============================================================================

/*
Decision: Organization Account will NOT be created.

Implications:
- Single-account deployment without centralized management features
- Organization-level features are not available
- Can be enabled later if you select or upgrade to Snowflake edition Enterprise or higher

Note: For multi-account strategies, an Organization Account is REQUIRED.
If you plan to expand to multiple accounts in the future, consider 
enabling the Organization Account for seamless expansion.
*/

-- Verify current account configuration for standalone operation
-- Note: Account edition is visible in Snowsight under Admin > Accounts,
-- or via SHOW ORGANIZATION ACCOUNTS (requires ORGADMIN role).
SELECT 
  CURRENT_ACCOUNT() AS current_account,
  CURRENT_ACCOUNT_NAME() AS account_name,
  CURRENT_ORGANIZATION_NAME() AS organization_name;

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- SKIPPED Step 1.4: Create Organization Account
-- Null/empty answers: org_admin_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- Step 1.5: Create Infrastructure Database
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"create-infrastructure-database"}';

-- ============================================================================
-- CREATE INFRASTRUCTURE DATABASE
-- ============================================================================
-- This script creates the central Infrastructure Database for platform
-- metadata, governance objects, and administrative resources
-- ============================================================================

USE ROLE SYSADMIN;

-- ============================================================================
-- STEP 1: CREATE INFRASTRUCTURE DATABASE
-- ============================================================================

CREATE DATABASE IF NOT EXISTS INFRA
  COMMENT = 'Infrastructure database for platform-wide metadata and governance objects';

-- ============================================================================
-- STEP 2: CREATE GOVERNANCE SCHEMA WITH MANAGED ACCESS
-- ============================================================================
-- Managed Access ensures only the schema owner can grant privileges
-- This schema will store tags, network rules, and governance policies

USE DATABASE INFRA;

CREATE SCHEMA IF NOT EXISTS GOVERNANCE
  WITH MANAGED ACCESS
  COMMENT = 'Schema for governance policies, tags, and security objects';

-- ============================================================================
-- STEP 3: SET UP ACCESS CONTROL
-- ============================================================================

-- Grant USAGE on database to SYSADMIN and SECURITYADMIN
GRANT USAGE ON DATABASE INFRA TO ROLE SYSADMIN;
GRANT USAGE ON DATABASE INFRA TO ROLE SECURITYADMIN;

-- Grant USAGE on schema
GRANT USAGE ON SCHEMA INFRA.GOVERNANCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA INFRA.GOVERNANCE TO ROLE SECURITYADMIN;

-- Grant CREATE TAG privilege to allow tag creation in later steps
GRANT CREATE TAG ON SCHEMA INFRA.GOVERNANCE TO ROLE SYSADMIN;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify database exists
SHOW DATABASES LIKE 'INFRA';

-- Verify schema with Managed Access
SHOW SCHEMAS IN DATABASE INFRA;
DESC SCHEMA INFRA.GOVERNANCE;

/*
============================================================================
NEXT STEPS
============================================================================
The Governance schema is now ready to store platform-wide objects.

In subsequent steps, you will create:
- Tags (DOMAIN, ENVIRONMENT, DATAPRODUCT, etc.) for cost allocation and to standardize account and/or data object naming conventions
- Network rules for IP allowlisting
- Governance views and procedures

============================================================================
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.6: Define Domains, Environments, and Object Naming Conventions
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"define-domains-environments-and-object-naming-conventions"}';

-- ============================================================================
-- DEFINE DOMAINS, ENVIRONMENTS & NAMING CONVENTIONS
-- ============================================================================
-- This script creates FinOps tags and documents naming conventions
-- Execute in your Organization Account (if created) or primary account
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INFRA;
USE SCHEMA GOVERNANCE;

-- ============================================================================
-- STEP 1: CREATE DOMAIN AND ENVIRONMENT TAGS
-- ============================================================================
-- These tags have restricted ALLOWED_VALUES based on your selections

-- DOMAIN tag - identifies business unit ownership
CREATE TAG IF NOT EXISTS domain
  ALLOWED_VALUES
    'PAYMENTS',
    'RISK',
    'LEDGER',
    'CUSTOMER',
    'COMPLIANCE'

  COMMENT = 'Business domain/unit for cost allocation and governance';

-- ENVIRONMENT tag - identifies SDLC stage
CREATE TAG IF NOT EXISTS environment
  ALLOWED_VALUES
    'DEV',
    'STG',
    'PROD'

  COMMENT = 'Environment/SDLC stage for cost allocation and governance';

-- ============================================================================
-- STEP 2: CREATE ADDITIONAL FINOPS TAGS
-- ============================================================================
-- We create these tags now (even though values aren't defined yet) because:
-- 1. They ensure immediate availability when data products are created
-- 2. They centralize all FinOps tags in the same Governance schema
-- 3. They align with naming convention components for consistent reporting
--
-- Unlike DOMAIN and ENVIRONMENT, these tags accept ANY value, allowing
-- flexibility when defining data products in subsequent workflows.
-- ============================================================================

-- DATAPRODUCT tag - identifies the specific data product
-- Values defined per data product (e.g., ANALYTICS, REPORTING, EDW)
CREATE TAG IF NOT EXISTS dataproduct
  COMMENT = 'Data product identifier for cost allocation';

-- WORKLOAD tag - classifies warehouse workload types
-- Recommended values: INGEST, TRANSFORM, BI, ADHOC, ML, ADMIN
CREATE TAG IF NOT EXISTS workload
  COMMENT = 'Workload type for warehouse cost allocation';

-- ZONE tag - classifies database data zones
-- Recommended values: RAW, CURATED, CONSUMPTION, WORKSPACE, ARCHIVE
CREATE TAG IF NOT EXISTS zone
  COMMENT = 'Data zone for database classification';

-- DATA_CLASSIFICATION tag - indicates data sensitivity level
-- Recommended values: PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED
CREATE TAG IF NOT EXISTS data_classification
  COMMENT = 'Data classification level for governance';

-- ============================================================================
-- STEP 3: CREATE NAMING CONVENTION REFERENCE VIEW
-- ============================================================================

CREATE OR REPLACE VIEW naming_convention_reference AS
SELECT
  '<domain>_<dataproduct>_<env>' AS component_order,
  'Single Account' AS account_strategy,
  -- Component inclusion based on account strategy
  TRUE AS include_domain_in_objects,
  TRUE AS include_environment_in_objects,
  -- Naming patterns
  '<DOMAIN>_<DATAPRODUCT>_<ENV>[_<ZONE>]' AS database_pattern,
  '<DOMAIN>_<DATAPRODUCT>_<ENV>_<WORKLOAD>' AS warehouse_pattern,
  '<DOMAIN>_<DATAPRODUCT>_<ENV>_<FUNCTION>' AS role_pattern
;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify all tags were created
SHOW TAGS IN SCHEMA INFRA.GOVERNANCE;

-- View DOMAIN tag allowed values
SHOW TAGS LIKE 'domain' IN SCHEMA INFRA.GOVERNANCE;

-- View ENVIRONMENT tag allowed values
SHOW TAGS LIKE 'environment' IN SCHEMA INFRA.GOVERNANCE;

-- View naming convention reference
SELECT * FROM naming_convention_reference;

/*
============================================================================
CONFIGURATION SUMMARY
============================================================================
Account Strategy: Single Account
Component Order: <domain>_<dataproduct>_<env>

Domains Configured:
- PAYMENTS
- RISK
- LEDGER
- CUSTOMER
- COMPLIANCE

Environments Configured:
- DEV
- STG
- PROD

Tags Created:
- DOMAIN (with allowed values) - for cost allocation by business unit
- ENVIRONMENT (with allowed values) - for cost allocation by SDLC stage
- DATAPRODUCT (any value) - for cost allocation by data product
- WORKLOAD (any value) - for warehouse classification
- ZONE (any value) - for database zone classification
- DATA_CLASSIFICATION (any value) - for data sensitivity governance

Note: Additional tags (DATAPRODUCT, WORKLOAD, ZONE, DATA_CLASSIFICATION) are created
now to ensure immediate availability when data products are configured in later
workflows. These tags align with naming convention components for consistent
FinOps reporting across your platform.
Usage: Both domains and environments will appear in database object names.
============================================================================
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- SKIPPED Step 1.7: Configure Infrastructure Database Replication
-- Null/empty answers: infrastructure_replication_group
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ============================================================================
-- TASK 2: Platform Security & Identity
-- Summary: Configure user provisioning via SCIM or manual management, provision platform administrators, configure single sign-on, create emergency access, implement network security, define authentication policies, and enable multi-factor authentication.
-- Personas: Security Administrator, Identity Team, Platform Administrator
-- Role Requirements: ACCOUNTADMIN privileges, Logged into Organization Account (if created) or primary account
-- External Requirements: Task 1 (Platform Foundation) completed, Identity Provider Access (Okta, Azure AD, etc.), Network Information (corporate IP ranges, VPN endpoints, cloud service IPs), Administrator Details (names and email addresses)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 2.1: Select Identity Management Approach
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"select-identity-management-approach"}';

-- ============================================================================
-- IDENTITY MANAGEMENT APPROACH - SELECTION ONLY
-- ============================================================================
-- User Provisioning: Okta
-- SAML/SSO: Yes - Configure SAML now
-- ============================================================================

-- This step captures your identity management choices.
-- No SQL is generated here - configuration follows in subsequent steps.

/*
SUMMARY:
- User Provisioning Method: Okta
- SAML/SSO Configuration: Yes - Configure SAML now
Next: Configure SCIM Integration to set up automated user provisioning.
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.2: Configure SCIM Integration
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-scim-integration"}';

-- ============================================================================
-- SCIM INTEGRATION SETUP
-- ============================================================================
-- Identity Provider: Okta
-- Integration Name: OKTA_SCIM_INTEGRATION
-- Provisioner Role: OKTA_PROVISIONER
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: CREATE SCIM PROVISIONER ROLE
-- ============================================================================
-- Create a dedicated role for SCIM provisioning
-- This role will own the integration and provisioned users

CREATE ROLE IF NOT EXISTS OKTA_PROVISIONER;

-- Grant necessary privileges to the SCIM provisioner role
GRANT CREATE USER ON ACCOUNT TO ROLE OKTA_PROVISIONER;
GRANT CREATE ROLE ON ACCOUNT TO ROLE OKTA_PROVISIONER;

-- Grant the provisioner role to ACCOUNTADMIN for management
GRANT ROLE OKTA_PROVISIONER TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 2: CREATE NETWORK RULE AND POLICY FOR SCIM (if IPs provided)
-- ============================================================================
-- Restrict SCIM API access to your IdP's IP addresses

-- ============================================================================
-- STEP 4: CREATE SCIM SECURITY INTEGRATION
-- ============================================================================
CREATE OR REPLACE SECURITY INTEGRATION OKTA_SCIM_INTEGRATION
  TYPE = SCIM
  SCIM_CLIENT = 'OKTA'
  RUN_AS_ROLE = 'OKTA_PROVISIONER'
  SYNC_PASSWORD = FALSE
  COMMENT = 'Okta SCIM integration for user provisioning';

-- ============================================================================
-- STEP 5: RETRIEVE SCIM TOKEN AND ENDPOINT
-- ============================================================================
-- IMPORTANT: Run this query and copy the token to your IdP configuration
-- The token is only shown once - save it securely!

SELECT SYSTEM$GENERATE_SCIM_ACCESS_TOKEN('OKTA_SCIM_INTEGRATION') AS scim_token;

/*
SCIM ENDPOINT URL (configure in your IdP):
https://fintechcorp-fintechcorp.snowflakecomputing.com/scim/v2/
*/

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify the role was created
SHOW ROLES LIKE 'OKTA_PROVISIONER';

-- Verify the security integration was created
SHOW SECURITY INTEGRATIONS LIKE 'OKTA_SCIM_INTEGRATION';
DESC SECURITY INTEGRATION OKTA_SCIM_INTEGRATION;

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.3: Provision Account Administrators
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"provision-account-administrators"}';

-- ============================================================================
-- PROVISION ACCOUNT ADMINISTRATORS
-- ============================================================================
-- This script grants administrative roles to SCIM-provisioned users
-- IMPORTANT: Run this AFTER users have been provisioned via SCIM
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: VERIFY USERS EXIST (from SCIM provisioning)
-- ============================================================================
-- Before granting roles, verify the users have been provisioned via SCIM
-- If users don't exist, they need to be assigned to Snowflake in your IdP first

-- Check if user exists: alex@fintechcorp.com
SHOW USERS LIKE 'alex@fintechcorp.com';

-- ============================================================================
-- STEP 2: GRANT ADMINISTRATIVE ROLES
-- ============================================================================
GRANT ROLE ACCOUNTADMIN TO USER "alex@fintechcorp.com";

-- ============================================================================
-- STEP 3: GRANT ROLE HIERARCHY (for ACCOUNTADMIN users)
-- ============================================================================
-- ACCOUNTADMIN users should also have SECURITYADMIN and SYSADMIN
-- to enable proper role usage for day-to-day tasks
GRANT ROLE SECURITYADMIN TO USER "alex@fintechcorp.com";
GRANT ROLE SYSADMIN TO USER "alex@fintechcorp.com";

-- ============================================================================
-- STEP 4: SET DEFAULT ROLES
-- ============================================================================
-- Set appropriate default roles for each administrator
-- Users should use the least-privileged role needed for their work
-- Set default role for alex@fintechcorp.com (use SYSADMIN for day-to-day work)
ALTER USER "alex@fintechcorp.com" SET DEFAULT_ROLE = 'SYSADMIN';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify admin role grants
SELECT 
  grantee_name,
  role,
  granted_by,
  created_on
FROM snowflake.account_usage.grants_to_users
WHERE role IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN')
  AND deleted_on IS NULL
ORDER BY role, grantee_name;

-- ============================================================================
-- POST-PROVISIONING NOTES
-- ============================================================================

/*
Administrators Configured:
- alex@fintechcorp.com - ACCOUNTADMIN

Next Steps:
1. Verify users can log in via SSO (Step 2.3)
2. Configure break-glass emergency access (Step 2.4)
3. Set up network policies (Step 2.5)
4. Enable MFA for all administrators (Step 2.7)
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.4: Create Organization Account Administrators
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"create-organization-account-administrators"}';

-- ============================================================================
-- CREATE ACCOUNT ADMINISTRATORS
-- ============================================================================
-- This script creates administrator users directly in Snowflake
-- (Manual user management - SCIM not configured)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: CREATE ADMINISTRATOR USERS
-- ============================================================================
-- All users are created with MUST_CHANGE_PASSWORD = TRUE for security
-- Initial password should be communicated securely to each user

-- ============================================================================
-- STEP 2: GRANT ADMINISTRATIVE ROLES
-- ============================================================================

-- ============================================================================
-- STEP 3: GRANT ROLE HIERARCHY (for ACCOUNTADMIN users)
-- ============================================================================
-- ACCOUNTADMIN users should also have SECURITYADMIN and SYSADMIN
-- to enable proper role usage for day-to-day tasks

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- List all created users
SHOW USERS;

-- Verify admin role grants
SELECT 
  grantee_name,
  role,
  granted_by,
  created_on
FROM snowflake.account_usage.grants_to_users
WHERE role IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN')
  AND deleted_on IS NULL
ORDER BY role, grantee_name;

-- ============================================================================
-- POST-CREATION STEPS
-- ============================================================================

/*
After running this script:

1. COMMUNICATE INITIAL PASSWORDS SECURELY
   - Use a secure password sharing tool or in-person communication
   - Do NOT send passwords via email or unencrypted channels
   
2. VERIFY USER ACCESS
   - Have each user log in and change their password
   - Confirm they can access Snowflake with their assigned role

3. ENABLE MFA (Enable Multi-Factor Authentication step)
   - All administrative users should enroll in MFA
   - This adds a critical layer of security

4. DOCUMENT ACCESS
   - Record who has administrative access and when it was granted
   - Establish a process for periodic access reviews

Users Created:
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.5: Configure SAML/SSO
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-samlsso"}';

-- ============================================================================
-- SAML SSO CONFIGURATION
-- ============================================================================
-- This script configures SAML Single Sign-On for federated authentication
-- Identity Provider: Okta
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CREATE SAML SECURITY INTEGRATION
-- ============================================================================
-- Note: The certificate should be the full PEM-encoded X.509 certificate
-- from your Identity Provider

CREATE OR REPLACE SECURITY INTEGRATION OKTA_SSO
  TYPE = SAML2
  ENABLED = TRUE
  SAML2_ISSUER = 'http://www.okta.com/REPLACE_WITH_OKTA_ENTITY_ID'
  SAML2_SSO_URL = 'https://fintechcorp.okta.com/app/REPLACE_WITH_OKTA_APP_ID/sso/saml'
  SAML2_PROVIDER = 'CUSTOM'
  SAML2_X509_CERT = 'REPLACE_WITH_OKTA_X509_SIGNING_CERTIFICATE_BASE64_BODY_ONLY'
  SAML2_SP_INITIATED_LOGIN_PAGE_LABEL = 'Okta SSO'
  SAML2_ENABLE_SP_INITIATED = TRUE
  SAML2_SNOWFLAKE_ACS_URL = 'https://fintechcorp-fintechcorp.snowflakecomputing.com/fed/login'
  SAML2_SNOWFLAKE_ISSUER_URL = 'https://fintechcorp-fintechcorp.snowflakecomputing.com'
  COMMENT = 'Okta SAML SSO integration';

-- ============================================================================
-- CONFIGURE LOGIN PAGE (Optional)
-- ============================================================================
-- Enable SSO button on the login page
ALTER ACCOUNT SET SAML_IDENTITY_PROVIDER = 'OKTA_SSO';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify the security integration was created
SHOW SECURITY INTEGRATIONS LIKE 'OKTA_SSO';

-- Get detailed integration settings
DESC SECURITY INTEGRATION OKTA_SSO;

-- ============================================================================
-- TESTING INSTRUCTIONS
-- ============================================================================
-- To test the SAML integration:
-- 
-- 1. SP-Initiated SSO:
--    Navigate to: https://fintechcorp-fintechcorp.snowflakecomputing.com
--    Click "Log in using Okta SSO"
--
-- 2. IdP-Initiated SSO:
--    Log into your IdP and click the Snowflake application tile
--
-- 3. Verify in Snowflake:
--    SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_SESSION();
-- ============================================================================

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.6: Create Break-Glass Emergency Access
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"create-break-glass-emergency-access"}';

-- ============================================================================
-- BREAK-GLASS EMERGENCY ACCESS SETUP
-- ============================================================================
-- This script creates break-glass emergency access account(s)
-- Use these accounts ONLY when SSO/SAML is unavailable
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: CREATE AUTHENTICATION POLICY FOR BREAK-GLASS
-- ============================================================================
-- This policy requires MFA but only allows OTP (one-time passcodes)
-- OTPs can be pre-generated and stored securely for emergency use
-- Restricted to web UI only for security

CREATE OR REPLACE AUTHENTICATION POLICY breakglass_auth_policy
  AUTHENTICATION_METHODS = (PASSWORD)
  MFA_ENROLLMENT = 'REQUIRED'
  MFA_POLICY = (ALLOWED_METHODS = ('OTP'))
  CLIENT_TYPES = (SNOWFLAKE_UI)
  SECURITY_INTEGRATIONS = ()
  COMMENT = 'Authentication policy for break-glass emergency access - password + OTP, UI only';

-- ============================================================================
-- STEP 2: CREATE BREAK-GLASS ACCOUNTS
-- ============================================================================



-- -----------------------------------------------------------------------------
-- Break-Glass Account: BREAKGLASS_ADMIN
-- -----------------------------------------------------------------------------

-- Create network rule for BREAKGLASS_ADMIN
CREATE OR REPLACE NETWORK RULE breakglass_admin_network_rule
  TYPE = IPV4
  MODE = INGRESS
  VALUE_LIST = ('10.0.0.0/8')
  COMMENT = 'Network rule for break-glass account BREAKGLASS_ADMIN';

-- Create network policy for BREAKGLASS_ADMIN
CREATE OR REPLACE NETWORK POLICY breakglass_admin_network_policy
  ALLOWED_NETWORK_RULE_LIST = (breakglass_admin_network_rule)
  COMMENT = 'Network policy for break-glass account BREAKGLASS_ADMIN';

-- Create break-glass user
-- ⚠️  IMPORTANT: Replace <REPLACE_WITH_SECURE_PASSWORD> with a strong, unique password before executing.
--    Password requirements: min 14 chars, 1+ uppercase, 1+ lowercase, 1+ digit, 1+ special character.
--    Do NOT use a shared or reused password. Use a password manager to generate and store it.
CREATE USER IF NOT EXISTS BREAKGLASS_ADMIN
  PASSWORD = '<REPLACE_WITH_SECURE_PASSWORD>'
  EMAIL = 'alex@fintechcorp.com'
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = 'ACCOUNTADMIN'
  DEFAULT_WAREHOUSE = NULL
  COMMENT = 'Break-glass emergency access account - use OTP workflow';

-- Grant ACCOUNTADMIN role for full recovery capabilities
GRANT ROLE ACCOUNTADMIN TO USER BREAKGLASS_ADMIN;

-- Apply the break-glass authentication policy
ALTER USER BREAKGLASS_ADMIN 
  SET AUTHENTICATION POLICY breakglass_auth_policy;
-- Apply the network policy to restrict access by IP
ALTER USER BREAKGLASS_ADMIN 
  SET NETWORK POLICY breakglass_admin_network_policy;

-- ============================================================================
-- STEP 3: GENERATE ONE-TIME PASSCODES (OTPs) FOR BREAK-GLASS ACCESS
-- ============================================================================
-- ⚠️  IMPORTANT: The output of these commands contains the OTPs!
--    Capture and store them securely - they cannot be retrieved later.
--    See the "Capturing OTPs" section above for details.
-- ============================================================================
-- Generate 10 OTPs for BREAKGLASS_ADMIN
--ALTER USER BREAKGLASS_ADMIN ADD MFA METHOD OTP COUNT = 10;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify users were created
SHOW USERS LIKE 'BREAKGLASS_ADMIN';

-- Verify authentication policy
SHOW AUTHENTICATION POLICIES LIKE 'breakglass_auth_policy';

-- Verify network policies
SHOW NETWORK POLICIES;

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.7: Configure Network Rules and Policies
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-network-rules-and-policies"}';

-- ============================================================================
-- NETWORK RULES AND POLICIES CONFIGURATION
-- ============================================================================
-- This script configures network access controls for your Snowflake account
-- Network rules are created in the infrastructure database's governance schema
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INFRA;
USE SCHEMA GOVERNANCE;

-- ============================================================================
-- STEP 1: CREATE ALLOWED NETWORK RULES
-- ============================================================================

-- Network Rule: CORPORATE_NETWORK
CREATE OR REPLACE NETWORK RULE CORPORATE_NETWORK
  TYPE = IPV4
  MODE = INGRESS
  VALUE_LIST = ('10.0.0.0/8')
  COMMENT = 'Allowed network rule: CORPORATE_NETWORK';

-- ============================================================================
-- STEP 3: CREATE NETWORK POLICY
-- ============================================================================
-- Network policies are account-level objects, but reference schema-level rules

CREATE OR REPLACE NETWORK POLICY account_network_policy
  ALLOWED_NETWORK_RULE_LIST = (
    INFRA.GOVERNANCE.CORPORATE_NETWORK
  )
  COMMENT = 'Primary network policy for account access';

-- ============================================================================
-- STEP 4: APPLY NETWORK POLICY
-- ============================================================================
-- Apply network policy at the account level
-- WARNING: Ensure all required IPs are included before running this!
ALTER ACCOUNT SET NETWORK_POLICY = account_network_policy;

-- Note: Break-glass and SCIM users have their own policies that override this

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify network rules were created
SHOW NETWORK RULES;

-- Verify network policy was created
SHOW NETWORK POLICIES;
DESC NETWORK POLICY account_network_policy;

-- Check current account network policy setting
SHOW PARAMETERS LIKE 'NETWORK_POLICY' IN ACCOUNT;

-- ============================================================================
-- TESTING INSTRUCTIONS
-- ============================================================================
-- Before enabling account-level policy:
--
-- 1. Test from an allowed IP:
--    - Connect to Snowflake
--    - Verify access works
--
-- 2. Test from a blocked IP (use mobile data or different network):
--    - Attempt to connect
--    - Verify access is blocked (only if account-level policy is enabled)
--
-- 3. Verify break-glass still works:
--    - Test break-glass account from allowed IPs
--    - Document results
-- ============================================================================

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.8: Configure Authentication Policies
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-authentication-policies"}';

-- ============================================================================
-- AUTHENTICATION POLICIES CONFIGURATION
-- ============================================================================
-- This script configures authentication policies for different user types
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INFRA;

-- ============================================================================
-- STEP 1: CREATE HUMAN USER AUTHENTICATION POLICY
-- ============================================================================
CREATE OR REPLACE AUTHENTICATION POLICY human_user_auth_policy
  AUTHENTICATION_METHODS = (SAML, PASSWORD)
  MFA_ENROLLMENT = 'REQUIRED'
  MFA_POLICY = (ALLOWED_METHODS = ('TOTP', 'PASSKEY'))
  CLIENT_TYPES = (SNOWFLAKE_UI, DRIVERS, SNOWSQL)
  SECURITY_INTEGRATIONS = (OKTA_SSO)
  COMMENT = 'Human user policy - SAML or Password with MFA';

-- ============================================================================
-- STEP 2: CREATE SERVICE ACCOUNT AUTHENTICATION POLICY
-- ============================================================================
CREATE OR REPLACE AUTHENTICATION POLICY service_account_auth_policy
  AUTHENTICATION_METHODS = (OAUTH, KEYPAIR)
  CLIENT_TYPES = (DRIVERS)
  SECURITY_INTEGRATIONS = ()
  COMMENT = 'Service account policy - OAuth, Key Pair, no UI access';

-- ============================================================================
-- STEP 3: APPLY AUTHENTICATION POLICIES
-- ============================================================================
-- Apply human user policy at account level
ALTER ACCOUNT SET AUTHENTICATION POLICY human_user_auth_policy;

-- Note: Break-glass user already has breakglass_auth_policy applied (from Create Break-Glass Emergency Access step)

-- ============================================================================
-- STEP 4: DOCUMENT POLICY ASSIGNMENTS
-- ============================================================================

-- For service accounts created in Data Product Configuration:
-- ALTER USER <service_account> SET AUTHENTICATION POLICY service_account_auth_policy;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- List all authentication policies
SHOW AUTHENTICATION POLICIES;

-- Describe each policy
DESC AUTHENTICATION POLICY human_user_auth_policy;
DESC AUTHENTICATION POLICY service_account_auth_policy;
DESC AUTHENTICATION POLICY breakglass_auth_policy;

-- Check account-level authentication policy
SHOW PARAMETERS LIKE 'AUTHENTICATION_POLICY' IN ACCOUNT;

-- List users and their authentication policies
SELECT 
  name,
  login_name,
  email,
  authentication_policy,
  has_mfa
FROM snowflake.account_usage.users
WHERE deleted_on IS NULL
ORDER BY name;

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.9: Enable Multi-Factor Authentication
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"enable-multi-factor-authentication"}';

-- ============================================================================
-- MFA VERIFICATION AND MONITORING
-- ============================================================================
-- This script provides queries to monitor MFA enrollment status
-- No configuration changes are made - MFA enforcement is via authentication policies
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CHECK CURRENT MFA SETTINGS
-- ============================================================================

-- View account-level MFA parameters
SHOW PARAMETERS LIKE '%MFA%' IN ACCOUNT;

-- ============================================================================
-- CHECK MFA ENROLLMENT STATUS - ADMIN USERS
-- ============================================================================

-- Check if administrative users have MFA enrolled
SELECT 
  name,
  login_name,
  email,
  has_mfa,
  ext_authn_uid,
  created_on,
  last_success_login
FROM snowflake.account_usage.users
WHERE deleted_on IS NULL
  AND name IN (
    'alex@fintechcorp.com'
  )
ORDER BY has_mfa DESC, name;

-- ============================================================================
-- CHECK MFA ENROLLMENT STATUS - ALL USERS
-- ============================================================================

-- Summary of MFA enrollment across all users
SELECT 
  CASE WHEN has_mfa THEN 'MFA Enrolled' ELSE 'MFA Not Enrolled' END as mfa_status,
  COUNT(*) as user_count
FROM snowflake.account_usage.users
WHERE deleted_on IS NULL
GROUP BY has_mfa;

-- Detailed list of users without MFA
SELECT 
  name,
  login_name,
  email,
  created_on,
  last_success_login
FROM snowflake.account_usage.users
WHERE deleted_on IS NULL
  AND has_mfa = FALSE
  AND name NOT LIKE '%SERVICE%'
  AND name NOT LIKE '%SVC%'
  AND name != 'BREAKGLASS_ADMIN'
ORDER BY last_success_login DESC;

-- ============================================================================
-- MFA AUDIT QUERIES
-- ============================================================================

-- Recent MFA enrollment events
SELECT 
  event_timestamp,
  user_name,
  event_type,
  is_success
FROM snowflake.account_usage.login_history
WHERE event_type LIKE '%MFA%'
  AND event_timestamp > DATEADD(day, -30, CURRENT_TIMESTAMP())
ORDER BY event_timestamp DESC
LIMIT 100;

-- Failed login attempts (potential MFA issues)
SELECT 
  event_timestamp,
  user_name,
  client_ip,
  reported_client_type,
  error_code,
  error_message
FROM snowflake.account_usage.login_history
WHERE is_success = FALSE
  AND event_timestamp > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY event_timestamp DESC;

-- ============================================================================
-- REMINDER: MFA GRACE PERIOD
-- ============================================================================
-- 
-- Timeline: Immediately - Require MFA now
-- 
-- If using "Immediately":
--   - Users must enroll on next login
--   - Have support available for issues
--
-- If using grace period:
--   - Users can log in without MFA during grace period
--   - They will see enrollment prompts
--   - After grace period, MFA is required
--
-- To manually disable a user's access until they enroll:
-- ALTER USER <username> SET DISABLED = TRUE;
-- 
-- To re-enable after enrollment:
-- ALTER USER <username> SET DISABLED = FALSE;
-- ============================================================================

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 3: Platform Cost Management
-- Summary: Set up Snowflake's native budget feature for automated spending alerts, configure account-level resource monitors with hard limits, extend the tagging framework with cost center and ownership tracking, and create cost reporting views.
-- Personas: FinOps Team, Finance Team, Platform Administrator
-- Role Requirements: ACCOUNTADMIN role access
-- External Requirements: Task 1 (Platform Foundation) completed, Task 2 (Security & Identity Configuration) completed, Estimated monthly credit budget from finance team, List of cost centers for chargeback (if applicable)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 3.1: Enable Spending Budgets
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"enable-spending-budgets"}';

-- ============================================================================
-- ENABLE SPENDING BUDGETS - DECISION DOCUMENTATION
-- ============================================================================
-- This step captures a foundational decision about budget usage.
-- Implementation SQL follows in the Configure Spending Budgets step based on specific configuration inputs.
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CURRENT ACCOUNT SPENDING OVERVIEW
-- ============================================================================
-- Review current spending to inform budget decisions

-- Current month credit usage
SELECT 
  DATE_TRUNC('month', start_time) AS month,
  SUM(credits_used) AS total_credits
FROM snowflake.account_usage.metering_history
WHERE start_time >= DATE_TRUNC('month', CURRENT_DATE())
GROUP BY DATE_TRUNC('month', start_time);

-- Credit usage by service type (last 30 days)
SELECT 
  service_type,
  SUM(credits_used) AS credits_used,
  ROUND(SUM(credits_used) / (SELECT SUM(credits_used) FROM snowflake.account_usage.metering_history WHERE start_time >= DATEADD(day, -30, CURRENT_DATE())) * 100, 2) AS percentage
FROM snowflake.account_usage.metering_history
WHERE start_time >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY service_type
ORDER BY credits_used DESC;

-- ============================================================================
-- DECISION DOCUMENTATION
-- ============================================================================

/*
Budget Decision: Yes

Snowflake native budgets will be configured in the Configure Spending Budgets step with:
- Monthly spending limit (in credits)
- Email addresses for alert recipients
- Refresh interval for spending updates
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.2: Configure Spending Budgets
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-spending-budgets"}';

-- ============================================================================
-- SNOWFLAKE NATIVE BUDGET CONFIGURATION
-- ============================================================================
-- Monthly Budget: 3000 credits
-- Notification Threshold: 75%
-- Notification Method: Email
-- Refresh Interval: 1 hour (frequent monitoring)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: ACTIVATE ACCOUNT BUDGET
-- ============================================================================

CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!ACTIVATE();

-- ============================================================================
-- STEP 2: CONFIGURE BUDGET SETTINGS
-- ============================================================================

-- Set the monthly spending limit
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_SPENDING_LIMIT(3000);

-- Set the notification threshold (alerts when projected spending > 75%)
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_NOTIFICATION_THRESHOLD(75);

-- ============================================================================
-- STEP 3: ADD EMAIL NOTIFICATION RECIPIENTS
-- ============================================================================

CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_EMAIL_NOTIFICATIONS('alex@fintechcorp.com');

-- ============================================================================
-- STEP 4: SET BUDGET REFRESH INTERVAL TO 1 HOUR
-- ============================================================================
-- Note: 1-hour refresh increases compute cost by ~12x compared to default

CALL SYSTEM$SET_BUDGET_REFRESH_TIER('HOURLY');

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify budget is active and check settings
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!GET_SPENDING_LIMIT();
CALL SYSTEM$GET_BUDGET_REFRESH_TIER();

-- Check current spending against budget
SELECT 
  DATE_TRUNC('month', CURRENT_DATE()) AS budget_month,
  3000 AS budget_limit,
  75 AS threshold_percent,
  ROUND(3000 * 75 / 100, 0) AS alert_trigger_credits,
  SUM(credits_used) AS credits_used_to_date,
  ROUND(SUM(credits_used) / 3000 * 100, 2) AS percentage_used
FROM snowflake.account_usage.metering_history
WHERE start_time >= DATE_TRUNC('month', CURRENT_DATE());

-- ============================================================================
-- OPTIONAL: UPGRADE TO WEBHOOK NOTIFICATIONS (FUTURE)
-- ============================================================================
-- If you want to receive alerts in Slack/Teams instead of email, run:
--
-- 1. Create a notification integration:
-- CREATE OR REPLACE NOTIFICATION INTEGRATION budget_slack_integration
--   TYPE = WEBHOOK
--   ENABLED = TRUE
--   WEBHOOK_URL = '<YOUR_SLACK_WEBHOOK_URL>'
--   WEBHOOK_BODY_TEMPLATE = '{"text": "Snowflake Budget Alert: <SNOWFLAKE_WEBHOOK_MESSAGE>"}'
--   COMMENT = 'Slack webhook for budget notifications';
--
-- 2. Add the integration to your budget:
-- CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!ADD_NOTIFICATION_INTEGRATION('budget_slack_integration');
--
-- See: https://docs.snowflake.com/en/user-guide/budgets/notifications

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.3: Enable Resource Monitors
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"enable-resource-monitors"}';

-- ============================================================================
-- ENABLE RESOURCE MONITORS - DECISION DOCUMENTATION
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CURRENT RESOURCE MONITOR STATUS
-- ============================================================================

SHOW RESOURCE MONITORS;
SHOW PARAMETERS LIKE 'RESOURCE_MONITOR' IN ACCOUNT;

-- ============================================================================
-- CREDIT USAGE ANALYSIS
-- ============================================================================

-- Daily credit usage for last 30 days
SELECT 
  DATE_TRUNC('day', start_time) AS usage_date,
  SUM(credits_used) AS daily_credits
FROM snowflake.account_usage.metering_history
WHERE start_time >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY DATE_TRUNC('day', start_time)
ORDER BY usage_date DESC;

-- Peak usage analysis
SELECT 
  MAX(daily_credits) AS peak_daily_credits,
  AVG(daily_credits) AS avg_daily_credits,
  MAX(daily_credits) * 30 AS projected_monthly_peak
FROM (
  SELECT 
    DATE_TRUNC('day', start_time) AS usage_date,
    SUM(credits_used) AS daily_credits
  FROM snowflake.account_usage.metering_history
  WHERE start_time >= DATEADD(day, -30, CURRENT_DATE())
  GROUP BY DATE_TRUNC('day', start_time)
);

-- ============================================================================
-- DECISION DOCUMENTATION
-- ============================================================================

/*
Resource Monitor Decision: Yes

Account-level resource monitor will be configured in the Configure Resource Monitors step.
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.4: Configure Resource Monitors
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-resource-monitors"}';

-- ============================================================================
-- ACCOUNT RESOURCE MONITOR CONFIGURATION
-- ============================================================================
-- Credit Limit: 3000 credits
-- Action: Suspend After Current Queries
-- Reset Frequency: Monthly
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: CREATE ACCOUNT-LEVEL RESOURCE MONITOR
-- ============================================================================

CREATE OR REPLACE RESOURCE MONITOR account_resource_monitor
  WITH CREDIT_QUOTA = 3000
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;

-- ============================================================================
-- STEP 2: APPLY RESOURCE MONITOR TO ACCOUNT
-- ============================================================================

ALTER ACCOUNT SET RESOURCE_MONITOR = account_resource_monitor;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SHOW RESOURCE MONITORS LIKE 'account_resource_monitor';
SHOW PARAMETERS LIKE 'RESOURCE_MONITOR' IN ACCOUNT;

-- To view detailed credit usage, query the Account Usage view:
-- SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
--   WHERE name = 'ACCOUNT_RESOURCE_MONITOR';

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.5: Enable Cost Allocation Tags
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"enable-cost-allocation-tags"}';

-- ============================================================================
-- ENABLE COST ALLOCATION TAGS - DECISION DOCUMENTATION
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INFRA;
USE SCHEMA GOVERNANCE;

-- ============================================================================
-- REVIEW EXISTING TAGS (from Task 1)
-- ============================================================================

SHOW TAGS IN SCHEMA INFRA.GOVERNANCE;

-- ============================================================================
-- DECISION DOCUMENTATION
-- ============================================================================

/*
Cost Allocation Tags Decision: Yes

Additional cost allocation tags will be created in the Configure Cost Allocation Tags step:
- cost_center
- owner
- project
- application
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.6: Configure Cost Allocation Tags
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-cost-allocation-tags"}';

-- ============================================================================
-- COST ALLOCATION TAGS CONFIGURATION
-- ============================================================================
-- Additional Tags: Cost Center, Owner, Project
-- Enforcement: Yes (all resources)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INFRA;
USE SCHEMA GOVERNANCE;

-- ============================================================================
-- STEP 1: CREATE ADDITIONAL COST ALLOCATION TAGS
-- ============================================================================
CREATE TAG IF NOT EXISTS cost_center
  COMMENT = 'Accounting cost center code for chargeback';
CREATE TAG IF NOT EXISTS owner
  COMMENT = 'Team or individual responsible for the resource';
CREATE TAG IF NOT EXISTS project
  COMMENT = 'Project or initiative name for cost allocation';

-- ============================================================================
-- STEP 2: CREATE COST REPORTING VIEWS
-- ============================================================================

-- View: Credit usage by domain
CREATE OR REPLACE VIEW cost_by_domain AS
SELECT 
  tr.tag_value AS domain,
  DATE_TRUNC('day', wm.start_time) AS usage_date,
  SUM(wm.credits_used) AS total_credits
FROM snowflake.account_usage.warehouse_metering_history wm
JOIN snowflake.account_usage.tag_references tr
  ON wm.warehouse_name = tr.object_name
  AND tr.domain = 'WAREHOUSE'
  AND tr.tag_name = 'DOMAIN'
  AND tr.object_deleted IS NULL
WHERE wm.start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY tr.tag_value, DATE_TRUNC('day', wm.start_time)
ORDER BY usage_date DESC, total_credits DESC;

-- View: Credit usage by environment
CREATE OR REPLACE VIEW cost_by_environment AS
SELECT 
  tr.tag_value AS environment,
  DATE_TRUNC('day', wm.start_time) AS usage_date,
  SUM(wm.credits_used) AS total_credits
FROM snowflake.account_usage.warehouse_metering_history wm
JOIN snowflake.account_usage.tag_references tr
  ON wm.warehouse_name = tr.object_name
  AND tr.domain = 'WAREHOUSE'
  AND tr.tag_name = 'ENVIRONMENT'
  AND tr.object_deleted IS NULL
WHERE wm.start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY tr.tag_value, DATE_TRUNC('day', wm.start_time)
ORDER BY usage_date DESC, total_credits DESC;

-- View: Untagged warehouses
CREATE OR REPLACE VIEW untagged_warehouses AS
SELECT 
  w.name AS warehouse_name,
  w.size,
  w.created_on
FROM snowflake.account_usage.warehouses w
LEFT JOIN (
  SELECT DISTINCT object_name 
  FROM snowflake.account_usage.tag_references 
  WHERE tag_name = 'DOMAIN' AND domain = 'WAREHOUSE' AND object_deleted IS NULL
) d ON w.name = d.object_name
WHERE w.deleted IS NULL
  AND d.object_name IS NULL
ORDER BY w.created_on DESC;

-- Grant access to cost views
GRANT SELECT ON VIEW cost_by_domain TO ROLE SYSADMIN;
GRANT SELECT ON VIEW cost_by_environment TO ROLE SYSADMIN;
GRANT SELECT ON VIEW untagged_warehouses TO ROLE SYSADMIN;

-- ============================================================================
-- STEP 3: TAG THE INFRASTRUCTURE DATABASE
-- ============================================================================
ALTER DATABASE INFRA SET TAG 
  INFRA.GOVERNANCE.owner = 'Platform Team';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SHOW TAGS IN SCHEMA INFRA.GOVERNANCE;

SELECT * FROM cost_by_domain LIMIT 10;
SELECT * FROM cost_by_environment LIMIT 10;
SELECT * FROM untagged_warehouses;

-- ============================================================================
-- PLATFORM FOUNDATION SETUP COMPLETE
-- ============================================================================
/*
Task 3: Cost Management Summary

Spending Budgets:
- Status: Enabled
- Monthly Limit: 3000 credits

Resource Monitors:
- Status: Enabled
- Credit Limit: 3000 credits
- Action: Suspend After Current Queries

Cost Allocation Tags:
- Core tags: domain, environment, dataproduct, workload, zone, data_classification
- Additional tags: Cost Center, Owner, Project

NEXT STEPS:
1. Apply tags to existing warehouses and databases
2. Set up regular cost review meetings
3. Proceed to Data Product Configuration workflow
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 4: Platform Observability
-- Summary: Configure account-level telemetry parameters to enable logging, metrics, and tracing for stored procedures, UDFs, and handler code in the Organization Account.
-- Personas: Platform Administrator, SRE / Observability Team
-- Role Requirements: ACCOUNTADMIN role access
-- External Requirements: Task 1 (Platform Foundation) completed, Task 2 (Security & Identity Configuration) completed
-- ============================================================================


-- ------------------------------------------------------------
-- Step 4.1: Configure Telemetry Parameters
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4d563df2","step":"configure-telemetry-parameters"}';

-- ============================================================================
-- STEP: Configure Telemetry Parameters
-- ============================================================================
-- Sets account-level telemetry parameters to enable logging, metrics, and
-- tracing for stored procedures, UDFs, and other handler code. Telemetry
-- data is written to the default event table (SNOWFLAKE.TELEMETRY.EVENTS).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Set execution context
-- ----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

-- ----------------------------------------------------------------------------
-- Set Event Table
-- ----------------------------------------------------------------------------
-- Every Snowflake account contains a pre-existing event table at
-- SNOWFLAKE.TELEMETRY.EVENTS. The EVENT_TABLE parameter has no default value,
-- so it must be explicitly set for telemetry data to be collected.
ALTER ACCOUNT SET EVENT_TABLE = 'SNOWFLAKE.TELEMETRY.EVENTS';

-- ----------------------------------------------------------------------------
-- Configure Log Level
-- ----------------------------------------------------------------------------
-- Controls which severity of log messages are captured from handler code.
-- Values (most to least verbose): TRACE, DEBUG, INFO, WARN, ERROR, FATAL, OFF
-- When set at multiple levels, the more verbose level wins.

ALTER ACCOUNT SET LOG_LEVEL = 'INFO';

-- ----------------------------------------------------------------------------
-- Configure Metric Level
-- ----------------------------------------------------------------------------
-- Controls whether execution metrics are collected from handler code.
-- Values: ALL (collect metrics), NONE (disabled)

ALTER ACCOUNT SET METRIC_LEVEL = 'ALL';

-- ----------------------------------------------------------------------------
-- Configure Trace Level
-- ----------------------------------------------------------------------------
-- Controls whether trace spans are captured from handler code execution.
-- Values: ALWAYS (always capture), ON_EVENT (capture when events added), OFF
-- IMPORTANT: Requires LOG_LEVEL to not be OFF.

ALTER ACCOUNT SET TRACE_LEVEL = 'ON_EVENT';

-- ----------------------------------------------------------------------------
-- Configure SQL Trace Query Text
-- ----------------------------------------------------------------------------
-- Controls whether SQL text of traced statements is captured in the event table.
-- Values: ON (capture up to 1024 chars), OFF (do not capture)
-- Disable if SQL may contain sensitive information.

ALTER ACCOUNT SET SQL_TRACE_QUERY_TEXT = 'OFF';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify all telemetry parameters are set correctly
SHOW PARAMETERS LIKE 'EVENT_TABLE' IN ACCOUNT;
SHOW PARAMETERS LIKE 'LOG_LEVEL' IN ACCOUNT;
SHOW PARAMETERS LIKE 'METRIC_LEVEL' IN ACCOUNT;
SHOW PARAMETERS LIKE 'TRACE_LEVEL' IN ACCOUNT;
SHOW PARAMETERS LIKE 'SQL_TRACE_QUERY_TEXT' IN ACCOUNT;

-- Check for recent telemetry data (may take a few minutes to populate)
SELECT RECORD_TYPE, COUNT(*) AS record_count
FROM SNOWFLAKE.TELEMETRY.EVENTS
WHERE TIMESTAMP > DATEADD('hour', -1, CURRENT_TIMESTAMP())
GROUP BY RECORD_TYPE;


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;
