class Department
  attr_accessor(:id,:name)

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS departments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT);"
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS departments"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_department = Department.new
    new_department.id = row[0]
    new_department.name = row[1]
    new_department
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM departments WHERE name=?"
    results = DB[:conn].execute(sql,name)
    results.map{|row| self.new_from_db(row)}.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM departments WHERE id=?"
    results = DB[:conn].execute(sql,id)
    results.map{|row| self.new_from_db(row)}.first
  end

  def insert
    sql = "INSERT INTO departments (name) VALUES (?)"
    DB[:conn].execute(sql,@name)
    id_sql = "SELECT last_insert_rowid() FROM departments"
    @id = DB[:conn].execute(id_sql).flatten[0]
  end

  def update
    sql = "UPDATE departments SET name=? WHERE id=?"
    DB[:conn].execute(sql,name,id)
  end

  def persisted?
    !!id 
  end

  def save
    persisted?? self.update : self.insert 
  end

 def courses
    Course.find_all_by_department_id(@id)
  end

  def add_course(course)
   course.department=(self)
   save
  end
	 
end
