IF OBJECT_ID('dbo.comex_enrolments', 'V')IS NOT NULL DROP VIEW dbo.comex_enrolments;
GO
CREATE VIEW dbo.comex_enrolments
AS
SELECT
    dbo.offset(GETUTCDATE())AS"reporttime",
    "enrolment_last"."enrolmentid",
    CASE
        WHEN"enrolment_status"."progress_measure"=1 AND"vt_users"."deleted"=0 AND"vt_users"."datecredituse"IS NULL              THEN 1
        WHEN"enrolment_status"."progress_measure"=1                                                                             THEN 3
        WHEN
            "vt_enrolments"."active"=0
            OR"vt_users"."deleted"=1
            OR"vt_users"."datecredituse"IS NOT NULL
            OR"vt_enrolments"."endtime"<DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
            AND"vt_courses"."active"=0                                                                                          THEN 4
                                                                                    THEN 5
        WHEN"vt_enrolments"."endtime"<DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)AND"enrolment_status"."lastaccess"IS NOT NULL THEN 6
        WHEN"vt_enrolments"."endtime"<DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)                                              THEN 7
        WHEN"vt_enrolments"."starttime"<=GETDATE()AND"enrolment_status"."lastaccess"IS NOT NULL                                 THEN 8
        WHEN"vt_enrolments"."starttime"<=GETDATE()                                                                              THEN 9
        ELSE 10
    END AS"completion_status",
    "vt_enrolments"."userid",
    "vt_course_groups"."courseid",
    "enrolment_status"."progress_measure",
    "enrolment_status"."pre_score",
    CASE WHEN"enrolment_status"."progress_measure"=1 THEN"enrolment_status"."post_score"END AS"post_score",
    CAST("vt_enrolments"."starttime"AS SMALLDATETIME)AS "starttime",
    CAST("vt_enrolments"."endtime"AS SMALLDATETIME)AS"endtime",
    CASE
        WHEN"vt_courses"."courseversion"IN('BLENDED', 'LIGA')THEN CAST("vt_enrolments"."endtime"AS SMALLDATETIME)
        ELSE"enrolment_status"."lastaccess"
    END AS"lastaccess",
    "requestby"."id" AS "requestby",
    --CASE 
    --  WHEN"vt_course_groups"."name"='Inscripciones libres'THEN 13177 
    --  WHEN"requestby"."id"IS NULL                         THEN"vt_course_groups"."creatorid"
    --  ELSE"requestby"."id"
    --END AS"requestby",
    "enrolment_last"."enrolments",
    "vt_enrolments"."active",
    "vt_enrolments"."creatorid",
    dbo.offset("vt_enrolments"."creationtime")AS"creationtime"
FROM(
        SELECT MAX("vt_enrolments"."id")AS"enrolmentid",NULLIF(COUNT(*), 1)AS"enrolments"
        FROM
            "vt_enrolments"
            LEFT JOIN"vt_course_groups" ON"vt_course_groups"."id"="vt_enrolments"."groupid"
            LEFT JOIN"vt_users"         ON"vt_users"."id"="vt_enrolments"."userid"
        WHERE"vt_course_groups"."name"<>'Inscripciones libres'
        GROUP BY"vt_enrolments"."userid","vt_course_groups"."courseid"
    ) AS"enrolment_last"
    LEFT JOIN(
        SELECT
            "enrolmentid",
            1.0*AVG("progress_measure")/100AS"progress_measure",
            AVG("pre_score")AS"pre_score",
            AVG("post_score")AS"post_score",
            MAX("lastaccess")AS"lastaccess"
        FROM"comex_enrolment_activities"
        GROUP BY"enrolmentid"
    )AS"enrolment_status"               ON"enrolment_status"."enrolmentid"="enrolment_last"."enrolmentid"
    LEFT JOIN"vt_enrolments"            ON"vt_enrolments"."id"="enrolment_last"."enrolmentid"
    LEFT JOIN"vt_course_groups"         ON"vt_course_groups"."id"="vt_enrolments"."groupid"
    LEFT JOIN"vt_courses"               ON"vt_courses"."id"="vt_course_groups"."courseid"
    LEFT JOIN"vt_users"                 ON"vt_users"."id"="vt_enrolments"."userid"
    LEFT JOIN"vt_users" AS"requestby"   ON
        "requestby"."siteid"=5
        AND"requestby"."username"=SUBSTRING("vt_course_groups"."name", NULLIF(CHARINDEX('|',"vt_course_groups"."name"), 0) + 1, 20)
WHERE"vt_users"."siteid"=5;