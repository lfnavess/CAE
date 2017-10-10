UPDATE "vt_activities"
SET "vt_activities"."filename" = 'pre/index_lms_html5.html'
FROM
	"vt_activities"
	LEFT JOIN "vt_course_activities" 	ON "vt_course_activities"."activityid" = "vt_activities"."id"
 WHERE "vt_course_activities"."id" = 45070;