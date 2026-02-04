/*
Purpose:
Create a sample SQL Server database with multiple data and log files.
Lab / learning purposes.
*/

USE master;
GO

-- Optional: create directories (requires sysadmin)
EXEC sys.xp_create_subdir 'D:\BBDD\disco1';
EXEC sys.xp_create_subdir 'D:\BBDD\disco2';
EXEC sys.xp_create_subdir 'D:\BBDD\disco3';
GO

-- Drop database if it exists
IF DB_ID('BaseDatosEjemplo') IS NOT NULL
    DROP DATABASE BaseDatosEjemplo;
GO

-- Create database
CREATE DATABASE BaseDatosEjemplo
ON PRIMARY
(
    NAME = 'BaseDatosEjemplo_Data',
    FILENAME = 'D:\BBDD\disco1\BaseDatosEjemplo.mdf',
    SIZE = 5MB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = 'BaseDatosEjemplo_Log',
    FILENAME = 'D:\LOGS\BaseDatosEjemplo.ldf',
    SIZE = 512KB,
    FILEGROWTH = 512KB
);
GO

-- Add secondary data file
ALTER DATABASE BaseDatosEjemplo
ADD FILE
(
    NAME = 'BaseDatosEjemplo_Data2',
    FILENAME = 'D:\BBDD\disco2\BaseDatosEjemplo2.ndf',
    SIZE = 1MB,
    MAXSIZE = 10MB,
    FILEGROWTH = 1MB
);
GO

-- Add secondary log file
ALTER DATABASE BaseDatosEjemplo
ADD LOG FILE
(
    NAME = 'BaseDatosEjemplo_Log2',
    FILENAME = 'D:\LOGS\BaseDatosEjemplo2.ldf',
    SIZE = 1MB,
    MAXSIZE = 5MB,
    FILEGROWTH = 1MB
);
GO

-- Review files
SELECT name, physical_name, size
FROM sys.database_files;
GO
