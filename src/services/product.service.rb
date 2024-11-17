require_relative '../models/user'
require_relative '../../database/config/database'

class ProductService
  def self.get_products(order_id)
    connection = Database.connect

    products = connection.exec_params("SELECT * FROM products WHERE order_id = $1", [order_id])

    connection.close

    products
  end

    def self.create_product(product_id, order_id, value, connection)
      connection.exec_params("INSERT INTO products (product_id, order_id, value) VALUES ($1, $2, $3)", [product_id, order_id, value])
    end

end
