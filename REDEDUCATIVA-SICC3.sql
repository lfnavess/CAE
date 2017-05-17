USE [Reportes];

IF OBJECT_ID('tempdb..#SICC3') IS NOT NULL DROP TABLE #SICC3
SELECT
	"tbl_colaboradores_view"."CAE ID"																		AS "id",
	"tbl_colaboradores_view"."CAE usuario" COLLATE Latin1_General_CS_AS										AS "username",
	CAST("tbl_colaboradores_view"."Nombre(s)" AS NVARCHAR(50)) COLLATE Latin1_General_CS_AS					AS "firstname",
	CAST("tbl_colaboradores_view"."Apellido paterno" AS NVARCHAR(70)) COLLATE Latin1_General_CS_AS			AS "lastname",
	CAST("tbl_colaboradores_view"."Posición >Lugar" AS VARCHAR(25)) COLLATE Latin1_General_CS_AS			AS "zipcode",
	CAST(NULL AS VARCHAR(40)) COLLATE Latin1_General_CS_AS													AS "telephone1",
	CAST("tbl_colaboradores_view"."Posición >CC >Nombre" AS NVARCHAR(80)) COLLATE Latin1_General_CS_AS		AS "state",
	CAST("tbl_colaboradores_view"."Posición >Puesto >Nombre" AS VARCHAR(40)) COLLATE Latin1_General_CS_AS	AS "telephone2",
	CAST(
		COALESCE("tbl_colaboradores_view"."Posición >Email", 'REDEDUCATIVA@PPG.COM')
		AS NVARCHAR(100)
	) COLLATE Latin1_General_CS_AS 																			AS "email",
	CONVERT(VARCHAR(40), "tbl_colaboradores_view"."Posición >Alta", 103) COLLATE Latin1_General_CS_AS		AS "fax",
	CONVERT(VARCHAR(8), "tbl_colaboradores_view"."Posición >Baja", 112) COLLATE Latin1_General_CS_AS		AS "datecredituse",
	CAST("jefe"."Nombre corto" AS NVARCHAR(200)) COLLATE Latin1_General_CS_AS								AS "address",
	CAST(NULL AS VARCHAR(40)) COLLATE Latin1_General_CS_AS													AS "dni",
	CAST(NULL AS VARCHAR(40)) COLLATE Latin1_General_CS_AS													AS "city",
	CASE WHEN "tbl_colaboradores_view"."CAE licencia" = 0 THEN 1 ELSE 0 END									AS "deleted",
	CASE WHEN "tbl_colaboradores_view"."Posición >Email" IS NULL THEN 0 ELSE 1 END							AS "emailnotifications",
	COALESCE("tbl_colaboradores_view"."Actualizado por", "tbl_colaboradores_view"."Actualizado por")		AS "modifierid",
	COALESCE("tbl_colaboradores_view"."Fecha actualizado", "tbl_colaboradores_view"."Fecha insertado")		AS "modificationtime"
INTO #SICC3
FROM
	"tbl_colaboradores_view"
	LEFT JOIN"tbl_colaboradores_view" AS "jefe" ON "jefe"."Colaborador ID" = "tbl_colaboradores_view"."Posición >Posición jefe >Colaborador";

IF OBJECT_ID('tempdb..#REDEDUCATIVA') IS NOT NULL DROP TABLE #REDEDUCATIVA
SELECT 
	"vt_users"."id",
	"vt_users"."username" COLLATE Latin1_General_CS_AS												AS "username",
	"vt_users"."firstname" COLLATE Latin1_General_CS_AS												AS "firstname",
	"vt_users"."lastname" COLLATE Latin1_General_CS_AS												AS "lastname",
	COALESCE("vt_users"."zipcode", '') COLLATE Latin1_General_CS_AS									AS "zipcode",
	COALESCE("vt_users"."telephone1", '') COLLATE Latin1_General_CS_AS								AS "telephone1",
	COALESCE("vt_users"."state", '') COLLATE Latin1_General_CS_AS									AS "state",
	COALESCE("vt_users"."telephone2", '') COLLATE Latin1_General_CS_AS								AS "telephone2",
	COALESCE("vt_users"."email", '') COLLATE Latin1_General_CS_AS									AS "email",
	COALESCE("vt_users"."fax", '') COLLATE Latin1_General_CS_AS										AS "fax",
	COALESCE(CONVERT(VARCHAR(8), "vt_users"."datecredituse", 112), '') COLLATE Latin1_General_CS_AS	AS "datecredituse",
	COALESCE("vt_users"."address", '') COLLATE Latin1_General_CS_AS									AS "address",
	COALESCE("vt_users"."dni", '') COLLATE Latin1_General_CS_AS										AS "dni",
	COALESCE("vt_users"."city", '') COLLATE Latin1_General_CS_AS									AS "city",
	"vt_users"."deleted",
	"vt_users"."emailnotifications",
	"vt_users"."modifierid",
	"vt_users"."modificationtime"
INTO #REDEDUCATIVA
FROM "WWW.REDEDUCATIVA.COM.MX"."comex"."dbo"."vt_users" 
WHERE "vt_users"."siteid" = 5;


UPDATE "vt_users" SET
	"vt_users"."username" 			= #SICC3."username",
	"vt_users"."firstname" 			= #SICC3."firstname",
	"vt_users"."lastname" 			= #SICC3."lastname",
	"vt_users"."zipcode" 			= #SICC3."zipcode",
	"vt_users"."telephone1" 		= #SICC3."telephone1",
	"vt_users"."state" 				= #SICC3."state",
	"vt_users"."telephone2" 		= #SICC3."telephone2",
	"vt_users"."email" 				= #SICC3."email",
	"vt_users"."fax" 				= #SICC3."fax",
	"vt_users"."datecredituse"		= #SICC3."datecredituse",
	"vt_users"."address" 			= #SICC3."address",
	"vt_users"."dni"				= #SICC3."dni",
	"vt_users"."city"				= #SICC3."city",
	"vt_users"."deleted" 			= #SICC3."deleted",
	"vt_users"."emailnotifications"	= #SICC3."emailnotifications",
	"vt_users"."modifierid"			= 6206,
	"vt_users"."modificationtime"	= GETUTCDATE()
FROM
	#SICC3
	INNER JOIN #REDEDUCATIVA ON #REDEDUCATIVA."id" = #SICC3."id"
	LEFT JOIN #REDEDUCATIVA AS "COLISION" ON
		"COLISION"."username" collate Latin1_General_CI_AS = #SICC3."username" collate Latin1_General_CI_AS
		AND "COLISION"."id" <> #SICC3."id"
	INNER JOIN "WWW.REDEDUCATIVA.COM.MX"."comex"."dbo"."vt_users" ON "vt_users"."id" = #SICC3."id"
WHERE
	"COLISION"."id" IS NULL
	AND(
		   #REDEDUCATIVA."username" 			<> #SICC3."username"
		OR #REDEDUCATIVA."firstname" 			<> #SICC3."firstname"
		OR #REDEDUCATIVA."lastname" 			<> #SICC3."lastname"
		OR #REDEDUCATIVA."zipcode" 				<> COALESCE(#SICC3."zipcode", '')
		OR #REDEDUCATIVA."telephone1"			<> COALESCE(#SICC3."telephone1", '')
		OR #REDEDUCATIVA."state" 				<> COALESCE(#SICC3."state", '')
		OR #REDEDUCATIVA."telephone2" 			<> COALESCE(#SICC3."telephone2", '')
		OR #REDEDUCATIVA."email" 				<> COALESCE(#SICC3."email", '')
		OR #REDEDUCATIVA."fax"					<> COALESCE(#SICC3."fax", '')
		OR #REDEDUCATIVA."datecredituse"		<> COALESCE(#SICC3."datecredituse", '')
		OR #REDEDUCATIVA."address" 				<> COALESCE(#SICC3."address", '')
		OR #REDEDUCATIVA."dni" 					<> COALESCE(#SICC3."dni", '')
		OR #REDEDUCATIVA."city" 				<> COALESCE(#SICC3."city", '')
		OR #REDEDUCATIVA."deleted" 				<> #SICC3."deleted"
		OR #REDEDUCATIVA."emailnotifications"	<> #SICC3."emailnotifications"
	);

GO
	
--cursos
IF OBJECT_ID('dbo.cursos') IS NOT NULL DROP TABLE dbo.cursos;
SELECT * INTO "Cursos" FROM "WWW.REDEDUCATIVA.COM.MX"."comex"."dbo"."comex_courses";

--inscripciones
IF OBJECT_ID('dbo.inscripciones') IS NOT NULL DROP TABLE dbo.inscripciones;
SELECT * INTO "inscripciones" FROM "WWW.REDEDUCATIVA.COM.MX"."comex"."dbo"."comex_enrolments";

GO

--Reporte del año	
SELECT *
FROM "Reporte_RedEducativa"
WHERE
	"Capacitación año" >= 2017 OR
	"Curso >Categoría" = 'Institucional >Todos'
	AND "Estado" NOT IN('Fuga', 'Cancelado')
ORDER BY
	"Alumno >Nombre corto",
	"Alumno >PPG ID",
	"Fecha inicio" DESC,
	"Curso >Nombre";