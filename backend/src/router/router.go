package router

import (
	"net/http"
	"taas/func/admin"
	"taas/func/login"
	"taas/func/student"
	"taas/func/teacher"
	"taas/func/tools"
)

func withCORS(handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		handler(w, r)
	}
}

func Build() {
	//http.HandleFunc("/api/", sayhelloName) //设置访问的路由
	http.HandleFunc("/api/login", withCORS(login.Login))
	http.HandleFunc("/api/student/profile", withCORS(student.Profile))
	http.HandleFunc("/api/student/courseCalendar", withCORS(student.CourseCalendar))
	http.HandleFunc("/api/student/courseQuery", withCORS(student.CourseQuery))
	http.HandleFunc("/api/student/scoreTable", withCORS(student.ScoreTable))
	http.HandleFunc("/api/student/scoreSummary", withCORS(student.ScoreSummary))
	http.HandleFunc("/api/student/scoreTrend", withCORS(student.ScoreTrend))
	http.HandleFunc("/api/student/scoreCollege", withCORS(student.ScoreCollege))

	http.HandleFunc("/api/teacher/profile", withCORS(teacher.Profile))
	http.HandleFunc("/api/teacher/scoreManagement", withCORS(teacher.ScoreManagement))
	http.HandleFunc("/api/teacher/scoreAnalysis", withCORS(teacher.ScoreAnalysis))
	http.HandleFunc("/api/teacher/courseCalendar", withCORS(teacher.CourseCalendar))
	http.HandleFunc("/api/teacher/classTable", withCORS(teacher.ClassTable))

	http.HandleFunc("/api/admin/profile", withCORS(admin.Profile))
	http.HandleFunc("/api/admin/teacherManagement", withCORS(admin.TeacherManagement))
	http.HandleFunc("/api/admin/studentManagement", withCORS(admin.StudentManagement))
	http.HandleFunc("/api/admin/courseManagement", withCORS(admin.CourseManagement))
	http.HandleFunc("/api/admin/termManagement", withCORS(admin.TermManagement))

	http.HandleFunc("/api/getDepartment", withCORS(tools.GetDepartment))
	http.HandleFunc("/api/getCurrentTerm", withCORS(tools.GetCurrentTerm))
	http.HandleFunc("/api/getTidTname", withCORS(tools.GetTidTname))
	http.HandleFunc("/api/getTeacherCourseInfo", withCORS(tools.GetTeacherCourseInfo))
}
// tid, term
// cid, cname, classTime
