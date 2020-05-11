FROM ruby:2.5.1


RUN apt-get update -qq && apt-get install -y sudo \
    build-essential \
    libpq-dev \
    curl \
    software-properties-common \
    nginx \
    vim \
    supervisor

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
ARG USERNAME=bilbo

RUN addgroup --gid $GR_ID $USERNAME
RUN adduser --disabled-password --gecos '' --uid $US_ID --gid $GR_ID $USERNAME

# allow user to run sudo commands without password
RUN chmod 644 /etc/sudoers && \
    echo "$USERNAME     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    # && \
    #chmod 400 /etc/sudoers

USER $USERNAME

RUN mkdir /home/$USERNAME/app
WORKDIR /home/$USERNAME/app
COPY --chown=$USERNAME . .

RUN bundle install

# Run asset precompile if CI_AGENT key is set
RUN if [ -n "$CI_AGENT" ]; then bundle exec rake assets:precompile; fi

# Prevent server pid from saving
RUN rm -f tmp/pids/server.pid

CMD /usr/bin/sudo -E -u root /usr/bin/supervisord
