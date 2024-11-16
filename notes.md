Aqui está um passo a passo para criar uma API utilizando Ruby sem framework, com PostgreSQL e Docker:

Passo 1: Instalar Dependências

- Instale Ruby (versão 2.7 ou superior)
- Instale PostgreSQL (versão 12 ou superior)
- Instale Docker

Passo 2: Criar Projeto

- Crie um novo diretório para o projeto: mkdir minha_api
- Acesse o diretório: cd minha_api
- Crie um arquivo Gemfile com as seguintes linhas:

source '(link unavailable)'

gem 'pg'
gem 'rack'

- Execute bundle install para instalar as dependências

Passo 3: Configurar Banco de Dados

- Crie um arquivo database.yml com as seguintes linhas:

adapter: postgresql
encoding: unicode
database: minha_api
username: seu_usuario
password: sua_senha
host: localhost
port: 5432

- Substitua seu_usuario e sua_senha pelas suas credenciais de banco de dados

Passo 4: Criar Modelo de Dados

- Crie um arquivo models/usuario.rb com as seguintes linhas:

require 'pg'

class Usuario
  def initialize(nome, email)
    @nome = nome
    @email = email
  end

  def salvar
    conn = PG.connect(database: 'minha_api', user: 'seu_usuario', password: 'sua_senha')
    conn.exec_params("INSERT INTO usuarios (nome, email) VALUES ($1, $2)", [@nome, @email])
    conn.close
  end
end

Passo 5: Criar API

- Crie um arquivo api.rb com as seguintes linhas:

require 'rack'
require_relative 'models/usuario'

class MinhaApi < Rack::Application
  def call(env)
    request = Rack::Request.new(env)

    case request.path_info
    when '/usuarios'
      case request.request_method
      when 'GET'
        usuarios = Usuario.all
        [200, {'Content-Type' => 'application/json'}, [usuarios.to_json]]
      when 'POST'
        usuario = Usuario.new(request.params['nome'], request.params['email'])
        usuario.salvar
        [201, {'Content-Type' => 'application/json'}, [{message: 'Usuário criado com sucesso'}.to_json]]
      end
    else
      [404, {'Content-Type' => 'text/plain'}, ['Não encontrado']]
    end
  end
end

Passo 6: Criar Dockerfile

- Crie um arquivo Dockerfile com as seguintes linhas:

FROM ruby:2.7

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

RUN mkdir /app/db

ENV DATABASE_URL=postgres://seu_usuario:sua_senha@localhost:5432/minha_api

CMD ["rackup", "-p", "3000"]

Passo 7: Criar Container Docker

- Execute docker build -t minha_api . para criar o container
- Execute docker run -p 3000:3000 minha_api para iniciar o container

Passo 8: Testar API com Insomnia

- Abra o Insomnia e crie uma nova requisição
- Selecione o método POST e insira a URL http://localhost:3000/usuarios
- Adicione os parâmetros nome e email no corpo da requisição
- Envie a requisição e verifique a resposta

Agora você tem uma API em Ruby sem framework, com PostgreSQL e Docker!