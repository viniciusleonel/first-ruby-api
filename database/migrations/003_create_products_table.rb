require_relative '../config/database'

class CreateProductsTable

  def self.up
    connection = Database.connect
    connection.exec(<<-SQL)
    CREATE TABLE IF NOT EXISTS products (
        product_id INTEGER PRIMARY KEY,
        value NUMERIC(12, 2) NOT NULL,
        order_id INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
      );
    SQL
  end

  def self.down
    connection = Database.connect
    connection.exec("DROP TABLE IF EXISTS products")
  end
end