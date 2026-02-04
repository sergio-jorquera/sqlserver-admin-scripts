# SQL Server Administration Scripts

Collection of SQL Server administration scripts created for learning and practice.

## Topics covered
- Database creation and file management
- Filegroups and data movement
- Table partitioning by date
- Security: logins, users, roles and permissions
- Backups: full, differential and transaction log
- Backup validation and history (msdb)
- Encrypted backups using certificates
- Restore scenarios:
  - Restore with MOVE
  - Restore using log chain (FULL + LOG)
  - Point-in-time restore (STOPAT)

## Notes
- Scripts are intended for lab environments.
- Paths, database names and passwords are placeholders and must be adapted.
- Some scripts require sysadmin privileges (e.g. xp_create_subdir).
- Do not execute directly on production systems.

