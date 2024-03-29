FROM php:8.1-fpm
# Arguments defined in docker-compose.yml
# ARG user
# ARG uid
# Copy composer.lock and composer.json into the working directory
COPY ./web/composer.lock /var/www/html/ 
COPY ./web/composer.json /var/www/html/
# Set working directory
WORKDIR /var/www/html/
# Install dependencies for the operating system software
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    locales \
    libzip-dev \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    nano

#Download appropriate package for the OS version
RUN apt-get update \
    && apt-get install -y curl apt-transport-https locales gnupg2
# Install MSSQL Connect
RUN apt-get -y install unixodbc-dev
RUN pecl install sqlsrv pdo_sqlsrv
RUN apt-get install unixodbc -y \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN echo "extension=sqlsrv.so" >> /usr/local/etc/php/conf.d/sqlsrv.ini
RUN echo "extension=pdo_sqlsrv.so" >> /usr/local/etc/php/conf.d/pdo_sqlsrv.ini

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions for php
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js
RUN apt-get update && apt-get install -y curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash
RUN apt-get install --yes nodejs
# RUN node -v
# RUN npm -v

# Cleanup
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

# Create system user to run Composer and Artisan Commands
# RUN useradd -G www-data,root -u $uid -d /home/$user $user
# RUN mkdir -p /home/$user/.composer && \
#     chown -R $user:$user /home/$user

# Copy existing application directory contents to the working directory
COPY . /var/www/html
COPY openssl.cnf /etc/ssl/openssl.cnf
COPY cacert.pem /usr/local/etc/php/conf.d/cacert.pem

# Set working directory
# WORKDIR /var/www/html
# USER $user

# Expose port 9000 and start php-fpm server (for FastCGI Process Manager)
EXPOSE 9000
CMD ["php-fpm"]
