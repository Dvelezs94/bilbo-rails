FROM ruby:2.5.1


RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl software-properties-common nginx vim supervisor

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y nodejs

# Copy supervisor config files
COPY .docker/supervisord.conf /etc/supervisor/supervisord.conf
COPY .docker/supervisor-services.conf /etc/supervisor/conf.d/services.conf

# Copy nginx files
RUN rm /etc/nginx/sites-enabled/default
COPY .docker/nginx.conf /etc/nginx/sites-enabled/

RUN mkdir /bilbo
WORKDIR /bilbo
COPY . .

RUN bundle install

# Prevent server pid from saving
RUN rm -f tmp/pids/server.pid

# cleanup
RUN rm -rf /var/lib/apt/lists/*

CMD ["/usr/bin/supervisord"]
