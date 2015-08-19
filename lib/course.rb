require 'pry'

class Course
  attr_accessor(:id,:name,:department_id)

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS courses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      department_id INTEGER);"
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_course = Course.new
    new_course.id = row[0]
    new_course.name = row[1]
    new_course.department_id = row[2]
    new_course
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM courses WHERE name=?"
    results = DB[:conn].execute(sql,name)
    results.map{|row| self.new_from_db(row)}.first
  end

  def self.find_all_by_department_id(id)
    sql = "SELECT * FROM courses WHERE department_id=?"
    results = DB[:conn].execute(sql,id)
    final_results = results.map{|row| self.new_from_db(row)}
    final_results
  end

  def insert
    sql = "INSERT INTO courses (name,department_id) VALUES (?,?)"
    DB[:conn].execute(sql,@name,@department_id)
    id_sql = "SELECT last_insert_rowid() FROM courses"
    @id = DB[:conn].execute(id_sql).flatten[0]
  end

  def update
    sql = "UPDATE courses SET name=?,department_id=? WHERE id=?"
    DB[:conn].execute(sql,name,department_id,id)
  end

  def persisted?
    !!id
  end

  def save
    persisted?? self.update : self.insert
  end

  def department=(department)
    @department = department
    @department_id = department.id
    save
  end

  def department
    @department = Department.find_by_id(@department_id)
  end

 def students
    sql = "SELECT *
      FROM students
      JOIN registrations
        ON students.id = registrations.student_id
      WHERE registrations.course_id = ?"
    result = DB[:conn].execute(sql, self.id)
    result.map do |row|
      Student.new_from_db(row)
    end
 end
 
 def add_student(student)
    sql = "INSERT INTO registrations
        (course_id, student_id)
      VALUES (?,?);"
    DB[:conn].execute(sql, self.id, student.id)
 end

end
