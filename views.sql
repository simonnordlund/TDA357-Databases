-- BasicInformation
CREATE VIEW BasicInformation AS
	SELECT idnr, name, login, Students.program, branch
	FROM Students LEFT OUTER JOIN StudentBranches ON idnr=student; 

-- FinishedCourses
CREATE VIEW FinishedCourses AS
	SELECT student, course, name AS courseName, grade, credits 
	FROM Courses INNER JOIN Taken ON code = course;
	
-- Registrations
CREATE VIEW Registrations AS
	(SELECT student, course, 'registered' AS status
	FROM Registered)
  UNION 
	(SELECT student, course, 'waiting' AS status
	FROM WaitingList);
	
-- PathToGraduations
CREATE VIEW PassedCourses AS
	SELECT student, course, credits
	FROM FinishedCourses
	WHERE grade != 'U';

CREATE VIEW UnreadMandatory AS
	(SELECT idnr AS Student, course 
	FROM Students JOIN MandatoryProgram ON Students.program=MandatoryProgram.program)
  UNION
	(SELECT student, course 
	 FROM StudentBranches JOIN MandatoryBranch 
	 ON StudentBranches.branch = MandatoryBranch.branch 
	 AND StudentBranches.program = MandatoryBranch.program)
  EXCEPT
  	(SELECT student, course FROM PassedCourses);
	
CREATE VIEW TotalCredits AS
	SELECT student, SUM(credits) AS totalCredits
	FROM PassedCourses
	GROUP BY student;
	
CREATE VIEW CountUnreadMandatory AS
	SELECT student, COUNT(course) AS mandatoryLeft
	FROM UnreadMandatory
	GROUP BY student;
	
CREATE VIEW PartPath AS
	SELECT 
		Students.idnr, 
		COALESCE(totalCredits, 0) AS totalCredits, 
		COALESCE(mandatoryLeft, 0) AS mandatoryLeft
	FROM Students LEFT JOIN TotalCredits ON Students.idnr=TotalCredits.student
	LEFT JOIN CountUnreadMandatory ON Students.idnr=CountUnreadMandatory.student;

CREATE VIEW PassedCreditsRecommended AS
	SELECT 
		StudentBranches.student,
		SUM(credits) AS recommendedCredits
	FROM StudentBranches JOIN RecommendedBranch 
	ON StudentBranches.branch = RecommendedBranch.branch 
	AND StudentBranches.program = RecommendedBranch.program
	JOIN PassedCourses 
	ON StudentBranches.student = PassedCourses.student
	AND PassedCourses.course = RecommendedBranch.course
	GROUP BY StudentBranches.student;
	
CREATE VIEW PassedCreditsMath AS
	SELECT 
		student,  
		SUM(credits) AS mathCredits
	FROM PassedCourses JOIN Classified 
	ON PassedCourses.course = Classified.course 
	WHERE classification = 'math'
	GROUP BY student;

CREATE VIEW PassedCoursesSeminar AS
	SELECT 
		student,  
		COUNT(PassedCourses.course) AS SeminarCourses
	FROM PassedCourses JOIN Classified 
	ON PassedCourses.course = Classified.course 
	WHERE classification = 'seminar'
	GROUP BY student;

CREATE VIEW PathToGraduation AS
	SELECT 
		idnr AS student, 
		totalCredits,
		mandatoryLeft,
		COALESCE(mathCredits, 0) AS mathCredits,
		COALESCE(seminarCourses, 0) AS seminarCourses,
		COALESCE(recommendedCredits >= 10 AND mandatoryLeft = 0 AND mathCredits >= 20 AND seminarCourses > 0, FALSE) AS qualified
	FROM PartPath LEFT JOIN PassedCreditsRecommended ON PartPath.idnr=PassedCreditsRecommended.student
	LEFT JOIN PassedCreditsMath ON PartPath.idnr = PassedCreditsMath.student
	LEFT JOIN PassedCoursesSeminar ON PartPath.idnr = PassedCoursesSeminar.student;
		
	