CREATE TABLE Students(
	idnr CHAR(10) NOT NULL PRIMARY KEY,
	name TEXT NOT NULL,
	login TEXT NOT NULL UNIQUE,
	program TEXT NOT NULL,
	CONSTRAINT course_and_program_unique UNIQUE (idnr, program)
	);

CREATE TABLE Courses(
	code CHAR(6) NOT NULL PRIMARY KEY,
	name TEXT NOT NULL,
	credits FLOAT NOT NULL CHECK(credits >= 0),
	department TEXT NOT NULL
	);

CREATE TABLE Classifications(
	name TEXT NOT NULL PRIMARY KEY
	);

CREATE TABLE Programs(
	name TEXT NOT NULL PRIMARY KEY
	);

CREATE TABLE Departments(
	name TEXT NOT NULL PRIMARY KEY,
	abbreviation TEXT NOT NULL UNIQUE
	);

CREATE TABLE LimitedCourses(
	code CHAR(6) NOT NULL PRIMARY KEY,
	capacity INT NOT NULL CHECK (capacity >= 0),
	FOREIGN KEY (code) REFERENCES Courses
	);

CREATE TABLE GivenBy(
	courseCode CHAR(6) NOT NULL PRIMARY KEY,
	departmentName TEXT NOT NULL,
	FOREIGN KEY (courseCode) REFERENCES Courses,
	FOREIGN KEY (departmentName) REFERENCES Departments
	);

CREATE TABLE Classified(
	course CHAR(6) NOT NULL,
	classification TEXT NOT NULL,
	PRIMARY KEY (course, classification),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (classification) REFERENCES Classifications
	);

-- Position is the absolute position (an integer)
CREATE TABLE WaitingList(
	student CHAR(10) NOT NULL,
	course CHAR(6) NOT NULL,
	position INT NOT NULL CHECK (position >= 0),
	PRIMARY KEY (student, course),
	CONSTRAINT course_and_position_unique UNIQUE (course, position),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES LimitedCourses
	);

CREATE TABLE MandatoryProgram(
	course CHAR(6) NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, program),
	FOREIGN KEY (course) REFERENCES Courses
	);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (name, program),
	FOREIGN KEY (program) REFERENCES Programs
	);
	
CREATE TABLE StudentBranches(
	student CHAR(10) NOT NULL PRIMARY KEY,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
	FOREIGN KEY (branch, program) REFERENCES Branches
	);
	
CREATE TABLE MandatoryBranch(
	course CHAR(6) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (branch, program) REFERENCES Branches
	);

CREATE TABLE RecommendedBranch(
	course CHAR(6) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (branch, program) REFERENCES Branches
	);

CREATE TABLE Taken(
	student CHAR(10) NOT NULL,
	course CHAR(6) NOT NULL,
	grade CHAR(1) NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Courses
	);

CREATE TABLE Registered(
	student CHAR(10) NOT NULL,
	course CHAR(6) NOT NULL,
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Courses
	);

CREATE TABLE Prerequisite(
	course CHAR(6) NOT NULL,
	prerequisiteCourse CHAR(6) NOT NULL,
	PRIMARY KEY (course, prerequisiteCourse),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (prerequisiteCourse) REFERENCES Courses
	);