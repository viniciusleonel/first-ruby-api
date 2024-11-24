class User
  attr_accessor :user_id, :name, :orders

  def initialize(user_id = nil, name = nil, orders = [])
    @user_id = user_id
    @name = name
    @orders = orders
  end

  def add_order(order)
    @orders.push(order)
  end

  def to_h
    {
      user_id: @user_id,
      name: @name,
      orders: @orders
    }
  end

end