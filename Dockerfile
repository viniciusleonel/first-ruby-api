FROM ruby:3.1

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

ENV DATABASE_URL=postgres://postgres:123456@db:5432/luizalabs

CMD ["rackup", "-o", "0.0.0.0", "-p", "8080"]