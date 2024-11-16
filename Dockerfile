FROM ruby:3.1

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

ENV DATABASE_URL=postgres://postgres:123456@db:5432/luizalabs

# Expõe a porta 9292
EXPOSE 8080

CMD ["wait-for-it.sh", "db:5432", "--", "rackup", "-o", "0.0.0.0", "-p", "8080"]