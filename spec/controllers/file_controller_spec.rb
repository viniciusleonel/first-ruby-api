require './app'
require 'rack/test'
require_relative '../spec_helper'
require_relative '../../src/routes/router'

RSpec.describe FileController do
  include Rack::Test::Methods

  def app
    Application.new
  end

  let(:uploads_folder) { 'uploads' }
  let(:file_path) { 'spec/fixtures/data.txt' }
  let(:uploaded_file_path) { "#{uploads_folder}/data.txt" }

  context 'quando um arquivo é enviado' do
    it 'retorna status 201 e processa o arquivo' do

      Migrator.rollback
      Migrator.migrate
      file = Rack::Test::UploadedFile.new(file_path, 'multipart/form-data')

      post '/upload', file: file

      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(File.exist?(uploaded_file_path)).to be true
    end
  end

  context 'quando nenhum arquivo é enviado' do
    it 'retorna status 400 com mensagem de erro' do
      post '/upload'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('File not provided')
    end
  end
end