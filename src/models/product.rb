class Product
  attr_accessor :product_id, :value

  def initialize(product_id, value)
    @product_id = product_id
    @value = value
  end

  def to_h
    {
      product_id: @product_id,
      value: @value
    }
  end
end