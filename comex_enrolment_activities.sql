IF OBJECT_ID('dbo.comex_enrolment_activities', 'V')IS NOT NULL DROP VIEW dbo.comex_enrolment_activities;
GO
CREATE VIEW dbo.comex_enrolment_activities
AS
SELECT
    dbo.offset(GETUTCDATE())                                                                        AS"reporttime",
    "vt_enrolments"."id"                                                                            AS"enrolmentid",
    "vt_course_activities"."id"                                                                     AS"activityid",
    CASE
        WHEN"vt_enrolment_activities"."cmi_completion_status"='completed'OR"vt_courses"."courseversion"IN('BLENDED', 'LIGA')THEN 1.0
        ELSE 0
    END                                                                                             AS"progress_measure",
    CASE
        WHEN
            "vt_activities_lang"."title"='Autodiagnóstico'
            AND"vt_courses"."minscore"IS NOT NULL
            AND"vt_enrolment_activities"."cmi_completion_status"='completed'
            AND"vt_enrolment_activities"."cmi_score_max">0
        THEN
            CAST(
                CAST("vt_enrolment_activities"."cmi_score_raw"-"vt_enrolment_activities"."cmi_score_min"AS DECIMAL(7,4))
                /CAST("vt_enrolment_activities"."cmi_score_max"-"vt_enrolment_activities"."cmi_score_min"AS DECIMAL(7,4))*100
                AS INT
            )
    END                                                                                             AS"pre_score",
    CASE
        WHEN
            "vt_activities_lang"."title"<>'Autodiagnóstico'
            AND("vt_ca_access_control"."scoreweight"IS NULL OR"vt_ca_access_control"."scoreweight"<>0)
            AND"vt_courses"."minscore"IS NOT NULL
            AND"vt_enrolment_activities"."cmi_completion_status"='completed'
            AND"vt_enrolment_activities"."cmi_score_max">0
        THEN
            CAST(
                CAST("vt_enrolment_activities"."cmi_score_raw"-"vt_enrolment_activities"."cmi_score_min"AS DECIMAL(7,4))
                /CAST("vt_enrolment_activities"."cmi_score_max"-"vt_enrolment_activities"."cmi_score_min"AS DECIMAL(7,4))*100
                AS INT
            )
    END                                                                                             AS"post_score",
    dbo.offset("vt_enrolment_activities"."lastaccess")                                              AS"lastaccess",
    "vt_enrolment_activities"."cmi_suspend_data"
FROM
    "vt_enrolments"
    LEFT JOIN"vt_course_groups"         ON"vt_course_groups"."id"="vt_enrolments"."groupid"
    LEFT JOIN"vt_courses"               ON"vt_courses"."id"="vt_course_groups"."courseid"
    LEFT JOIN"vt_course_activities"     ON"vt_course_activities"."courseid"="vt_courses"."id"
    JOIN"vt_activities"                 ON"vt_activities"."type"=1 AND"vt_activities"."id"="vt_course_activities"."activityid"
    LEFT JOIN"vt_ca_access_control"     ON
        "vt_ca_access_control"."groupid"="vt_course_groups"."id"
        AND"vt_ca_access_control"."activityid"="vt_course_activities"."id"
    LEFT JOIN"vt_activities_lang"       ON"vt_activities_lang"."lang"='xx'AND"vt_activities_lang"."activityid" = "vt_course_activities"."activityid"
    LEFT JOIN"vt_enrolment_activities"  ON
        "vt_enrolment_activities"."enrolmentid"="vt_enrolments"."id"
        AND"vt_enrolment_activities"."activityid"="vt_course_activities"."id";