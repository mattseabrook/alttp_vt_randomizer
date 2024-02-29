[![Build Status](https://travis-ci.org/sporchia/alttp_vt_randomizer.svg?branch=master)](https://travis-ci.org/sporchia/alttp_vt_randomizer)

# ALttP VT Randomizer

## First and foremost, big thanks to Dessyreqt, Christos, Smallhacker, and KatDevsGames for their work.
### Without their work none of this would even be remotely possible.

## Local Setup

### System Setup
This assumes you're running Ubuntu 22.04 (either natively, or via Windows Subsystem for Linux).
Native Windows is not currently supported.
Users of either Mac OS or other Linux distributions will need to install the appropriate packages for their system.

This version of the randomizer requires version 8.1 of PHP.

```
sudo apt-get install php8.1 php8.1-bcmath php8.1-xml php8.1-mbstring php8.1-curl php8.1-sqlite3 \
php8.1-mysql php8.1-cli php8.1-opcache python3 mariadb-server sqlite3 composer -y
```

### Installing PHP dependencies
The above step installs the [Composer](https://getcomposer.org/) PHP package manager. Run:

```
$ composer install
```

## Database setup

Run the following command to create a new config for the app:
```
$ cp .env.example .env
```

### MySQL
Create a new mysql database for the randomizer (see mysql documentation.) Modify .env with
appropriate username, password, and database name. Change the db connection to `mysql`.

Example:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=randomizer
DB_USERNAME=foo
DB_PASSWORD=bar
```

### SQLite
SQLite can also be used too, this might be a better option for a quick setup. The
`php artisan migrate` command below will ask if you want to create this database if
it doesn't exist.

```
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/existing/folder/db.sqlite
```

Then run the following commands to setup the app configuration

### Last steps on DB setup
```
$ php artisan key:generate
$ php artisan config:cache
```
p.s. If you update the .env file then you'll need to run the config:cache command to pick up the new changes.

Now run the db migration command:

```
$ php artisan migrate
```

## Generate a base patch

In you .env file, update `ENEMIZER_BASE=` to the **absolute path** of an unheadered Japanese 1.0 ROM of A Link to the Past.

Then, in the command line run this to create the base patch.

```
php artisan config:cache
php artisan alttp:updatebuildrecord
```

## Running from the command line
To generate a game one simply runs the command:

```
$ php artisan alttp:randomize {input_file.sfc} {output_directory}
```

For help (and all the options):

```
$ php artisan alttp:randomize -h
```

## Running the Web Interface

### Web server setup
You will need to build assets the first time (you will need [NPM](https://www.npmjs.com/get-npm) to install the javascript dependencies).

```
$ npm install
```

And then

```
$ npm run production
```

Once you have the dependencies installed. Run the following command then navigate to http://localhost:8000/.

```
$ php artisan serve
```

## Running tests
You can run the current test suite with the following command (you may need to install [PHPUnit](https://phpunit.de/))

```
$ phpunit
```

## Bug Reports
Bug reports for the current release version can be opened in this repository's [issue tracker](https://github.com/sporchia/alttp_vt_randomizer/issues).

Please do not open issues for bugs that you encounter when testing a development branch.

# Seabrook

Instructions for Use

## Build the Docker Image

```sh
Copy code
docker build -t alttp-randomizer .
```

## Run the Docker Container

```sh
Copy code
docker run -d -p 9000:9000 -p 9001:9001 --name alttp-randomizer-app alttp-randomizer
```

## Docker Post Install

```Dockerfile
# Install NPM dependencies and build assets
RUN npm install && npm run production

# Copy the .env.example file to .env and setup the application
RUN cp .env.example .env \
    && sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/g' .env \
    && sed -i 's/DB_DATABASE=homestead/DB_DATABASE=\/var\/www\/html\/database\/database.sqlite/g' .env \
    && touch database/database.sqlite

# Generate key and cache configuration
RUN php artisan key:generate && php artisan config:cache

# Run database migrations
RUN php artisan migrate

# Permissions adjustment, to ensure that the web server can access the necessary files
RUN chown -R www-data:www-data /var/www/html && find /var/www/html -type d -exec chmod 755 {} \; && find /var/www/html -type f -exec chmod 644 {} \;

# When the container starts, serve the application via Apache in the foreground
CMD ["apache2-foreground"]
```

## NPM Dependencies

Updates:

```bash
[====================] 41/41 100%

 @babel/core               ^7.10.3  →   ^7.24.0
 @babel/preset-env         ^7.10.3  →   ^7.24.0
 @sentry/browser           ^5.18.1  →  ^7.103.0
 ajv                       ^6.12.2  →   ^8.12.0
 axios                     ^0.21.4  →    ^1.6.7
 axios-mock-adapter        ^1.18.1  →   ^1.22.0
 bootstrap                  ^4.5.0  →    ^5.3.3
 cross-env                  ^7.0.2  →    ^7.0.3
 date-fns                  ^2.14.0  →    ^3.3.1
 eslint                     ^6.8.0  →   ^8.57.0
 eslint-plugin-jest       ^23.17.1  →   ^27.9.0
 eslint-plugin-vue          ^6.2.2  →   ^9.22.0
 file-saver                 ^2.0.2  →    ^2.0.5
 jquery                     ^3.5.1  →    ^3.7.1
 laravel-mix                ^5.0.4  →   ^6.0.49
 localforage                ^1.7.4  →   ^1.10.0
 prando                     ^5.1.2  →    ^6.0.1
 resolve-url-loader         ^3.1.1  →    ^5.0.0
 sass                      ^1.26.9  →   ^1.71.1
 sass-loader                ^8.0.2  →   ^14.1.1
 spark-md5                  ^3.0.1  →    ^3.0.2
 ts-loader                  ^6.2.2  →    ^9.5.1
 typescript                 ^3.9.5  →    ^5.3.3
 v-tooltip                  ^2.0.3  →    ^2.1.3
 vue                       ^2.6.11  →   ^3.4.21
 vue-i18n                  ^8.18.2  →    ^9.9.1
 vue-multiselect            ^2.1.6  →    ^2.1.9
 vue-slider-component       ^3.1.5  →   ^3.2.24
 vue-template-compiler     ^2.6.11  →   ^2.7.16
 vue-timeago                ^5.1.2  →    ^5.1.3
 vuex                       ^3.4.0  →    ^4.1.0
 webpack-bundle-analyzer    ^3.8.0  →   ^4.10.1
 ```

 ## NPM Audit

 ```bash
 npm ERR! code ERESOLVE
npm ERR! ERESOLVE could not resolve
npm ERR!
npm ERR! While resolving: vue-js-toggle-button@1.3.3
npm ERR! Found: vue@3.4.21
npm ERR! node_modules/vue
npm ERR!   dev vue@"^3.4.21" from the root project
npm ERR!   peer vue@"3.4.21" from @vue/server-renderer@3.4.21
npm ERR!   node_modules/@vue/server-renderer
npm ERR!     @vue/server-renderer@"3.4.21" from vue@3.4.21
npm ERR!   3 more (vue-i18n, vue-property-decorator, vuex)
npm ERR!
npm ERR! Could not resolve dependency:
npm ERR! peer vue@"^2.0.0" from vue-js-toggle-button@1.3.3
npm ERR! node_modules/vue-js-toggle-button
npm ERR!   vue-js-toggle-button@"^1.3.3" from the root project
npm ERR!
npm ERR! Conflicting peer dependency: vue@2.7.16
npm ERR! node_modules/vue
npm ERR!   peer vue@"^2.0.0" from vue-js-toggle-button@1.3.3
npm ERR!   node_modules/vue-js-toggle-button
npm ERR!     vue-js-toggle-button@"^1.3.3" from the root project
npm ERR!
npm ERR! Fix the upstream dependency conflict, or retry
npm ERR! this command with --force or --legacy-peer-deps
npm ERR! to accept an incorrect (and potentially broken) dependency resolution.
npm ERR!
npm ERR!
npm ERR! For a full report see:
npm ERR! /root/.npm/_logs/2024-02-29T03_52_04_220Z-eresolve-report.txt

npm ERR! A complete log of this run can be found in:
npm ERR!     /root/.npm/_logs/2024-02-29T03_52_04_220Z-debug-0.log
```