require './app'
require 'rack/test'
require_relative '../spec_helper'
require_relative '../../src/controllers/api_controller'
require_relative '../../database/migrations/migrate'
require_relative '../../src/services/file_service'

RSpec.describe ApiController do
  include Rack::Test::Methods
  def app
    Application.new
  end

  context 'quando um endpoint inválido é chamado' do
    it 'retorna status 404 com a mensagem de erro' do

      get '/invalido'

      expect(last_response.status).to eq(404)
      expect(last_response.body).to include('Endpoint Not Found')

    end
  end

  describe 'GET /' do
    it 'retorna status 200 e dados em formato JSON' do
      get '/?page=1&size=5'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      json_response = JSON.parse(last_response.body)
      expect(json_response).to have_key('users')
      expect(json_response).to have_key('page')
      expect(json_response).to have_key('size')
      expect(json_response).to have_key('total_users')
      expect(json_response).to have_key('total_pages')
    end
  end
end 