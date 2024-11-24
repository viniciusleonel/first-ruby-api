# Documentação do Projeto

Este projeto é uma API simples desenvolvida em Ruby, utilizando PostgreSQL como banco de dados e Docker para containerização, com um pipeline de CI/CD utilizando GitHub Actions que automatiza a validação de código, testes, criação de imagens Docker e implantação contínua no Azure, garantindo entregas rápidas, confiáveis e seguras.

Esta API foi desenvolvida para integrar dois sistemas, permitindo a transformação de um arquivo de pedidos desnormalizado proveniente de um sistema legado em um arquivo JSON normalizado. A API oferece funcionalidades para acessar e gerenciar dados de pedidos, incluindo a capacidade de realizar consultas gerais e aplicar filtros específicos, como:

- **ID do pedido**: possibilitando a busca de um pedido específico.
- **Intervalo de data de compra**: permitindo filtrar pedidos com base em um intervalo de datas definido (data de início e data de fim).
- **Paginação**: possibilitando a listagem de pedidos em páginas, facilitando a navegação por grandes volumes de dados.
- **Verificação do documento enviado**: garantindo que o arquivo de pedidos enviado atenda ao formato esperado e contenha os dados necessários para processamento. A validação inclui:
  - **Comprimento da linha**: cada linha do arquivo deve ter exatamente 95 caracteres.
  - **Formato dos campos**: os campos devem seguir as seguintes regras:
    - **ID do usuário**: deve ser um número de 10 dígitos.
    - **Nome do usuário**: deve ter no máximo 45 caracteres e conter apenas letras e espaços.
    - **ID do pedido**: deve ser um número de 10 dígitos.
    - **ID do produto**: deve ser um número de 10 dígitos.
    - **Valor**: deve ser um número decimal com até duas casas decimais.
    - **Data**: deve estar no formato `YYYYMMDD`.
  - **Tratamento de erros**: se o arquivo não atender a qualquer uma dessas condições, a API retornará um erro informando a linha e o problema específico encontrado.


Essas funcionalidades garantem uma manipulação eficiente dos dados de pedidos, facilitando a integração e a análise das informações.

[Link deploy Azure](https://luizalabs-ruby-a7dghshjbkcahyg3.eastus-01.azurewebsites.net/)

---

## Tecnologias Utilizadas

Este projeto utiliza as seguintes tecnologias e ferramentas:

- **Ruby**: A linguagem de programação utilizada para desenvolver a API.
- **Rack**: Gem que fornece uma interface modular para servidores web e aplicações Ruby, facilitando a construção de aplicações web.
- **PostgreSQL**: O sistema de gerenciamento de banco de dados relacional utilizado para armazenar os dados.
- **Docker**: Ferramenta de containerização que permite empacotar a aplicação e suas dependências em um ambiente isolado.
- **Docker Compose**: Utilizado para definir e executar aplicações Docker multi-container.
- **RSpec**: Framework de testes para Ruby, utilizado para garantir a qualidade e a confiabilidade do código.
- **Async**: Gem utilizada para processamento assíncrono, permitindo que a API continue respondendo a novas requisições enquanto processa dados em segundo plano.
- **GitHub Actions**: Ferramenta de integração contínua e entrega contínua (CI/CD) que automatiza o processo de deploy da aplicação.
- **Microsoft Azure**: Plataforma de nuvem utilizada para hospedar a aplicação em produção.

Essas tecnologias foram escolhidas para garantir a escalabilidade, a eficiência e a facilidade de manutenção da API.

---

## Pré-requisitos

- Docker e Docker Compose instalados em sua máquina.
- Ruby (versão 3.1 ou superior) instalado.
- Clonar este repositório: https://github.com/viniciusleonel/first-ruby-api

---

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

[//]: # (- Em um único comando `powershel`:)

[//]: # (   ```bash)

[//]: # (   docker-compose -f docker-compose.local.yml build; docker-compose -f docker-compose.local.yml up -d)

[//]: # (   ```)

[//]: # (- Em um único comando`bash`)

[//]: # (  ```bash)

[//]: # (   docker-compose -f docker-compose.local.yml build && docker-compose -f docker-compose.local.yml up -d)

[//]: # (   ```)

Isso irá criar primeiro um container com um banco de dados PostgreSQL (cria automaticamente a database para a aplicação).

Em seguida irá criar o container para a aplicação, executando automaticamente as migrations, o `bundle install` e o `rackup`.

A aplicação estará disponível em `http://localhost:9292`.

### 2. API em produção utilizando GitHub Actions, DockerHub e MicrosoftAzure
- Esta configuração é específica para rodar a API em produção, ela utiliza as configurações do arquivo arquivo [continuous delivery](.github/workflows/continuous_delivery.yml),
  fazendo uma integração contínua e deploy automatizado utilizando **GitHub Actions**, **DockerHub** e **Microsoft Azure**.

https://luizalabs-ruby-a7dghshjbkcahyg3.eastus-01.azurewebsites.net/

### 3. Rodar a API em uma IDEA de sua escolha com um banco de dados PostgreSQL(Container ou nuvem).
- Requisito: **Precisa ter o Ruby instalado.**
- Dentro da sua plataforma de deploy, crie uma variável de ambiente `PROFILE` o valor `development`
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

---

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
- O endpoint `/files` é responsável por retornar os nomes dos arquivos que já foram enviados na API. Ele suporta paginação por meio dos parâmetros `page` e `size`  retornando informações como a página atual, o tamanho da página, o total de páginas e o total de dados armazenados.
- O endpoint `/orders` permite a listagem de pedidos com suporte a paginação e filtros por data, utilizando os parâmetros `start_date` e `end_date` no formato `YYYY-MM-DD`. A ordenação padrão para este endpoint é por data, facilitando a busca de pedidos em um intervalo específico.
- O endpoint `/order/:id` permite a consulta de um pedido específico pelo seu identificador único (`id`), retornando detalhes completos sobre o pedido, incluindo informações associadas.

Você pode testar a API utilizando ferramentas como o Insomnia ou Postman.

---

## Endpoints
### Endpoint "/upload"

- **POST**: Endpoint para envio do arquivo `.txt`
  - **Descrição**: Este endpoint permite que o cliente envie um arquivo `.txt` que será salvo temporariamente no servidor.

  **Parâmetros da Requisição**:
  - O arquivo deve ser enviado no `body` como parte de um formulário `multipart/form-data` com o campo `file`.

  **Exemplo de Requisição**:

  Para fazer a requisição de envio do arquivo, você pode usar o `cURL` ou ferramentas como Postman e Insomnia.


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

---

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
      - **400 Bad Request**: Se o arquivo já estiver sido salvo no banco de dados. (Salva somente o nome na tabela `files`)
      ```json
      {
      "error": "An error occurred while processing the file: File 'data_1' already exists in database!"
      }
      ```
    - **400 Bad Request**: Se o arquivo não for do formato `.txt`.
      ```json
      {
          "error": "Invalid file type. Only .txt files are allowed."
      }
      ```
    - **400 Bad Request**: Se o arquivo for do formato `.txt` mas não for do padrão esperado pela API.
      ```json
      {
      "error": "An error occurred while processing the file: Error in line 1: Line has invalid length: 63 characters"
      }
      ```
      Outro exemplo:
      ```json
      {
      "error": "An error occurred while processing the file: Error in line 2: Error in line format: Invalid user name"
      }
      ```

---

### Endpoint "/"

- **GET**: Endpoint para listagem de todos os dados como:
  - Aceita filtros de paginação: `/?page=1&size=5`
  - Paginação padrão por nome
     ```json
     {
       "users": [
         {
           "user_id": "123",
           "name": "John Doe",
           "orders": [
             {
               "order_id": "456",
               "file_id": "1", 
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

---

### Endpoint "/orders"

- **GET**: Endpoint para listagem de todos os pedidos:
  - Aceita filtros de paginação: `?page=1&size=1`
  - Aceita paginação com intervalo de data de compra (data início e data fim) `?start_date=YYYY-mm-dd&end_date=YYYY-mm-dd`
  - Paginação padrão por data
  ```json
    {
      "orders": [
        {
          "order_id": "523",
          "file_id": "1",
          "user_id": "49",
          "total": "586.74",
          "date": "2021-09-03",
          "products": [
            {
              "value": 586.74,
              "product_id": 3
            }
          ]
        },
        {
          "order_id": "620",
          "file_id": "1",
          "user_id": "57",
          "total": "1417.25",
          "date": "2021-09-19",
          "products": [
            {
              "value": 1417.25,
              "product_id": 0
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

---

### Endpoint "/orders/:id"

- **GET**: Endpoint para buscar pedido por id:

  ```json
  {
    "order_id": "753",
    "file_id": "1",
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

---

### Endpoint "/files"

- **GET**: Endpoint para buscar os arquivos salvos:

    ```json
    {
    "files": [
      {
        "file_id": "1",
        "name": "data_1",
        "date": "2024-11-22 20:37:47"
      },
      {
        "file_id": "2",
        "name": "data_2",
        "date": "2024-11-22 20:37:53"
      }
     ],
      "page": 1,
      "size": 5,
      "total_files": 8,
      "total_pages": 2
    }
    ```

---

### **Todos Endpoints possuem tratamento de erro para a rota e metódo:**
- **400 Bad Request**:
    ```json
    {
      "error": "Endpoint not Found"
    }
    ```
- **400 Bad Request**:
  ```json
  {
    "error": "Method Not Allowed"
  }
  ```
    
---

## Testes (Necessário a configuração de AMBIENTE DE TESTES!)

A qualidade do código é garantida por meio de testes automatizados com RSpec, localizados no diretório `spec`, que cobrem as funcionalidades essenciais da API.

### Executando os Testes

###  AMBIENTE DE TESTES - Rodar toda a aplicação em um container (API + Banco de dados)
- Requisito: Precisa ter o Docker e Docker Compose instalados.
- No seu arquivo `.env`, crie uma variável de ambiente `PROFILE` e insira o valor `test`.
- Insira o link de conexão na variável de ambiente `DATABASE_TEST_URL` com o valor `postgres://postgres:123456@localhost/luizalabs_test` no arquivo `.env`

- Execute o seguinte comando para iniciar o container do banco de dados de testes PostgreSQL:

   ```bash
   docker-compose -f docker-compose.test.yml up -d
   ```

- Instale as dependências executando o seguinte comando no diretório raiz do projeto:

   ```bash
   bundle install
   ```

[//]: # (- Inicie a aplicação executando o seguinte comando no diretório raiz do projeto:)

[//]: # (  &#40;as migrations serão feitas automaticamente&#41;)

[//]: # ()
[//]: # (   ```bash)

[//]: # (   rackup)

[//]: # (   ```)

- Execute os testes com o seguinte comando:
   ```bash
  bundle exec rspec
   ```

---

## Estrutura dos Testes

- **Gems e Configurações**
  - `Rack::Test`: Utilizado para simular requisições HTTP e verificar as respostas.
  - `Application`: A classe principal que gerencia as rotas da aplicação.
  - **spec/controllers**: Diretório que contém os testes para os controladores, assegurando que as requisições sejam processadas corretamente e as respostas estejam no formato esperado.

Este teste usa o RSpec em conjunto com o módulo Rack::Test para 
simular requisições HTTP e validar se os controladores da aplicação 
estão processando as rotas corretamente, retornando os status e 
conteúdos esperados para cada tipo de requisição.

---

## Descrição do Teste: `FileController`

Este teste verifica o comportamento do `FileController`, que gerencia 
o upload de arquivos e a recuperação de informações sobre arquivos. 
O teste cobre cenários como envio de arquivos .txt válidos, ausência 
de arquivos, arquivos com formato inválido, arquivos com dados 
incorretos e a recuperação de dados sobre arquivos enviados. 
Ele garante que a API responda corretamente a diferentes tipos 
de requisições e erros, retornando os status e mensagens apropriadas.

## Cenários de Teste

### 1. **Envio de um arquivo .txt válido**
- **Descrição**: Quando um arquivo [.txt](challenge/data_1.txt) válido é enviado retorna um status 201 e dados em formato JSON.
- **Requisição**: `POST /upload` com um arquivo anexado.
- **Expectativas**:
  - Status HTTP: **201 Created**.
  - `Content-Type`: **application/json**.
  - O arquivo é salvo no diretório configurado.
  - Verifica se a resposta da API está conforme as expectativas.

### 2. **Envio Sem Arquivo**
- **Descrição**: Nenhum arquivo é enviado na requisição.
- **Requisição**: `POST /upload` sem parâmetros.
- **Expectativas**:
  - Status HTTP: **400 Bad Request**.
  - Corpo da resposta inclui a mensagem: "File not provided".
  
### 3. **Envio de um arquivo com formato inválido (Arquivo que não seja .txt)**
- **Descrição**: Um arquivo [.pdf](challenge/Desafio%20técnico%20-%20Vertical%20Logistica.pdf) é enviado na requisição.
- **Requisição**: `POST /upload` com um arquivo .pdf anexado.
- **Expectativas**:
  - Status HTTP: **400 Bad Request**.
  - Corpo da resposta inclui a mensagem: "Invalid file type. Only .txt files are allowed.".

### 4. **Envio de um arquivo .txt com padrão fora do esperado**
- **Descrição**: Um arquivo [.txt](spec/fixtures/invalid-data.txt) com um texto comum é enviado na requisição.
- **Requisição**: `POST /upload` com um arquivo anexado.
- **Expectativas**:
  - Status HTTP: **400 Bad Request**.
  - Corpo da resposta inclui a mensagem: "An error occurred while processing the file: Error in line 1: Line has invalid length: 63 characters".

### 5. **Envio de um arquivo .txt com formato padrão porém falta dados**
- **Descrição**: Um arquivo [.txt](spec/fixtures/invalid-data_2.txt) com dados faltando é enviado na requisição.
- **Requisição**: `POST /upload` sem parâmetros.
- **Expectativas**:
  - Status HTTP: **400 Bad Request**.
  - Corpo da resposta inclui a mensagem: "An error occurred while processing the file: Error in line 2: Error in line format: Invalid user name".

### 6. **Retorno de Dados Válidos**
- **Descrição**: Este teste verifica se a requisição GET para o endpoint `/files` retorna um status 200 e dados em formato JSON.
- **Requisição**: `GET /files?page=1&size=5`.
- **Expectativas**:
  - O status da resposta deve ser 200.
  - O tipo de conteúdo da resposta deve ser `application/json`.
  - A resposta JSON deve conter as chaves:
    - `files`
    - `page`
    - `size`
    - `total_files`
    - `total_pages`

---

## Descrição do Teste: `ApiController`

Este teste avalia o comportamento do `ApiController`, cobrindo dois cenários principais: 
valida se endpoints inválidos retornam um `status 404` com a mensagem de erro adequada e assegura que 
o endpoint raiz (`GET /`) responde com `status 200`, retornando dados 
estruturados no formato `JSON` com informações como `data`, `page`, `size`, 
`total_users` e `total_pages`. Esse processo garante a integridade e 
confiabilidade das respostas da API conforme o esperado.

## Cenários de Teste

### 1. **Retorno de Dados Válidos**
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

### 2. **Requisição para endpoint inválido**
- **Descrição**: Este teste retorna uma mensagem de erro se o endpoint na requisição for inválido.
- **Requisição**: `GET /invalido`
- **Expectativas**:
  - Status HTTP: **404 Not Found**.
  - Corpo da resposta inclui a mensagem: "Endpoint Not Found".

---

## Descrição do Teste: `OrderController`

Este teste avalia o comportamento do `OrderController`, responsável 
por gerenciar e processar requisições relacionadas aos pedidos na 
aplicação. O teste cobre três cenários principais: verifica se o 
endpoint `/orders` retorna `status 200` e dados em formato `JSON` com 
informações como `orders`, `page`, `size`, `total_orders` e `total_pages`; 
assegura que o endpoint `/orders/:id` retorne os detalhes do pedido, 
incluindo `order_id`, `file_id`, `user_id`, `total`, `date` e `products` quando 
um `ID` válido é fornecido; e valida que um `ID` de pedido inexistente 
resulta em um `status 404` com a mensagem de erro apropriada, garantindo 
que o sistema lida corretamente com diferentes tipos de requisição e 
retorno.

## Cenários de Teste

### 1. **Retorno de Pedidos Válidos**
- **Descrição**: Este teste verifica se a requisição GET para o endpoint `/orders` retorna um status 200 e dados em formato JSON.
- **Requisição**: `GET /orders`
- **Expectativas**:
  - O status da resposta deve ser 200.
  - O tipo de conteúdo da resposta deve ser `application/json`.
  - A resposta JSON deve conter as chaves:
    - `orders`
    - `page`
    - `size`
    - `total_orders`
    - `total_pages`

### 2. **Retorno de Pedido Específico**
- **Descrição**: Este teste verifica se a requisição GET para o endpoint `/orders/:id` retorna um status 200 e o pedido específico em formato JSON.
- **Requisição**: `GET /orders/:id`
- **Expectativas**:
  - O status da resposta deve ser 200.
  - O tipo de conteúdo da resposta deve ser `application/json`.
  - A resposta JSON deve conter as chaves:
    - `order_id`
    - `file_id`
    - `user_id`
    - `total`
    - `date`
    - `products`

### 3. **Retorno de Pedido Inexistente**
- **Descrição**: Este teste verifica se a requisição GET para o endpoint `/orders/:id` retorna um status 404 quando o pedido especificado não existe.
- **Requisição**: `GET /orders/:id` com um ID inválido.
- **Expectativas**:
  - O status da resposta deve ser 404.
  - O corpo da resposta deve incluir a mensagem: "Order not found".

---

## Continuous Delivery Workflow 

### Descrição
Este workflow configura um processo de Continuous Delivery (CD) para uma aplicação Ruby utilizando GitHub Actions. Ele realiza testes automatizados, cria e envia uma imagem Docker para o Docker Hub e realiza o deploy em uma Azure Web App.

---

### Gatilho
O workflow é acionado automaticamente para qualquer push na branch `main`.

---

## Estrutura do Workflow

### Jobs

### 1. Build
#### Responsabilidade
Configurar o ambiente, rodar os testes automatizados, criar uma imagem Docker e enviá-la para o Docker Hub.

#### Executado em
Ubuntu-latest.

#### Etapas
1. **Checkout do Código**
  - Baixa o código da branch `main` do repositório.

2. **Configuração do Ruby**
  - Configura a versão do Ruby 3.1 para execução do projeto.

3. **Instalação das Dependências**
  - Executa `bundle install` para instalar as dependências Ruby definidas no `Gemfile`.

4. **Instalação do Docker e Docker Compose**
  - Instala Docker e Docker Compose para suporte à execução de containers.

5. **Inicialização do Banco de Dados de Teste**
  - Executa o arquivo `docker-compose.test.yml` para subir um container PostgreSQL para testes.

6. **Espera pelo PostgreSQL**
  - Aguarda o banco de dados estar pronto com o comando `pg_isready`.

7. **Execução dos Testes**
  - Roda os testes automatizados com `bundle exec rspec`.

8. **Login no Docker Hub**
  - Realiza login no Docker Hub utilizando credenciais armazenadas nos secrets (`DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`).

9. **Build e Push da Imagem Docker**
  - Cria a imagem Docker utilizando o `Dockerfile`, com uma tag baseada no SHA do commit, e a envia para o Docker Hub.

---

### 2. Deploy
#### Responsabilidade
Realizar o deploy da aplicação na Azure Web App usando a imagem Docker criada.

#### Executado em
Ubuntu-latest.

#### Dependência
Executado apenas após o sucesso do job `build`.

#### Etapas
1. **Deploy para a Azure Web App**
  - Realiza o deploy da imagem Docker utilizando a ação `azure/webapps-deploy@v2`.
  - Configurações:
    - `app-name`: Nome do aplicativo na Azure Web App (`luizalabs-ruby`).
    - `slot-name`: Nome do slot de produção (`production`).
    - `publish-profile`: Perfil de publicação armazenado em secrets (`AZURE_PROFILE`).
    - `images`: Imagem Docker criada no job `build`.

---

### Variáveis de Ambiente
- `DATABASE_TEST_URL`: String de conexão com o banco de dados PostgreSQL para testes.
- `PROFILE`: Define o perfil de execução como `test`.

---

### Secrets Utilizados
- `DOCKERHUB_USERNAME`: Usuário do Docker Hub.
- `DOCKERHUB_TOKEN`: Token de autenticação no Docker Hub.
- `AZURE_PROFILE`: Credenciais para deploy na Azure Web App.

---

### Arquivos Utilizados
- **`docker-compose.test.yml`**
  - Configuração do container de banco de dados para testes.
- **`Dockerfile`**
  - Configuração da imagem Docker da aplicação.

---

### Resultado Esperado
1. **Build e Testes:**
  - Testes automatizados executados com sucesso.
  - Imagem Docker criada e enviada ao Docker Hub.
2. **Deploy:**
  - Aplicação implantada no ambiente de produção da Azure Web App utilizando a imagem Docker mais recente.

---

## Continuous Integration Workflow

### Descrição
Este workflow configura um processo de Continuous Integration (CI) para validar as alterações realizadas no código da aplicação Ruby. Ele é acionado por pull requests e executa testes automatizados para garantir a integridade e funcionalidade da aplicação.

---

### Gatilho
O workflow é acionado automaticamente para cada `pull_request` no repositório.

---

## Estrutura do Workflow

### Jobs

### 1. Build
#### Responsabilidade
Configurar o ambiente, executar testes automatizados e verificar a integridade da aplicação.

#### Executado em
Ubuntu-latest.

#### Etapas
1. **Checkout do Código**
  - Baixa o código atualizado da branch relacionada ao `pull_request`.

2. **Configuração do Ruby**
  - Configura a versão do Ruby 3.1 para execução do projeto.

3. **Instalação das Dependências**
  - Executa `bundle install` para instalar as dependências Ruby definidas no `Gemfile`.

4. **Instalação do Docker e Docker Compose**
  - Instala Docker e Docker Compose para suporte à execução de containers.

5. **Inicialização do Banco de Dados de Teste**
  - Executa o arquivo `docker-compose.test.yml` para subir um container PostgreSQL para testes.

6. **Espera pelo PostgreSQL**
  - Aguarda o banco de dados estar pronto com o comando `pg_isready`.

7. **Execução dos Testes**
  - Roda os testes automatizados com `bundle exec rspec`.

---

### Variáveis de Ambiente
- `DATABASE_TEST_URL`: String de conexão com o banco de dados PostgreSQL para testes.
- `PROFILE`: Define o perfil de execução como `test`.

---

### Arquivos Utilizados
- **`docker-compose.test.yml`**
  - Configuração do container de banco de dados para testes.

---

### Resultado Esperado
1. Testes automatizados executados com sucesso para validar as alterações realizadas.
2. Notificação sobre possíveis falhas para correção antes da aprovação do pull request.

---

## Conclusão


A API desenvolvida oferece uma solução robusta e eficiente para a integração e gerenciamento de dados de pedidos, permitindo a transformação de arquivos desnormalizados em um formato JSON estruturado. Com funcionalidades como validação de arquivos, processamento assíncrono e suporte a consultas filtradas, a API garante uma experiência de usuário fluida e responsiva.

A utilização de tecnologias modernas, como Docker e PostgreSQL, assegura a escalabilidade e a facilidade de manutenção do sistema. Além disso, a implementação de CI/CD com GitHub Actions e Azure permite um fluxo de trabalho contínuo e automatizado, facilitando o deploy e a integração de novas funcionalidades de forma rápida e segura. Essa abordagem não apenas melhora a eficiência do desenvolvimento, mas também garante que a aplicação esteja sempre atualizada e em conformidade com as melhores práticas.

A implementação de testes automatizados com RSpec contribui para a confiabilidade e a qualidade do código, permitindo que a API se adapte a futuras necessidades e evoluções. Com isso, a API se posiciona como uma ferramenta valiosa para empresas que buscam otimizar seus processos de gestão de pedidos e dados, promovendo uma integração eficaz entre sistemas legados e novas soluções.
