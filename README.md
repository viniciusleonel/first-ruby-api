# Documentação do Projeto

Este projeto é uma API simples desenvolvida em Ruby sem framework, utilizando PostgreSQL como banco de dados e Docker
para containerização.

## Pré-requisitos

- Docker e Docker Compose instalados em sua máquina.
- Ruby (versão 2.7 ou superior) instalado.
- Clonar este repositório: https://github.com/viniciusleonel/first-ruby-api

## Passo a Passo para Iniciar o Container do Banco de Dados utilizando PostgreSQL

**Garanta que esteja na pasta raiz do projeto**

1. **Configurar o Docker Compose:**

   Certifique-se de que o arquivo `docker-compose.yml` está configurado corretamente. Ele deve conter as informações do
   banco de dados, como usuário, senha e nome do banco de dados.

   [Caminho para o arquivo docker-compose.yml](docker-compose.yml)


2. **Garantir que não haja conflito de dados:**

   Execute o seguinte comando abaixo para parar um container existente:

   ```bash
   docker-compose down -v
   ```

   Isso irá iniciar o container do banco de dados em segundo plano.

3. **Iniciar o Container do Banco de Dados:**

   Execute o seguinte comando para iniciar o container do PostgreSQL:

   ```bash
   docker-compose up -d
   ```
   **Pode acontecer que, ao utilizar o comando `docker-compose down -v` e em seguida `docker-compose up -d db`, o
   container seja criado mas não iniciado, então execute o comando novamente:**

   ```bash
   docker-compose up -d
   ```

   Isso irá iniciar o container do banco de dados em segundo plano e criar a database automaticamente.

## Passo a Passo para Iniciar a Aplicação

1. **Instalar Dependências:**

   Certifique-se de que as dependências do projeto estão instaladas. No diretório raiz do projeto, execute:

   ```bash
   bundle install
   ```

2. **Configurar o Banco de Dados:**

   Verifique se o arquivo de configuração do banco de dados está correto. O arquivo `database/config/database.rb` deve
   conter as credenciais corretas para conectar ao banco de dados.

   [Caminho para o arquivo database.rb](database/config/database.rb)


3. **Iniciar a Aplicação:**

   Ao iniciar a aplicação, as migrations serão feitas automaticamente.

   Para iniciar a aplicação, execute o seguinte comando:

   ```bash
   rackup
   ```

   A aplicação estará disponível em `http://localhost:9292`.

   Ou se preferir a porta 3000:

   ```bash
      rackup
   ```
   
   A aplicação estará disponível em `http://localhost:3000`.

## Testar a API

Você pode testar a API utilizando ferramentas como o Insomnia ou Postman. Por exemplo, para criar um novo usuário, envie
uma requisição POST para `http://localhost:3000/users` com os parâmetros `name` e `email` no corpo da requisição.

## Conclusão

Agora você tem uma API em Ruby sem framework, com PostgreSQL e Docker, pronta para ser utilizada e testada. Se tiver
dúvidas ou problemas, consulte a documentação ou entre em contato com o desenvolvedor responsável.
