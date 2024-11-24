require 'date'
require 'json'
require_relative '../models/user'
require_relative '../../database/config/database'
require_relative 'user_service'
require_relative 'order.service'

class ApiService
  def self.get_data(page, size)
    connection = Database.connect
    begin
      user_data = UserService.get_users(page, size, connection)
      result = []

      user_data[:users].each do |user|
        user_info = {
          user_id: user['user_id'],
          name: user['name'],
          orders: []
        }

        orders = OrderService.get_orders_by_user_id(user['user_id'], connection)

        orders.each do |order|
          order_info = {
            order_id: order['order_id'],
            file_id: order['file_id'],
            total: order['total'],
            date: Date.parse(order['date']).strftime('%Y-%m-%d'),
            products: []
          }

          products = order['products'] ? JSON.parse(order['products']) : []

          products.each do |product|
            product_info = {
              product_id: product['product_id'],
              value: product['value']
            }
            order_info[:products] << product_info
          end

          user_info[:orders] << order_info
        end

        result << user_info
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

