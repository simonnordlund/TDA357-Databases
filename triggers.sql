------------------

-- Add students --

------------------

CREATE FUNCTION register_students() RETURNS TRIGGER AS $$
	DECLARE 
		amountWaiting integer := (SELECT COUNT(student) FROM WaitingList
			WHERE course = NEW.course);
		registered_students integer := (SELECT COUNT(student) FROM Registered, LimitedCourses
			WHERE code = NEW.course AND code = course);
		capacity integer := (SELECT capacity FROM LimitedCourses
			WHERE code = NEW.course);
		taken_prerequisites integer := (SELECT COUNT(*) FROM Prerequisite, Taken
			WHERE Prerequisite.course = NEW.course AND prerequisiteCourse = Taken.course AND student = NEW.student AND grade != 'U');
		amount_prerequisites integer := (SELECT COUNT(*) FROM Prerequisite
			WHERE Prerequisite.course = NEW.course);
	BEGIN
		--RAISE EXCEPTION '% %', taken_prerequisites, amount_prerequisites;
		
		IF EXISTS ( -- if students is already registered or on the waiting list
			SELECT student, course FROM Registrations 
			WHERE NEW.Student = student AND NEW.Course = course
		) THEN
				RAISE EXCEPTION 'Student % is already registered or on the waiting list for the course %', NEW.student, NEW.course;
		END IF;
		
		IF taken_prerequisites != amount_prerequisites THEN
				RAISE EXCEPTION 'Student % does not meet the prerequisites for the course %', NEW.student, NEW.course;
		END IF;
		
		IF EXISTS ( -- student has already passed course
			SELECT * FROM Taken
			WHERE student = NEW.student AND course = NEW.course AND grade != 'U'
		) THEN 
			RAISE EXCEPTION 'Student % has already passed the course %', NEW.student, NEW.course;
		END IF;
		
		-- If the student is elligible
		IF NOT EXISTS( -- no capacity limitation
			SELECT code FROM LimitedCourses
			WHERE code = NEW.Course
			) THEN INSERT INTO Registered VALUES (NEW.student, NEW.course);
		ELSIF registered_students >= capacity
			THEN INSERT INTO WaitingList VALUES (NEW.student, NEW.course, amountWaiting+1);
		ELSE
			INSERT INTO Registered VALUES (NEW.student, NEW.course);
		END IF;
		
		RETURN NEW;
	END
$$ LANGUAGE plpgsql;

CREATE TRIGGER RegisterStudent
	INSTEAD OF INSERT ON Registrations
	FOR EACH ROW
	EXECUTE FUNCTION register_students();
	

---------------------

-- Remove students --

---------------------

CREATE FUNCTION unregister_students() RETURNS TRIGGER AS $$
	DECLARE 
		registered_students integer := (SELECT COUNT(*) FROM Registered, LimitedCourses
			WHERE code = OLD.course AND course = code);
		capacity integer := (SELECT capacity FROM LimitedCourses
			WHERE code = OLD.course);
		waitingPosition integer := COALESCE((SELECT position FROM WaitingList -- the selection either returns 0 (student already registered), or its actual position
			WHERE course = OLD.course AND student = OLD.student), 0);
	BEGIN
		
		-- Delete the value
		DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
		DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
		
		-- Check with WaitingList
		IF waitingPosition = 0 THEN -- remove from registered
			IF registered_students-1 < capacity THEN -- minus one since we just removed a student
				INSERT INTO Registered
					SELECT student, course FROM WaitingList
					WHERE course = OLD.course AND position = 1;
				DELETE FROM WaitingList WHERE course = OLD.course AND position = 1;
				UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;
			END IF;
		ELSE
			UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course AND position > waitingPosition;
		END IF;
		
		RETURN OLD;
	END
$$ LANGUAGE plpgsql;

CREATE TRIGGER UnregisterStudent
	INSTEAD OF DELETE ON Registrations
	FOR EACH ROW
	EXECUTE FUNCTION unregister_students();