# Documentação do Projeto

Este projeto é uma API simples desenvolvida em Ruby sem framework, utilizando PostgreSQL como banco de dados e Docker
para containerização.

[Link deploy Azure](https://luizalabs-ruby-a7dghshjbkcahyg3.eastus-01.azurewebsites.net/users)

## Pré-requisitos

- Docker e Docker Compose instalados em sua máquina.
- Ruby (versão 3.1 ou superior) instalado.
- Clonar este repositório: https://github.com/viniciusleonel/first-ruby-api

## Configurações da API

**Esta API possui três configurações:**

### 1. Rodar a API em uma IDEA de sua escolha com um banco de dados na nuvem.
   - Requisito: **Precisa ter o Ruby instalado.**
   - Substitua o link de conexão na var de ambiente `DATABASE_LOCAL_URL` do [arquivo .env](.env)
   - Instale as dependências executando o seguinte comando no diretório raiz do projeto:
   
      ```bash
      bundle install
      ```
   - Inicie a aplicação executando o seguinte comando no diretório raiz do projeto:
     (as migrations serão feitas automaticamente)

      ```bash
      rackup
      ```


A aplicação estará disponível em `http://localhost:9292`.

### 2. Rodar toda a aplicação em um container (API + Banco de dados)
   - Requisito: **Precisa ter o Docker e Docker Compose instalados.**
   - Inserira o link de conexão na var de ambiente `DATABASE_LOCAL_URL` com o valor `postgres://postgres:123456@db:5432/luizalabs` no [arquivo .env](.env)

   - Crie a imagem da aplicação executando o seguinte comando abaixo:

      ```bash
      docker-compose -f docker-compose.local.yml build
      ```

   - Execute o seguinte comando para iniciar os containers do PostgreSQL e da aplicação:

      ```bash
      docker-compose -f docker-compose.local.yml up
      ```

   Isso irá criar primeiro um container com um banco de dados PostgreSQL (cria automaticamente a database para a aplicação).

   Em seguida irá criar o container para a aplicação, executando automaticamente as migrations, o `bundle install` e o `rackup`.

   A aplicação estará disponível em `http://localhost:9292`.

### 3. API em produção utilizando GitHub Actions, DockerHub e MicrosoftAzure
   - Esta configuração é específica para rodar a API em produção, ela utiliza as configurações do arquivo arquivo [continuous delivery](.github/workflows/continuous_delivery.yml), 
fazendo uma integração contínua e deploy automatizado utilizando **GitHub Actions**, **DockerHub** e **Microsoft Azure**.

## Testar a API

Você pode testar a API utilizando ferramentas como o Insomnia ou Postman. Por exemplo, para criar um novo usuário, envie
uma requisição POST para `http://localhost:9292/users` com os parâmetros `name` e `email` no corpo da requisição.

## Conclusão

Agora você tem uma API em Ruby sem framework, com PostgreSQL e Docker, pronta para ser utilizada e testada. Se tiver
dúvidas ou problemas, consulte a documentação ou entre em contato com o desenvolvedor responsável.
