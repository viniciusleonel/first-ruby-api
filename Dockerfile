FROM ruby:3.1

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

ENV DATABASE_URL=postgres://postgres:123456@db:5432/luizalabs

EXPOSE 9292

ENTRYPOINT ["rackup", "-o", "0.0.0.0"]