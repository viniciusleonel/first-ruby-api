require_relative '../config/database'

class CreateOrdersTable
  def self.up
    connection = Database.connect
    connection.exec(<<-SQL)
        CREATE TABLE IF NOT EXISTS orders (
          order_id INT PRIMARY KEY,
          user_id INT NOT NULL,
          total DECIMAL NOT NULL,
          date DATE NOT NULL,
          products JSONB NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (user_id)
      );
    SQL
  end

  def self.down
    connection = Database.connect
    connection.exec("DROP TABLE IF EXISTS orders CASCADE")
  end

  def self.clean
    connection = Database.connect
    connection.exec("DELETE FROM orders CASCADE")
  end
end