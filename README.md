# Documentação do Projeto

Este projeto é uma API simples desenvolvida em Ruby sem framework, utilizando PostgreSQL como banco de dados e Docker
para containerização.

Esta API permite acessar e manipular dados de usuários, pedidos e produtos. Ela suporta operações de listagem com paginação, filtros por data, e a criação de novos registros.

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

## Funcionamento da API

Você pode testar a API utilizando ferramentas como o Insomnia ou Postman. 

### Endpoint "/upload"

- **POST**: Endpoint para envio do arquivo `.txt`
    - **Descrição**: Este endpoint permite que o cliente envie um arquivo `.txt` que será salvo no servidor.

  **Parâmetros da Requisição**:
    - O arquivo deve ser enviado como parte de um formulário `multipart/form-data` com o campo `file`.

  **Exemplo de Requisição**:

  Para fazer a requisição de envio do arquivo, você pode usar o `cURL` ou ferramentas como Postman e Insomnia.

  **Usando cURL**:
    ```bash
    curl -X POST http://localhost:3000/upload \
         -F "file=@/caminho/para/seu/arquivo.txt"
    ```

  **Usando o Postman**:
    1. Selecione o método `POST`.
    2. Insira a URL `http://localhost:3000/upload`.
    3. Vá para a aba `Body` e selecione `form-data`.
    4. Adicione um campo com as seguintes configurações:
       - **Key (name)**: `file`
       - **Type**: Marque como `File`
       - **Content-Type**: Defina como `multipart/form-data`
    5. Selecione o arquivo `.txt` desejado no seu computador.
    6. Clique em `Send`.

  **Respostas Esperadas**:
    - **201 Created**: Se o arquivo for recebido e salvo com sucesso.
      ```json
      {
        "message": "Arquivo 'nome_do_arquivo.txt' recebido, salvo em 'uploads/nome_do_arquivo.txt'"
      }
      ```
    - **400 Bad Request**: Se o arquivo não for fornecido ou se houver um erro durante o upload (por exemplo, o arquivo já existir).
      ```json
      {
        "error": "File not provided" 
      }
      ```
      ou
      ```json
      {
        "error": "O arquivo já existe na pasta de uploads"
      }
      ```

    - **404 Not Found**: Se a rota chamada não for `/upload`.
      ```json
      {
        "error": "Not Found"
      }
      ```

### Endpoint "/"

- **GET**: Endpoint para listagem de todos os dados como:
     - Aceita filtros de paginação: **/?page=1&size=5**
     ```json
     {
       "users": [
         {
           "user_id": "123",
           "name": "John Doe",
           "orders": [
             {
               "order_id": "456",
               "total": 200.50,
               "date": "2024-11-15",
               "products": [
                 {
                   "product_id": "789",
                   "value": 100.25
                 }
               ]
             }
           ]
         }
       ],
       "page": 1,
       "size": 5,
       "total_users": 100,
       "total_pages": 20
     }
     ```

- **POST**: Salva dados de um novo pedido, usuário e produto no banco de dados.

     ```json
     {
      "userId": "123",
      "userName": "John Doe",
      "orderId": "456",
      "prodId": "789",
      "value": 100.25,
      "date": "2024-11-10"
     }
     ```
     - Funcionalidade de tratamente de erros, caso seja fornecido um ID existente, os dados


## Conclusão

Agora você tem uma API em Ruby sem framework, com PostgreSQL e Docker, pronta para ser utilizada e testada. Se tiver
dúvidas ou problemas, consulte a documentação ou entre em contato com o desenvolvedor responsável.
