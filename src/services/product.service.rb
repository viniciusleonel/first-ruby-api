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

  def self.get_products_by_order_id(order_id)
    connection = Database.connect

    # Buscar produtos associados ao order_id
    products = connection.exec_params("SELECT * FROM products WHERE order_id = $1", [order_id]).map do |product|
      {
        product_id: product['product_id'],
        value: product['value']
      }
    end

    connection.close

    products
  end


end
