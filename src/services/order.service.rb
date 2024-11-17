require_relative '../models/user'
require_relative '../../database/config/database'

class OrderService
  def self.get_orders(user_id)
    connection = Database.connect

    orders = connection.exec_params("SELECT * FROM orders WHERE user_id = $1", [user_id])

    connection.close

    orders
  end

    def self.create_order(order_id, user_id, value, date, connection)
      connection.exec_params("INSERT INTO orders (order_id, user_id, total, date) VALUES ($1, $2, $3, $4)", [order_id, user_id, value, date])
    end
end
