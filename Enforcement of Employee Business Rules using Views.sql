--Business Rules---
-- 1. College Management wants to know the student's detail who graduated the program with Distinction for providing them with a gold medal and distinction certificates.
-- 2. College Management wants to know the Course's detail with the least number of enrollment to improve the standards of that course in the upcoming year.
-- 3. College Management wants to know the student's detail who deferred the program to update the new fee details of the upcoming semester.
-- 4. College Management wants to know the student's detail who failed to graduate from the program.
-- 5. College Management wants to know the Course's detail with the most number of enrollments.
-- 6)To generate a report containing the average score of students in each program
--7) To analyse whether the number of program taken by the professor and the avg grade of the course
--8) the financial department wants to know the list of graduate students who have pending fees before they can issuse the certificate.
--9)the registra wants to have the mailing address of all the graduate students, inorder to mail them
--their transcript.
--10)The studen success members wants to know of all the possible status code which a student can have.

-- 1. College Management wants to know the student's detail who graduated the program with Distinction for providing them with a gold medal and distinction certificates.
USE SIS
GO
CREATE or alter VIEW Honour_Students with SCHEMABINDING,ENCRYPTION AS
SELECT StudentProgram.studentNumber,StudentProgram.programCode, CourseStudent.finalMark, StudentProgram.programStatusCode
FROM [dbo].[StudentProgram] INNER JOIN [dbo].[CourseStudent]
ON (StudentProgram.studentNumber = CourseStudent.studentNumber)
WHERE CourseStudent.finalMark >= 80 AND StudentProgram.programStatusCode = 'G'
WITH CHECK OPTION
GO
SELECT * 
FROM Honour_Students
GO

--When first tried to execute the view with schema binding got an error msg of
--"Names must be in two-part format and an object cannot reference itself."
--Which was due to using databasename.user.table but after removing the database name to reference the table
--everything worked out
--system query to list the view syntax worked before encrypt but didnt after 
--returned null 
-- when tried to insert a value less than 80 to view as manual testing resulted in an error
--thus we can say that check option prevents values that does not meet the filter condition to enter.
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Honour_Students')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Honour_Students');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Honour_Students';
GO

-- 2. College Management wants to know the Course's detail with the least number of enrollment to improve the standards of that course in the upcoming year.

CREATE VIEW Unpopular_Courses with SCHEMABINDING,ENCRYPTION AS
SELECT ProgramCourse.programCode, ProgramCourse.courseNumber, CourseOffering.enrollment
FROM [dbo].[ProgramCourse] INNER JOIN [dbo].[CourseOffering]
ON (ProgramCourse.courseNumber = CourseOffering.courseNumber)
WHERE CourseOffering.enrollment <= 15
WITH CHECK OPTION
GO
SELECT *
FROM Unpopular_Courses
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Unpopular_Courses')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Unpopular_Courses');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Unpopular_Courses';
GO

-- 3. College Management wants to know the student's detail who deferred the program to update the new fee details of the upcoming semester.

CREATE VIEW Deferred_Students  with SCHEMABINDING,ENCRYPTION AS
SELECT Student.number, Student.isInternational, Student.academicStatusCode, Student.financialStatusCode, 
       Student.sequentialNumber, Student.balance, Student.localStreet, Student.localCity, Student.localProvinceCode,
	   Student.localCountryCode, Student.localPostalCode, Student.localPhone, FinancialStatus.explanation
FROM [dbo].[Student] INNER JOIN [dbo].[FinancialStatus]
ON (Student.financialStatusCode = FinancialStatus.code)
WHERE Student.financialStatusCode = 'D'
WITH CHECK OPTION
GO
SELECT *
FROM Deferred_Students
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Deferred_Students')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Deferred_Students');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Deferred_Students';
GO

-- 4. College Management wants to know the student's detail who failed to graduate from the program.

CREATE VIEW Failed_Students with SCHEMABINDING,ENCRYPTION AS
SELECT StudentProgram.studentNumber,StudentProgram.programCode, CourseStudent.finalMark, StudentProgram.programStatusCode
FROM [dbo].[StudentProgram] INNER JOIN [dbo].[CourseStudent]
ON (StudentProgram.studentNumber = CourseStudent.studentNumber)
WHERE CourseStudent.finalMark <= 59 AND StudentProgram.programStatusCode = 'G'
WITH CHECK OPTION
GO
SELECT * 
FROM Failed_Students
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Failed_Students')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Failed_Students');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Failed_Students';
GO

-- 5. College Management wants to know the Course's detail with the most number of enrollments.

CREATE VIEW Popular_Courses with SCHEMABINDING,ENCRYPTION AS
SELECT ProgramCourse.programCode, ProgramCourse.courseNumber, CourseOffering.enrollment
FROM [dbo].[ProgramCourse] INNER JOIN [dbo].[CourseOffering]
ON (ProgramCourse.courseNumber = CourseOffering.courseNumber)
WHERE CourseOffering.enrollment >= 25
WITH CHECK OPTION
GO
SELECT *
FROM Popular_Courses
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Popular_Courses')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Popular_Courses');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Popular_Courses';
GO

--6)To see the average final grade for each course and the total number of graduates from it.
CREATE or ALTER VIEW AvgScr_of_courses with SCHEMABINDING,ENCRYPTION AS 
SELECT  c.[courseNumber],avg(s.[finalMark]) as Avg_scr,count(c.[enrollment]) as Total_students
FROM 
     [dbo].[CourseStudent] s
    INNER JOIN [dbo].[CourseOffering] c
        ON s.[CourseOfferingId] = c.[id]
	where s.[finalMark]>0
	Group by c.[courseNumber]
WITH CHECK OPTION
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.AvgScr_of_courses')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.AvgScr_of_courses');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.AvgScr_of_courses';
GO

--7)now let us see the number of courses taken by a professor and its impact on the average grade of the course
Create or alter view Professor_performance with SCHEMABINDING,ENCRYPTION AS
SELECT  count(Distinct c.[courseNumber]) AS Courses,c.[employeeNumber],avg(s.[finalMark]) as Avg_scr,count(c.[enrollment]) as Total_students
FROM 
     [dbo].[CourseStudent] s
    INNER JOIN [dbo].[CourseOffering] c
        ON s.[CourseOfferingId] = c.[id]
	where s.[finalMark]>0
	Group by c.[employeeNumber]
WITH CHECK OPTION
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Professor_performance')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Professor_performance');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Professor_performance';
GO

--8)the financial department wants to know the list of graduate students who have pending fees
-- before they can issuse the certificate.

CREATE OR ALTER VIEW Student_pendings with SCHEMABINDING,ENCRYPTION AS
SELECT a.[studentNumber],a.[semester],a.[balanceAfter],s.[CourseOfferingId],c.[courseNumber],c.[sectionNumber]
FROM [dbo].[Audit] as a
INNER JOIN [dbo].[CourseStudent] as s
ON a.[studentNumber] = s.[studentNumber]
INNER JOIN [dbo].[CourseOffering] as c
ON s.[CourseOfferingId] = c.[id]
where a.balanceAfter < 0 and a.semester=3
WITH CHECK OPTION

GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Student_pendings')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Student_pendings');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Student_pendings';
GO

-- 9)the registra wants to have the mailing address of all the graduate students, inorder to mail them
--their transcript.
CREATE OR ALTER VIEW Grad_list with SCHEMABINDING,ENCRYPTION AS
SELECT s.[number],s.[localStreet],s.[localCity],s.[localProvinceCode],
s.[localCountryCode],s.[localPostalCode],s.[localPhone]
from [dbo].[Student] as s
INNER JOIN [dbo].[StudentProgram] as g
ON s.[number] = g.[studentNumber]
where g.programStatusCode like 'G'
WITH CHECK OPTION

GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Grad_list')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Grad_list');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Grad_list';
GO

--10)To list all the academic and program status possible (Cross join or cartesian join)

CREATE OR ALTER VIEW Possible_status with SCHEMABINDING,ENCRYPTION AS
SELECT s.[explanation] as academicStatus,p.[explanation] as programStatus  from [dbo].[StudentProgramStatus] as s
CROSS JOIN [dbo].[AcademicStatus] as p
ORDER BY s.[explanation] 
OFFSET 0 ROWS
WITH CHECK OPTION
GO
--System testing  
SELECT  OBJECT_DEFINITION(OBJECT_ID('dbo.Grad_list')) [THE INNER CONTENT OF THE VIEW SYNTAX];
Go
-- To list all  attributes of the view

GO  
SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound  
FROM sys.sql_modules  
WHERE object_id = OBJECT_ID('dbo.Grad_list');   
GO  
-- It will return a sentence if the viewis encrypted 
EXEC sp_helptext 'dbo.Grad_list';
GO


--System testing
--To list all the view in the database
EXEC sp_tables 
  @table_owner = 'dbo',
  @table_type = "'VIEW'";

SELECT * 
FROM   INFORMATION_SCHEMA.VIEWS 
WHERE  VIEW_DEFINITION like '%dbo.%'
