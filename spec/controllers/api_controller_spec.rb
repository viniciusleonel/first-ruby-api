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

  describe 'GET /' do
    it 'retorna status 200 e dados em formato JSON' do
      get '/?page=1&size=5'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      json_response = JSON.parse(last_response.body)
      expect(json_response).to have_key('data')
      expect(json_response).to have_key('page')
      expect(json_response).to have_key('size')
      expect(json_response).to have_key('total_users')
      expect(json_response).to have_key('total_pages')
    end

    it 'retorna dados vazios quando não há usuários' do
      Migrator.clean
      get '/?page=1&size=5'

      json_response = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(json_response['data']).to be_empty
      expect(json_response['total_users']).to eq(0)
      expect(json_response['total_pages']).to eq(0)
    end
  end
end 