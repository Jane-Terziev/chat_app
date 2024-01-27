FROM ruby:3.2.2-alpine3.18

RUN apk update && apk upgrade && apk add --no-cache \
    bash \
    build-base \
    nodejs \
    libpq-dev \
    postgresql-client \
    tzdata \
    git \
    && rm -rf /var/cache/apk/*

RUN mkdir /chat_app
WORKDIR /chat_app

COPY Gemfile Gemfile.lock ./

RUN gem update --system \
    && gem install bundler \
    && bundle lock --add-platform x86_64-linux \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle install

COPY . .

EXPOSE 3000