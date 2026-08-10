-- ============================================================
-- RENDERED JOURNEY: Account Creation
-- Generated: 2026-08-10 14:52:52
-- Blueprint: account-creation
-- Language: sql
-- ============================================================


-- ============================================================================
-- TASK 1: Account Provisioning
-- Summary: Define the new account's purpose (domain, environment, description), configure account parameters (edition, region, initial administrator), create the account in your Snowflake organization, and establish access to shared infrastructure objects.
-- Personas: Platform Administrator, Cloud Team, Security Team
-- Role Requirements: ORGADMIN role access in the Organization Account
-- External Requirements: Platform Foundation workflow completed with Multi-Account strategy (recommended), Infrastructure Database Sharing configured (Step 1.8 of Platform Foundation)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 1.1: Confirm Account Strategy
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4e7081df","step":"confirm-account-strategy"}';

-- ============================================================================
-- CONFIRM ACCOUNT STRATEGY
-- ============================================================================
-- Strategy: Single Account
-- ============================================================================

-- This step confirms the multi-account strategy for your organization.
-- No SQL is generated here - this captures organizational configuration.

/*
ACCOUNT STRATEGY CONFIRMATION
==============================
Strategy: Single Account

This is an organization-level setting that applies to all accounts.

DOMAIN + ENVIRONMENT STRATEGY
- Each account = one domain-environment combination
- Maximum isolation between domains and environments
*/

-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- SKIPPED Step 1.2: Define Account Purpose - Domain
-- Null/empty answers: account_domain
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 1.3: Define Account Purpose - Environment
-- Null/empty answers: account_environment
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 1.4: Define Account Purpose - Domain + Environment
-- Null/empty answers: account_domain
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 1.5: Configure Account Parameters
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 1.6: Create Account
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 1.7: Create Infrastructure Database Replica
-- Null/empty answers: infrastructure_replication_group
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ============================================================================
-- TASK 2: Account Security & Identity
-- Summary: Configure user provisioning (SCIM or manual), establish administrator access, set up network rules and policies, configure authentication policies, create break-glass emergency access, and enable multi-factor authentication.
-- Personas: Security Administrator, Platform Administrator, Network Team
-- Role Requirements: ACCOUNTADMIN role access, Logged into the new account
-- External Requirements: Account created and accessible (Task 1 completed), Infrastructure share consumed, Identity Provider selection (Okta, Azure, None), SAML/SSO configuration preference, Network policy IP ranges
-- ============================================================================


-- ------------------------------------------------------------
-- SKIPPED Step 2.1: Select Security Configuration Approach
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.2: Configure Account SCIM Integration
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.3: Create Account Administrators
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.4: Configure Account SAML/SSO
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.5: Create Account Break-Glass Emergency Access
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.6: Configure Account Custom Network Rules
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- Step 2.7: Configure Network Rules and Policies
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4e7081df","step":"configure-network-rules-and-policies"}';

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
-- SKIPPED Step 2.8: Apply Organization Network Configuration
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.9: Configure Account Authentication Policies
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 2.10: Enable Account Multi-Factor Authentication
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ============================================================================
-- TASK 3: Account Cost Management
-- Summary: Configure an account-level budget with spending limits and alerts, set up a resource monitor for active cost control, and apply domain and environment tags for cost allocation and FinOps reporting.
-- Personas: FinOps Team, Platform Administrator, Finance Team
-- Role Requirements: ACCOUNTADMIN role access
-- External Requirements: Security & Identity Configuration complete (Task 2), Infrastructure share consumed (access to governance objects), Knowledge of expected credit consumption for this account, List of stakeholders to receive budget alerts
-- ============================================================================


-- ------------------------------------------------------------
-- SKIPPED Step 3.1: Configure Account Budget
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 3.2: Configure Account Resource Monitor
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- SKIPPED Step 3.3: Apply Cost Allocation Tags
-- Null/empty answers: new_account_name
-- Provide values for the above variables to render this step.
-- ------------------------------------------------------------


-- ============================================================================
-- TASK 4: Account Observability
-- Summary: Configure account-level telemetry parameters to enable logging, metrics, and tracing for stored procedures, UDFs, and handler code in the newly created account.
-- Personas: Platform Administrator, SRE / Observability Team
-- Role Requirements: ACCOUNTADMIN role access
-- External Requirements: Security & Identity Configuration complete (Task 2)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 4.1: Configure Telemetry Parameters
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_4e7081df","step":"configure-telemetry-parameters"}';

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
