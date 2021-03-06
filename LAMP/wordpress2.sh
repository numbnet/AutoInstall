#!/bin/bash


# ====================================== #
#     Confiruge Server and WordPress     #
# ====================================== #


# -------------------------------------
#      VARIABLE & Function
# -------------------------------------

function OSrelease {
  OS="$(cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )";
  release="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";
}; OSRel

function wait() { echo -en "\n\tress [ANY] key to continue..." && read -s -n 1; }
function pause() { echo -en "\n\tPress [ENTER] key to continue..." && read fackEnterKey; }
function title { clear && echo "${title}" && wait; }

function myip() {
ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
ipW="$(echo $(curl -4 icanhazip.com))";
ipH=$(hostname -I|cut -f1 -d ' ');

  if [ "$ipE" == "$ipW" ]; then
    myip="$ipE";
    elif [ "$ipH" == "$ipW" ]; then
      myip="$ipH"
    else myip="$ipW"
  fi
  
if [ "$ipE" == "$ipW" ]; then myip="$ipE";
else if [ "$ipH" == "$ipW" ]; then myip="$ipH"; else myip="$ipW"; fi; fi
}

function TIMER() { if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; else T="3"; fi;
SE="$((1 * ${T}))" && SC='\033[0K\r';
while [ $SE -gt 0 ]; do echo -ne "\t $SE$SC"; sleep 1 && : $((SE--)); done; }
function DATA() { DATA=$(date +%Y-%m-%d_%k%M%S) && echo "$DATA"; }
function APT_INSTALL() {
APTGET=$(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed")
  if [ "${APTGET}" -eq 0 ]; then
    echo -en "${YELLOW}\nInstalling $1 ${NC}\n";
    apt-get install $1 --yes;
    elif [ "${APTGET}" -eq 1 ]; then
      echo -en "\n${GREEN} $1 is installed!${NC}\n"
  fi
}


## -------------------------------------
##      COLORS SETTINGS
## -------------------------------------
BLUE='\033[0;34m'               # BLUE
GREEN='\033[0;32m'              # GREEN
RED='\033[0;31m'                # RED
YELLOW="\033[0;33m"             # YELLOW
PURPLE='\033[0;4;35m'           # PURPLE
CYAN='\033[4;36m'               # CYAN
NC='\033[0m'                    # No Color

#WELCOME MESSAGE
# -------------------------------------
clear && echo -e "Welcome to WordPress & LAMP stack installation and configuration wizard!
First of all, we going to check all required packeges..."



#CHECKING PACKAGES
# -------------------------------------

echo -e "${YELLOW}Checking UPdate packages...${NC}"
read -r -p "Do you want to update pac...? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) apt-get update -y && apt-get upgrade -y ;;
    *) echo -e "${RED}Packeges update is ignored!${NC}" ;;
esac


# install
echo -e "${YELLOW}Checking packages...${NC}"
echo -e "List of required packeges: nano, zip, unzip, mc, htop, fail2ban, apache2 & php, mysql, php curl, phpmyadmin, wget, curl"

read -r -p "Do you want to check packeges? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
    
  APT_INSTALL curl
  APT_INSTALL wget
  APT_INSTALL nano
  APT_INSTALL zip
  APT_INSTALL mc
  APT_INSTALL unzip
  APT_INSTALL htop
  APT_INSTALL fail2ban
  APT_INSTALL apache2
  APT_INSTALL mysql-server
  APT_INSTALL php5-curl
  APT_INSTALL phpmyadmin

 ;;
    *) echo -e "${RED} Packeges check is ignored! \n Please be aware, that apache2, mysql, phpmyadmin and other software may not be installed! ${NC}" ;;
esac


#PHPMYADMIN DEFAULT PATH CHANGE
# -------------------------------------
echo -e "${YELLOW}Changing phpMyAdmin default path from /phpMyAdmin to /myadminphp...${NC}"

read -r -p "Do you want to change default phpMyAdmin path to /myadminphp? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
  
cat >/etc/phpmyadmin/apache.conf <<EOL
# phpMyAdmin default Apache configuration

Alias /myadminphp /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options FollowSymLinks
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_flag magic_quotes_gpc Off
        php_flag track_vars On
        php_flag register_globals Off
        php_admin_flag allow_url_fopen Off
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOL

	echo -e "${GREEN}Path was succesfully changed!\n New phpMyAdmin path is: /myadminphp (i.e.: yourwebsite.com/myadminphp)${NC}" ;;
    *) echo -en "${RED}Path was not changed!${NC}\n\n" ;;
esac


#CREATING USER
# -------------------------------------
echo -e "${YELLOW}Adding separate user & creating website home folder for secure running of your website...${NC}"

  echo -e "${YELLOW}Please, enter new username [def. www-data]: ${NC}"
  #read username
  if [[ -z "${username}" ]]; then username="www-data"; fi;
  
  echo -e "${YELLOW}Please enter website name: ${NC}"
  read websitename
  if [[ -z "${websitename}" ]]; then websitename="domain.com"; fi;
  
  groupadd $username
  adduser --home /var/www/$websitename --ingroup $username $username
  mkdir -p /var/www/$websitename
  chown -R $username:$username /var/www/$websitename
  echo -e "${GREEN}User, group and home folder were succesfully created!
  Username: $username
  Group: $username
  Home folder: /var/www/$websitename
  Website folder: /var/www/$websitename${NC}"


# CONFIGURING APACHE2
# -------------------------------------
echo -e "${YELLOW}Now we going to configure apache2 for your domain name & website root folder...${NC}"

read -r -p "Do you want to configure Apache2 automatically? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  echo -e "Please, provide us with your domain name [domain.com]: "
  #read domain_name
  domain_name="$websitename"

  echo -e "Please, provide us with your email [ root@domain ]: "
  read domain_email
  if [ -z "${domain_email}" ]; then domain_email=admin@${websitename}; fi;
  cat >/etc/apache2/sites-available/$domain_name.conf <<EOL
  <VirtualHost *:80>
        ServerAdmin $domain_email
        ServerName $domain_name
        ServerAlias www.$domain_name
        DocumentRoot /var/www/$websitename/
        <Directory />
                Options +FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/$websitename>
                Options -Indexes +FollowSymLinks +MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL
	a2dissite 000-default
    a2ensite $domain_name
    service apache2 restart
    P_IP="`wget http://ipinfo.io/ip -qO -`"

    echo -en "${GREEN}Apache2 config was updated!\n
    Config:            /etc/apache2/sites-available/$domain_name.conf
    Domain:            $domain_name
    Admin email:       $domain_email
    Root folder:       /var/www/$websitename
    Option Indexes:    -Indexes (to close directory listing)
    Server IP(public): $P_IP 
    (Please, set this IP into your domain name 'A' record)
    
    Website was activated & apache2 service reloaded! ${NC}\n"  ;;
    *) echo -e "${RED}WARNING! Apache2 was not configured properly, you can do this manually or re run our script.${NC}"  ;;
esac




# DOWNLOADING WORDPRESS, UNPACKING, ADDING BASIC PACK OF PLUGINS, CREATING .HTACCESS WITH OPTIMAL & SECURE CONFIGURATION
# -------------------------------------
echo -e "${YELLOW}On this step we going to download latest version of WordPress with EN or RUS language, set optimal & secure configuration and add basic set of plugins...${NC}"
read -r -p "Do you want to install WordPress & automatically set optimal and secure configuration with basic set of plugins? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  echo -e "${GREEN}Please, choose WordPress language you need (set RU or EN): "
  wordpress_lang="RU"
  #read wordpress_lang

  if [[ "$wordpress_lang" == 'RU' ]] && [[ -z "${wordpress_lang}" ]]; then
    wordpress_lang="RU";
    wget ru.wordpress.org/latest-ru_RU.zip -O /tmp/$wordpress_lang.zip
  else
    wordpress_lang="EN"
    wget https://wordpress.org/latest.zip -O /tmp/$wordpress_lang.zip
  fi

  echo -e "Unpacking WordPress into website home directory..."
  sleep 5
  unzip /tmp/$wordpress_lang.zip -d /var/www/$websitename/
  mv /var/www/$websitename/wordpress/* /var/www/$websitename
  rm -rf /var/www/$websitename/wordpress
  rm /tmp/$wordpress_lang.zip
  mkdir -p /var/www/$websitename/wp-content/uploads
  chmod -R 777 /var/www/$websitename/wp-content/uploads

  echo -e "Now we going to download some useful plugins:
  1. Google XML Sitemap generator
  2. Social Networks Auto Poster
  3. Add to Any
  4. Easy Watermark"
  sleep 7
  
  SITEMAP="`curl https://wordpress.org/plugins/google-sitemap-generator/ | grep https://downloads.wordpress.org/plugin/google-sitemap-generator.*.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $SITEMAP -O /tmp/sitemap.zip
  unzip /tmp/sitemap.zip -d /tmp/sitemap
  mv /tmp/sitemap/* /var/www/$websitename/wp-content/plugins/

  wget https://downloads.wordpress.org/plugin/social-networks-auto-poster-facebook-twitter-g.zip -O /tmp/snap.zip
  unzip /tmp/snap.zip -d /tmp/snap
  mv /tmp/snap/* /var/www/$websitename/wp-content/plugins/

  ADDTOANY="`curl https://wordpress.org/plugins/add-to-any/ | grep https://downloads.wordpress.org/plugin/add-to-any.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $ADDTOANY -O /tmp/addtoany.zip
  unzip /tmp/addtoany.zip -d /tmp/addtoany
  mv /tmp/addtoany/* /var/www/$websitename/wp-content/plugins/

  WATERMARK="`curl https://wordpress.org/plugins/easy-watermark/ | grep https://downloads.wordpress.org/plugin/easy-watermark.*.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $WATERMARK -O /tmp/watermark.zip
  unzip /tmp/watermark.zip -d /tmp/watermark
  mv /tmp/watermark/* /var/www/$websitename/wp-content/plugins/

  rm -rf /tmp/sitemap.zip /tmp/snap.zip /tmp/addtoany.zip /tmp/watermark.zip
  rm -rf /tmp/sitemap/ /tmp/snap/ /tmp/addtoany/ /tmp/watermark/

  echo -e "Downloading of plugins finished! All plugins were transfered into /wp-content/plugins directory.${NC}" ;;
    *) echo -e "${RED}WordPress and plugins were not downloaded & installed. You can do this manually or re run this script.${NC}" ;;
esac


#creating of swap
# -------------------------------------
echo -e "On next step we going to create SWAP (it should be your RAM x2)..."

read -r -p "Do you need SWAP? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  RAM="`free -m | grep Mem | awk '{print $2}'`"
  swap_allowed=$(($RAM * 2))
  swap=$swap_allowed"M"
  fallocate -l $swap /var/swap.img
  chmod 600 /var/swap.img
  mkswap /var/swap.img
  swapon /var/swap.img

  echo -en "${GREEN}
  RAM detected: $RAM
  Swap was created: $swap${NC}"
  sleep 5 
  ;;
    *) echo -e "${RED}You didn't create any swap for faster system working. You can do this manually or re run this script.${NC}"   ;;
esac




#creation of secure .htaccess
# -------------------------------------
echo -e "${YELLOW}Creation of secure .htaccess file...${NC}"
sleep 3
cat >/var/www/$websitename/.htaccess <<EOL
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

RewriteCond %{query_string} concat.*\( [NC,OR]
RewriteCond %{query_string} union.*select.*\( [NC,OR]
RewriteCond %{query_string} union.*all.*select [NC]
RewriteRule ^(.*)$ index.php [F,L]

RewriteCond %{QUERY_STRING} base64_encode[^(]*\([^)]*\) [OR]
RewriteCond %{QUERY_STRING} (<|%3C)([^s]*s)+cript.*(>|%3E) [NC,OR]
</IfModule>

<Files .htaccess>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config.php>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config-sample.php>
Order Allow,Deny
Deny from all
</Files>

<Files readme.html>
Order Allow,Deny
Deny from all
</Files>

<Files xmlrpc.php>
Order allow,deny
Deny from all
</files>

# Gzip
<ifModule mod_deflate.c>
AddOutputFilterByType DEFLATE text/text text/html text/plain text/xml text/css application/x-javascript application/javascript text/javascript
</ifModule>

Options +FollowSymLinks -Indexes

EOL

chmod 644 /var/www/$websitename/.htaccess

echo -e "${GREEN}.htaccess file was succesfully created!${NC}"



#cration of robots.txt
# -------------------------------------
echo -e "${YELLOW}Creation of robots.txt file...${NC}"
sleep 3
cat >/var/www/$websitename/robots.txt <<EOL
User-agent: *
Disallow: /cgi-bin
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /wp-content/
Disallow: /wp-content/plugins/
Disallow: /wp-content/themes/
Disallow: /trackback
Disallow: */trackback
Disallow: */*/trackback
Disallow: */*/feed/*/
Disallow: */feed
Disallow: /*?*
Disallow: /tag
Disallow: /?author=*
EOL

echo -e "${GREEN}File robots.txt was succesfully created!
Setting correct rights on user's home directory and 755 rights on robots.txt${NC}"
sleep 3

chmod 755 /var/www/$websitename/robots.txt

echo -e "${GREEN}Configuring fail2ban...${NC}"
sleep 3
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf-old
cat >/etc/fail2ban/jail.conf <<EOL
[DEFAULT]

ignoreip = 127.0.0.1/8
ignorecommand =
bantime  = 1200
findtime = 1200
maxretry = 3
backend = auto
usedns = warn
destemail = $domain_email
sendername = Fail2Ban
sender = fail2ban@localhost
banaction = iptables-multiport
mta = sendmail

# Default protocol
protocol = tcp
# Specify chain where jumps would need to be added in iptables-* actions
chain = INPUT
# ban & send an e-mail with whois report to the destemail.
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
              %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]
action = %(action_mw)s

[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5

[ssh-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 5

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 5
EOL

service fail2ban restart

echo -e "${GREEN}fail2ban configuration finished!
fail2ban service was restarted, default confige backuped at /etc/fail2ban/jail.conf-old
Jails were set for: ssh bruteforce, ssh ddos, apache overflows${NC}"

sleep 5

echo -e "${GREEN} Configuring apache2 prefork & worker modules...${NC}"
sleep 3
cat >/etc/apache2/mods-available/mpm_prefork.conf <<EOL
<IfModule mpm_prefork_module>
	StartServers			 1
	MinSpareServers		  1
	MaxSpareServers		 3
	MaxRequestWorkers	  10
	MaxConnectionsPerChild   3000
</IfModule>
EOL

cat > /etc/apache2/mods-available/mpm_worker.conf <<EOL
<IfModule mpm_worker_module>
	StartServers			 1
	MinSpareThreads		 5
	MaxSpareThreads		 15
	ThreadLimit			 25
	ThreadsPerChild		 5
	MaxRequestWorkers	  25
	MaxConnectionsPerChild   200
</IfModule>
EOL

a2dismod status

echo -e "${GREEN}Configuration of apache mods was succesfully finished!
Restarting Apache & MySQL services...${NC}"

service apache2 restart
service mysql restart

echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3

echo -e "${GREEN}Adding user & database for WordPress, setting wp-config.php...${NC}"
echo -e "Please, set username for database: "
read db_user
echo -e "Please, set password for database user: "
read db_pass

mysql -u root -p <<EOF
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';
CREATE DATABASE IF NOT EXISTS $db_user;
GRANT ALL PRIVILEGES ON $db_user.* TO '$db_user'@'localhost';
ALTER DATABASE $db_user CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

cat >/var/www/$websitename/wp-config.php <<EOL
<?php

define('DB_NAME', '$db_user');

define('DB_USER', '$db_user');

define('DB_PASSWORD', '$db_pass');

define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

define('AUTH_KEY',         '$db_user');
define('SECURE_AUTH_KEY',  '$db_user');
define('LOGGED_IN_KEY',    '$db_user');
define('NONCE_KEY',        '$db_user');
define('AUTH_SALT',        '$db_user');
define('SECURE_AUTH_SALT', '$db_user');
define('LOGGED_IN_SALT',   '$db_user');
define('NONCE_SALT',       '$db_user');

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL

chown -R $username:$username /var/www/$websitename
echo -e "${GREEN}Database user, database and wp-config.php were succesfully created & configured!${NC}"
sleep 3
echo -e "Installation & configuration succesfully finished."

# exit
