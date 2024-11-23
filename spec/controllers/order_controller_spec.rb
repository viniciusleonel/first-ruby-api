require './app'
require 'rack/test'
require_relative '../spec_helper'
require_relative '../../src/controllers/order_controller'
require_relative '../../database/migrations/migrate'
require_relative '../../src/services/file_service'

RSpec.describe OrderController do
  include Rack::Test::Methods
  def app
    Application.new
  end

  let(:valid_id) { 753 }
  let(:invalid_id) { 75333 }

  before do
    file = Rack::Test::UploadedFile.new('spec/fixtures/data.txt', 'multipart/form-data')
    post '/upload', file: file
  end

  context "quando o endpoint '/orders' é chamado" do
    it 'retorna status 200 e dados em formato JSON' do
      get '/orders'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      json_response = JSON.parse(last_response.body)
      expect(json_response).to have_key('orders')
      expect(json_response).to have_key('page')
      expect(json_response).to have_key('size')
      expect(json_response).to have_key('total_orders')
      expect(json_response).to have_key('total_pages')
    end
    end

  context "quando o endpoint '/orders/:id' é chamado passando ID como parâmetro" do
    it 'retorna status 200 e o pedido cujo ID foi chamado com formato JSON' do
      get "/orders/753"

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      json_response = JSON.parse(last_response.body)
      expect(json_response).to have_key('order_id')
      expect(json_response).to have_key('file_id')
      expect(json_response).to have_key('user_id')
      expect(json_response).to have_key('total')
      expect(json_response).to have_key('date')
      expect(json_response).to have_key('products')
    end
    end

  context "quando o endpoint '/orders/#id' é chamado passando ID que não existe como parâmetro" do
    it 'retorna status 404 com mensagem de erro' do
      get "/orders/#{invalid_id}"

      expect(last_response.status).to eq(404)
      expect(last_response.body).to include('Order Not Found')
    end
  end
end