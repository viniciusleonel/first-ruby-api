class Order
  attr_accessor :order_id, :total, :date, :products

  def initialize(order_id, total, date, products = [])
    @order_id = order_id
    @total = total
    @date = date
    @products = products
  end

  def add_product(product)
    @products.push(product)
  end
end