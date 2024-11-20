# Documentação do Projeto

Este projeto é uma API simples desenvolvida em Ruby sem framework, utilizando PostgreSQL como banco de dados e Docker
para containerização.

Esta API permite acessar e manipular dados de usuários, pedidos e produtos. Ela suporta operações de listagem com paginação, filtros por data, e a criação de novos registros.

[Link deploy Azure](https://luizalabs-ruby-a7dghshjbkcahyg3.eastus-01.azurewebsites.net/)

## Pré-requisitos

- Docker e Docker Compose instalados em sua máquina.
- Ruby (versão 3.1 ou superior) instalado.
- Clonar este repositório: https://github.com/viniciusleonel/first-ruby-api

## Configurações da API

**Esta API possui quatro configurações:**

### 1. Rodar toda a aplicação em um container (API + Banco de dados)
   - Requisito: **Precisa ter o Docker e Docker Compose instalados.**
   - No seu arquivo `.env`, crie uma variável de ambiente `PROFILE` o valor `development`
   - Insira o link de conexão na variável de ambiente `DATABASE_LOCAL_URL` com o valor `postgres://postgres:123456@db:5432/luizalabs` no arquivo `.env`

   - Crie a imagem da aplicação executando o seguinte comando abaixo:

      ```bash
      docker-compose -f docker-compose.local.yml build
      ```

   - Execute o seguinte comando para iniciar os containers do PostgreSQL e da aplicação:

      ```bash
      docker-compose -f docker-compose.local.yml up -d
      ```

   Isso irá criar primeiro um container com um banco de dados PostgreSQL (cria automaticamente a database para a aplicação).

   Em seguida irá criar o container para a aplicação, executando automaticamente as migrations, o `bundle install` e o `rackup`.

   A aplicação estará disponível em `http://localhost:9292`.

### 2. API em produção utilizando GitHub Actions, DockerHub e MicrosoftAzure
   - Esta configuração é específica para rodar a API em produção, ela utiliza as configurações do arquivo arquivo [continuous delivery](.github/workflows/continuous_delivery.yml), 
fazendo uma integração contínua e deploy automatizado utilizando **GitHub Actions**, **DockerHub** e **Microsoft Azure**.

https://luizalabs-ruby-a7dghshjbkcahyg3.eastus-01.azurewebsites.net/

### 3. Rodar a API em uma IDEA de sua escolha com um banco de dados na nuvem.
- Requisito: **Precisa ter o Ruby instalado.**
- Dentro da sua plataforma de deploy, crie uma variável de ambiente `PROFILE` o valor `production`
- Substitua o link de conexão na var de ambiente `DATABASE_PROD_URL` do [arquivo .env](.env)
- Instale as dependências executando o seguinte comando no diretório raiz do projeto:

   ```bash
   bundle install
   ```
- Inicie a aplicação executando o seguinte comando no diretório raiz do projeto:
  (as migrations serão feitas automaticamente)

   ```bash
   rackup
   ```

### 4. AMBIENTE DE TESTES - Esta configuração vai ser descrita na parte de TESTES

## Fluxo da API

A API foi projetada para gerenciar dados de usuários, pedidos e produtos, possibilitando operações como listagem, criação e upload de arquivos. O fluxo detalhado da API é descrito abaixo:

1. **Envio e Validação de Arquivos**:
  - Quando um arquivo `.txt` é enviado para o endpoint `/upload` através de uma requisição POST, a API, por meio do `FileController`, realiza a verificação dos parâmetros, garantindo que a chave e o nome do arquivo estejam corretos e que o arquivo tenha sido enviado corretamente.
  - Após a validação, o `FileService` lê o conteúdo do arquivo e o salva temporariamente em um local seguro, retornando os dados do arquivo na resposta.

2. **Processamento Assíncrono do Arquivo**:
  - Uma vez armazenado, a API inicia um processo de processamento assíncrono em segundo plano, utilizando threads e a `gem` `Async`. O método `FileService.save_data_to_db(file_path, filename)` é executado para ler o conteúdo do arquivo e persistir os dados no banco de dados.
  - Este processo assíncrono permite que a API continue respondendo a novas requisições sem bloqueios, garantindo que operações intensivas, como a gravação em banco de dados, não afetem a performance da aplicação.
  - Após o término do processamento e da gravação dos dados, o arquivo é excluído do armazenamento temporário para liberar espaço e manter a segurança dos dados.
  - Pode-se obter informações sobre o processamento do arquivo no terminal, confirmando que foi armazenado e deletado com sucesso.

3. **Consulta de Dados Salvos**:
  - O endpoint `/` é responsável por retornar os dados que foram salvos no banco de dados. Ele suporta paginação por meio dos parâmetros `page` e `size`  retornando informações como a página atual, o tamanho da página, o total de páginas e o total de dados armazenados.
  - O endpoint `/orders` permite a listagem de pedidos com suporte a paginação e filtros por data, utilizando os parâmetros `start_date` e `end_date` no formato `YYYY-MM-DD`. A ordenação padrão para este endpoint é por data, facilitando a busca de pedidos em um intervalo específico.
  - O endpoint `/order/:id` permite a consulta de um pedido específico pelo seu identificador único (`id`), retornando detalhes completos sobre o pedido, incluindo informações associadas.

Você pode testar a API utilizando ferramentas como o Insomnia ou Postman. 


## Endpoints
### Endpoint "/upload"

- **POST**: Endpoint para envio do arquivo `.txt`
    - **Descrição**: Este endpoint permite que o cliente envie um arquivo `.txt` que será salvo temporariamente no servidor.

  **Parâmetros da Requisição**:
    - O arquivo deve ser enviado no `body` como parte de um formulário `multipart/form-data` com o campo `file`.

  **Exemplo de Requisição**:

  Para fazer a requisição de envio do arquivo, você pode usar o `cURL` ou ferramentas como Postman e Insomnia.

  **Usando cURL**:
    ```bash
    curl -X POST http://localhost:3000/upload \
         -F "file=@/caminho/para/seu/arquivo.txt"
    ```

  **Usando o Postman**:
    1. Selecione o método `POST`.
    2. Insira a URL `http://localhost:9292/upload`.
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
      [
        {
          "user_id":1,
          "name":"Zarelli",
          "orders":[
            {
              "order_id":123,
              "total":"1024.48",
              "date":"2021-12-01",
              "products":[
                {
                  "product_id":111,
                  "value":"512.24"
                },
                {
                  "product_id":122,
                  "value":"512.24"
                }
              ]
            }
          ]
        },
        {
          "user_id":2,
          "name":"Medeiros",
          "orders":[
            {
              "order_id":12345,
              "total":"512.48",
              "date":"2020-12-01",
              "products":[
                {
                  "product_id":111,
                  "value":"256.24"
                },
                {
                  "product_id":122,
                  "value":"256.24"
                }
              ]
            }
          ]
        }
      ]
    ```
    **Tratamento de Erros**:
    - **400 Bad Request**: Se o arquivo não for fornecido ou se houver um erro durante o upload (por exemplo, key ou name inválidos).
      ```json
      {
        "error": "File not provided" 
      }
      ```
    - **404 Not Found**: Se a rota chamada não for `/upload`.
      ```json
      {
        "error": "Endpoint not Found"
      }
      ```

### Endpoint "/"

- **GET**: Endpoint para listagem de todos os dados como:
     - Aceita filtros de paginação: `/?page=1&size=5`
     - Paginação padrão por nome
     ```json
     {
       "data": [
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
    - Caso não tenha dados no bando de dados:
    ```json
    {
      "data": [],
      "page": 1,
      "size": 5,
      "total_users": 0,
      "total_pages": 0
    }
    ```

### Endpoint "/orders"

- **GET**: Endpoint para listagem de todos os pedidos:
  - Aceita filtros de paginação: `?page=1&size=1`
  - Aceita paginação com intervalo de data de compra (data início e data fim) `?start_date=YYYY-mm-dd&end_date=YYYY-mm-dd`
  - Paginação padrão por data
  ```json
    {
      "orders": [
        {
          "order_id": "1072",
          "user_id": "100",
          "total": "650.12",
          "date": "2021-03-04",
          "products": [
            {
              "value": 650.12,
              "product_id": 1
            }
          ]
        }
      ],
      "page": 1,
      "size": 1,
      "total_orders": 1084,
      "total_pages": 1084
    }
  ```
  - Caso não tenha dados no bando de dados:
  ```json
  {
    "orders": [],
    "page": 1,
    "size": 1,
    "total_orders": 0,
    "total_pages": 0
  }
  ```

### Endpoint "/orders/:id"

- **GET**: Endpoint para buscar pedido por id:

  ```json
  {
    "order_id": "753",
    "user_id": "70",
    "total": "787.46",
    "date": "2021-03-08",
    "products": [
      {
        "value": 1836.74,
        "product_id": 3
      },
      {
        "value": 1009.54,
        "product_id": 3
      },
      {
        "value": 618.79,
        "product_id": 4
      },
      {
        "value": 787.46,
        "product_id": 3
      }
    ]
  }
  ```

  **Tratamento de Erros**:
  - **400 Bad Request**: Caso `id` fornecido não seja encontrado
  ```json
  {
    "error": "Order Not Found"
  }
  ```
  
**Todos Endpoints possuem tratamento de erro para a rota**
- **400 Bad Request**:
    ```json
    {
      "error": "Endpoint not Found"
    }
    ```

## Testes (Necessário a configuração de AMBIENTE DE TESTES descrita no início deste arquivo!)

A qualidade do código é garantida por meio de testes automatizados com RSpec, localizados no diretório `spec`, que cobrem as funcionalidades essenciais da API.

### Executando os Testes

###  AMBIENTE DE TESTES - Rodar toda a aplicação em um container (API + Banco de dados)
- Requisito: **Precisa ter o Docker e Docker Compose instalados.**
- No seu arquivo `.env`, crie uma variável de ambiente `PROFILE` o valor `test`
- Insira o link de conexão na variável de ambiente `DATABASE_TEST_URL` com o valor `postgres://postgres:123456@localhost/luizalabs_test` no arquivo `.env`

- Execute o seguinte comando para iniciar o container do banco de dados de testes PostgreSQL:

   ```bash
   docker-compose -f docker-compose.test.yml up -d
   ```

- Instale as dependências executando o seguinte comando no diretório raiz do projeto:

   ```bash
   bundle install
   ```
- Inicie a aplicação executando o seguinte comando no diretório raiz do projeto:
  (as migrations serão feitas automaticamente)

   ```bash
   rackup
   ```

- Execute os testes com o seguinte comando:
   ```bash
  bundle exec rspec
   ```



## Estrutura do Teste

- **Gems e Configurações**
  - `Rack::Test`: Usado para simular requisições HTTP.
  - `Application`: Classe principal da aplicação que gerencia as rotas.

[//]: # (Os testes estão organizados da seguinte forma:)

[//]: # (- **spec/services**: Contém testes para os serviços da aplicação, como `ApiService`, `UserService`, e `OrderService`.)
- **spec/controllers**: Contém testes para os controladores, garantindo que as requisições HTTP sejam tratadas corretamente.

## Descrição do Teste: `FileController`

Este teste utiliza **RSpec** para verificar o comportamento do `FileController` em uma aplicação Ruby ao lidar com o envio de arquivos via upload. Ele utiliza o módulo `Rack::Test` para simular requisições HTTP, e os testes estão organizados em dois cenários principais.

## Cenários de Teste

### 1. **Envio de Arquivo com Sucesso**
- **Cenário**: Um arquivo válido é enviado.
- **Requisição**: `POST /upload` com um arquivo anexado.
- **Expectativas**:
  - Status HTTP: **201 Created**.
  - `Content-Type`: **application/json**.
  - O arquivo é salvo no diretório configurado.

### 2. **Envio Sem Arquivo**
- **Cenário**:  Nenhum arquivo é enviado na requisição.
- **Requisição**: `POST /upload` sem parâmetros.
- **Expectativas**:
  - Status HTTP: **400 Bad Request**.
  - Corpo da resposta inclui a mensagem: "File not provided".


## Descrição do Teste: `ApiController`
Este teste verifica o comportamento do `ApiController`, que é responsável por gerenciar as requisições para o endpoint principal da API. O teste utiliza a biblioteca RSpec e o módulo Rack::Test para simular requisições HTTP e validar as respostas.

## Cenários de Teste

### 1. Retorno de Dados Válidos
- **Descrição**: Este teste verifica se a requisição GET para o endpoint `/` retorna um status 200 e dados em formato JSON.
- **Requisição**: `GET /?page=1&size=5`
- **Expectativas**:
  - O status da resposta deve ser 200.
  - O tipo de conteúdo da resposta deve ser `application/json`.
  - A resposta JSON deve conter as chaves:
    - `data`
    - `page`
    - `size`
    - `total_users`
    - `total_pages`

### 2. Retorno de Dados Vazios
- **Descrição**: Este teste verifica se a requisição GET para o endpoint `/` retorna dados vazios quando não há usuários no banco de dados.
- **Preparação**: O banco de dados é limpo utilizando `Migrator.clean` antes da requisição.
- **Requisição**: `GET /?page=1&size=5`
- **Expectativas**:
  - O campo `data` na resposta JSON deve estar vazio.
  - O campo `total_users` deve ser igual a 0.
  - O campo `total_pages` deve ser igual a 0.

## Conclusão
Os testes garantem que o `ApiController` está respondendo corretamente às requisições, tanto quando há dados disponíveis quanto quando não há. Isso é fundamental para assegurar que a API funcione conforme o esperado e forneça informações precisas aos usuários.

## Conclusão

Agora você tem uma API em Ruby sem framework, com PostgreSQL e Docker, pronta para ser utilizada e testada. Se tiver
dúvidas ou problemas, consulte a documentação ou entre em contato com o desenvolvedor responsável.
