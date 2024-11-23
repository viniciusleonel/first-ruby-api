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
  let(:uploaded_file_path) { "#{uploads_folder}/data.txt" }
  let(:valid_txt_file) { 'spec/fixtures/data.txt' }
  let(:pdf_file) { 'challenge/Desafio técnico - Vertical Logistica.pdf' }
  let(:no_format_txt) { 'spec/fixtures/invalid-data.txt' }
  let(:invalid_txt) { 'spec/fixtures/invalid-data_2.txt' }

  context 'quando um arquivo é enviado' do
    it 'retorna status 201 e processa o arquivo', :first do
      Migrator.clean
      file = Rack::Test::UploadedFile.new(valid_txt_file, 'multipart/form-data')

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

  context 'quando um arquivo de formato inválido é enviado' do
    it 'retorna status 400 com mensagem de erro' do
      file = Rack::Test::UploadedFile.new(pdf_file, 'multipart/form-data')

      post '/upload', file: file

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('Invalid file type. Only .txt files are allowed.')
    end
  end

  context 'quando um arquivo .txt é enviado mas seu formato é inválido' do
    it 'retorna status 400 com mensagem de erro' do
      file = Rack::Test::UploadedFile.new(no_format_txt, 'multipart/form-data')

      post '/upload', file: file

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('An error occurred while processing the file: Error in line 1: Line has invalid length: 63 characters')
    end
  end

  context 'quando um arquivo .txt é enviado mas falta dados' do
    it 'retorna status 400 com mensagem de erro' do
      file = Rack::Test::UploadedFile.new(invalid_txt, 'multipart/form-data')

      post '/upload', file: file

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('An error occurred while processing the file: Error in line 2: Error in line format: Invalid user name')
    end
  end

end