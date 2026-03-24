-- English test data script
-- Usage: run school.sql first to create the schema, then run this file to import test data.

USE school;

-- Clear existing data if present
DELETE FROM CourseCalendar;
DELETE FROM CourseSelect;
DELETE FROM User;
DELETE FROM Other;
DELETE FROM Term;
DELETE FROM Student;
DELETE FROM Teacher;
DELETE FROM Course;
DELETE FROM Department;

-- ==================== Department Data ====================
INSERT INTO Department (did, dname, address, phone) VALUES
('01', 'Computer Science', 'Main Building A-101', '010-12345678'),
('02', 'Software Engineering', 'Main Building B-201', '010-12345679'),
('03', 'Mathematics', 'Main Building C-301', '010-12345680'),
('04', 'Physics', 'Main Building D-401', '010-12345681'),
('05', 'Foreign Languages', 'Main Building E-501', '010-12345682');

-- ==================== Student Data ====================
INSERT INTO Student (id, name, gender, birthday, birthplace, phone, did) VALUES
('2021001', 'Alex Carter', 'Male', '2003-01-15', 'Beijing', '13800138001', '01'),
('2021002', 'Bella Chen', 'Female', '2003-03-20', 'Shanghai', '13800138002', '01'),
('2021003', 'Chris Lin', 'Male', '2003-05-10', 'Guangzhou', '13800138003', '01'),
('2021004', 'Diana Moore', 'Female', '2003-07-25', 'Shenzhen', '13800138004', '01'),
('2021005', 'Ethan Park', 'Male', '2003-09-30', 'Hangzhou', '13800138005', '01'),
('2021101', 'Fiona Davis', 'Female', '2003-02-14', 'Nanjing', '13800138101', '02'),
('2021102', 'Grace Kim', 'Male', '2003-04-18', 'Wuhan', '13800138102', '02'),
('2021103', 'Henry Lee', 'Female', '2003-06-22', 'Chengdu', '13800138103', '02'),
('2021104', 'Ivy Turner', 'Male', '2003-08-05', 'Xi''an', '13800138104', '02'),
('2021201', 'Jack Hall', 'Male', '2003-03-12', 'Tianjin', '13800138201', '03'),
('2021202', 'Lily Scott', 'Female', '2003-05-16', 'Chongqing', '13800138202', '03'),
('2021203', 'Mason Reed', 'Male', '2003-07-20', 'Qingdao', '13800138203', '03');

-- ==================== Teacher Data ====================
INSERT INTO Teacher (tid, did, tname, gender, birthday, education, wage) VALUES
('T001', '01', 'Prof. Adams', 'Male', '1975-03-15', 'Doctorate', 15000),
('T002', '01', 'Assoc. Prof. Baker', 'Female', '1980-06-20', 'Doctorate', 12000),
('T003', '01', 'Lect. Clark', 'Male', '1985-09-10', 'Master', 9000),
('T101', '02', 'Prof. Evans', 'Female', '1970-02-08', 'Doctorate', 16000),
('T102', '02', 'Assoc. Prof. Foster', 'Male', '1978-11-25', 'Doctorate', 13000),
('T201', '03', 'Prof. Green', 'Male', '1972-05-18', 'Doctorate', 15500),
('T202', '03', 'Lect. Harris', 'Female', '1983-08-30', 'Master', 9500);

-- ==================== Course Data ====================
INSERT INTO Course (cid, cname, credit, did) VALUES
('CS101', 'Data Structures', '4', '01'),
('CS102', 'Computer Networks', '3', '01'),
('CS103', 'Operating Systems', '4', '01'),
('CS104', 'Database Systems', '3', '01'),
('CS105', 'Algorithm Design', '4', '01'),
('SE101', 'Software Engineering', '3', '02'),
('SE102', 'Software Testing', '2', '02'),
('SE103', 'Web Development', '3', '02'),
('SE104', 'Mobile Development', '3', '02'),
('MA101', 'Advanced Mathematics', '5', '03'),
('MA102', 'Linear Algebra', '3', '03'),
('MA103', 'Probability Theory', '3', '03');

-- ==================== Term Data ====================
INSERT INTO Term (term, isCurrent) VALUES
('2022-2023 Fall', 'no'),
('2022-2023 Spring', 'no'),
('2023-2024 Fall', 'no'),
('2023-2024 Spring', 'yes'),
('2024-2025 Fall', 'no');

-- ==================== User Data ====================
-- All passwords are: 123456
INSERT INTO User (id, password, identity) VALUES
('admin', '123456', 'admin'),
('2021001', '123456', 'student'),
('2021002', '123456', 'student'),
('2021003', '123456', 'student'),
('2021004', '123456', 'student'),
('2021005', '123456', 'student'),
('2021101', '123456', 'student'),
('2021102', '123456', 'student'),
('2021103', '123456', 'student'),
('2021104', '123456', 'student'),
('2021201', '123456', 'student'),
('2021202', '123456', 'student'),
('2021203', '123456', 'student'),
('T001', '123456', 'teacher'),
('T002', '123456', 'teacher'),
('T003', '123456', 'teacher'),
('T101', '123456', 'teacher'),
('T102', '123456', 'teacher'),
('T201', '123456', 'teacher'),
('T202', '123456', 'teacher');

-- ==================== Enrollment and Score Data ====================
INSERT INTO CourseCalendar (id, cid, tid, term, classTime, score) VALUES
('2021001', 'CS101', 'T001', '2023-2024 Spring', 'Mon1-2', 92),
('2021001', 'CS102', 'T002', '2023-2024 Spring', 'Tue3-4', 88),
('2021001', 'MA101', 'T201', '2023-2024 Spring', 'Wed5-6', 85),
('2021002', 'CS101', 'T001', '2023-2024 Spring', 'Mon1-2', 95),
('2021002', 'CS103', 'T003', '2023-2024 Spring', 'Thu1-2', 90),
('2021002', 'MA102', 'T202', '2023-2024 Spring', 'Fri3-4', 93),
('2021003', 'CS101', 'T001', '2023-2024 Spring', 'Mon1-2', 78),
('2021003', 'CS102', 'T002', '2023-2024 Spring', 'Tue3-4', 82),
('2021003', 'CS104', 'T001', '2023-2024 Spring', 'Wed1-2', 86),
('2021004', 'CS101', 'T001', '2023-2024 Spring', 'Mon1-2', 91),
('2021004', 'MA101', 'T201', '2023-2024 Spring', 'Wed5-6', 89),
('2021005', 'CS102', 'T002', '2023-2024 Spring', 'Tue3-4', 87),
('2021005', 'CS103', 'T003', '2023-2024 Spring', 'Thu1-2', 84),
('2021101', 'SE101', 'T101', '2023-2024 Spring', 'Mon3-4', 92),
('2021101', 'SE102', 'T102', '2023-2024 Spring', 'Tue5-6', 88),
('2021101', 'MA101', 'T201', '2023-2024 Spring', 'Wed5-6', 90),
('2021102', 'SE101', 'T101', '2023-2024 Spring', 'Mon3-4', 85),
('2021102', 'SE103', 'T101', '2023-2024 Spring', 'Wed1-2', 87),
('2021103', 'SE101', 'T101', '2023-2024 Spring', 'Mon3-4', 94),
('2021103', 'SE104', 'T102', '2023-2024 Spring', 'Thu3-4', 91),
('2021201', 'MA101', 'T201', '2023-2024 Spring', 'Wed5-6', 96),
('2021201', 'MA102', 'T202', '2023-2024 Spring', 'Fri3-4', 94),
('2021201', 'CS101', 'T001', '2023-2024 Spring', 'Mon1-2', 88),
('2021202', 'MA101', 'T201', '2023-2024 Spring', 'Wed5-6', 92),
('2021202', 'MA103', 'T201', '2023-2024 Spring', 'Tue1-2', 90),
('2021203', 'MA102', 'T202', '2023-2024 Spring', 'Fri3-4', 87),
('2021203', 'CS102', 'T002', '2023-2024 Spring', 'Tue3-4', 85),
('2021001', 'CS105', 'T001', '2023-2024 Fall', 'Mon3-4', 90),
('2021001', 'MA102', 'T202', '2023-2024 Fall', 'Fri3-4', 87),
('2021002', 'CS104', 'T001', '2023-2024 Fall', 'Wed1-2', 93),
('2021002', 'SE101', 'T101', '2023-2024 Fall', 'Mon3-4', 91),
('2021101', 'SE104', 'T102', '2023-2024 Fall', 'Thu3-4', 89),
('2021102', 'SE102', 'T102', '2023-2024 Fall', 'Tue5-6', 86);

-- ==================== System Settings ====================
INSERT INTO Other (name, msg) VALUES
('courseSelectionOpen', '1'),
('systemName', 'Academic System');

-- ==================== Completed ====================
SELECT 'English test data import completed.' AS message;

SELECT 'Departments' AS category, COUNT(*) AS total FROM Department
UNION ALL
SELECT 'Students', COUNT(*) FROM Student
UNION ALL
SELECT 'Teachers', COUNT(*) FROM Teacher
UNION ALL
SELECT 'Courses', COUNT(*) FROM Course
UNION ALL
SELECT 'Terms', COUNT(*) FROM Term
UNION ALL
SELECT 'Users', COUNT(*) FROM User
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM CourseCalendar;

SELECT '
Test Accounts (all passwords: 123456)

[Admin]
Username: admin
Password: 123456
Role: admin

[Students]
Username: 2021001 (Alex Carter - Computer Science)
Username: 2021002 (Bella Chen - Computer Science)
Username: 2021003 (Chris Lin - Computer Science)
Username: 2021101 (Fiona Davis - Software Engineering)
Username: 2021201 (Jack Hall - Mathematics)
Password: 123456
Role: student

[Teachers]
Username: T001 (Prof. Adams - Computer Science)
Username: T002 (Assoc. Prof. Baker - Computer Science)
Username: T101 (Prof. Evans - Software Engineering)
Username: T201 (Prof. Green - Mathematics)
Password: 123456
Role: teacher
' AS account_info;
