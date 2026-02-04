/*
Purpose:
Backup and restore demo using variables and msdb history:
- Create dated backup file name
- Find backup device in msdb
- Restore from a specific position (FILE = 2)
- Restore as a new database using MOVE

Notes:
- Adjust paths, database names, and logical file names.
- SINGLE_USER impacts connections; use with care.
- Lab / learning purposes.
*/

USE master;
GO

/*------------------------------------------------------------
 01 - Create a dated full backup
------------------------------------------------------------*/

DECLARE @date CHAR(8) = CONVERT(CHAR(8), GETDATE(), 112); -- yyyyMMdd
DECLARE @path NVARCHAR(260);
DECLARE @db SYSNAME = N'AdventureWorks2025';

SET @path = N'E:\BACKUPS\' + @db + N'_' + @date + N'.bak';

-- Optional: create directory (requires sysadmin)
-- EXEC sys.xp_create_subdir 'E:\BACKUPS';
-- GO

BACKUP DATABASE AdventureWorks2014
TO DISK = @path;
GO

/*------------------------------------------------------------
 02 - List today's full backups for the database (msdb)
------------------------------------------------------------*/

SELECT
    a.database_name,
    a.backup_start_date,
    a.position,
    b.physical_device_name
FROM msdb.dbo.backupset a
JOIN msdb.dbo.backupmediafamily b
  ON a.media_set_id = b.media_set_id
WHERE a.database_name = 'AdventureWorks2025'
  AND a.type = 'D'
  AND CONVERT(CHAR(8), a.backup_start_date, 112) = CONVERT(CHAR(8), GETDATE(), 112)
ORDER BY a.backup_start_date DESC;
GO

/*------------------------------------------------------------
 03 - Restore AdventureWorks2025 from FILE = 2 (same day example)
------------------------------------------------------------*/

DECLARE @device NVARCHAR(260);

SELECT TOP (1) @device = b.physical_device_name
FROM msdb.dbo.backupset a
JOIN msdb.dbo.backupmediafamily b
  ON a.media_set_id = b.media_set_id
WHERE a.database_name = 'AdventureWorks2025'
  AND a.type = 'D'
  AND CONVERT(CHAR(8), a.backup_start_date, 112) = CONVERT(CHAR(8), GETDATE(), 112)
  AND a.position = 2
ORDER BY a.backup_start_date DESC;

-- If @device is NULL, there is no FILE=2 backup matching the filter.
SELECT @device AS selected_device;
GO

ALTER DATABASE AdventureWorks2025
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE AdventureWorks2025
FROM DISK = @device
WITH FILE = 2, REPLACE;
GO

ALTER DATABASE AdventureWorks2014
SET MULTI_USER;
GO

/*------------------------------------------------------------
 04 - Restore as a new database using MOVE (demo)
------------------------------------------------------------*/

-- IMPORTANT:
-- Logical file names must match the backup contents.
-- You can check them with:
-- RESTORE FILELISTONLY FROM DISK = @device;

RESTORE DATABASE AdventureWorks2025_RestoreDemo
FROM DISK = @device
WITH FILE = 2,
MOVE 'AdventureWorks2025_Data' TO 'E:\BBDD\AdventureWorks2025_RestoreDemo_Data.mdf',
MOVE 'AdventureWorks2025_Log'  TO 'E:\LOGS\AdventureWorks2025_RestoreDemo_Log.ldf',
REPLACE;
GO
