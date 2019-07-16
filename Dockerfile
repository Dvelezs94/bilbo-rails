FROM ruby:2.5.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y nodejs
RUN mkdir /bilbo
WORKDIR /bilbo
COPY . .
RUN bundle install
RUN rm -f tmp/pids/server.pid
CMD bundle exec rails s -p 3000 -b '0.0.0.0'
