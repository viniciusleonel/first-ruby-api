class Order
  attr_accessor :order_id, :total, :date, :products, :file_id

  def initialize(order_id, total, date, products = [], file_id = nil)
    @order_id = order_id
    @total = total
    @date = date
    @products = products
    @file_id = file_id
  end

  def add_product(product)
    @products.push(product)
  end
end