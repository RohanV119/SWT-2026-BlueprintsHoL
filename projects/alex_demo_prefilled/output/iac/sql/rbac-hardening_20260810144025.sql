-- ============================================================
-- RENDERED JOURNEY: RBAC Hardening
-- Generated: 2026-08-10 14:40:25
-- Blueprint: rbac-hardening
-- Language: sql
-- ============================================================


-- ============================================================================
-- TASK 1: RBAC Assessment
-- Summary: Discover the current state of role-based access controls in your Snowflake account by auditing the role hierarchy, privilege grants, and stale access patterns. All queries are read-only diagnostics.
-- Personas: Security Administrator, Compliance Team, Platform Administrator
-- Role Requirements: SECURITYADMIN, ACCOUNTADMIN
-- External Requirements: Account accessible with SECURITYADMIN or ACCOUNTADMIN role, SNOWFLAKE database IMPORTED PRIVILEGES granted (for Account Usage views), Data Product Setup completed (if auditing data product roles)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 1.1: Audit Role Hierarchy
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"audit-role-hierarchy"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- AUDIT ROLE HIERARCHY
-- ============================================================================
-- Audit Scope: Full Account
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: ACCOUNTADMIN (for Account Usage views)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: COMPLETE ROLE HIERARCHY
-- ============================================================================
-- Recursive query showing the full role-to-role grant tree.
-- Each row represents a parent-child relationship between roles.

WITH RECURSIVE role_hierarchy AS (
  -- Base: all direct role-to-role grants
  SELECT
    name AS child_role,
    grantee_name AS parent_role,
    1 AS depth
  FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
  WHERE granted_on = 'ROLE'
    AND privilege = 'USAGE'
    AND deleted_on IS NULL

  UNION ALL

  -- Recursive: walk up the tree
  SELECT
    rh.child_role,
    g.grantee_name AS parent_role,
    rh.depth + 1
  FROM role_hierarchy rh
  JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES g
    ON g.name = rh.parent_role
    AND g.granted_on = 'ROLE'
    AND g.privilege = 'USAGE'
    AND g.deleted_on IS NULL
  WHERE rh.depth < 10
)
SELECT
  child_role,
  parent_role,
  depth
FROM role_hierarchy
ORDER BY depth, parent_role, child_role;

-- ============================================================================
-- STEP 2: ORPHANED ROLES
-- ============================================================================
-- Find roles that are not granted to any parent role.
-- These roles are unreachable from the standard hierarchy and may indicate
-- incomplete setup or manual role creation.

SELECT r.name AS orphaned_role,
       r.created_on,
       r.owner,
       r.comment
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES r
WHERE r.deleted_on IS NULL
  AND r.name NOT IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN', 'PUBLIC', 'ORGADMIN')
  AND r.name NOT IN (
    SELECT DISTINCT name
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
    WHERE granted_on = 'ROLE'
      AND privilege = 'USAGE'
      AND deleted_on IS NULL
  )
ORDER BY r.created_on DESC;

-- ============================================================================
-- STEP 3: EXCESSIVE HIERARCHY DEPTH
-- ============================================================================
-- Find roles with hierarchy depth greater than 5 levels.
-- Deep hierarchies are harder to audit and may indicate design issues.

WITH RECURSIVE role_depth AS (
  SELECT
    name AS role_name,
    grantee_name AS parent_role,
    1 AS depth
  FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
  WHERE granted_on = 'ROLE'
    AND privilege = 'USAGE'
    AND deleted_on IS NULL

  UNION ALL

  SELECT
    rd.role_name,
    g.grantee_name AS parent_role,
    rd.depth + 1
  FROM role_depth rd
  JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES g
    ON g.name = rd.parent_role
    AND g.granted_on = 'ROLE'
    AND g.privilege = 'USAGE'
    AND g.deleted_on IS NULL
  WHERE rd.depth < 15
)
SELECT
  role_name,
  MAX(depth) AS max_depth
FROM role_depth
GROUP BY role_name
HAVING MAX(depth) > 5
ORDER BY max_depth DESC;

-- ============================================================================
-- STEP 4: ROLE GRANT SUMMARY
-- ============================================================================
-- Overview of role hierarchy health: total roles, orphaned count, max depth.

SELECT
  (SELECT COUNT(*) FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES WHERE deleted_on IS NULL) AS total_roles,
  (SELECT COUNT(*) FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES r
   WHERE r.deleted_on IS NULL
     AND r.name NOT IN ('ACCOUNTADMIN','SECURITYADMIN','SYSADMIN','USERADMIN','PUBLIC','ORGADMIN')
     AND r.name NOT IN (
       SELECT DISTINCT name FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
       WHERE granted_on = 'ROLE' AND privilege = 'USAGE' AND deleted_on IS NULL
     )
  ) AS orphaned_roles;

-- ============================================================================
-- STEP 5: OBJECT OWNERSHIP CONCENTRATION
-- ============================================================================
-- Find roles that own a disproportionate number of objects.
-- Concentrated ownership creates single points of failure: if the role is
-- dropped or misconfigured, all owned objects become inaccessible.

SELECT
  grantee_name AS role_name,
  granted_on AS object_type,
  COUNT(*) AS owned_objects
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE privilege = 'OWNERSHIP'
  AND deleted_on IS NULL
GROUP BY grantee_name, granted_on
HAVING COUNT(*) > 10
ORDER BY owned_objects DESC;

-- ============================================================================
-- STEP 6: OWNERSHIP WITHOUT HIERARCHY PARENT
-- ============================================================================
-- Find roles that own objects but are not granted to any parent role.
-- These roles sit outside the hierarchy: ownership without accountability.
-- If dropped, the owned objects lose their owner and become inaccessible.

SELECT
  gr.grantee_name AS role_name,
  COUNT(*) AS owned_objects
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES gr
WHERE gr.privilege = 'OWNERSHIP'
  AND gr.deleted_on IS NULL
  AND gr.grantee_name NOT IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN', 'PUBLIC', 'ORGADMIN')
  AND gr.grantee_name NOT IN (
    SELECT DISTINCT name
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
    WHERE granted_on = 'ROLE'
      AND privilege = 'USAGE'
      AND deleted_on IS NULL
  )
GROUP BY gr.grantee_name
ORDER BY owned_objects DESC;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Confirm Account Usage access is working
SELECT COUNT(*) AS grant_records
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE deleted_on IS NULL;

/*
ROLE HIERARCHY AUDIT COMPLETE
==============================

Queries generated:
1. Complete role hierarchy tree (recursive)
2. Orphaned roles (no parent grant)
3. Excessive hierarchy depth (>5 levels)
4. Role grant summary statistics
5. Object ownership concentration (>10 objects per role)
6. Ownership without hierarchy parent (structural gap)

Audit Scope: Full Account

NEXT STEPS:
- Review orphaned roles and wire them into the hierarchy or drop them
- Investigate any roles with depth > 5
- Proceed to Step 1.2: Audit Privilege Grants
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.2: Audit Privilege Grants
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"audit-privilege-grants"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- AUDIT PRIVILEGE GRANTS
-- ============================================================================
-- Audit Scope: Full Account
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: ACCOUNTADMIN
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: DIRECT USER GRANTS (ANTI-PATTERN)
-- ============================================================================
-- Find privileges granted directly to users instead of to roles.
-- All access should flow through the role hierarchy.

SELECT
  grantee_name AS user_name,
  privilege,
  granted_on AS object_type,
  name AS object_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND privilege != 'USAGE'  -- Exclude role USAGE grants (those are role assignments)
  AND granted_on != 'ROLE'  -- Exclude role grants
ORDER BY grantee_name, granted_on, name;

-- ============================================================================
-- STEP 2: PUBLIC ROLE GRANTS
-- ============================================================================
-- Find all privileges granted to the PUBLIC role.
-- Every user inherits PUBLIC privileges automatically.

SELECT
  privilege,
  granted_on AS object_type,
  name AS object_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = 'PUBLIC'
  AND deleted_on IS NULL
  AND privilege != 'USAGE'   -- USAGE on ROLE is a role grant, not an object privilege
  AND granted_on != 'ROLE'
ORDER BY granted_on, name;

-- ============================================================================
-- STEP 3: ACCOUNTADMIN ROLE HOLDERS
-- ============================================================================
-- Find all users currently granted the ACCOUNTADMIN role.
-- Best practice: limit to 2-3 break-glass users.

SELECT
  grantee_name AS user_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE name = 'ACCOUNTADMIN'
  AND granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
ORDER BY created_on;

-- ============================================================================
-- STEP 4: ROLES WITH POWERFUL ACCOUNT-LEVEL PRIVILEGES
-- ============================================================================
-- Find roles with high-risk privileges like MANAGE GRANTS, CREATE ROLE,
-- CREATE USER, or OWNERSHIP on account-level objects.

SELECT
  grantee_name AS role_name,
  privilege,
  granted_on AS object_type,
  name AS object_name,
  granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE deleted_on IS NULL
  AND (
    privilege IN ('MANAGE GRANTS', 'CREATE ROLE', 'CREATE USER', 'CREATE ACCOUNT',
                  'MONITOR USAGE', 'MANAGE ACCOUNT SUPPORT CASES')
    OR (privilege = 'OWNERSHIP' AND granted_on = 'ACCOUNT')
  )
  AND grantee_name NOT IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'USERADMIN')
ORDER BY privilege, grantee_name;

-- ============================================================================
-- STEP 5: PRIVILEGE GRANT SUMMARY
-- ============================================================================
-- High-level summary of grant health across the account.

SELECT 'Direct User Grants' AS finding,
       COUNT(*) AS count
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND privilege != 'USAGE'
  AND granted_on != 'ROLE'

UNION ALL

SELECT 'PUBLIC Role Grants' AS finding,
       COUNT(*) AS count
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = 'PUBLIC'
  AND deleted_on IS NULL
  AND privilege != 'USAGE'
  AND granted_on != 'ROLE'

UNION ALL

SELECT 'ACCOUNTADMIN Holders' AS finding,
       COUNT(*) AS count
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE name = 'ACCOUNTADMIN'
  AND granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL;

-- ============================================================================
-- STEP 6: RECENT GRANT VELOCITY
-- ============================================================================
-- Find grants created in the last 30 days, grouped by day.
-- High-churn periods signal ad-hoc access patterns or bulk provisioning events
-- that may have bypassed normal governance controls.

SELECT
  DATE_TRUNC('day', created_on) AS grant_date,
  COUNT(*) AS grants_created,
  COUNT(DISTINCT grantee_name) AS distinct_grantees
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE created_on > DATEADD('day', -30, CURRENT_TIMESTAMP())
  AND deleted_on IS NULL
  AND granted_on != 'ROLE'  -- Object grants only, not role-to-role
GROUP BY grant_date
ORDER BY grant_date DESC;

-- ============================================================
-- WAREHOUSE ACCESS BY NON-ADMIN ROLES (COST VISIBILITY CHECK)
-- ============================================================
-- Surfaces roles with USAGE on warehouses larger than X-Small that are
-- not ACCOUNTADMIN or SYSADMIN. This is an audit/visibility check, not
-- an enforcement recommendation — resource monitors are the primary cost
-- control (they hard-suspend at quota). Use this output to verify that
-- large warehouses have appropriate per-warehouse resource monitors.
--
-- NOTE: SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES does not exist.
-- This query uses SHOW WAREHOUSES + RESULT_SCAN to get warehouse metadata.
SHOW WAREHOUSES;

SELECT
    g.grantee_name                                          AS role_name,
    g.name                                                  AS warehouse_name,
    wh."size"                                               AS warehouse_size,
    wh."auto_suspend"                                       AS auto_suspend_seconds,
    wh."resource_monitor"                                   AS resource_monitor
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES g
JOIN TABLE(RESULT_SCAN(LAST_QUERY_ID())) wh
  ON UPPER(wh."name") = UPPER(g.name)
WHERE g.granted_on   = 'WAREHOUSE'
  AND g.privilege    = 'USAGE'
  AND g.deleted_on   IS NULL
  AND wh."size"      NOT IN ('X-Small')
  AND g.grantee_name NOT IN ('ACCOUNTADMIN', 'SYSADMIN')
ORDER BY wh."size" DESC, g.grantee_name;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Quick check: total privilege grants in account
SELECT COUNT(*) AS total_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE deleted_on IS NULL;

/*
PRIVILEGE GRANT AUDIT COMPLETE
===============================

Queries generated:
1. Direct user grants (anti-pattern - should be on roles)
2. PUBLIC role grants (exposure to all users)
3. ACCOUNTADMIN holders (should be 2-3 break-glass users)
4. Roles with powerful account-level privileges
5. Summary statistics
6. Recent grant velocity (last 30 days)
7. Warehouse access by non-admin roles (cost visibility / resource monitor check)

Audit Scope: Full Account

NEXT STEPS:
- Review direct user grants and plan migration to roles (Step 2.3)
- Review PUBLIC grants and plan revocation with exceptions (Step 2.1)
- Confirm ACCOUNTADMIN holders match break-glass policy (Step 2.2)
- Proceed to Step 1.3: Audit Stale Access
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 1.3: Audit Stale Access
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"audit-stale-access"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- AUDIT STALE ACCESS
-- ============================================================================
-- Audit Scope: Full Account
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: ACCOUNTADMIN
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: DORMANT USERS WITH ACTIVE ROLE GRANTS
-- ============================================================================
-- Find users who haven't logged in for 90+ days but still have role grants.
-- These are high-priority candidates for access revocation.

SELECT
  u.name AS user_name,
  u.login_name,
  u.email,
  u.disabled,
  u.last_success_login,
  u.created_on,
  DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) AS days_since_login,
  COUNT(g.name) AS active_role_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS u
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS g
  ON g.grantee_name = u.name
  AND g.granted_on = 'ROLE'
  AND g.privilege = 'USAGE'
  AND g.deleted_on IS NULL
WHERE u.deleted_on IS NULL
  AND u.disabled = 'false'
  AND (
    u.last_success_login IS NULL
    OR DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) > 90
  )
GROUP BY u.name, u.login_name, u.email, u.disabled, u.last_success_login, u.created_on
HAVING COUNT(g.name) > 0
ORDER BY days_since_login DESC NULLS FIRST;

-- ============================================================================
-- STEP 2: USERS WHO HAVE NEVER LOGGED IN
-- ============================================================================
-- Find users with no login history who still have active role grants.
-- These may be pre-provisioned accounts, forgotten test users, or orphaned records.

SELECT
  u.name AS user_name,
  u.login_name,
  u.email,
  u.created_on,
  u.owner,
  DATEDIFF('day', u.created_on, CURRENT_TIMESTAMP()) AS days_since_creation,
  LISTAGG(g.name, ', ') WITHIN GROUP (ORDER BY g.name) AS granted_roles
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS u
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS g
  ON g.grantee_name = u.name
  AND g.granted_on = 'ROLE'
  AND g.privilege = 'USAGE'
  AND g.deleted_on IS NULL
WHERE u.deleted_on IS NULL
  AND u.last_success_login IS NULL
  AND u.disabled = 'false'
GROUP BY u.name, u.login_name, u.email, u.created_on, u.owner
HAVING COUNT(g.name) > 0
ORDER BY u.created_on;

-- ============================================================================
-- STEP 3: UNUSED ROLES (NO ACTIVE USER ASSIGNMENTS)
-- ============================================================================
-- Find roles that are not granted to any user (directly or indirectly).
-- These roles may be orphaned from decommissioned projects.

SELECT
  r.name AS role_name,
  r.created_on,
  r.owner,
  r.comment,
  COUNT(DISTINCT g.grantee_name) AS user_count
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES r
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS g
  ON g.name = r.name
  AND g.granted_on = 'ROLE'
  AND g.privilege = 'USAGE'
  AND g.deleted_on IS NULL
WHERE r.deleted_on IS NULL
  AND r.name NOT IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN', 'PUBLIC', 'ORGADMIN')
GROUP BY r.name, r.created_on, r.owner, r.comment
HAVING COUNT(DISTINCT g.grantee_name) = 0
ORDER BY r.created_on;

-- ============================================================================
-- STEP 4: USER ACCESS HEALTH SUMMARY
-- ============================================================================
-- Bucket all users by their last login activity for a quick health overview.

SELECT
  CASE
    WHEN u.last_success_login IS NULL THEN 'Never Logged In'
    WHEN DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) <= 30 THEN 'Active (< 30 days)'
    WHEN DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) <= 90 THEN 'Stale (30-90 days)'
    ELSE 'Dormant (> 90 days)'
  END AS login_status,
  COUNT(*) AS user_count,
  SUM(CASE WHEN g.grant_count > 0 THEN 1 ELSE 0 END) AS users_with_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS u
LEFT JOIN (
  SELECT grantee_name, COUNT(*) AS grant_count
  FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
  WHERE granted_on = 'ROLE' AND privilege = 'USAGE' AND deleted_on IS NULL
  GROUP BY grantee_name
) g ON g.grantee_name = u.name
WHERE u.deleted_on IS NULL
  AND u.disabled = 'false'
GROUP BY login_status
ORDER BY user_count DESC;

-- ============================================================================
-- STEP 5: ROLE ACCUMULATION PER USER
-- ============================================================================
-- Find users who have been granted more than 10 roles.
-- Over-provisioned users accumulate roles over time through project access,
-- team changes, and one-off requests that never get cleaned up.

SELECT
  grantee_name AS user_name,
  COUNT(*) AS role_count,
  LISTAGG(name, ', ') WITHIN GROUP (ORDER BY name) AS granted_roles
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
GROUP BY grantee_name
HAVING COUNT(*) > 10
ORDER BY role_count DESC;

-- ============================================================
-- STEP 6: MFA ENROLLMENT GAPS
-- ============================================================
-- Finds active human users who have not enrolled in any MFA method.
-- Context: Snowflake BCR 2025_06 is rolling out mandatory MFA enforcement
-- in three phases. Phase 1 (Sep 2025–Jan 2026, currently active) enforces
-- MFA only for Snowsight password logins. Phase 3 (Aug–Oct 2026) will extend
-- enforcement to all password-based interfaces (drivers, BI tools, etc.).
-- Until Phase 3 completes, non-Snowsight auth is still a gap.
-- Additionally, even with MFA_ENROLLMENT = 'REQUIRED' set in an auth policy,
-- users who haven't logged in since the policy was applied won't have enrolled
-- yet. BYPASS_MFA_UNTIL may also create temporary exemptions worth flagging.
--
-- Use HAS_MFA (not the legacy EXT_AUTHN_DUO, which is Duo-specific).
SELECT
    u.name                                              AS user_name,
    u.login_name,
    u.email,
    u.has_mfa,
    u.bypass_mfa_until,
    u.last_success_login,
    u.type,
    DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP) AS days_since_login
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS u
WHERE u.deleted_on IS NULL
  AND u.disabled   = 'false'
  AND u.has_mfa    = FALSE
  AND u.type       NOT IN ('SERVICE', 'LEGACY_SERVICE')
ORDER BY u.last_success_login DESC NULLS LAST;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Quick sanity check: total users and their status
SELECT
  COUNT(*) AS total_users,
  SUM(CASE WHEN disabled = 'true' THEN 1 ELSE 0 END) AS disabled_users,
  SUM(CASE WHEN disabled = 'false' THEN 1 ELSE 0 END) AS active_users
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE deleted_on IS NULL;

/*
STALE ACCESS AUDIT COMPLETE
============================

Queries generated:
1. Dormant users with active role grants (>90 days since login)
2. Users who have never logged in but have role grants
3. Unused roles (no direct user assignments)
4. User access health summary by login activity bucket
5. Role accumulation per user (>10 roles)
6. MFA enrollment gaps (active human users without MFA enrolled)

Audit Scope: Full Account

NEXT STEPS:
- Disable dormant users and revoke their role grants
- Investigate never-logged-in users (pending onboarding vs. orphaned)
- Drop or reassign unused roles
- Proceed to Task 2: Privilege Hardening
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 2: Privilege Hardening
-- Summary: Tighten access controls based on RBAC Assessment findings by revoking unnecessary PUBLIC grants, restricting ACCOUNTADMIN to break-glass users, eliminating direct user-level privileges, and enforcing managed access schemas.
-- Personas: Security Administrator, Platform Administrator
-- Role Requirements: SECURITYADMIN, ACCOUNTADMIN
-- External Requirements: Task 1 (RBAC Assessment) completed and findings reviewed, Agreement on which PUBLIC grants to revoke (exceptions documented), Agreement on authorized ACCOUNTADMIN users (break-glass list), Understanding of which users have direct privileges that need migration
-- ============================================================================


-- ------------------------------------------------------------
-- Step 2.1: Restrict PUBLIC Role Grants
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"restrict-public-role"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- RESTRICT PUBLIC ROLE GRANTS
-- ============================================================================
-- Restrict PUBLIC: Yes
-- Exceptions: 
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- STEP 1: DISCOVER CURRENT PUBLIC GRANTS
-- ============================================================================
-- Run this query first to review all current PUBLIC grants before revoking.

SHOW GRANTS TO ROLE PUBLIC;

-- ============================================================================
-- STEP 2: REVOKE WAREHOUSE USAGE FROM PUBLIC
-- ============================================================================
-- This prevents all users from consuming compute by default.
-- Users must be granted a role with warehouse access.

REVOKE USAGE ON ALL WAREHOUSES IN ACCOUNT FROM ROLE PUBLIC;

-- ============================================================================
-- STEP 3: REVOKE DATABASE AND SCHEMA USAGE FROM PUBLIC
-- ============================================================================
-- Remove default visibility into database structures.
-- NOTE: Review each database below. Exceptions are preserved.

-- Discovery query: find all databases with grants to PUBLIC
-- Use this to generate targeted REVOKE statements for your environment.
SELECT
  privilege,
  granted_on AS object_type,
  name AS object_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "privilege" != 'USAGE' OR "granted_on" != 'ROLE';

-- Revoke all database-level grants from PUBLIC
-- IMPORTANT: This is a broad revocation. Review the discovery query results
-- and comment out any databases that should remain accessible.
REVOKE USAGE ON ALL DATABASES IN ACCOUNT FROM ROLE PUBLIC;

-- Exceptions: re-grant access for approved databases/schemas

-- ============================================================================
-- STEP 4: REVOKE FUNCTION AND PROCEDURE EXECUTION FROM PUBLIC
-- ============================================================================
-- Remove default ability to execute shared functions and procedures.

-- Note: This requires iterating databases. Use the following pattern
-- for each database in your account:
-- REVOKE USAGE ON ALL FUNCTIONS IN DATABASE <db> FROM ROLE PUBLIC;
-- REVOKE USAGE ON ALL PROCEDURES IN DATABASE <db> FROM ROLE PUBLIC;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Confirm PUBLIC grants have been reduced
SHOW GRANTS TO ROLE PUBLIC;

-- Count remaining grants
SELECT COUNT(*) AS remaining_public_grants
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

/*
PUBLIC ROLE RESTRICTION COMPLETE
========================================
Actions taken:
1. Revoked USAGE on all warehouses from PUBLIC
2. Revoked USAGE on all databases from PUBLIC
3. Re-granted exceptions:
   (none)

IMPORTANT: Test with a PUBLIC-only user to verify access is correctly restricted.

NEXT STEPS:
- Verify restricted users can still access required resources
- Proceed to Step 2.2: Enforce Admin Separation of Duties
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.2: Enforce Admin Separation of Duties
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"enforce-admin-separation"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- ENFORCE ADMIN SEPARATION OF DUTIES
-- ============================================================================
-- Authorized ACCOUNTADMIN users:
--   1. ALEX@FINTECHCORP.COM
--   2. BREAKGLASS_ADMIN
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- STEP 1: DISCOVER CURRENT ACCOUNTADMIN HOLDERS
-- ============================================================================
-- Run this first to see who currently has ACCOUNTADMIN.
-- Compare this list against the authorized users below.

SELECT
  grantee_name AS user_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE name = 'ACCOUNTADMIN'
  AND granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
ORDER BY created_on;

-- ============================================================================
-- STEP 2: ENSURE AUTHORIZED USERS HAVE ACCOUNTADMIN
-- ============================================================================
-- Grant ACCOUNTADMIN to all authorized break-glass users.
-- This is idempotent — no harm if they already have it.

-- Authorized break-glass user 1: ALEX@FINTECHCORP.COM
GRANT ROLE ACCOUNTADMIN TO USER ALEX@FINTECHCORP.COM;

-- Authorized break-glass user 2: BREAKGLASS_ADMIN
GRANT ROLE ACCOUNTADMIN TO USER BREAKGLASS_ADMIN;

-- ============================================================================
-- STEP 3: REVOKE ACCOUNTADMIN FROM UNAUTHORIZED USERS
-- ============================================================================
-- IMPORTANT: Review the output of Step 1 before running these statements.
-- For each user in Step 1 that is NOT in the authorized list above,
-- uncomment and run the corresponding REVOKE statement.
--
-- The authorized users are:
--   ALEX@FINTECHCORP.COM
--   BREAKGLASS_ADMIN
--
-- Template (uncomment and replace <USERNAME> for each unauthorized user):
-- REVOKE ROLE ACCOUNTADMIN FROM USER <USERNAME>;

-- Automated discovery and revocation:
-- Run this query to generate REVOKE statements for unauthorized users.
SELECT
  'REVOKE ROLE ACCOUNTADMIN FROM USER ' || grantee_name || ';' AS revoke_statement,
  grantee_name AS unauthorized_user,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE name = 'ACCOUNTADMIN'
  AND granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
  AND grantee_name NOT IN (
    'ALEX@FINTECHCORP.COM',
    'BREAKGLASS_ADMIN'
  )
ORDER BY grantee_name;

-- ============================================================================
-- STEP 4: ENSURE AUTHORIZED USERS ALSO HAVE SECURITYADMIN AND SYSADMIN
-- ============================================================================
-- Break-glass users should also have SECURITYADMIN and SYSADMIN
-- for administrative operations that don't require ACCOUNTADMIN.

GRANT ROLE SECURITYADMIN TO USER ALEX@FINTECHCORP.COM;
GRANT ROLE SYSADMIN TO USER ALEX@FINTECHCORP.COM;

GRANT ROLE SECURITYADMIN TO USER BREAKGLASS_ADMIN;
GRANT ROLE SYSADMIN TO USER BREAKGLASS_ADMIN;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Confirm ACCOUNTADMIN is now limited to authorized users
SELECT
  grantee_name AS user_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE name = 'ACCOUNTADMIN'
  AND granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
ORDER BY grantee_name;

/*
ADMIN SEPARATION OF DUTIES ENFORCED
=====================================

Authorized ACCOUNTADMIN users:
  1. ALEX@FINTECHCORP.COM
  2. BREAKGLASS_ADMIN

Actions:
1. Granted ACCOUNTADMIN to authorized users (idempotent)
2. Generated REVOKE statements for unauthorized users (review Step 3 output)
3. Ensured authorized users also have SECURITYADMIN and SYSADMIN

IMPORTANT: Run the REVOKE statements from Step 3 manually after review.
These are not auto-executed to prevent accidental lockout.

NEXT STEPS:
- Execute REVOKE statements for unauthorized ACCOUNTADMIN holders
- Enable MFA for all authorized ACCOUNTADMIN users
- Configure ACCOUNTADMIN usage alerts (Task 4)
- Proceed to Step 2.3: Revoke Direct User Privileges
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.3: Revoke Direct User Privileges
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"revoke-direct-user-privileges"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- REVOKE DIRECT USER PRIVILEGES
-- ============================================================================
-- Audit Scope: Full Account
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- STEP 1: DISCOVER DIRECT USER GRANTS
-- ============================================================================
-- Find all object-level privileges granted directly to users.
-- These should be migrated to roles.

SELECT
  grantee_name AS user_name,
  privilege,
  granted_on AS object_type,
  name AS object_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND granted_on NOT IN ('ROLE')  -- Exclude role grants (those are role assignments)
ORDER BY grantee_name, granted_on, name;

-- ============================================================================
-- STEP 2: GENERATE REVOKE STATEMENTS
-- ============================================================================
-- This query generates REVOKE statements for each direct user grant found.
-- IMPORTANT: Review each statement before executing.
-- Ensure the user has an equivalent role-based grant before revoking.

SELECT
  'REVOKE ' || privilege || ' ON ' || granted_on || ' ' || name
    || ' FROM USER ' || grantee_name || ';' AS revoke_statement,
  grantee_name AS user_name,
  privilege,
  granted_on AS object_type,
  name AS object_name,
  '-- Migrate to: GRANT ROLE <appropriate_role> TO USER '
    || grantee_name || ';' AS migration_note
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND granted_on NOT IN ('ROLE')
ORDER BY grantee_name, granted_on, name;

-- ============================================================================
-- STEP 3: DIRECT GRANT SUMMARY
-- ============================================================================
-- Count of direct user grants by type for prioritization.

SELECT
  granted_on AS object_type,
  privilege,
  COUNT(DISTINCT grantee_name) AS affected_users,
  COUNT(*) AS total_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND granted_on NOT IN ('ROLE')
GROUP BY granted_on, privilege
ORDER BY total_grants DESC;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- After executing REVOKE statements, re-run the discovery query.
-- Expected result: zero rows.

SELECT COUNT(*) AS remaining_direct_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND granted_on NOT IN ('ROLE');

/*
DIRECT USER PRIVILEGE REVOCATION
==================================

Queries generated:
1. Discovery: all direct user grants (excluding role assignments)
2. REVOKE statement generator (review before executing)
3. Summary by object type and privilege

IMPORTANT:
- Run discovery (Step 1) first
- For each direct grant, identify the correct functional role
- Verify the role has equivalent privileges
- Execute REVOKE statements only after confirming role coverage

Migration pattern:
  1. GRANT ROLE <prefix>_READ TO USER <user>;     -- For SELECT grants
  2. GRANT ROLE <prefix>_WRITE TO USER <user>;    -- For INSERT/UPDATE/DELETE
  3. GRANT ROLE <prefix>_CREATE TO USER <user>;   -- For CREATE privileges
  4. REVOKE <privilege> ON <object> FROM USER <user>;

NEXT STEPS:
- Execute migration for each direct user grant
- Proceed to Step 2.4: Enforce Managed Access Schemas
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.4: Transfer Object Ownership
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"transfer-object-ownership"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- TRANSFER OBJECT OWNERSHIP
-- ============================================================================
-- Reassign Ownership:  Yes
-- Default Target Role: SYSADMIN
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- NOTE: Run BEFORE enforce-managed-access-schemas (Step 2.4).
--       COPY CURRENT GRANTS preserves existing downstream grants.
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- STEP 1: OWNERSHIP DISCOVERY
-- ============================================================================
-- Find all OWNERSHIP grants held by roles outside the standard hierarchy.
-- Review ALL results before executing any transfer statements.
-- Any role appearing here that is not an approved hierarchy role is a
-- candidate for ownership transfer.

SELECT
  grantee_name  AS owning_role,
  granted_on    AS object_type,
  name          AS object_name
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE privilege    = 'OWNERSHIP'
  AND deleted_on   IS NULL
  AND grantee_name NOT IN (
    'ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN', 'PUBLIC'
  )
ORDER BY grantee_name, granted_on, name;

-- ============================================================================
-- STEP 2: SANITY CHECK — MANAGED SCHEMA COMPATIBILITY
-- ============================================================================
-- Flag schemas where the proposed target role is NOT a subordinate of the
-- schema owner.  In managed access schemas, GRANT OWNERSHIP will fail for
-- non-subordinate target roles.  Resolve WARNING rows BEFORE running Step 3.

SELECT
  s.catalog_name   AS database_name,
  s.schema_name,
  s.schema_owner,
  s.is_managed_access,
  proposed.target_role,
  CASE
    WHEN s.is_managed_access = 'NO'
      THEN 'OK — schema not yet in managed access'
    WHEN EXISTS (
      SELECT 1
      FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES hier
      WHERE hier.granted_on   = 'ROLE'
        AND hier.privilege    = 'USAGE'
        AND hier.grantee_name = s.schema_owner
        AND hier.name         = proposed.target_role
        AND hier.deleted_on   IS NULL
    )
      THEN 'OK — target role is subordinate to schema owner'
    ELSE
      'WARNING — target role is NOT subordinate to schema owner; transfer will fail'
  END AS compatibility_check
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA s
JOIN (
  -- No rbac_ownership_scope configured; insert target schemas manually.
  VALUES ('-- CONFIGURE rbac_ownership_scope --', '--', 'SYSADMIN')
) AS proposed (db_name, schema_name, target_role)
  ON  s.catalog_name = proposed.db_name
  AND s.schema_name  = proposed.schema_name
WHERE s.deleted IS NULL
ORDER BY compatibility_check DESC, s.catalog_name, s.schema_name;

-- ============================================================================
-- STEP 3: OWNERSHIP TRANSFER
-- ============================================================================
-- IMPORTANT: Resolve any WARNING rows in Step 2 before executing.
-- COPY CURRENT GRANTS preserves downstream shares and dependent grants.
-- Note: COPY CURRENT GRANTS is NOT valid on the FUTURE form — this is expected.
-- rbac_ownership_scope not configured.
-- Review the discovery query above (Step 1) and run the following pattern
-- for each schema containing objects owned by non-hierarchy roles:
--
-- GRANT OWNERSHIP ON ALL TABLES         IN SCHEMA <db>.<schema> TO ROLE SYSADMIN COPY CURRENT GRANTS;
-- GRANT OWNERSHIP ON ALL VIEWS          IN SCHEMA <db>.<schema> TO ROLE SYSADMIN COPY CURRENT GRANTS;
-- GRANT OWNERSHIP ON ALL STAGES         IN SCHEMA <db>.<schema> TO ROLE SYSADMIN COPY CURRENT GRANTS;
-- GRANT OWNERSHIP ON ALL FUNCTIONS      IN SCHEMA <db>.<schema> TO ROLE SYSADMIN COPY CURRENT GRANTS;
-- GRANT OWNERSHIP ON ALL PROCEDURES     IN SCHEMA <db>.<schema> TO ROLE SYSADMIN COPY CURRENT GRANTS;
-- GRANT OWNERSHIP ON ALL DYNAMIC TABLES IN SCHEMA <db>.<schema> TO ROLE SYSADMIN COPY CURRENT GRANTS;
-- GRANT OWNERSHIP ON FUTURE TABLES      IN SCHEMA <db>.<schema> TO ROLE SYSADMIN;

-- ============================================================================
-- STEP 4: VERIFICATION
-- ============================================================================
-- Re-run discovery after executing transfers.
-- Expected result: zero rows for all in-scope schemas.

SELECT
  grantee_name  AS owning_role,
  granted_on    AS object_type,
  COUNT(*)      AS object_count
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE privilege    = 'OWNERSHIP'
  AND deleted_on   IS NULL
  AND grantee_name NOT IN (
    'ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN', 'PUBLIC'
  )
GROUP BY grantee_name, granted_on
ORDER BY object_count DESC;

/*
OWNERSHIP TRANSFER COMPLETE
=========================

Actions generated:
1. Discovery: surfaced OWNERSHIP held by non-hierarchy roles
2. Sanity check: validated target roles against managed-access schema owners
3. Transfer: GRANT OWNERSHIP ON ALL ... COPY CURRENT GRANTS per configured scope
4. Future grants: GRANT OWNERSHIP ON FUTURE to prevent regression

IMPORTANT REMINDERS:
- COPY CURRENT GRANTS preserves downstream shares and dependent grants
- GRANT OWNERSHIP ON FUTURE does NOT support COPY CURRENT GRANTS (expected Snowflake behavior)
- Transfers in managed-access schemas are restricted to subordinate roles of the schema owner
- Resolve all WARNING rows from Step 2 before executing Step 3

NEXT STEPS:
- Verify Step 4 shows zero rows for in-scope schemas
- Proceed to Step 2.4: Enforce Managed Access Schemas
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 2.5: Enforce Managed Access Schemas
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"enforce-managed-access-schemas"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- ENFORCE MANAGED ACCESS SCHEMAS
-- ============================================================================
-- Enforce Managed Access: Yes
-- Audit Scope: Full Account
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- STEP 1: DISCOVER SCHEMAS WITHOUT MANAGED ACCESS
-- ============================================================================
-- Find all schemas that do not have Managed Access enabled.

SELECT
  catalog_name AS database_name,
  schema_name,
  schema_owner,
  created,
  last_altered,
  'ALTER SCHEMA ' || catalog_name || '.' || schema_name
    || ' ENABLE MANAGED ACCESS;' AS enable_statement
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE deleted IS NULL
  AND schema_name NOT IN ('INFORMATION_SCHEMA')
  AND catalog_name NOT IN ('SNOWFLAKE')
  AND is_managed_access = 'NO'
ORDER BY catalog_name, schema_name;

-- ============================================================================
-- STEP 2: ENABLE MANAGED ACCESS ON DISCOVERED SCHEMAS
-- ============================================================================
-- IMPORTANT: Review the discovery results before running these statements.
-- Managed Access restricts who can GRANT on objects within the schema.

-- Run the following generated statements from Step 1 output.
-- Example (replace with actual values from Step 1):
-- ALTER SCHEMA MY_DB.MY_SCHEMA ENABLE MANAGED ACCESS;

-- ============================================================================
-- STEP 3: VERIFY ALL TARGET SCHEMAS HAVE MANAGED ACCESS
-- ============================================================================
-- After enabling, re-run discovery. Expected: zero results.

SELECT
  catalog_name AS database_name,
  schema_name,
  schema_owner,
  is_managed_access
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE deleted IS NULL
  AND schema_name NOT IN ('INFORMATION_SCHEMA')
  AND catalog_name NOT IN ('SNOWFLAKE')
  AND is_managed_access = 'NO'
ORDER BY catalog_name, schema_name;

-- ============================================================================
-- STEP 4: MANAGED ACCESS SUMMARY
-- ============================================================================

SELECT
  is_managed_access,
  COUNT(*) AS schema_count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE deleted IS NULL
  AND schema_name NOT IN ('INFORMATION_SCHEMA')
  AND catalog_name NOT IN ('SNOWFLAKE')
GROUP BY is_managed_access;

/*
MANAGED ACCESS ENFORCEMENT COMPLETE
==========================================
Actions:
1. Discovered schemas without Managed Access
2. Generated ALTER SCHEMA ... ENABLE MANAGED ACCESS statements
3. Verified all target schemas have Managed Access enabled

After enabling Managed Access:
- Object owners cannot GRANT on their objects
- Only schema owner and SECURITYADMIN can manage grants
- Existing grants remain in effect (no automatic revocation)

NEXT STEPS:
- Run ALTER SCHEMA statements from Step 1 output
- Proceed to Task 3: User & Service Account Provisioning
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 3: User & Service Account Provisioning
-- Summary: Bridge the gap between role creation and actual usage by assigning end users to data product functional roles and provisioning dedicated service account users with least-privilege roles, key-pair authentication, and warehouse restrictions.
-- Personas: Security Administrator, Identity Team, Data Product Owner
-- Role Requirements: USERADMIN, SECURITYADMIN
-- External Requirements: Requires: data-product-setup blueprint completed — functional roles (e.g., {PREFIX}_ADMIN, {PREFIX}_READ) must exist before users can be assigned. Run data-product-setup once per data product, then return to this task., User roster with required access levels documented, Service account requirements documented (name, purpose, access level), SCIM prefix configured (if using SCIM for role assignment)
-- ============================================================================


-- ------------------------------------------------------------
-- Step 3.1: Assign Functional Roles to Users
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"assign-functional-roles"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- ASSIGN FUNCTIONAL ROLES
-- ============================================================================
-- User Role Assignments:
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- STEP 1: GRANT FUNCTIONAL ROLES TO USERS
-- ============================================================================
-- Each user is granted their designated role level for the specified
-- data product. Role hierarchy ensures inherited access (e.g., WRITE
-- inherits READ automatically).

-- ============================================================================
-- STEP 2: VERIFY ROLE ASSIGNMENTS
-- ============================================================================
-- Confirm that all assignments were applied successfully.

-- ============================================================================
-- STEP 3: ROLE MEMBERSHIP SUMMARY
-- ============================================================================
-- Cross-reference assigned roles with what the system reports.

SELECT
  grantee_name AS user_name,
  name AS role_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
  AND grantee_name IN (
  )
ORDER BY grantee_name, name;

/*
FUNCTIONAL ROLE ASSIGNMENT COMPLETE
=====================================

Assignments applied:

IMPORTANT:
- Verify each user can access their data product at the correct level
- Remove any legacy direct grants (completed in Step 2.3)
- For SCIM environments, map IDP groups to these roles

NEXT STEPS:
- Proceed to Step 3.2: Provision Service Accounts
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 3.2: Provision Service Accounts
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"provision-service-accounts"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- PROVISION SERVICE ACCOUNTS
-- ============================================================================
-- Service Accounts:
--   1. SVC_INGEST_GATEWAY (Ingests card transactions, bank transfers and gateway events from the payment gateway into the prod raw zone.) → PAYMENTS_CORE_PROD_WRITE
--   2. SVC_TRANSFORM_PROD (Runs scheduled transformations from raw to curated to analytics in prod.) → PAYMENTS_CORE_PROD_WRITE
--   3. SVC_BI_REPORTING (BI tool service account for analytics dashboards. Read-only against the analytics zone.) → PAYMENTS_CORE_PROD_READ
--   4. SVC_ML_TRAINING (Data science feature extraction and model training against curated and analytics zones.) → PAYMENTS_CORE_PROD_READ
--   5. SVC_TRANSFORM_STG (Runs the same transformation pipeline in staging for release validation.) → PAYMENTS_CORE_STG_CREATE
--   6. SVC_TRANSFORM_DEV (CI pipeline account for building and testing transformations in dev.) → PAYMENTS_CORE_DEV_CREATE
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLES: USERADMIN (create user), SECURITYADMIN (grant roles)
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE SERVICE ACCOUNT USERS
-- ============================================================================
-- Each service account is created with TYPE = SERVICE and key-pair auth.
-- NOTE: Replace <RSA_PUBLIC_KEY> with the actual base64-encoded public key.

USE ROLE USERADMIN;

-- Service Account 1: SVC_INGEST_GATEWAY
-- Purpose: Ingests card transactions, bank transfers and gateway events from the payment gateway into the prod raw zone.
CREATE USER IF NOT EXISTS SVC_INGEST_GATEWAY
  TYPE = SERVICE
  DEFAULT_ROLE = 'PAYMENTS_CORE_PROD_WRITE'
  DEFAULT_WAREHOUSE = 'PAYMENTS_CORE_PROD_WH_LOAD'
  COMMENT = 'Ingests card transactions, bank transfers and gateway events from the payment gateway into the prod raw zone.'
  MUST_CHANGE_PASSWORD = FALSE;
  -- RSA_PUBLIC_KEY = '<paste base64-encoded public key here>';

-- Service Account 2: SVC_TRANSFORM_PROD
-- Purpose: Runs scheduled transformations from raw to curated to analytics in prod.
CREATE USER IF NOT EXISTS SVC_TRANSFORM_PROD
  TYPE = SERVICE
  DEFAULT_ROLE = 'PAYMENTS_CORE_PROD_WRITE'
  DEFAULT_WAREHOUSE = 'PAYMENTS_CORE_PROD_WH_TRANSFORM'
  COMMENT = 'Runs scheduled transformations from raw to curated to analytics in prod.'
  MUST_CHANGE_PASSWORD = FALSE;
  -- RSA_PUBLIC_KEY = '<paste base64-encoded public key here>';

-- Service Account 3: SVC_BI_REPORTING
-- Purpose: BI tool service account for analytics dashboards. Read-only against the analytics zone.
CREATE USER IF NOT EXISTS SVC_BI_REPORTING
  TYPE = SERVICE
  DEFAULT_ROLE = 'PAYMENTS_CORE_PROD_READ'
  DEFAULT_WAREHOUSE = 'PAYMENTS_CORE_PROD_WH_REPORT'
  COMMENT = 'BI tool service account for analytics dashboards. Read-only against the analytics zone.'
  MUST_CHANGE_PASSWORD = FALSE;
  -- RSA_PUBLIC_KEY = '<paste base64-encoded public key here>';

-- Service Account 4: SVC_ML_TRAINING
-- Purpose: Data science feature extraction and model training against curated and analytics zones.
CREATE USER IF NOT EXISTS SVC_ML_TRAINING
  TYPE = SERVICE
  DEFAULT_ROLE = 'PAYMENTS_CORE_PROD_READ'
  DEFAULT_WAREHOUSE = 'PAYMENTS_CORE_PROD_WH_SCIENCE'
  COMMENT = 'Data science feature extraction and model training against curated and analytics zones.'
  MUST_CHANGE_PASSWORD = FALSE;
  -- RSA_PUBLIC_KEY = '<paste base64-encoded public key here>';

-- Service Account 5: SVC_TRANSFORM_STG
-- Purpose: Runs the same transformation pipeline in staging for release validation.
CREATE USER IF NOT EXISTS SVC_TRANSFORM_STG
  TYPE = SERVICE
  DEFAULT_ROLE = 'PAYMENTS_CORE_STG_CREATE'
  DEFAULT_WAREHOUSE = 'PAYMENTS_CORE_STG_WH_TRANSFORM'
  COMMENT = 'Runs the same transformation pipeline in staging for release validation.'
  MUST_CHANGE_PASSWORD = FALSE;
  -- RSA_PUBLIC_KEY = '<paste base64-encoded public key here>';

-- Service Account 6: SVC_TRANSFORM_DEV
-- Purpose: CI pipeline account for building and testing transformations in dev.
CREATE USER IF NOT EXISTS SVC_TRANSFORM_DEV
  TYPE = SERVICE
  DEFAULT_ROLE = 'PAYMENTS_CORE_DEV_CREATE'
  DEFAULT_WAREHOUSE = 'PAYMENTS_CORE_DEV_WH_TRANSFORM'
  COMMENT = 'CI pipeline account for building and testing transformations in dev.'
  MUST_CHANGE_PASSWORD = FALSE;
  -- RSA_PUBLIC_KEY = '<paste base64-encoded public key here>';

-- ============================================================================
-- STEP 2: GRANT FUNCTIONAL ROLES TO SERVICE ACCOUNTS
-- ============================================================================

USE ROLE SECURITYADMIN;

-- Grant PAYMENTS_CORE_PROD_WRITE to SVC_INGEST_GATEWAY
GRANT ROLE PAYMENTS_CORE_PROD_WRITE
  TO USER SVC_INGEST_GATEWAY;

-- Grant PAYMENTS_CORE_PROD_WRITE to SVC_TRANSFORM_PROD
GRANT ROLE PAYMENTS_CORE_PROD_WRITE
  TO USER SVC_TRANSFORM_PROD;

-- Grant PAYMENTS_CORE_PROD_READ to SVC_BI_REPORTING
GRANT ROLE PAYMENTS_CORE_PROD_READ
  TO USER SVC_BI_REPORTING;

-- Grant PAYMENTS_CORE_PROD_READ to SVC_ML_TRAINING
GRANT ROLE PAYMENTS_CORE_PROD_READ
  TO USER SVC_ML_TRAINING;

-- Grant PAYMENTS_CORE_STG_CREATE to SVC_TRANSFORM_STG
GRANT ROLE PAYMENTS_CORE_STG_CREATE
  TO USER SVC_TRANSFORM_STG;

-- Grant PAYMENTS_CORE_DEV_CREATE to SVC_TRANSFORM_DEV
GRANT ROLE PAYMENTS_CORE_DEV_CREATE
  TO USER SVC_TRANSFORM_DEV;

-- ============================================================================
-- STEP 3: GRANT WAREHOUSE USAGE TO SERVICE ACCOUNT ROLES
-- ============================================================================
-- Ensure each service account's role can use its designated warehouse.

-- Warehouse for SVC_INGEST_GATEWAY
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD
  TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_LOAD
  TO ROLE PAYMENTS_CORE_PROD_WRITE;
ALTER USER SVC_INGEST_GATEWAY
  SET NETWORK_POLICY = 'account_network_policy';

-- Warehouse for SVC_TRANSFORM_PROD
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM
  TO ROLE PAYMENTS_CORE_PROD_WRITE;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_TRANSFORM
  TO ROLE PAYMENTS_CORE_PROD_WRITE;
ALTER USER SVC_TRANSFORM_PROD
  SET NETWORK_POLICY = 'account_network_policy';

-- Warehouse for SVC_BI_REPORTING
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT
  TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_REPORT
  TO ROLE PAYMENTS_CORE_PROD_READ;
ALTER USER SVC_BI_REPORTING
  SET NETWORK_POLICY = 'account_network_policy';

-- Warehouse for SVC_ML_TRAINING
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE
  TO ROLE PAYMENTS_CORE_PROD_READ;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_PROD_WH_SCIENCE
  TO ROLE PAYMENTS_CORE_PROD_READ;
ALTER USER SVC_ML_TRAINING
  SET NETWORK_POLICY = 'account_network_policy';

-- Warehouse for SVC_TRANSFORM_STG
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_STG_WH_TRANSFORM
  TO ROLE PAYMENTS_CORE_STG_CREATE;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_STG_WH_TRANSFORM
  TO ROLE PAYMENTS_CORE_STG_CREATE;
ALTER USER SVC_TRANSFORM_STG
  SET NETWORK_POLICY = 'account_network_policy';

-- Warehouse for SVC_TRANSFORM_DEV
GRANT USAGE ON WAREHOUSE PAYMENTS_CORE_DEV_WH_TRANSFORM
  TO ROLE PAYMENTS_CORE_DEV_CREATE;
GRANT OPERATE ON WAREHOUSE PAYMENTS_CORE_DEV_WH_TRANSFORM
  TO ROLE PAYMENTS_CORE_DEV_CREATE;
ALTER USER SVC_TRANSFORM_DEV
  SET NETWORK_POLICY = 'account_network_policy';

-- ============================================================================
-- STEP 4: SET RSA PUBLIC KEYS
-- ============================================================================
-- IMPORTANT: Generate RSA key pairs and set the public key for each account.
-- This is required for key-pair authentication.

USE ROLE SECURITYADMIN;

-- Set RSA key for SVC_INGEST_GATEWAY
-- Uncomment and replace with actual public key:
-- ALTER USER SVC_INGEST_GATEWAY SET RSA_PUBLIC_KEY = '<base64-encoded-public-key>';

-- Set RSA key for SVC_TRANSFORM_PROD
-- Uncomment and replace with actual public key:
-- ALTER USER SVC_TRANSFORM_PROD SET RSA_PUBLIC_KEY = '<base64-encoded-public-key>';

-- Set RSA key for SVC_BI_REPORTING
-- Uncomment and replace with actual public key:
-- ALTER USER SVC_BI_REPORTING SET RSA_PUBLIC_KEY = '<base64-encoded-public-key>';

-- Set RSA key for SVC_ML_TRAINING
-- Uncomment and replace with actual public key:
-- ALTER USER SVC_ML_TRAINING SET RSA_PUBLIC_KEY = '<base64-encoded-public-key>';

-- Set RSA key for SVC_TRANSFORM_STG
-- Uncomment and replace with actual public key:
-- ALTER USER SVC_TRANSFORM_STG SET RSA_PUBLIC_KEY = '<base64-encoded-public-key>';

-- Set RSA key for SVC_TRANSFORM_DEV
-- Uncomment and replace with actual public key:
-- ALTER USER SVC_TRANSFORM_DEV SET RSA_PUBLIC_KEY = '<base64-encoded-public-key>';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Confirm service accounts were created
DESCRIBE USER SVC_INGEST_GATEWAY;
DESCRIBE USER SVC_TRANSFORM_PROD;
DESCRIBE USER SVC_BI_REPORTING;
DESCRIBE USER SVC_ML_TRAINING;
DESCRIBE USER SVC_TRANSFORM_STG;
DESCRIBE USER SVC_TRANSFORM_DEV;

-- Verify role assignments
SELECT
  grantee_name AS service_account,
  name AS role_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
  AND grantee_name IN (
    'SVC_INGEST_GATEWAY',
    'SVC_TRANSFORM_PROD',
    'SVC_BI_REPORTING',
    'SVC_ML_TRAINING',
    'SVC_TRANSFORM_STG',
    'SVC_TRANSFORM_DEV'
  )
ORDER BY grantee_name, name;

/*
SERVICE ACCOUNT PROVISIONING COMPLETE
=======================================

Service accounts created:
  1. SVC_INGEST_GATEWAY
     Purpose: Ingests card transactions, bank transfers and gateway events from the payment gateway into the prod raw zone.
     Role: PAYMENTS_CORE_PROD_WRITE
     Warehouse: PAYMENTS_CORE_PROD_WH_LOAD
  2. SVC_TRANSFORM_PROD
     Purpose: Runs scheduled transformations from raw to curated to analytics in prod.
     Role: PAYMENTS_CORE_PROD_WRITE
     Warehouse: PAYMENTS_CORE_PROD_WH_TRANSFORM
  3. SVC_BI_REPORTING
     Purpose: BI tool service account for analytics dashboards. Read-only against the analytics zone.
     Role: PAYMENTS_CORE_PROD_READ
     Warehouse: PAYMENTS_CORE_PROD_WH_REPORT
  4. SVC_ML_TRAINING
     Purpose: Data science feature extraction and model training against curated and analytics zones.
     Role: PAYMENTS_CORE_PROD_READ
     Warehouse: PAYMENTS_CORE_PROD_WH_SCIENCE
  5. SVC_TRANSFORM_STG
     Purpose: Runs the same transformation pipeline in staging for release validation.
     Role: PAYMENTS_CORE_STG_CREATE
     Warehouse: PAYMENTS_CORE_STG_WH_TRANSFORM
  6. SVC_TRANSFORM_DEV
     Purpose: CI pipeline account for building and testing transformations in dev.
     Role: PAYMENTS_CORE_DEV_CREATE
     Warehouse: PAYMENTS_CORE_DEV_WH_TRANSFORM

REMAINING MANUAL STEPS:
1. Generate RSA key pair for each service account
2. Set RSA_PUBLIC_KEY (uncomment Step 4 statements)
3. Store private keys in your secrets manager
4. Test connections using key-pair authentication

NEXT STEPS:
- Complete RSA key setup
- Proceed to Task 4: Monitoring & Compliance
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ============================================================================
-- TASK 4: Monitoring & Compliance
-- Summary: Establish ongoing RBAC monitoring by creating governance views for access review, configuring Snowflake alerts on suspicious privilege changes, and generating documentation for periodic compliance reviews.
-- Personas: Security Administrator, Compliance Team, Platform Administrator
-- Role Requirements: SYSADMIN, ACCOUNTADMIN
-- External Requirements: Platform Infrastructure Database and Governance schema exist (from Platform Foundation Setup), SNOWFLAKE database IMPORTED PRIVILEGES granted, Notification integration configured (for alerts), Warehouse available for alert execution
-- ============================================================================


-- ------------------------------------------------------------
-- Step 4.1: Create RBAC Monitoring Views
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"create-rbac-monitoring-views"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- CREATE RBAC MONITORING VIEWS
-- ============================================================================
-- Monitoring Warehouse: INFRA_WH_ADMIN
-- Audit Scope: Full Account
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SYSADMIN (view creation), SECURITYADMIN (grants)
-- ============================================================================

USE ROLE SYSADMIN;

-- ============================================================================
-- STEP 1: CREATE MONITORING DATABASE AND SCHEMA
-- ============================================================================
-- A dedicated schema for RBAC monitoring views and procedures.

CREATE DATABASE IF NOT EXISTS RBAC_MONITORING;
CREATE SCHEMA IF NOT EXISTS RBAC_MONITORING.VIEWS WITH MANAGED ACCESS;

USE SCHEMA RBAC_MONITORING.VIEWS;

-- ============================================================================
-- STEP 2: ROLE MEMBERSHIP SNAPSHOT VIEW
-- ============================================================================
-- Current role assignments for all users, including inherited roles.

CREATE OR REPLACE VIEW RBAC_MONITORING.VIEWS.V_ROLE_MEMBERSHIP AS
SELECT
  grantee_name AS user_name,
  name AS role_name,
  granted_by,
  created_on AS granted_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE granted_on = 'ROLE'
  AND privilege = 'USAGE'
  AND deleted_on IS NULL
;

-- ============================================================================
-- STEP 3: PRIVILEGE CHANGE HISTORY VIEW
-- ============================================================================
-- Track all privilege grants and revocations over time.

CREATE OR REPLACE VIEW RBAC_MONITORING.VIEWS.V_PRIVILEGE_CHANGES AS
SELECT
  granted_on AS object_type,
  name AS object_name,
  privilege,
  grantee_name,
  grant_option,
  granted_by,
  created_on AS change_date,
  deleted_on AS revoked_date,
  CASE WHEN deleted_on IS NULL THEN 'ACTIVE' ELSE 'REVOKED' END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE TRUE
;

-- ============================================================================
-- STEP 4: DIRECT USER GRANTS MONITOR VIEW
-- ============================================================================
-- Surfaces any direct user grants that bypass the RBAC hierarchy.
-- This should return zero rows if Step 2.3 was completed.

CREATE OR REPLACE VIEW RBAC_MONITORING.VIEWS.V_DIRECT_USER_GRANTS AS
SELECT
  grantee_name AS user_name,
  privilege,
  granted_on AS object_type,
  name AS object_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE deleted_on IS NULL
  AND granted_on NOT IN ('ROLE')
;

-- ============================================================================
-- STEP 5: ROLE HIERARCHY DEPTH VIEW
-- ============================================================================
-- Detect role chains that exceed recommended depth (4 levels).

CREATE OR REPLACE VIEW RBAC_MONITORING.VIEWS.V_ROLE_HIERARCHY_DEPTH AS
WITH RECURSIVE role_tree AS (
  SELECT
    name AS role_name,
    grantee_name AS parent_role,
    1 AS depth,
    name || ' → ' || grantee_name AS path
  FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
  WHERE granted_on = 'ROLE'
    AND privilege = 'USAGE'
    AND deleted_on IS NULL

  UNION ALL

  SELECT
    rt.role_name,
    g.grantee_name AS parent_role,
    rt.depth + 1,
    rt.path || ' → ' || g.grantee_name
  FROM role_tree rt
  JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES g
    ON rt.parent_role = g.name
    AND g.granted_on = 'ROLE'
    AND g.privilege = 'USAGE'
    AND g.deleted_on IS NULL
  WHERE rt.depth < 10
)
SELECT
  role_name,
  MAX(depth) AS max_depth,
  MAX(path) AS longest_path,
  CASE
    WHEN MAX(depth) <= 4 THEN 'HEALTHY'
    WHEN MAX(depth) <= 6 THEN 'WARNING'
    ELSE 'CRITICAL'
  END AS health_status
FROM role_tree
GROUP BY role_name
HAVING MAX(depth) > 2
;

-- ============================================================================
-- STEP 6: USER ACTIVITY MONITOR VIEW
-- ============================================================================
-- Track user login activity for dormancy detection.

CREATE OR REPLACE VIEW RBAC_MONITORING.VIEWS.V_USER_ACTIVITY AS
SELECT
  u.name AS user_name,
  u.login_name,
  u.created_on,
  u.last_success_login,
  u.disabled,
  u.has_mfa,
  DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) AS days_since_login,
  CASE
    WHEN u.disabled = 'true' THEN 'DISABLED'
    WHEN u.last_success_login IS NULL THEN 'NEVER_LOGGED_IN'
    WHEN DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) > 90 THEN 'DORMANT'
    WHEN DATEDIFF('day', u.last_success_login, CURRENT_TIMESTAMP()) > 30 THEN 'INACTIVE'
    ELSE 'ACTIVE'
  END AS activity_status
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS u
WHERE u.deleted_on IS NULL
;

-- ============================================================================
-- STEP 7: GRANT READ ACCESS ON MONITORING VIEWS
-- ============================================================================
-- Grant access to security team or monitoring role.

USE ROLE SECURITYADMIN;

-- Grant usage on the monitoring database and schema
GRANT USAGE ON DATABASE RBAC_MONITORING TO ROLE SECURITYADMIN;
GRANT USAGE ON SCHEMA RBAC_MONITORING.VIEWS TO ROLE SECURITYADMIN;
GRANT SELECT ON ALL VIEWS IN SCHEMA RBAC_MONITORING.VIEWS TO ROLE SECURITYADMIN;

-- Grant warehouse usage for monitoring queries
GRANT USAGE ON WAREHOUSE INFRA_WH_ADMIN TO ROLE SECURITYADMIN;

/*
RBAC MONITORING VIEWS CREATED
================================

Views created in RBAC_MONITORING.VIEWS:
1. V_ROLE_MEMBERSHIP — Current role assignments
2. V_PRIVILEGE_CHANGES — Grant/revoke history
3. V_DIRECT_USER_GRANTS — Bypass detection (should be empty)
4. V_ROLE_HIERARCHY_DEPTH — Depth analysis with health status
5. V_USER_ACTIVITY — Login activity and dormancy detection

Monitoring warehouse: INFRA_WH_ADMIN

NEXT STEPS:
- Query these views periodically to track RBAC health
- Proceed to Step 4.2: Configure Privilege Change Alerts
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 4.2: Configure Privilege Change Alerts
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"configure-privilege-change-alerts"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- CONFIGURE PRIVILEGE CHANGE ALERTS
-- ============================================================================
-- Enable Alerts: Yes
-- Notification Integration: EMAIL_SECURITY_ALERTS
-- Monitoring Warehouse: INFRA_WH_ADMIN
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SYSADMIN
-- ============================================================================

USE ROLE SYSADMIN;
USE SCHEMA RBAC_MONITORING.VIEWS;
USE WAREHOUSE INFRA_WH_ADMIN;

-- ============================================================================
-- STEP 1: ALERT — NEW ACCOUNTADMIN GRANT
-- ============================================================================
-- Fires when a new user is granted ACCOUNTADMIN.
-- This is a critical security event that should always trigger review.

CREATE OR REPLACE ALERT RBAC_MONITORING.VIEWS.ALERT_NEW_ACCOUNTADMIN_GRANT
  WAREHOUSE = INFRA_WH_ADMIN
  SCHEDULE = 'USING CRON 0 */1 * * * America/Los_Angeles'
  IF (EXISTS (
    SELECT 1
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
    WHERE name = 'ACCOUNTADMIN'
      AND granted_on = 'ROLE'
      AND privilege = 'USAGE'
      AND deleted_on IS NULL
      AND created_on > DATEADD('hour', -1, CURRENT_TIMESTAMP())
  ))
  THEN
    CALL SYSTEM$SEND_NOTIFICATION(
      'EMAIL_SECURITY_ALERTS',
      'RBAC Alert: New ACCOUNTADMIN Grant',
      'A new ACCOUNTADMIN role grant was detected. Review immediately.'
    );

ALTER ALERT RBAC_MONITORING.VIEWS.ALERT_NEW_ACCOUNTADMIN_GRANT RESUME;

-- ============================================================================
-- STEP 2: ALERT — DIRECT USER GRANT DETECTED
-- ============================================================================
-- Fires when a privilege is granted directly to a user (bypassing roles).

CREATE OR REPLACE ALERT RBAC_MONITORING.VIEWS.ALERT_DIRECT_USER_GRANT
  WAREHOUSE = INFRA_WH_ADMIN
  SCHEDULE = 'USING CRON 0 */6 * * * America/Los_Angeles'
  IF (EXISTS (
    SELECT 1
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
    WHERE deleted_on IS NULL
      AND granted_on NOT IN ('ROLE')
      AND created_on > DATEADD('hour', -6, CURRENT_TIMESTAMP())
  ))
  THEN
    CALL SYSTEM$SEND_NOTIFICATION(
      'EMAIL_SECURITY_ALERTS',
      'RBAC Alert: Direct User Grant Detected',
      'A privilege was granted directly to a user instead of a role. Review V_DIRECT_USER_GRANTS.'
    );

ALTER ALERT RBAC_MONITORING.VIEWS.ALERT_DIRECT_USER_GRANT RESUME;

-- ============================================================================
-- STEP 3: ALERT — PUBLIC ROLE GRANT DETECTED
-- ============================================================================
-- Fires when a new grant is added to the PUBLIC role.

CREATE OR REPLACE ALERT RBAC_MONITORING.VIEWS.ALERT_PUBLIC_ROLE_GRANT
  WAREHOUSE = INFRA_WH_ADMIN
  SCHEDULE = 'USING CRON 0 */6 * * * America/Los_Angeles'
  IF (EXISTS (
    SELECT 1
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
    WHERE grantee_name = 'PUBLIC'
      AND deleted_on IS NULL
      AND created_on > DATEADD('hour', -6, CURRENT_TIMESTAMP())
  ))
  THEN
    CALL SYSTEM$SEND_NOTIFICATION(
      'EMAIL_SECURITY_ALERTS',
      'RBAC Alert: New PUBLIC Role Grant',
      'A new privilege was granted to the PUBLIC role. Review and revoke if unintended.'
    );

ALTER ALERT RBAC_MONITORING.VIEWS.ALERT_PUBLIC_ROLE_GRANT RESUME;

-- ============================================================================
-- STEP 4: ALERT — DORMANT USER WITH ACTIVE ROLES
-- ============================================================================
-- Weekly check for users who haven't logged in for 90+ days but still have roles.

CREATE OR REPLACE ALERT RBAC_MONITORING.VIEWS.ALERT_DORMANT_USERS
  WAREHOUSE = INFRA_WH_ADMIN
  SCHEDULE = 'USING CRON 0 8 * * 1 America/Los_Angeles'
  IF (EXISTS (
    SELECT 1
    FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY
    WHERE activity_status = 'DORMANT'
  ))
  THEN
    CALL SYSTEM$SEND_NOTIFICATION(
      'EMAIL_SECURITY_ALERTS',
      'RBAC Alert: Dormant Users Detected',
      'Users inactive for 90+ days still have active roles. Review V_USER_ACTIVITY.'
    );

ALTER ALERT RBAC_MONITORING.VIEWS.ALERT_DORMANT_USERS RESUME;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- List all RBAC alerts
SHOW ALERTS IN SCHEMA RBAC_MONITORING.VIEWS;

-- Check alert history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.ALERT_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD('hour', -24, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC;

/*
PRIVILEGE CHANGE ALERTS CONFIGURED
==========================================
Alerts created:
1. ALERT_NEW_ACCOUNTADMIN_GRANT — Hourly check for new ACCOUNTADMIN grants
2. ALERT_DIRECT_USER_GRANT — Every 6 hours, checks for RBAC bypasses
3. ALERT_PUBLIC_ROLE_GRANT — Every 6 hours, checks for PUBLIC grants
4. ALERT_DORMANT_USERS — Weekly check for inactive users with roles

Notification integration: EMAIL_SECURITY_ALERTS
Warehouse: INFRA_WH_ADMIN

NEXT STEPS:
- Verify alert notifications reach your team
- Proceed to Step 4.3: Generate Access Review Report
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;


-- ------------------------------------------------------------
-- Step 4.3: Generate Access Review Report
-- ------------------------------------------------------------

ALTER SESSION SET QUERY_TAG = '{"src":"blueprints","bp":"blueprint_e2a16d54","step":"generate-access-review-report"}';

-- Author: Richie Bachala (richie.bachala@snowflake.com)
-- ============================================================================
-- GENERATE ACCESS REVIEW REPORT
-- ============================================================================
-- Review Frequency: Quarterly
-- Audit Scope: Full Account
-- Monitoring Warehouse: INFRA_WH_ADMIN
-- ============================================================================
-- EXECUTE FROM: Target Account
-- REQUIRED ROLE: SECURITYADMIN
-- ============================================================================

USE ROLE SECURITYADMIN;
USE WAREHOUSE INFRA_WH_ADMIN;

-- ============================================================================
-- ACCESS REVIEW REPORT
-- Generated: Run this query set on a Quarterly basis
-- ============================================================================

-- ============================================================================
-- SECTION 1: EXECUTIVE SUMMARY
-- ============================================================================

-- 1a. Total users and role assignments
SELECT
  'Total Users' AS metric,
  COUNT(DISTINCT user_name) AS value
FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY
UNION ALL
SELECT
  'Active Users (last 30 days)',
  COUNT(DISTINCT user_name)
FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY
WHERE activity_status = 'ACTIVE'
UNION ALL
SELECT
  'Dormant Users (90+ days)',
  COUNT(DISTINCT user_name)
FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY
WHERE activity_status = 'DORMANT'
UNION ALL
SELECT
  'Never Logged In',
  COUNT(DISTINCT user_name)
FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY
WHERE activity_status = 'NEVER_LOGGED_IN'
UNION ALL
SELECT
  'Direct User Grants (bypasses)',
  COUNT(*)
FROM RBAC_MONITORING.VIEWS.V_DIRECT_USER_GRANTS;

-- ============================================================================
-- SECTION 2: ACCOUNTADMIN HOLDERS
-- ============================================================================
-- List all users with ACCOUNTADMIN. Should match your authorized list.

SELECT
  user_name,
  granted_on
FROM RBAC_MONITORING.VIEWS.V_ROLE_MEMBERSHIP
WHERE role_name = 'ACCOUNTADMIN'
ORDER BY user_name;

-- ============================================================================
-- SECTION 3: RBAC BYPASSES
-- ============================================================================
-- Direct user grants that bypass the role hierarchy.
-- Expected: zero rows.

SELECT
  user_name,
  privilege,
  object_type,
  object_name,
  granted_by,
  created_on
FROM RBAC_MONITORING.VIEWS.V_DIRECT_USER_GRANTS
ORDER BY created_on DESC;

-- ============================================================================
-- SECTION 4: ROLE HIERARCHY HEALTH
-- ============================================================================
-- Roles with depth exceeding recommended limits.

SELECT
  role_name,
  max_depth,
  health_status,
  longest_path
FROM RBAC_MONITORING.VIEWS.V_ROLE_HIERARCHY_DEPTH
WHERE health_status != 'HEALTHY'
ORDER BY max_depth DESC;

-- ============================================================================
-- SECTION 5: DORMANT USERS WITH ACTIVE ROLES
-- ============================================================================
-- Users inactive for 90+ days who still have role assignments.
-- Recommendation: disable or remove role assignments.

SELECT
  ua.user_name,
  ua.days_since_login,
  ua.activity_status,
  rm.role_name
FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY ua
JOIN RBAC_MONITORING.VIEWS.V_ROLE_MEMBERSHIP rm
  ON ua.user_name = rm.user_name
WHERE ua.activity_status IN ('DORMANT', 'NEVER_LOGGED_IN')
ORDER BY ua.days_since_login DESC, ua.user_name;

-- ============================================================================
-- SECTION 6: RECENT PRIVILEGE CHANGES
-- ============================================================================
-- All privilege grants and revocations since last review.

SELECT
  object_type,
  object_name,
  privilege,
  grantee_name,
  granted_by,
  change_date,
  status
FROM RBAC_MONITORING.VIEWS.V_PRIVILEGE_CHANGES
WHERE change_date > DATEADD('day', -90, CURRENT_TIMESTAMP())
   OR (revoked_date IS NOT NULL AND revoked_date > DATEADD('day', -90, CURRENT_TIMESTAMP()))
ORDER BY change_date DESC;

-- ============================================================================
-- SECTION 7: PUBLIC ROLE GRANTS
-- ============================================================================
-- Current grants on the PUBLIC role. Should be minimal or empty.

SELECT
  privilege,
  granted_on AS object_type,
  name AS object_name,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = 'PUBLIC'
  AND deleted_on IS NULL
ORDER BY created_on DESC;

-- ============================================================================
-- SECTION 8: MFA STATUS
-- ============================================================================
-- Users without MFA enabled (especially important for privileged roles).

SELECT
  ua.user_name,
  ua.has_mfa,
  rm.role_name,
  CASE
    WHEN rm.role_name IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN') THEN 'CRITICAL'
    WHEN rm.role_name LIKE '%ADMIN%' THEN 'HIGH'
    ELSE 'MEDIUM'
  END AS mfa_priority
FROM RBAC_MONITORING.VIEWS.V_USER_ACTIVITY ua
JOIN RBAC_MONITORING.VIEWS.V_ROLE_MEMBERSHIP rm
  ON ua.user_name = rm.user_name
WHERE ua.has_mfa = 'false'
  AND ua.activity_status = 'ACTIVE'
ORDER BY mfa_priority, ua.user_name;

/*
ACCESS REVIEW REPORT GENERATED
=================================

Review Frequency: Quarterly
Report Sections:
1. Executive Summary — User counts and bypass totals
2. ACCOUNTADMIN Holders — Verify against authorized list
3. RBAC Bypasses — Direct user grants (should be zero)
4. Role Hierarchy Health — Depth violations
5. Dormant Users — Inactive users with active roles
6. Recent Privilege Changes — Changes in last 90 days
7. PUBLIC Role Grants — Should be minimal
8. MFA Status — Users without MFA on privileged roles

ACTION ITEMS (complete before next review):
- Disable dormant users (Section 5)
- Revoke any RBAC bypasses (Section 3)
- Fix role hierarchy depth issues (Section 4)
- Enable MFA for flagged users (Section 8)
- Revoke unauthorized ACCOUNTADMIN (Section 2)

RBAC HARDENING BLUEPRINT COMPLETE
====================================
All 4 tasks have been executed:
  Task 1: RBAC Assessment ✓
  Task 2: Privilege Hardening ✓
  Task 3: User & Service Account Provisioning ✓
  Task 4: Monitoring & Compliance ✓

Schedule this report to run quarterly.
*/


-- ------------------------------------------------------------
-- End of step: clear QUERY_TAG.
-- ------------------------------------------------------------
ALTER SESSION UNSET QUERY_TAG;
