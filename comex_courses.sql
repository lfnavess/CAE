IF OBJECT_ID('dbo.comex_courses', 'V') IS NOT NULL DROP VIEW dbo.comex_courses;
GO
CREATE VIEW dbo.comex_courses
AS
SELECT TOP 100 PERCENT
	CAST(getdate() AS SMALLDATETIME) AS "reporttime",
	"vt_courses"."id",
	"vt_courses"."name" + '|' + CAST("vt_courses"."id" AS VARCHAR(20)) AS "course",
	"vt_courses"."name" AS "coursename",
	"vt_categories"."name" AS "category",
	"vt_courses"."provider",
	CASE WHEN "minscore" > 0 THEN 'Evaluar' ELSE 'No evaluar' END AS "evaluar",
	CAST(DATEADD(MINUTE, "vt_courses"."duration", 0) AS SMALLDATETIME) AS "duration",
	COALESCE("coursecode", "referencecode") AS "coursecode",
	CASE
		WHEN "vt_courses"."active" = 1 AND "vt_courses"."visible" = 1 	THEN N'EN CATÁLOGO'
		WHEN "vt_courses"."active" = 1 									THEN N'ACTIVO'
																		ELSE N'DESCONTINUADO'
	END AS "coursestatus",
	CASE
		WHEN"courseversion"IS NULL THEN'ELEARNING'
		ELSE"courseversion"
	END AS "courseversion",
	CAST(
		CASE
			WHEN"releasetime"IS NULL THEN DATEADD(HOUR, -5, "creationtime")
			ELSE"releasetime"
		END
		AS DATE
	)AS "releasetime",
	"categoryid",
	"vt_course_activities"."activities",
	"vt_courses"."active",
	"vt_courses"."visible",
	"vt_courses"."creatorid",
	"vt_courses"."creationtime"
FROM
	"vt_courses"
	JOIN "vt_categories" ON"vt_categories"."id" = "vt_courses"."categoryid"
	JOIN(
		SELECT "courseid", COUNT(*) AS "activities"
		FROM "vt_course_activities"
		WHERE "type" = 0
		GROUP BY "courseid"
	) AS "vt_course_activities" ON "vt_course_activities"."courseid" = "vt_courses"."id"
WHERE"vt_courses"."siteid" = 5;