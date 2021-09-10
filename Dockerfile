FROM ruby:2.7.1

# remove deprecation warning messages
ENV RUBYOPT='-W0'

RUN apt-get update -qq && apt-get install -y sudo \
    build-essential \
    libpq-dev \
    curl \
    ffmpeg \
    software-properties-common \
    nginx \
    vim \
    supervisor \
    python3 \
    python3-pip \
    jq && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt install -y nodejs && \
    npm install yarn -g && \
    pip3 install --upgrade awscli && \
    rm -rf /var/lib/apt/lists/*

# Copy supervisor config files
COPY .docker/supervisord.conf /etc/supervisor/supervisord.conf
COPY .docker/supervisor-services.conf /etc/supervisor/conf.d/services.conf

# Copy nginx files
RUN rm /etc/nginx/sites-enabled/default && \ 
    # Disable server signature 
    sed -i 's/# server_tokens off/server_tokens off/g' /etc/nginx/nginx.conf
COPY .docker/nginx.conf /etc/nginx/sites-enabled/

# Create app user for correct file permissions
ARG US_ID=1000
ARG GR_ID=1000
ARG USERNAME=bilbo

RUN addgroup --gid $GR_ID $USERNAME && \
    adduser --disabled-password --gecos '' --uid $US_ID --gid $GR_ID $USERNAME && \
    # allow user to run sudo commands without password
    chmod 644 /etc/sudoers && \
    echo "$USERNAME     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME

RUN mkdir /home/$USERNAME/app
WORKDIR /home/$USERNAME/app
COPY --chown=$USERNAME . .

RUN bundle install

# Optional arguments for CICD
ARG CI_AGENT
ARG ENVNAME
ARG PAYPAL_USERNAME
ARG PAYPAL_PASSWORD
ARG PAYPAL_SIGNATURE
ARG MAPS_API_KEY

# Run asset precompile if CI_AGENT key is set
RUN if [ -n "$CI_AGENT" ]; then rails assets:clobber && rails assets:precompile --trace; fi

# Prevent server pid from saving
RUN rm -f tmp/pids/server.pid


ENTRYPOINT [".docker/entrypoint.sh"]

CMD ["web"]
