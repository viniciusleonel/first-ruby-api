FROM ruby:3.1

# Instalar o dockerize
RUN apt-get update && apt-get install -y wget && \
    wget https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.6.1.tar.gz && \
    rm dockerize-linux-amd64-v0.6.1.tar.gz

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .

ENV DATABASE_URL=postgres://postgres:123456@db:5432/luizalabs

# Usar dockerize antes de iniciar a aplicação
CMD ["dockerize", "-wait", "tcp://db:5432", "-timeout", "60s", "rackup", "-o", "0.0.0.0", "-p", "8080"]
