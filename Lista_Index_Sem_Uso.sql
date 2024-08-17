

--
-- Script responsável por listar o tamanho do INDEX e se ele está sendo usado ou não
WITH
    LISTA_INDEX AS (
        
                            SELECT
                                 OWNER
                                ,INDEX_NAME
                                ,TABLE_NAME 
                            FROM
                                ALL_INDEXES
                            WHERE
                                OWNER NOT IN (
                                                'AUDSYS','DBSAT','DBSFWUSER','GGSYS',
                                                'GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER',
                                                'SQLADMIN','SYSBACKUP','SYSDG','SYSKM','SYS$UMF',
                                                'QS_CB','PERFSTAT','QS_ADM', 'SYSRAC',
                                                'PM','SH','HR','OE',
                                                'ODM_MTR','WKPROXY','ANONYMOUS',
                                                'OWNER','SYS','SYSTEM','SCOTT',
                                                'SYSMAN','XDB','DBSNMP','EXFSYS',
                                                'OLAPSYS','MDSYS','WMSYS','WKSYS',
                                                'DMSYS','ODM','EXFSYS','CTXSYS','LBACSYS',
                                                'ORDPLUGINS','SQLTXPLAIN','OUTLN',
                                                'TSMSYS','XS$NULL','TOAD','STREAM',
                                                'SPATIAL_CSW_ADMIN','SPATIAL_WFS_ADMIN',
                                                'SI_INFORMTN_SCHEMA','QS','QS_CBADM',
                                                'QS_CS','QS_ES','QS_OS','QS_WS','PA_AWR_USER',
                                                'OWBSYS_AUDIT','OWBSYS','ORDSYS','ORDDATA',
                                                'ORACLE_OCM','MGMT_VIEW','MDDATA',
                                                'FLOWS_FILES','FLASHBACK','AWRUSER',
                                                'APPQOSSYS','APEX_PUBLIC_USER',
                                                'APEX_030200','FLOWS_020100'
                                             )
    ),
    WDS_LISTA_INDEX_EM_USO AS (
    
                                SELECT     
                                    DISTINCT
                                    OBJECT_NAME
                                FROM 
                                    gv$sql_plan p
                                JOIN 
                                    gv$sql s ON p.sql_id = s.sql_id
                                WHERE 
                                    OBJECT_NAME IN ( SELECT INDEX_NAME FROM LISTA_INDEX )
                                    
                            )
SELECT
     IDX.OWNER
    ,IDX.INDEX_NAME
    ,CASE
        WHEN IDX_EM_USO.OBJECT_NAME IS NOT NULL THEN 
            'YES' 
        ELSE 
        'NO'
     END INDEX_EM_USO
    ,CASE 
        WHEN C.CONSTRAINT_TYPE = 'P' THEN 'PRIMARY KEY'
        WHEN C.CONSTRAINT_TYPE = 'R' THEN 'FOREIGN KEY'
        ELSE 'OTHER'
    END AS CONSTRAINT_TYPE
   ,ROUND( BYTES / 1024 / 1024 / 1024 ) AS TAMANHO_INDEX_GB
FROM
    LISTA_INDEX IDX
    INNER JOIN DBA_SEGMENTS SEG ON SEG.SEGMENT_NAME = IDX.INDEX_NAME
    LEFT JOIN ALL_CONSTRAINTS C ON C.TABLE_NAME = IDX.TABLE_NAME AND C.INDEX_NAME = IDX.INDEX_NAME
    LEFT JOIN WDS_LISTA_INDEX_EM_USO IDX_EM_USO ON IDX_EM_USO.OBJECT_NAME = IDX.INDEX_NAME
ORDER BY
    TAMANHO_INDEX_GB DESC;
	
