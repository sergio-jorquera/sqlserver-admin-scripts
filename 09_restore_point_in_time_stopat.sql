/*
Purpose:
Point-in-time restore using STOPAT (restore to a specific timestamp).

Notes:
- You need a FULL backup + relevant LOG backup(s).
- Use NORECOVERY on the full restore, then STOPAT on log restore.
- Replace @stopAt with your target timestamp.
- Lab / learning purposes.
*/

USE master;
GO

DECLARE @db SYSNAME = N'EjemploRestauracionLogs';
DECLARE @full NVARCHAR(260) = N'E:\BACKUPS\EjemploRestauracionLogs_time_full.bak';
DECLARE @log  NVARCHAR(260) = N'E:\BACKUPS\EjemploRestauracionLogs_time_log.trn';
DECLARE @stopAt DATETIME = '2025-10-31T12:02:40.000';

ALTER DATABASE EjemploRestauracionLogs
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE EjemploRestauracionLogs
FROM DISK = @full
WITH NORECOVERY, REPLACE;
GO

RESTORE LOG EjemploRestauracionLogs
FROM DISK = @log
WITH RECOVERY,
     STOPAT = @stopAt;
GO

ALTER DATABASE EjemploRestauracionLogs
SET MULTI_USER;
GO
