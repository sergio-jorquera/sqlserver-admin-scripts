/*
Purpose:
Security basics in SQL Server:
- Server logins (Windows / SQL)
- Database users
- Grant/Deny CONNECT
- Database roles and permissions

Notes:
- Replace DOMAIN\User and passwords for your environment.
- Do NOT store real passwords in source control.
- Lab / learning purposes.
*/

USE master;
GO

/*------------------------------------------------------------
 Server level: Windows login / group login examples
------------------------------------------------------------*/

-- Windows login example
-- CREATE LOGIN [DOMAIN\User] FROM WINDOWS
-- WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = English;

-- Windows group example
-- CREATE LOGIN [DOMAIN\GroupName] FROM WINDOWS
-- WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = English;

-- List Windows logins/groups
SELECT name, type_desc
FROM sys.server_principals
WHERE type_desc IN ('WINDOWS_LOGIN', 'WINDOWS_GROUP')
ORDER BY type_desc;
GO

/*------------------------------------------------------------
 Server level: SQL login example (password placeholder)
------------------------------------------------------------*/

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'app_login')
BEGIN
    CREATE LOGIN app_login
    WITH PASSWORD = 'CHANGE_ME_STRONG_PASSWORD',
         DEFAULT_DATABASE = master,
         CHECK_POLICY = ON,
         CHECK_EXPIRATION = ON;
END
GO


-- Examples of login control (execute only if required)
-- Disable / enable login
-- ALTER LOGIN app_login DISABLE;
-- ALTER LOGIN app_login ENABLE;


-- Deny / grant server connection
-- DENY CONNECT SQL TO app_login;
-- GRANT CONNECT SQL TO app_login;

/*------------------------------------------------------------
 Database level: user and role example
------------------------------------------------------------*/

-- Create a demo database if needed
IF DB_ID('SecurityLab') IS NULL
    CREATE DATABASE SecurityLab;
GO

USE SecurityLab;
GO

-- Create a database user mapped to server login
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_user')
    CREATE USER app_user FOR LOGIN app_login;
GO

-- Create role and grant permissions
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ReportingRole')
    CREATE ROLE ReportingRole AUTHORIZATION dbo;
GO

-- Example permission (adjust object)
-- GRANT SELECT ON dbo.SomeTable TO ReportingRole;

-- Add member to role
ALTER ROLE ReportingRole ADD MEMBER app_user;
GO
