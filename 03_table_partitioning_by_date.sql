/*
Purpose:
Demonstrate table partitioning by date using filegroups,
partition functions and partition schemes.

Topics covered:
- Database creation for partitioning
- Filegroup allocation per partition
- Partition function and scheme
- Partitioned table creation
- Adding new partitions (SPLIT)

Notes:
- Adjust file paths according to your environment.
- xp_create_subdir requires sysadmin privileges.
- Lab / learning purposes.
*/

USE master;
GO

/*------------------------------------------------------------
 Create directory (optional)
------------------------------------------------------------*/

EXEC sys.xp_create_subdir 'E:\BBDD\Particionamiento';
GO

/*------------------------------------------------------------
 Create database
------------------------------------------------------------*/

IF DB_ID('BaseDatosParticionamiento') IS NOT NULL
    DROP DATABASE BaseDatosParticionamiento;
GO

CREATE DATABASE BaseDatosParticionamiento
ON PRIMARY
(
    NAME = 'BaseDatosParticionamiento_Data',
    FILENAME = 'E:\BBDD\Particionamiento\BaseDatosParticionamiento.mdf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
)
LOG ON
(
    NAME = 'BaseDatosParticionamiento_Log',
    FILENAME = 'E:\BBDD\BaseDatosParticionamiento.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
);
GO

/*------------------------------------------------------------
 Create filegroups for partitions
------------------------------------------------------------*/

ALTER DATABASE BaseDatosParticionamiento ADD FILEGROUP fgPartition01;
ALTER DATABASE BaseDatosParticionamiento ADD FILEGROUP fgPartition02;
ALTER DATABASE BaseDatosParticionamiento ADD FILEGROUP fgPartition03;
ALTER DATABASE BaseDatosParticionamiento ADD FILEGROUP fgPartition04;
GO

ALTER DATABASE BaseDatosParticionamiento
ADD FILE (NAME = 'bdPartition01', FILENAME = 'E:\BBDD\Particionamiento\bdPartition01.ndf', SIZE = 2MB)
TO FILEGROUP fgPartition01;
GO

ALTER DATABASE BaseDatosParticionamiento
ADD FILE (NAME = 'bdPartition02', FILENAME = 'E:\BBDD\Particionamiento\bdPartition02.ndf', SIZE = 2MB)
TO FILEGROUP fgPartition02;
GO

ALTER DATABASE BaseDatosParticionamiento
ADD FILE (NAME = 'bdPartition03', FILENAME = 'E:\BBDD\Particionamiento\bdPartition03.ndf', SIZE = 2MB)
TO FILEGROUP fgPartition03;
GO

ALTER DATABASE BaseDatosParticionamiento
ADD FILE (NAME = 'bdPartition04', FILENAME = 'E:\BBDD\Particionamiento\bdPartition04.ndf', SIZE = 2MB)
TO FILEGROUP fgPartition04;
GO

/*------------------------------------------------------------
 Create partition function and scheme
------------------------------------------------------------*/

USE BaseDatosParticionamiento;
GO

CREATE PARTITION FUNCTION pfDateRange (DATETIME)
AS RANGE LEFT FOR VALUES
(
    '2017-01-01T00:00:00',
    '2018-01-01T00:00:00',
    '2019-01-01T00:00:00'
);
GO

CREATE PARTITION SCHEME psDateRange
AS PARTITION pfDateRange
TO (fgPartition01, fgPartition02, fgPartition03, fgPartition04);
GO

/*------------------------------------------------------------
 Create partitioned table
------------------------------------------------------------*/

CREATE TABLE dbo.TablaPersonas
(
    idPersona BIGINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    fecha DATETIME NOT NULL,
    CONSTRAINT PK_TablaPersonas
        PRIMARY KEY CLUSTERED (idPersona, fecha)
)
ON psDateRange (fecha);
GO

/*------------------------------------------------------------
 Insert test data and check partitions
------------------------------------------------------------*/

INSERT INTO dbo.TablaPersonas (nombre, fecha)
VALUES
('Fernando',  '2018-10-22T00:00:00'),
('Luis',      '2017-10-02T00:00:00'),
('Alejandro', '2019-05-09T00:00:00'),
('Fernando',  '2000-03-04T00:00:00');
GO

SELECT nombre, fecha,
       $PARTITION.pfDateRange(fecha) AS PartitionNumber
FROM dbo.TablaPersonas;
GO

/*------------------------------------------------------------
 Add new partition (SPLIT)
------------------------------------------------------------*/

ALTER DATABASE BaseDatosParticionamiento
ADD FILEGROUP fgPartition05;
GO

ALTER DATABASE BaseDatosParticionamiento
ADD FILE
(
    NAME = 'bdPartition05',
    FILENAME = 'E:\BBDD\Particionamiento\bdPartition05.ndf',
    SIZE = 2MB
)
TO FILEGROUP fgPartition05;
GO

ALTER PARTITION SCHEME psDateRange
NEXT USED fgPartition05;
GO

ALTER PARTITION FUNCTION pfDateRange()
SPLIT RANGE ('2020-01-01T00:00:00');
GO

INSERT INTO dbo.TablaPersonas (nombre, fecha)
VALUES ('Ana', '2020-03-04T00:00:00');
GO

SELECT nombre, fecha,
       $PARTITION.pfDateRange(fecha) AS PartitionNumber
FROM dbo.TablaPersonas;
GO
