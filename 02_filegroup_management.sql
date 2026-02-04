/*
Purpose:
Manage SQL Server filegroups and move tables between filegroups.

Topics covered:
- Create filegroups and data files
- Set default filegroup
- Create tables on specific filegroups
- Move data between filegroups using clustered indexes
- Remove filegroups safely

Notes:
- Adjust file paths according to your environment.
- Intended for lab / learning purposes.
*/

USE master;
GO

/*------------------------------------------------------------
 Create filegroup and add data file
------------------------------------------------------------*/

ALTER DATABASE BaseDatosEjemplo
ADD FILEGROUP GrupoArchivo02;
GO

ALTER DATABASE BaseDatosEjemplo
ADD FILE
(
    NAME = 'BaseDatosEjemploFichero3',
    FILENAME = 'E:\BBDD\disco2\BaseDatosEjemplo3.ndf',
    SIZE = 1MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP GrupoArchivo02;
GO

-- Set new filegroup as default
ALTER DATABASE BaseDatosEjemplo
MODIFY FILEGROUP GrupoArchivo02 DEFAULT;
GO

/*------------------------------------------------------------
 Create table on specific filegroup
------------------------------------------------------------*/

USE BaseDatosEjemplo;
GO

CREATE TABLE dbo.Prueba
(
    id INT IDENTITY,
    nombre VARCHAR(30),
    edad INT
)
ON GrupoArchivo02;
GO

/*------------------------------------------------------------
 Review filegroups and table placement
------------------------------------------------------------*/

SELECT * FROM sys.filegroups;
GO

SELECT o.name AS table_name,
       i.name AS index_name,
       i.index_id,
       f.name AS filegroup_name
FROM sys.indexes i
JOIN sys.filegroups f 
  ON i.data_space_id = f.data_space_id
JOIN sys.all_objects o
  ON i.object_id = o.object_id
WHERE o.type = 'U';
GO

/*------------------------------------------------------------
 Option 1: Table without clustered index
 Move data by creating clustered PK on another filegroup
------------------------------------------------------------*/

ALTER TABLE dbo.Prueba
ADD CONSTRAINT PK_Prueba PRIMARY KEY CLUSTERED (id)
ON [PRIMARY];
GO

/*------------------------------------------------------------
 Option 2: Table with clustered PK constraint
 Drop and recreate the clustered index on another filegroup
------------------------------------------------------------*/

CREATE TABLE dbo.Prueba2
(
    id INT IDENTITY CONSTRAINT PK_Prueba2 PRIMARY KEY CLUSTERED,
    nombre VARCHAR(30),
    edad INT
)
ON GrupoArchivo02;
GO

ALTER TABLE dbo.Prueba2
DROP CONSTRAINT PK_Prueba2;
GO

ALTER TABLE dbo.Prueba2
ADD CONSTRAINT PK_Prueba2 PRIMARY KEY CLUSTERED (id)
ON [PRIMARY];
GO

/*------------------------------------------------------------
 Option 3: Table with clustered index (no constraint)
 Rebuild index using DROP_EXISTING
------------------------------------------------------------*/

CREATE TABLE dbo.Prueba3
(
    id INT IDENTITY,
    nombre VARCHAR(30),
    edad INT
)
ON GrupoArchivo02;
GO

CREATE CLUSTERED INDEX IX_Prueba3
ON dbo.Prueba3(id);
GO

CREATE CLUSTERED INDEX IX_Prueba3
ON dbo.Prueba3(id)
WITH (DROP_EXISTING = ON)
ON [PRIMARY];
GO

/*------------------------------------------------------------
 Remove filegroup (must be empty)
------------------------------------------------------------*/

-- Set PRIMARY as default filegroup
ALTER DATABASE BaseDatosEjemplo
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

-- Remove data file
ALTER DATABASE BaseDatosEjemplo
REMOVE FILE BaseDatosEjemploFichero3;
GO

-- Remove filegroup
ALTER DATABASE BaseDatosEjemplo
REMOVE FILEGROUP GrupoArchivo02;
GO
