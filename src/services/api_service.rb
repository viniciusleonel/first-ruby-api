require 'date'
require 'json'
require_relative 'user_service'
require_relative 'order.service'
require_relative '../models/user'
require_relative '../models/order'
require_relative '../models/product'
require_relative '../../database/config/database'

class ApiService
  def self.get_data(page, size)
    connection = Database.connect
    begin
      user_data = UserService.get_users(page, size, connection)
      result = []

      user_data[:users].each do |user|
        user_info =
          User.new(
            user['user_id'],
            user['name'],
            orders = []
          )

        orders = OrderService.get_orders_by_user_id(user_info.user_id, connection)
        orders.each do |order|
          order_info =
            Order.new(
              order['order_id'], order['total'],
              Date.parse(order['date']).strftime('%Y-%m-%d'),
              products = [],
              order['file_id']
            )

          products = JSON.parse(order['products'] || '[]')

          products.each do |product|
            product_info =
              Product.new(
                product['product_id'],
                product['value']
              )
            order_info.products << product_info
          end

          user_info.orders << order_info.to_h
        end

        result << user_info.to_h
      end

      {
        users: result,
        page: page,
        size: size,
        total_users: user_data[:total_users],
        total_pages: user_data[:total_pages]
      }.to_json
    ensure
      connection.close if connection
    end
  end
end

