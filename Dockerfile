FROM ruby:2.5.1


RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl software-properties-common nginx vim supervisor

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y nodejs

# cleanup
RUN rm -rf /var/lib/apt/lists/*

# Copy supervisor config files
COPY .docker/supervisord.conf /etc/supervisor/supervisord.conf
COPY .docker/supervisor-services.conf /etc/supervisor/conf.d/services.conf

# Copy nginx files
RUN rm /etc/nginx/sites-enabled/default
COPY .docker/nginx.conf /etc/nginx/sites-enabled/

# Create app user for correct file permissions
ARG US_ID=1000
ARG GR_ID=1000
ARG USERNAME=bilbouser

RUN addgroup --gid $GR_ID $USERNAME
RUN adduser --disabled-password --gecos '' --uid $US_ID --gid $GR_ID $USERNAME
USER $USERNAME

RUN mkdir /home/$USERNAME/app
WORKDIR /home/$USERNAME/app
COPY --chown=$USERNAME . .

RUN bundle install

# Prevent server pid from saving
RUN rm -f tmp/pids/server.pid

CMD ["/usr/bin/supervisord"]
