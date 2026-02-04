/*
Purpose:
Restore full backup + transaction log backups (log chain restore).

Notes:
- Requires FULL recovery model for log backups.
- Restore order matters: full -> log1 -> log2 -> ... -> RECOVERY
- Lab / learning purposes.
*/

USE master;
GO

DECLARE @db SYSNAME = N'EjemploRestauracionLogs';
DECLARE @full NVARCHAR(260) = N'E:\BACKUPS\EjemploRestauracionLogs_full.bak';
DECLARE @log1 NVARCHAR(260) = N'E:\BACKUPS\EjemploRestauracionLogs_01.trn';
DECLARE @log2 NVARCHAR(260) = N'E:\BACKUPS\EjemploRestauracionLogs_02.trn';

-- Put DB in SINGLE_USER (optional if restoring over existing DB)
ALTER DATABASE EjemploRestauracionLogs
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- 1) Restore FULL with NORECOVERY
RESTORE DATABASE EjemploRestauracionLogs
FROM DISK = @full
WITH NORECOVERY, REPLACE;
GO

-- 2) Restore LOGs in order
RESTORE LOG EjemploRestauracionLogs
FROM DISK = @log1
WITH NORECOVERY;
GO

RESTORE LOG EjemploRestauracionLogs
FROM DISK = @log2
WITH RECOVERY;
GO

ALTER DATABASE EjemploRestauracionLogs
SET MULTI_USER;
GO
