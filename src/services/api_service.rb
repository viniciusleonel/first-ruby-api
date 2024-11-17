require_relative '../models/user'
require_relative '../../database/config/database'
require_relative 'user_service'
require_relative 'order.service'
require_relative 'product.service'

class ApiService
  def self.get_data(page = 1, size)
    user_data = UserService.get_users(page, size)
    result = []

    user_data[:users].each do |user|
      user_info = {
        user_id: user['user_id'],
        name: user['name'],
        orders: []
      }

      orders = OrderService.get_orders(user['user_id'])

      orders.each do |order|
        order_info = {
          order_id: order['order_id'],
          total: order['total'],
          date: Date.parse(order['date']).strftime('%Y-%m-%d'),
          products: []
        }

        products = ProductService.get_products(order['order_id'])

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
      data: result,
      page: page,
      size: size,
      total_users: user_data[:total_users],
      total_pages: user_data[:total_pages]
    }.to_json
  end

  def self.save_data(data, connection)
    user_id = data['userId']
    user_name = data['userName']
    order_id = data['orderId']
    product_id = data['prodId']
    value = data['value']
    date = data['date']

    UserService.create_user(user_id, user_name, connection)
    OrderService.create_order(order_id, user_id, value, date, connection)
    ProductService.create_product(product_id, order_id, value, connection)

  end
end

