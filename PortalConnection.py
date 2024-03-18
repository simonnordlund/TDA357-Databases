import psycopg2


class PortalConnection:
    def __init__(self):
            self.conn = psycopg2.connect(
                host="localhost",
                dbname="portal",
                user="postgres",
                password="postgres")
            self.conn.autocommit = True

    def getInfo(self,student):
      with self.conn.cursor() as cur:
        # Here's a start of the code for this part
        sql = """
                SELECT JSON_BUILD_OBJECT(
                    'student', b.idnr,
                    'name', b.name,
                    'login', b.login,
                    'program', b.program,
                    'branch', b.branch,
                    'finished', (
                        SELECT COALESCE(JSON_AGG(JSON_BUILD_OBJECT(
                            'course', f.courseName, 
                            'code', f.course, 
                            'credits', f.credits, 
                            'grade', f.grade)) :: JSONB, '[]')
                        FROM FinishedCourses AS f
                        WHERE student=%s),
                    'registered', (
                        SELECT COALESCE(JSON_AGG(JSON_BUILD_OBJECT(
                            'course', c.name, 
                            'code', r.course, 
                            'credits', c.credits,
                            'status', r.status,
                            'position', w.position)) :: JSONB, '[]')
                        FROM Courses AS c 
                        JOIN Registrations AS r ON r.course=c.code
                        LEFT JOIN WaitingList AS w ON c.code=w.course
                        WHERE r.student=%s),
                    'seminarCourses', p.seminarCourses,
                    'mathCredits', p.mathCredits,
                    'totalCredits', p.totalCredits,
                    'canGraduate', p.qualified) :: TEXT
                FROM BasicInformation AS b
                LEFT JOIN PathToGraduation AS p ON p.student=b.idnr
                WHERE b.idnr=%s;"""
        cur.execute(sql, (student,student,student))
        res = cur.fetchone()
        if res:
            return (str(res[0]))
        else:
            return """{"student":"Not found :("}"""

    def register(self, student, courseCode):
        try:
            with self.conn.cursor() as cur:
                cur.execute("INSERT INTO Registrations VALUES (%s, %s)", (student, courseCode))

            return """{"success":true}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

    def unregister(self, student, courseCode):
        try:
            with self.conn.cursor() as cur:
                cur.execute("DELETE FROM Registrations WHERE student='%s' AND course='%s'" % (student, courseCode))
                rowcount = cur.rowcount

            if rowcount == 0:
                return """{"success":false, "error": "the student is not registered/waiting or the course does not exist"}"""
            else:
                return """{"success":true}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

def getError(e):
    message = repr(e)
    message = message.replace("\\n"," ")
    message = message.replace("\"","\\\"")
    return message