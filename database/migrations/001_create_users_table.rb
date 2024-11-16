class CreateUsersTable
  def self.up
    connection = Database.connect
    connection.exec(<<-SQL)
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100)
      );
    SQL
  end

  def self.down
    connection = Database.connect
    connection.exec("DROP TABLE IF EXISTS users")
  end
end
