require_relative '../spec_helper'
require_relative '../../src/services/api_service'
require_relative '../../src/services/user_service'
require_relative '../../src/services/order.service'

RSpec.describe ApiService do
  describe '.get_data' do
    it 'retorna uma lista de dados' do
      # Mock do método UserService.get_users
      allow(UserService).to receive(:get_users).with(1, 5).and_return({
        users: [
          { 'user_id' => 1, 'name' => 'Test User' }
        ],
        total_users: 1,
        total_pages: 1
      })

      # Mock do método OrderService.get_orders_by_user_id
      allow(OrderService).to receive(:get_orders_by_user_id).with(1).and_return([
        {
          'order_id' => 101,
          'total' => 150.0,
          'date' => '2023-10-01',
          'products' => '[{"product_id": 201, "value": 50.0}]'
        }
      ])

      result = ApiService.get_data(1, 5)
      expected_data = {
        data: [
          {
            user_id: 1,
            name: 'Test User',
            orders: [
              {
                order_id: 101,
                total: 150.0,
                date: '2023-10-01',
                products: [
                  { product_id: 201, value: 50.0 }
                ]
              }
            ]
          }
        ],
        page: 1,
        size: 5,
        total_users: 1,
        total_pages: 1
      }.to_json

      expect(result).to eq(expected_data)
    end
  end
end
