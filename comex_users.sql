IF OBJECT_ID('dbo.comex_users', 'V') IS NOT NULL DROP VIEW dbo.comex_users;
GO
CREATE VIEW dbo.comex_users
AS 
SELECT 
	"vt_users"."id"										AS "id",
	"vt_users"."username"								AS "CAE usuario",
	"vt_users"."firstname"								AS "Nombre",
	"vt_users"."lastname"								AS "Apellido paterno",
	"vt_users"."firstname" + ' ' + 
	"vt_users"."lastname"   							AS "Nombre corto"
	"vt_users"."address"								AS "Posición >Jefe >Colaborador",
	"vt_users"."zipcode"								AS "Posición >Lugar",
	"vt_users"."state"									AS "Posición >CC",
	"vt_users"."telephone1"								AS "Posición >Tipo",
	"vt_users"."telephone2"								AS "Posición >Puesto",
	NULLIF("vt_users"."email", 'REDEDUCATIVA@PPG.COM')	AS "Posición >Email",
	"vt_users"."fax"									AS "Posición >Alta",
	"vt_users"."deleted"								AS "Posición >Baja"
FROM "vt_users"
WHERE "vt_users"."siteid" = 5;