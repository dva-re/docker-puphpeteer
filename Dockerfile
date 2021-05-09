FROM php:7.4
ENV NODE_VERSION 12.0.0

# Fixed for now. Could be auto-updated or passed in as well.
ENV NVM_VERSION v0.37.2

# Update the repository sources list and install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl libzip-dev zip ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils
RUN apt-get autoclean -y && apt-get autoremove -y

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# The current version requires sockets and zip
RUN docker-php-ext-install sockets zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \ 
    mv composer.phar /usr/local/bin/composer && \ 
    chmod +x /usr/local/bin/composer


# nvm environment variables
ENV NVM_DIR /usr/local/nvm
RUN mkdir $NVM_DIR

# install nvm
# https://github.com/creationix/nvm#install-script  
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/{$NVM_VERSION}/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install "$NODE_VERSION" \
    && nvm use "$NODE_VERSION"

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV PHP_CLI_SERVER_WORKERS 4

# Install requirements for PuPHPeteer
#RUN composer require nesk/puphpeteer
RUN npm install @nesk/puphpeteer

ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh
EXPOSE 80
CMD ["/bin/bash", "/root/start.sh"]
