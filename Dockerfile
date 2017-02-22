FROM ruby:2.3-slim
MAINTAINER Trang Tung Nguyen<trangtungn@gmail.com>

RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends apt-utils

ENV INSTALL_PATH /shines
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile
RUN gem update --system

RUN bundle install

COPY . .

RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://trangtungn:12345678@127.0.0.1/shines SECRET_TOKEN=pickasecuretoken assets:precompile

VOLUME ["$INSTALL_PATH/public"]

CMD bundle exec puma -C config/puma.rb
