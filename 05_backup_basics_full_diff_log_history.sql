/*
Purpose:
SQL Server backup basics:
- Full / Differential / Log backups
- Compression + CHECKSUM + RESTORE VERIFYONLY
- COPY_ONLY backups
- Striped backups (multiple files)
- Backup history query (msdb)

Notes:
- Adjust paths and database names to your environment.
- xp_create_subdir requires sysadmin privileges.
- Lab / learning purposes.
*/

USE master;
GO

/*------------------------------------------------------------
 00 - Create backup directory (optional)
------------------------------------------------------------*/

EXEC sys.xp_create_subdir 'E:\BACKUPS';
GO

/*------------------------------------------------------------
 01 - Full backup
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_full.bak';
GO

/*------------------------------------------------------------
 02 - Full backup with compression
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_full_compressed.bak'
WITH COMPRESSION;
GO

/*------------------------------------------------------------
 03 - Full backup with CHECKSUM + VERIFYONLY
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_full_checksum.bak'
WITH CHECKSUM;
GO

RESTORE VERIFYONLY
FROM DISK = 'E:\BACKUPS\AdventureWorks2014_full_checksum.bak'
WITH CHECKSUM;
GO

/*------------------------------------------------------------
 04 - Transaction log backup (requires FULL recovery model)
------------------------------------------------------------*/

-- Note: Log backups require FULL recovery model (or BULK_LOGGED in some cases)
BACKUP LOG AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_log.trn';
GO

/*------------------------------------------------------------
 05 - Differential backup
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_diff.bak'
WITH DIFFERENTIAL;
GO

/*------------------------------------------------------------
 06 - COPY_ONLY backup (does not affect backup chain)
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_copy_only.bak'
WITH COPY_ONLY;
GO

/*------------------------------------------------------------
 07 - Striped backup (multiple files)
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_stripe_1.bak',
   DISK = 'E:\BACKUPS\AdventureWorks2014_stripe_2.bak'
WITH COMPRESSION,
     STATS = 5;
GO

/*------------------------------------------------------------
 08 - Backup history (msdb)
------------------------------------------------------------*/

USE msdb;
GO

SELECT 
    bs.database_name AS database_name,
    bs.backup_start_date AS backup_start_date,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
        WHEN 'F' THEN 'File or filegroup'
        WHEN 'G' THEN 'Differential file'
        WHEN 'P' THEN 'Partial'
        WHEN 'Q' THEN 'Differential partial'
        ELSE 'Unknown'
    END AS backup_type,
    bmf.physical_device_name,
    bs.backup_size / 1024 / 1024 AS backup_size_mb
FROM dbo.backupset bs
JOIN dbo.backupmediafamily bmf
  ON bs.media_set_id = bmf.media_set_id
ORDER BY bs.database_name, bs.backup_start_date DESC;
GO
