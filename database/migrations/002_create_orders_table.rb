require_relative '../config/database'

class CreateOrdersTable
  def self.up
    connection = Database.connect
    connection.exec(<<-SQL)
        CREATE TABLE IF NOT EXISTS orders (
          order_id INTEGER PRIMARY KEY,
          total NUMERIC(12, 2) NOT NULL,
          date DATE NOT NULL,
          user_id INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(user_id)
      );
    SQL
  end

  def self.down
    connection = Database.connect
    connection.exec("DROP TABLE IF EXISTS orders")
  end
end