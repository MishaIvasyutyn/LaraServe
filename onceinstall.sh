#!/usr/bin/env bash
RED='\033[0;31m'
GREEN='\033[1;32m'
PURPLE='\033[1;33m'
YELLOW='\033[1;35m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color
LIGHTPURPLE='\033[1;30m'
matrix() {
  local blue="\033[0;34m"
  local brightblue="\033[1;34m"
  local cyan="\033[0;36m"
  local brightcyan="\033[1;36m"
  local green="\033[0;32m"
  local brightgreen="\033[1;32m"
  local red="\033[0;31m"
  local brightred="\033[1;31m"
  local white="\033[1;37m"
  local black="\033[0;30m"
  local grey="\033[0;37m"
  local darkgrey="\033[1;30m"
  local colors=($green $brightgreen)
  spacing=${1:-100}
  scroll=${2:-0}
  screenlines=$(expr $(tput lines) - 1 + $scroll)
  screencols=$(expr $(tput cols) / 2 - 1)

  chars=(ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ﾝ)

  count=${#chars[@]}
  colorcount=${#colors[@]}

  trap "tput sgr0; clear; exit" SIGTERM SIGINT

  if [[ $1 =~ '-h' ]]; then
    echo "Display a Matrix(ish) screen in the terminal"
    echo "Usage:		matrix [SPACING [SCROLL]]"
    echo "Example:	matrix 100 0"
    exit 0
  fi

  clear
  tput cup 0 0
  end=$((SECONDS + 3))
  while [ $SECONDS -lt $end ]; do
    for i in $(eval echo {1..$screenlines}); do
      for i in $(eval echo {1..$screencols}); do
        rand=$(($RANDOM % $spacing))
        case $rand in
        0)
          printf "${colors[$RANDOM % $colorcount]}${chars[$RANDOM % $count]} "
          ;;
        1)
          printf "  "
          ;;
        *)
          printf "\033[2C"
          ;;
        esac
      done
      printf "\n"

      # sleep .005
    done
    tput cup 0 0
  done
}
if [[ $EUID -eq 0 ]]; then
  echo -e "${RED}This script must be run without  root${NC}"
  exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo -e "You system is mac os,  ${RED}which currently unsupported${NC}"
  exit
fi
if [[ "$OSTYPE" == "msys" ]]; then
  echo -e "You system is windows, ${RED}which currently unsupported!${NC}"
  exit
fi

kernel_version=$(uname -v)
kernel_year="${kernel_version##* }"
if [ $kernel_year -gt "2022" ]; then
  echo -e "${RED}This installation script is to old for you linux, please update it, or install oldest linux version!${NC}"
  exit
elif [ $kernel_year -lt "2018" ]; then
  echo -e "${RED}This installation script using for newer linux versions, please update your linux distro,or install oldest installation script version!${NC}"
  exit
fi

matrix

clear
echo -e "${GREEN}
,--.
|  |    ,--,--.,--.--. ,--,--.
|  |   ' ,-.  ||  .--'' ,-.  |
|  '--.\ '-'  ||  |   \ '-'  |
'-----' '--'--''--'    '--'--'
                               ${NC}"
echo -e "${BLUE}"$'\n' \
  $'                  ##        .\n' \
  $'            ## ## ##       ==\n' \
  $'         ## ## ## ##      ===\n' \
  $'     /""""""""""""""""\___/ ===\n' \
  $'~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===-- ~~~\n' \
  $'     \______ o          __/\n' \
  $'       \    \        __/\n' \
  $'        \____\______/\n'"${NC}"

echo -e "${PURPLE}🐳by Misha               ©${NC}🇲​​​​​🇮​​​​​🇸​​​​​🇭​​​​​🇦​​​​​\n"

while true; do
  echo -en "${BLUE}Do you really want to install laraserve?${NC}${YELLOW} (y-yes/n-no)${NC}: "
  read yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo -e "${YELLOW}Please answer yes or no."${NC} ;;
  esac
done

if [ -d "laraserve" ]; then
  echo -e "${YELLOW}Laraserve already installed${NC}"
  #rm -f onceinstall.sh
  exit
fi

nginx_config() {
  if [[ $1 == "laravel" ]]; then
    path=laraserve/config/laravel/docker/nginx/conf.d/app.conf
    publicFolder=/var/www/public
    dirpath=laraserve/config/laravel/docker/
  elif [[ $1 == "ownproject" ]]; then
    path=laraserve/config/ownproject/laravel/docker/nginx/conf.d/app.conf
    publicFolder=/var/www/public
    dirpath=laraserve/config/ownproject/laravel/docker/
  elif [[ $1 == "ownotlaravel" ]]; then
    path=laraserve/config/ownproject/notlaravel/docker/nginx/conf.d/app.conf
    publicFolder=/var/www/dynchange
    dirpath=laraserve/config/ownproject/notlaravel/docker/
  fi
  mkdir -p $dirpath/nginx/conf.d && touch $dirpath/nginx/conf.d/app.conf
  echo "server {
    listen 443 ssl;
    server_name project.dev;
    ssl_certificate /etc/nginx/ssl/project.dev+1.pem;
    ssl_certificate_key /etc/nginx/ssl/project.dev+1-key.pem;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root $publicFolder;
    ssl on;
    charset utf-8;

    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-XSS-Protection \"1; mode=block\";
    add_header X-Content-Type-Options \"nosniff\";

    location ~ \\.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
        gzip_static on;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

}" >$path
}
php_config() {
  versions=(7.4 8)
  #echo ${versions[0]} ${versions[1]}
  if [[ $1 == "laravel" ]]; then
    dirpath=laraserve/config/laravel/docker/
  elif [[ $1 == "ownproject" ]]; then
    dirpath=laraserve/config/ownproject/laravel/docker/
  elif [[ $1 == "ownotlaravel" ]]; then
    dirpath=laraserve/config/ownproject/notlaravel/docker/
  fi
  mkdir $dirpath/php
  for version in ${versions[*]}; do
    mkdir $dirpath/php/$version
    mkdir $dirpath/php/$version/extensions && touch $dirpath/php/$version/php.ini
    if [ $version = "7.4" ]; then
      exctver="extension=\"bolt.so\""
    else
      exctver=" "
    fi
    echo "$exctver

[xdebug]
xdebug.mode=debug
xdebug.log=\"/var/www/docker/php/$version/logs/xdebug.log\"
xdebug.client_port=9003
xdebug.start_with_request=yes
xdebug.discover_client_host=1
;xdebug.idekey=PHPSTORM
;xdebug.max_nesting_level = 500

;memory_limit = 256M
error_reporting = E_ALL
display_errors = on
log_errors = on
error_log = /var/www/docker/php/$version/logs/php_error.log
default_charset = UTF-8
post_max_size = 256M
upload_max_filesize = 256M
max_execution_time=1000
max_input_time=1000
" >$dirpath/php/$version/php.ini
    cp temp123244574558606/debug.png laraserve/config/laravel/docker/php/$version && cp temp123244574558606/debug.png laraserve/config/ownproject/laravel/docker/php/$version && cp temp123244574558606/debug.png laraserve/config/ownproject/notlaravel/docker/php/$version
  done
}
mysql_config() {
  if [[ $1 == "laravel" ]]; then
    path=laraserve/config/laravel/docker/mysql/my.cnf
    dirpath=laraserve/config/laravel/docker/
  elif [[ $1 == "ownproject" ]]; then
    path=laraserve/config/ownproject/laravel/docker/mysql/my.cnf
    dirpath=laraserve/config/ownproject/laravel/docker/
  elif [[ $1 == "ownotlaravel" ]]; then
    path=laraserve/config/ownproject/notlaravel/docker/mysql/my.cnf
    dirpath=laraserve/config/ownproject/notlaravel/docker/
  fi
  mkdir -p $dirpath/mysql/dumps && mkdir $dirpath/mysql/logs && touch $dirpath/mysql/my.cnf
  echo '[mysqld]
# default
skip-host-cache
skip-name-resolve
datadir = /var/lib/mysql
socket = /var/lib/mysql/mysql.sock
secure-file-priv = /var/lib/mysql-files
user = mysql

general_log = 1
general_log_file = /var/log/mysql/mysql.log
' >$path

}
docker_file() {
  versions=(7.4 8)
  if [[ $1 == "laravel" ]]; then
    dirpath=laraserve/config/laravel/docker/
  elif [[ $1 == "ownproject" ]]; then
    dirpath=laraserve/config/ownproject/laravel/docker/
  elif [[ $1 == "ownotlaravel" ]]; then
    dirpath=laraserve/config/ownproject/notlaravel/docker/
  fi

  for version in ${versions[*]}; do
    touch $dirpath/php/$version/Dockerfile
    if [ $version = "7.4" ]; then
      echo 'FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    git \
    bash \
    curl \
    dpkg-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    cron \
    libpng-dev zlib1g-dev libicu-dev g++ libmagickwand-dev --no-install-recommends libxml2-dev \
    unzip \
    libcurl4-openssl-dev \
        && docker-php-ext-configure intl \
        && docker-php-ext-install pdo_mysql curl mbstring exif pcntl bcmath gd xml zip soap sockets tokenizer iconv \
        && pecl install imagick \
        && docker-php-ext-enable imagick \
        && pecl install xdebug-3.0.1 \
        && docker-php-ext-enable xdebug

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
' >$dirpath/php/$version/Dockerfile
    else
      echo 'FROM php:8-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    git \
    bash \
    curl \
    dpkg-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    cron \
    libpng-dev zlib1g-dev libicu-dev g++ libmagickwand-dev --no-install-recommends libxml2-dev \
    unzip \
    libcurl4-openssl-dev \
        && docker-php-ext-configure intl \
        && docker-php-ext-install pdo_mysql curl mbstring exif pcntl bcmath gd xml zip soap sockets tokenizer iconv \
        && pecl install imagick \
        && docker-php-ext-enable imagick \
        && pecl install xdebug-3.0.1 \
        && docker-php-ext-enable xdebug

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
' >$dirpath/php/$version/Dockerfile
    fi
  done
}
docker_compose() {
  if [[ $1 == "laravel" ]]; then
    path=laraserve/config/laravel/docker-compose.yml
    dirpath=laraserve/config/laravel/
    projname=dyname
    network=laravel
  elif [[ $1 == "ownproject" ]]; then
    path=laraserve/config/ownproject/laravel/docker-compose.yml
    dirpath=laraserve/config/ownproject/laravel/
    projname=dyname
    network=laravel
  elif [[ $1 == "ownotlaravel" ]]; then
    path=laraserve/config/ownproject/notlaravel/docker-compose.yml
    dirpath=laraserve/config/ownproject/notlaravel/
    projname=dyname
    network=dynetwork
  fi
  touch $dirpath/docker-compose.yml
  echo "version: '3.8'
services:

  #PHP Service
  app:
    build:
      args:
        user: sammy
        uid: 1000
      context: ./
      dockerfile: docker/php/phpver/Dockerfile
    image: laravel
    container_name: app-php
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: app
      SERVICE_TAGS: dev
    working_dir: /var/www
    volumes:
      - ./:/var/www
      - ./docker/php/phpver/dynphp:/usr/local/etc/php/conf.d/dynphp
      - bolt
    networks:
      - $network

  #Nginx Service
  nginx:
    image: nginx:alpine
    container_name: app-server
    restart: unless-stopped
    tty: true
    ports:
      - '443:443'
    depends_on:
      - app
    volumes:
      - ./:/var/www
      - ./docker/nginx/conf.d/:/etc/nginx/conf.d/
      - ./docker/nginx/ssl:/etc/nginx/ssl
    networks:
      - $network

  #MySQL Service
  mysql:
    image: mysql/mysql-server:8.0
    command: [ \"\--default-authentication-plugin=mysql_native_password\" ]
    container_name: app-mysql
    restart: unless-stopped
    tty: true
    ports:
      - '\${DB_PORT:-3306}:\${DB_PORT:-3306}'
    environment:
      MYSQL_DATABASE: \${DB_DATABASE:-$projname}
      MYSQL_ROOT_PASSWORD: \${DB_PASSWORD:-root}
      MYSQL_PASSWORD: \${DB_PASSWORD:-root}
      MYSQL_USER: \${DB_USERNAME}
      MYSQL_ALLOW_EMPTY_PASSWORD: 'yes'
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql
    volumes:
     - '${network}mysql:/var/lib/mysql'
     - ./docker/mysql/dynmysql:/etc/mysql/dynmysql
     - ./docker/mysql/logs:/var/log/mysql
    networks:
      - $network

  #PHPMyadmin Service
  phpmydmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    container_name: app-phpmyadmin
    depends_on:
      - mysql
    ports:
      - '8080:80'
    environment:
      PMA_HOST: mysql
      MYSQL_ROOT_PASSWORD: root
    networks:
      - $network

    # memcached:
    #     image: 'memcached:alpine'
    #     ports:
    #         - '11211:11211'
    #     networks:
    #         - $network
  mailhog:
      image: 'mailhog/mailhog:latest'
      ports:
        - \${MAIL_PORT:-1025}:\${MAIL_PORT:-1025}
        - 8025:8025
      networks:
        - $network

#Docker Networks
networks:
  $network:
    driver: bridge
volumes:
  ${network}mysql:
    driver: local
" >$path
}
check_again_pakage_installed() {
  if [[ $(which $1) ]]; then
    echo -e "${GREEN}Done${NC}, $1 was ${GREEN}successfully installed${NC}"
    sleep 1
  else
    echo -e "${RED}Can't install${NC} $1 !"
    rm -rf temp123244574558606
    rm -rf laraserve
    sleep 1
    exit
  fi
}
check_package_installed() {
  echo -e "${LIGHTPURPLE}Check if ${NC} $1 ${LIGHTPURPLE}installed...${NC}"
  packetName=$1
  if [[ $packetName == "net-tools" ]]; then
      packetName=netstat
  fi
  if [[ $(which $packetName) ]]; then
    sleep 1
    echo -e "$1 ${GREEN}already installed${NC}"
  else
    if [[ $distro == "ubuntu" ]]; then
      echo -e " $1 ${YELLOW}not installed${NC}"
      sleep 1
      echo -e "${PURPLE}Installing $1...${NC}"
      sleep 1
      if [ $1 == "node" ]; then
        curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
        sudo apt install nodejs
      else
        sudo apt -y install $1
      fi
    elif [[ $distro == "fedora" ]]; then
      echo -e "$1 ${YELLOW} not installed${NC}"
      sleep 1
      echo -e "${PURPLE}Installing $1...${NC}"
      sleep 1
      if [ $1 == "node" ]; then
        sudo dnf -y install nodejs
#        pacman -S --noconfirm nodejs
#      elif [ $1 == "net-tools" ]; then
#        yum -y install net-tools
      else
        sudo dnf -y install $1
      fi
    elif [[ $distro == "arch" ]]; then
      echo -e "$1 ${YELLOW} not installed${NC}"
      sleep 1
      echo -e "${PURPLE}Installing $1...${NC}"
      sleep 1
      if [ $1 == "node" ]; then
        pacman -S --noconfirm nodejs
      else
        sudo pacman -S --noconfirm $1
      fi
    fi
    check_again_pakage_installed $packetName
  fi
}
check_docker_installed() {
  echo -e "${LIGHTPURPLE}Check if ${NC} docker ${LIGHTPURPLE}installed...${NC}"
  if [[ $(which "docker") ]]; then
    sleep 1
    echo -e "docker ${GREEN}already installed${NC}"
  else
    echo -e "${YELLOW} docker not installed${NC}"
    sleep 1
    echo -e "${PURPLE}Installing docker...${NC}"
    if [[ $distro == "ubuntu" ]]; then
      sleep 1
      # curl -fsSL https://get.docker.com -o get-docker.sh
      # sudo sh get-docker.sh
      sudo apt-get update
      sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release -y
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
      sudo apt-get update
      sudo apt-get install docker-ce docker-ce-cli containerd.io -y
      sudo groupadd docker
      sudo usermod -aG docker $USER
      newgrp docker
      #      su - $USER
    elif [[ $distro == "fedora" ]]; then
      echo -e "${YELLOW} docker not installed${NC}"
      sleep 1
      echo -e "${PURPLE}Installing docker...${NC}"
      dnf upgrade
      sudo yum -y install curl
      sudo dnf -y install dnf-plugins-core
      sudo dnf config-manager \
        --add-repo \
        https://download.docker.com/linux/fedora/docker-ce.repo
      sudo -y dnf install docker-ce docker-ce-cli containerd.io
      sudo systemctl start docker
      sudo groupadd docker
      sudo usermod -aG docker $USER
      newgrp docker
      #      su - $USER
    elif [[ $distro == "arch" ]]; then
      echo -e "${YELLOW} docker not installed${NC}"
      sleep 1
      echo -e "${PURPLE}Installing docker...${NC}"
      sudo pacman -Syu
      pacman -S --noconfirm curl
      sudo pacman -S --noconfirm docker
      sudo systemctl start docker.service
      sudo systemctl enable docker.service
      sudo groupadd docker
      sudo usermod -aG docker $USER
      newgrp docker
      #      su - $USER
    fi
    check_again_pakage_installed "docker"
  fi
}
check_docker_compose_installed() {
  echo -e "${LIGHTPURPLE}Check if ${NC} docker-compose ${LIGHTPURPLE}installed...${NC}"
  if [[ $(which "docker-compose") ]]; then
    sleep 1
    echo -e "Docker-compose  ${GREEN}already installed${NC}"
  else
    echo -e "Docker-compose ${YELLOW}not installed${NC}"
    sleep 1
    echo -e "${PURPLE}Installing docker-compose...${NC}"
    sleep 1
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    check_again_pakage_installed "docker-compose"
  fi
}
check_mkcert_installed() {
  echo -e "${LIGHTPURPLE}Check if additional settings  installed...${NC}"
  if [[ $(which "mkcert") ]]; then
    sleep 1
    echo -e "host ${GREEN}already installed${NC}"
  else
    if [[ $distro == "ubuntu" ]]; then
      echo -e "${PURPLE}Installing${NC} host.."
      sleep 1
      sudo apt install libnss3-tools -y
      export VER="v1.4.3"
      wget https://github.com/FiloSottile/mkcert/releases/download/${VER}/mkcert-${VER}-linux-amd64
      mv mkcert-${VER}-linux-amd64 mkcert
      chmod +x mkcert
      sudo mv mkcert /usr/local/bin
      mkcert -install
    elif [[ $distro == "fedora" ]]; then
      echo -e "${PURPLE}Installing${NC} host.."
      sleep 1
      sudo yum -y install nss-tools
      export VER="v1.4.3"
      wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/${VER}/mkcert-${VER}-linux-amd64
      chmod +x mkcert
      sudo mv mkcert /usr/local/bin
      mkcert -install
    elif [[ $distro == "arch" ]]; then
      echo -e "${PURPLE}Installing${NC} host.."
      sleep 1
      sudo pacman -S nss
      sudo pacman -Syu mkcert
      mkcert -install
    fi
    if [[ -z $(which "mkcert") ]]; then
      cd temp123244574558606/
      mv mkcert-v1.4.3-linux-amd64 mkcert
      chmod +x mkcert
      sudo mv mkcert /usr/local/bin
      mkcert -install
      cd ../
    fi
    check_again_pakage_installed "mkcert"
  fi
}
ngork_install() {
  echo -e "${LIGHTPURPLE}Check if tunnel settings  installed ...${NC}"
  if [[ $(which "ngrok") ]]; then
    sleep 1
    echo -e "tunnel ${GREEN}already installed${NC}"
  else
    echo -e "tunnel${YELLOW}not installed${NC}"
    sleep 1
    echo -e "${PURPLE}Installing${NC} tunnel..."
    sleep 1
    sudo npm install --unsafe-perm -g ngrok
    check_again_pakage_installed "ngrok"
  fi
}
yarn_install() {
  echo -e "${LIGHTPURPLE}Check if${NC} yarn ${LIGHTPURPLE}installed..${NC}"
  sleep 1
  if [[ $(which "yarn") ]]; then
    sleep 1
    echo -e "yarn ${GREEN}already installed${NC}"
  else
    echo -e "yarn${YELLOW}not installed${NC}"
    sleep 1
    echo -e "${PURPLE}Installing yarn...${NC}"
    sudo  npm install --global yarn
    sleep 1
    check_again_pakage_installed "yarn"
  fi
}
echo -e "${PURPLE}Checkin linux distro${NC}..."
distrobution=$(lsb_release -i | cut -f 2-)
if [[ $(which "apt") ]]; then
  echo -e "Your linux distro is ${YELLOW}ubuntu base${NC}"
  sleep 1
  echo -e "${PURPLE}Installing development tools...${NC}"
  sleep 1
  distro="ubuntu"
  sudo apt -y install build-essential
  echo -e "Dev tools have been ${GREEN}successfully  installed ${NC}"
  sleep 1
elif [ $(which "dnf") ] && [ $distrobution == "Fedora" ]; then
  echo -e "Your linux distro is ${BLUE}fedora${NC}"
  sleep 1
  echo -e "${PURPLE}Installing development tools...${NC}"
  sleep 1
  sudo dnf -y groupinstall "Development Tools" "Development Libraries"
  distro="fedora"
  echo -e "Dev tools have been ${GREEN}successfully  installed ${NC}"
  sleep 1
elif [[ $(which "pacman") ]]; then
  echo -e "Your linux distro is ${GREEN}arch base${NC}"
  sleep 1
  echo -e "${PURPLE}Installing development tools...${NC}"
  sleep 1
  distro="arch"
  sudo pacman -S --noconfirm base-devel
  echo -e "Dev tools have been ${GREEN}successfully  installed ${NC}"
  sleep 1
fi

if [ $distro == "ubuntu" ] || [ $distro == "arch" ] || [ $distro == "fedora" ]; then
  sleep 0.1
else
  echo -e "${RED}Your linux distro is currently not supported${NC}"
  exit
fi

echo -e "${PURPLE}Init projects folders and scripts...${NC}"
sleep 1
if [ ! -f install.tar.gz ]; then
  echo -e "${RED}Archive  install.tar.gz  not found!${NC}"
  exit
fi
mkdir -p laraserve/www
mkdir temp123244574558606
tar -xf install.tar.gz -C temp123244574558606/
cd temp123244574558606/
if [ ! -f debug.png ] || [ ! -f install.sh ] || [ ! -f bolt.so ] || [ ! -f mkcert-v1.4.3-linux-amd64 ]; then
  echo -e "${RED}Cant find additional files in installation archive!${NC}"
  rm -rf ../temp123244574558606
  rm -rf ../laraserve
  exit
fi
cd ../
cp temp123244574558606/install.sh laraserve/www/create.sh
touch laraserve/www/delete.sh

echo -e "${PURPLE}Installing packets for $distro ${NC}"
check_docker_installed
check_docker_compose_installed
check_package_installed "wget"
check_package_installed "git"
check_package_installed "node"
check_package_installed "npm"
check_package_installed "net-tools"
check_mkcert_installed
ngork_install
yarn_install

echo "#!/usr/bin/env bash
RED='\\033[1;31m'
GREEN='\\033[1;32m'
PURPLE='\\033[1;33m'
YELLOW='\\033[1;35m'
BLUE='\\033[1;34m'
LIGHTPURPLE='\\033[1;30m'
NC='\\033[0m' # No Color
echo \"                                                                                ░░▒▒
                                                                            ░░▒▒░░▒▒░░
                                                                      ░░▒▒▒▒▒▒▒▒░░▒▒░░
                                                              ░░░░▒▒▒▒▒▒░░░░  ░░▒▒▒▒▒▒▒▒
                                                        ░░▒▒▒▒▒▒▒▒░░░░░░  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░
                                                ░░▒▒▒▒▒▒▒▒░░░░    ▒▒▒▒▒▒  ▒▒▒▒░░░░  ▒▒▒▒▒▒
                                        ░░░░▒▒▒▒▒▒▒▒░░  ░░▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒    ░░▒▒▒▒▒▒▒▒▒▒░░
                                ░░░░▒▒▒▒▒▒▒▒▒▒░░  ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒
                        ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒  ▒▒▒▒░░    ░░▒▒▒▒
                  ░░▒▒▒▒▒▒▒▒▒▒░░▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒  ░░░░  ░░▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ░░▒▒▒▒▒▒▒▒▒▒▒▒
              ▒▒▒▒▒▒▒▒░░    ░░▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░
    ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
▒▒▒▒▒▒▒▒░░      ░░▒▒▒▒  ▒▒▒▒▒▒░░  ▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒░░░░    ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
  ▒▒▒▒  ▒▒▒▒▒▒▒▒░░  ▒▒    ░░▒▒▒▒▒▒▒▒▒▒░░  ▒▒▒▒▒▒██▒▒▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░
░░▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒  ▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒    ░░██░░  ██▓▓▓▓▒▒▒▒▒▒░░░░
░░▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒▒▒▒▒░░  ░░▒▒▒▒▒▒▓▓██▒▒░░██▓▓▒▒░░░░
  ▒▒▒▒  ░░▒▒▒▒▒▒▒▒  ▒▒▒▒      ░░▒▒▒▒▒▒▒▒▒▒▓▓▓▓▒▒██░░  ██▒▒██░░████▒▒████
  ▒▒▒▒░░  ▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░██░░░░▓▓▒▒░░▒▒▓▓░░░░██    ██
  ▒▒▒▒▒▒  ▒▒░░  ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░▓▓▒▒  ░░██░░░░██░░░░████░░░░██
  ▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░            ░░██  ░░██░░░░▒▒██░░  ██  ░░██
  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░                    ██░░░░  ██░░  ██    ▒▒░░░░░░██
  ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                          ░░██▓▓░░░░██░░░░░░░░░░░░  ░░░░██▒▒
  ░░▒▒▒▒▒▒▒▒▒▒▒▒░░░░                          ████████░░░░  ░░░░░░░░░░░░░░░░░░░░██
    ░░▒▒▒▒░░░░                              ██    ░░██░░░░░░░░░░░░░░░░  ░░░░  ░░▓▓
                                            ██░░░░░░░░░░    ░░░░░░  ░░░░░░    ▒▒██
                                              ▓▓▓▓██░░░░  ░░░░░░░░░░░░  ░░░░  ░░██▒▒
                                                  ██  ░░░░  ░░  ░░░░░░░░░░░░░░░░██
                                                  ▒▒▓▓██  ░░░░░░░░░░░░░░░░░░░░░░██
                                                      ▓▓██  ░░░░░░  ░░░░░░░░░░  ████
                                                        ▓▓▒▒░░░░░░░░░░░░░░░░██████▓▓
                                                        ▒▒████  ░░░░░░  ████████▒▒
                                                            ██████████████
                                                              ██▒▒
\"
path=\$(pwd | sed 's#.*/##')
fllpath=\$(echo \$PWD | awk -v h=\"laraserve/www\" '\$0 ~ h {print \"OK\"}' )
if [[ \$path !=  \"www\" ]]; then
 echo -e \"\${RED}The project creation script must be in the laraserve/www  folder\${NC}\"
  exit
fi
if [[ \$fllpath != \"OK\" ]]; then
  echo -e \"\${RED}The project creation  script must be in the laraserve/www  folder\${NC}\"
  exit
fi

deleting() {
  check_project_name() {
    echo -en \"\${LIGHTPURPLE}Enter project name \$again:\${NC} \"
    read project
    while [ -z \${project} ]; do
      echo -en \"\${YELLOW}Project  name can't be empty:\${NC} \"
      read project
    done
    while [[ \$project =~ ^[0-9]+$ ]]; do
      echo -en \"\${YELLOW}Please enter a string:\${NC}  \"
      read project
      while [ -z \${project} ]; do
        echo -en \"\${YELLOW}Project  name can't be empty:\${NC} \"
        read project
      done
    done
  }
  check_project_name
  project=\${project,,}
  while ! [ -d \"\$project\" ]; do
    echo -e \"Project \$project \${RED}not exist\${NC}\"
    again=\"again\"
    check_project_name
  done
  if [ -d \"\$project\" ]; then
    while true; do
      echo -en \"\${BLUE}Do you really want to delete \$project?\${NC}\${YELLOW} (y-yes/n-no)\${NC}: \"
      read yn
      case \$yn in
      [Yy]*)
        echo -e \"\${PURPLE}Deleting...\${NC}\"
        sleep 1
        ETC_HOSTS=/etc/hosts
        IP=127.0.0.1
        HOSTNAME=\$project'.dev'
        HOSTS_LINE=\"\$IP[[:space:]]\$HOSTNAME\"
        if [ -n \"\$(grep -P \$HOSTS_LINE \$ETC_HOSTS)\" ]; then
          echo -e \"\${PURPLE}\$HOSTS_LINE Found in your \$ETC_HOSTS, Removing now...\${NC}\"
          sleep 1
          sudo sed -i\".bak\" \"/\$HOSTS_LINE/d\" \$ETC_HOSTS
          echo -e \"\${GREEN}Done, was successfully\${Nc} removed \$project.dev  from host file\"
        elif [ ! -n \"\$(grep -P \$HOSTS_LINE \$ETC_HOSTS)\" ]; then
          echo -e \"\${YELLOW}\$HOSTNAME already deleted from your \$ETC_HOSTS\${NC}\"
          sleep 1
        else
          echo -e \"\${RED}Can't delete\${NC}  \$HOSTNAME  from your \$ETC_HOSTS\"
          sleep 1
        fi
        echo -e \"\${PURPLE}Stopping and removing \$project containers and volumes ...\${NC}\"
        sleep 1
        cd \$project
        if [ ! -f \"docker-compose.yml\" ]; then
          echo -e \"\${RED}Cannot find\${NC} docker-compose.yml file in \$project root directory\"
          sleep 1
          echo -e \"\${RED}Can't fully delete project\${NC}, try again after  moving your docker-compose.yml with configuration in root of  the \$project \"
          break #TODO maybe (exit) here better bag(if project exist bat docker file not found)
        fi
        docker-compose down -v
        echo -e \"\${GREEN}Done\${NC}, \$project containers and volumes was \${GREEN} successfully deleted \${NC}\"
        sleep 1
        cd ../
        echo -e \"\${PURPLE}Removing \$project folder...\${NC}\"
        sleep 1
        sudo rm -rf \$project
        echo -e \"\${GREEN}Done\${NC}, \$project was  \${GREEN}successfully\${NC} removed\"
        break
        ;;
      [Nn]*) break ;;
      *) echo -e \"\${YELLOW}Please answer yes or no.\"\${NC} ;;
      esac
    done
  fi
}
deleting
while true; do
  echo -en \"\${BLUE}Do you want delete another project?\${NC}\${YELLOW} (y-yes/n-no)\${NC}: \"
  read yen
  case \$yen in
  [Yy]*) deleting ;;
  [Nn]*) exit ;;
  *) echo -e \"\${YELLOW}Please answer yes or no.\"\${NC} ;;
  esac
done
" >laraserve/www/delete.sh
echo -e "${PURPLE}Creating config folder...${NC}"
sleep 1
mkdir -p laraserve/config/laravel && mkdir laraserve/config/ownproject && mkdir laraserve/config/ownproject/laravel && mkdir laraserve/config/ownproject/notlaravel
mkdir -p laraserve/config/laravel/docker && mkdir laraserve/config/ownproject/laravel/docker && mkdir laraserve/config/ownproject/notlaravel/docker
nginx_config "laravel"
php_config "laravel"
mysql_config "laravel"
docker_file "laravel"
docker_compose "laravel"
nginx_config "ownproject"
php_config "ownproject"
mysql_config "ownproject"
docker_file "ownproject"
docker_compose "ownproject"
nginx_config "ownotlaravel"
php_config "ownotlaravel"
mysql_config "ownotlaravel"
docker_file "ownotlaravel"
docker_compose "ownotlaravel"
cp temp123244574558606/bolt.so laraserve/config/laravel/docker/php/7.4/extensions/ && cp temp123244574558606/bolt.so laraserve/config/ownproject/laravel/docker/php/7.4/extensions/ && cp temp123244574558606/bolt.so laraserve/config/ownproject/notlaravel/docker/php/7.4/extensions/
echo -e "${PURPLE}Removing temp files ...${NC}"
sleep 1
rm -rf temp123244574558606
echo -e "${GREEN}Done${NC}"
sleep 1
echo -e "${PURPLE}Running project generator script${NC}"
sleep 1
rm -f onceinstall.sh
cd laraserve/www/
chmod +x create.sh
chmod +x delete.sh
bash create.sh
