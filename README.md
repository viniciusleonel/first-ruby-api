# Documentação do Projeto

Este projeto é uma API simples desenvolvida em Ruby sem framework, utilizando PostgreSQL como banco de dados e Docker
para containerização.

## Pré-requisitos

- Docker e Docker Compose instalados em sua máquina.
- Ruby (versão 2.7 ou superior) instalado.
- Clonar este repositório: https://github.com/viniciusleonel/first-ruby-api

## Passo a Passo para Iniciar a aplicação utilizando um container Docker

1. **Configurar o Docker Compose:**

   Certifique-se de que o arquivo `docker-compose.yml` e o arquivo `database.rb` estejam configurados corretamente. Ele deve conter as informações do
   banco de dados, como usuário, senha e nome do banco de dados.

   [Caminho para o arquivo docker-compose.yml](docker-compose.yml)

   [Caminho para o arquivo database.rb](database/config/database.rb)

**Garanta que esteja na pasta raiz do projeto**

2. **Crie a imagem da aplicação:**

   Execute o seguinte comando abaixo para criar a imagem:

   ```bash
   docker-compose build
   ```

3. **Inicie os containers:**

   Execute o seguinte comando para iniciar o container do PostgreSQL e da aplicação:

   ```bash
   docker-compose up -d
   ```

   Isso irá criar primeiro um container com um banco de dados PostgreSQL (cria automaticamente a database para a aplicação).

   Em seguida irá criar o container para a aplicação, executando automaticamente as migrations, o `bundle install` e o `rackup`.


[//]: # ()
[//]: # (## Passo a Passo para Iniciar a Aplicação)

[//]: # ()
[//]: # (1. **Instalar Dependências:**)

[//]: # ()
[//]: # (   Certifique-se de que as dependências do projeto estão instaladas. No diretório raiz do projeto, execute:)

[//]: # ()
[//]: # (   ```bash)

[//]: # (   bundle install)

[//]: # (   ```)

[//]: # ()
[//]: # (2. **Configurar o Banco de Dados:**)

[//]: # ()
[//]: # (   Verifique se o arquivo de configuração do banco de dados está correto. O arquivo `database/config/database.rb` deve)

[//]: # (   conter as credenciais corretas para conectar ao banco de dados.)

[//]: # ()
[//]: # (   [Caminho para o arquivo database.rb]&#40;database/config/database.rb&#41;)

[//]: # ()
[//]: # ()
[//]: # (3. **Iniciar a Aplicação:**)

[//]: # ()
[//]: # (   Ao iniciar a aplicação, as migrations serão feitas automaticamente.)

[//]: # ()
[//]: # (   Para iniciar a aplicação, execute o seguinte comando:)

[//]: # ()
[//]: # (   ```bash)

[//]: # (   rackup)

[//]: # (   ```)

[//]: # ()
[//]: # (   A aplicação estará disponível em `http://localhost:9292`.)

[//]: # ()
[//]: # (   Ou se preferir a porta 3000:)

[//]: # ()
[//]: # (   ```bash)

[//]: # (      rackup)

[//]: # (   ```)
   
   A aplicação estará disponível em `http://localhost:9292`.

## Testar a API

Você pode testar a API utilizando ferramentas como o Insomnia ou Postman. Por exemplo, para criar um novo usuário, envie
uma requisição POST para `http://localhost:9292/users` com os parâmetros `name` e `email` no corpo da requisição.

## Conclusão

Agora você tem uma API em Ruby sem framework, com PostgreSQL e Docker, pronta para ser utilizada e testada. Se tiver
dúvidas ou problemas, consulte a documentação ou entre em contato com o desenvolvedor responsável.
