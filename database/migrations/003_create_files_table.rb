require_relative '../config/database'

class CreateFilesTable
  def self.up
    connection = Database.connect
    connection.exec(<<-SQL)
        CREATE TABLE IF NOT EXISTS files (
          file_id SERIAL PRIMARY KEY,
          name VARCHAR(50) UNIQUE NOT NULL,
          date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    SQL
  end

  def self.down
    connection = Database.connect
    connection.exec("DROP TABLE IF EXISTS files CASCADE")
  end

  def self.clean
    connection = Database.connect
    connection.exec("DELETE FROM files CASCADE")
  end
end