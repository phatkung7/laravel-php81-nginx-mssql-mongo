FROM php:8.1-fpm
# Copy composer.lock and composer.json into the working directory
#COPY ./web/composer.lock /var/www/html/ 
#COPY ./web/composer.json /var/www/html/
# Set working directory
WORKDIR /var/www/html/
# Copy SSL
#COPY ./ssl/DigiCertCA.crt /etc/ssl/certs/DigiCertCA.crt
#COPY ./ssl/wildcard_moph_go_th.crt /etc/ssl/certs/wildcard_moph_go_th.crt
#COPY ./ssl/wildcard_moph_go_th.key /etc/ssl/certs/wildcard_moph_go_th.key
# Install dependencies for the operating system software
# Install dependencies
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
# Install MongoDB Connect
RUN pecl install mongodb
RUN apt-get update \
    && apt-get install -y curl apt-transport-https locales gnupg2
#RUN apt-get install apt-transport-https
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

# Install composer (php package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
#RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
#RUN apt-get install --yes nodejs
#RUN node -v
#RUN npm -v

# Cleanup
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

# Copy existing application directory contents to the working directory
COPY . /var/www/html
COPY openssl.cnf /etc/ssl/openssl.cnf
# Assign permissions of the working directory to the www-data user
#RUN useradd -G www-data,root -u 1000 -d /home/itc itc
#RUN chown -R www-data:www-data \
#         /var/www/html/storage \
#         /var/www/html/bootstrap/cache

# Expose port 9000 and start php-fpm server (for FastCGI Process Manager)
EXPOSE 9000
CMD ["php-fpm"]
