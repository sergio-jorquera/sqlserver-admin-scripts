/*
Purpose:
Encrypted backups using a server certificate:
- Create DMK (Database Master Key) in master
- Create certificate
- Backup database with ENCRYPTION (AES_256)
- Backup certificate + private key (required for restores on another server)

Notes:
- Adjust paths and database names to your environment.
- Do NOT store real passwords in source control.
- Replace placeholders <DMK_PASSWORD> and <PRIVATE_KEY_PASSWORD>.
- Lab / learning purposes.
*/

USE master;
GO

/*------------------------------------------------------------
 01 - Create DMK (only if not already created)
------------------------------------------------------------*/

-- If a master key already exists, this will fail.
-- You can check with: SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##';

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<DMK_PASSWORD>';
GO

/*------------------------------------------------------------
 02 - Create certificate
------------------------------------------------------------*/

CREATE CERTIFICATE AW2014_Backup_Cert
WITH SUBJECT = 'Certificate for AdventureWorks2014 backup encryption';
GO

/*------------------------------------------------------------
 03 - Encrypted full backup
------------------------------------------------------------*/

BACKUP DATABASE AdventureWorks2014
TO DISK = 'E:\BACKUPS\AdventureWorks2014_encrypted_cert.bak'
WITH ENCRYPTION
(
    ALGORITHM = AES_256,
    SERVER CERTIFICATE = AW2014_Backup_Cert
),
STATS = 5;
GO

/*------------------------------------------------------------
 04 - Validate backup exists in msdb (optional)
------------------------------------------------------------*/

USE msdb;
GO

SELECT TOP (20)
    bs.database_name,
    bs.backup_start_date,
    bs.type,
    bmf.physical_device_name
FROM dbo.backupset bs
JOIN dbo.backupmediafamily bmf
  ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'AdventureWorks2014'
ORDER BY bs.backup_start_date DESC;
GO

/*------------------------------------------------------------
 05 - Backup certificate + private key (required to restore elsewhere)
------------------------------------------------------------*/

USE master;
GO

BACKUP CERTIFICATE AW2014_Backup_Cert
TO FILE = 'E:\BACKUPS\AW2014_Backup_Cert.cer'
WITH PRIVATE KEY
(
    FILE = 'E:\BACKUPS\AW2014_Backup_Cert_PrivateKey.pvk',
    ENCRYPTION BY PASSWORD = '<PRIVATE_KEY_PASSWORD>'
);
GO

/*------------------------------------------------------------
 06 - Check certificate backup status (optional)
------------------------------------------------------------*/

SELECT 
    name AS certificate_name,
    pvt_key_encryption_type_desc,
    pvt_key_last_backup_date
FROM sys.certificates
WHERE name = 'AW2014_Backup_Cert';
GO
