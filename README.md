## Features
- Support Laravel App
- PHP 8.1
- Nginx
- Ext. MSSQL
- Ext. MongoDB
- Mysql 8
- phpMyAdmin
# How To Prepare Environment
- Install Docker and Docker Compose
- Clone This Repo First 
- Clone Your Laravel App and Create with Folder Name "web" And Create/Edit .env
- Run Below Command on Current Directory
```bash
    docker-compose up -d
```
- Already Done go to next step

# How To Custom Your Environment
- Run Below Command For Run composer update
```bash
    docker exec -it app bash
```
- In app Container run this command
```bash
    composer update
```
```bash
    chmod -R 777 /storage
```
# How To Fixed cURL error 77
cURL error 77: error setting certificate verify locations: CAfile: /usr/local/etc/php/conf.d/cacert.pem
- Download from (https://curl.haxx.se/ca/cacert.pem)
- Add This Line on php/local.ini curl.cainfo = /path/to/your/cacert.pem
- Restart app Container
# How To Use Feature
- Web Application http://localhost
- phpMyAdmin http://localhost:8080
## Authors
- [@phatkung7](https://github.com/phatkung7)
