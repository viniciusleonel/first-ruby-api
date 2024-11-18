require_relative '../config/database'

class CreateUsersTable
  def self.up
    connection = Database.connect
    connection.exec(<<-SQL)
      CREATE TABLE IF NOT EXISTS users (
        user_id INTEGER PRIMARY KEY,
        name VARCHAR(100) NOT NULL
      );
    SQL
  end

  def self.down
    connection = Database.connect
    connection.exec("DROP TABLE IF EXISTS users CASCADE")
  end
end
