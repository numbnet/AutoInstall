#!/bin/bash

#==========================================================
#	 Script to confiruge Server, WebServer and WordPress
#==========================================================

# bash <(curl -fLsS https://raw.githubusercontent.com/numbnet/AutoInstall/master/wp/wpca.sh)


#----------------------------------------------------------
# Colors settings
#----------------------------------------------------------
#  - - - - - - - - - - - - - - - - -
#            COLOR
#  - - - - - - - - - - - - - - - - -
GREEN="\033[32m";
RED="\033[1;31m";
BLUE="\033[1;34m";
YELOW="\033[1;33m";
PURPLE='\033[0;4;35m';
CYAN='\033[4;36m';
BLACK="\033[40m";
NC="\033[0m";

Black="`tput setaf 0`"
Red="`tput setaf 1`"
Green="`tput setaf 2`"
Yellow="`tput setaf 3`"
Blue="`tput setaf 4`"
Cyan="`tput setaf 5`"
Purple="`tput setaf 6`"
White="`tput setaf 7`"

BGBlack="`tput setab 0`"
BGRed="`tput setab 1`"
BGGreen="`tput setab 2`"
BGYellow="`tput setab 3`"
BGBlue="`tput setab 4`"
BGCyan="`tput setab 5`"
BGPurple="`tput setab 6`"
BGWhite="`tput setab 7`"

RC="`tput sgr0`"

TEXTCOLOR=$White;
BGCOLOR=$BLACK;


function THIS() {
 while true; do
  clear;
  echo -e -n "\n\t ${Yellow} Do you want Run THIS script [y/N] .? ${RC}" && read -e syn;
  case $syn in
  [Yy]* ) echo -e -n "\t ${GREEN} THIS script is Run ! ${NC} \n\n"; sleep 2 && break ;;
  [Nn]* ) echo -e "${RED}Cancel..${NC}"; exit 0 ;;
  esac
 done
}; THIS


#================================
#        Welcome message
#================================
clear
echo -e "Welcome to WordPress & LAMP stack installation and configuration wizard!
First of all, we going to check all required packeges..."
sleep 5


#================================
#     
#================================
echo -e -n "${YELLOW}Please, provide us with your domain name: ${NC}" && read domain
# echo -e -n "${YELLOW}Please, provide us with your email: ${NC}" && read domain_email
domain_email="webmaster@${domain}"

dbPassword=$(date +%s|sha256sum|base64|head -c 25) && db_pass="$dbPassword"
wp_pass=$(date +%s|sha256sum|base64|head -c 20)
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_") && db_user="$dbNameandUser";
authorization="mysql -uroot -p${db_pass}"

wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)
Host=\'%\'
#================================




#-----------------------------------
#       Checking packages
#-----------------------------------
function CHECking_PACK() {

echo -e "${YELLOW}Upgradin now all Packages ${NC}" && sleep 3;
apt-get update --yes && \
	apt-get upgrade --yes;

apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update

NANO=$(dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed")
	if [ "$NANO" -eq 0 ]; then
		echo -e "${YELLOW}Installing nano${NC}" && apt-get install nano --yes;
	elif [ "$NANO" -eq 1 ]; then
		echo -e "${GREEN}nano	- is installed!${NC}"
	fi; sleep 1

ZIP=$(dpkg-query -W -f='${Status}' zip 2>/dev/null | grep -c "ok installed")
	if [ "$ZIP" -eq 0 ]; then
		echo -e "${YELLOW}Installing zip${NC}" && apt-get install zip --yes;
	elif [ "$ZIP" -eq 1 ]; then
		echo -e "${GREEN}zip	- is installed!${NC}"
	fi; sleep 1

MC=$(dpkg-query -W -f='${Status}' mc 2>/dev/null | grep -c "ok installed")
	if [ "$MC" -eq 0 ]; then
		echo -e "${YELLOW}Installing mc${NC}" && apt-get install mc --yes;
	elif [ "$MC" -eq 1 ]; then
		echo -e "${GREEN}mc	- is installed!${NC}"
	fi; sleep 1

HTOP=$(dpkg-query -W -f='${Status}' htop 2>/dev/null | grep -c "ok installed")
	if [ "$HTOP" -eq 0 ]; then
		echo -e "${YELLOW}Installing htop${NC}" && apt-get install htop --yes;
	elif [ "$HTOP" -eq 1 ]; then
		echo -e "${GREEN}htop	- is installed!${NC}"
	fi; sleep 1

FAIL2BAN=$(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed")
	if [ "$FAIL2BAN" -eq 0 ]; then
		echo -e "${YELLOW}Installing fail2ban${NC}" && apt-get install fail2ban --yes;
	elif [ "$FAIL2BAN" -eq 1 ]; then
		echo -e "${GREEN}fail2ban	- is installed!${NC}"
	fi; sleep 1

APACHE2=$(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed")
	if [ "$APACHE2" -eq 0 ]; then
		echo -e "${YELLOW}Installing apache2${NC}" && apt-get install apache2 php5 --yes;
	elif [ "$APACHE2" -eq 1 ]; then
		echo -e "${GREEN}apache2\t- is installed!${NC}"
	fi; sleep 1

MYSQLSERVER=$(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c "ok installed")
	if [ "$MYSQLSERVER" -eq 0 ]; then
		echo -e "${YELLOW}Installing mysql-server${NC}"
		if [ ! -x /usr/bin/mysql ]; then apt-get install mysql-server --yes && systemctl start mysql;
		fi;
	elif [ "$MYSQLSERVER" -eq 1 ]; then
		echo -e "${GREEN}mysql-server	- is installed!${NC}"
		systemctl start mysql || systemctl restart mysql
	fi; sleep 1

PHP5-CURL=$(dpkg-query -W -f='${Status}' php5-curl 2>/dev/null | grep -c "ok installed")
	if [ "$PHP5-CURL" -eq 0 ]; then
		echo -e "${YELLOW}Installing php5-curl${NC}" && apt-get install php5-curl --yes;
	elif [ "$PHP5-CURL" -eq 1 ]; then
		echo -e "${GREEN}php5-curl	- is installed!${NC}"
	fi; sleep 1

PHPMYADMIN=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c "ok installed")
	if [ "$PHPMYADMIN" -eq 0 ]; then
		echo -e "${YELLOW}Installing phpmyadmin${NC}" && apt-get install phpmyadmin --yes;
	elif [ "$PHPMYADMIN" -eq 1 ]; then
		echo -e "${GREEN}phpmyadmin	- is installed!${NC}"
	fi; sleep 1

WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed")
	if [ "$WGET" -eq 0 ]; then
		echo -e "${YELLOW}Installing wget${NC}" && apt-get install wget --yes;
	elif [ "$WGET" -eq 1 ]; then
		echo -e "${GREEN}wget	- is installed!${NC}"
	fi; sleep 1

CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
	if [ "$CURL" -eq 0 ]; then
		echo -e "${YELLOW}Installing curl${NC}" && apt-get install curl --yes;
	elif [ "$CURL" -eq 1 ]; then
		echo -e "${GREEN}curl	- is installed!${NC}"
	fi; sleep 1
        echo "=====  End Check package   ====="; sleep 1

}

echo -e "${YELLOW}Checking packages...${NC}"
echo -e "List of required packeges: nano, zip, unzip, mc, htop, fail2ban, apache2 & php, mysql, php curl, phpmyadmin, wget, curl"
read -r -p "Do you want to check packeges? [y/N] " response
case $response in
	[yY][eE][sS]|[yY]) CHECking_PACK ;;
	*) echo -e "${RED}Packeges check is ignored! \nSoftware may not be installed! ${NC}" ;;
esac




#-----------------------------------
#   phpmyadmin default path change
#-----------------------------------
function Chang_phpMyAdmin() {
  echo -e "${YELLOW}Changing phpMyAdmin default path from /phpMyAdmin to /phpmyadmin...${NC}"

  cat >/etc/phpmyadmin/apache.conf <<EOL
## phpMyAdmin default Apache configuration

Alias /phpmyadmin /usr/share/phpmyadmin

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

echo -e "${GREEN}Path was succesfully changed/\nNew phpMyAdmin path is: /phpmyadmin (i.e.: yourwebsite.com/phpmyadmin)${NC}"

}

#-----------------------------------

read -r -p "Do you want to change default phpMyAdmin path to /phpMyAdmin? [y/N] " response
echo -e "Default phpMyAdmin path to /phpMyAdmin? [y/N] " && response=y;

case $response in
	[yY][eE][sS]|[yY]) Chang_phpMyAdmin	;;
	*) echo -e "${RED}Path was not changed!${NC}" ;;
esac




#-----------------------------------
#creating user
echo -e "${YELLOW}Adding separate user & creating website home folder for secure running of your website...${NC}"

	#echo -e "${YELLOW}Please, enter new username: ${NC}"
	#read username
	username='www-data'
	groupadd $username
	adduser --home /var/www/$domain --ingroup $username $username
	mkdir /var/www/$domain
	chown -R $username:$username /var/www/$domain
	echo -e "${GREEN}User, group and home folder were succesfully created!
	Username: $username
	Group: $username
	Home folder: /var/www/$domain
	Website folder: /var/www/$domain${NC}"




#-----------------------------------
#     configuring apache2
#-----------------------------------
function CONFIGURE_APACHE() {
echo -e "${YELLOW}Now we going to configure apache2 for your domain name & website root folder...${NC}"

	cat >/etc/apache2/sites-available/$domain.conf <<EOL
	<VirtualHost *:80>
		ServerAdmin $domain_email
		ServerName $domain
		ServerAlias www.$domain
		DocumentRoot /var/www/$domain/
	<Directory />
		Options +FollowSymLinks
		AllowOverride All
	</Directory>

	<Directory /var/www/$domain>
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
	a2ensite $domain
	service apache2 restart
	P_IP="`wget http://ipinfo.io/ip -qO -`"
	echo -e "${GREEN}Apache2 config was updated! \nNew config file was created: /etc/apache2/sites-available/$domain.conf \nDomain was set to: $domain \n Admin email was set to: $domain_email \n Root folder was set to: /var/www/$domain \nOption Indexes was set to: -Indexes (to close directory listing)\nYour server public IP is: $P_IP (Please, set this IP into your domain name 'A' record) \nWebsite was activated & apache2 service reloaded! ${NC}"
}

read -r -p "Do you want to CONFIGURE APACHE2 automatically? [y/N] " response
case $response in
	[yY][eE][sS]|[yY]) CONFIGURE_APACHE ;;
	*) echo -e "\t\t\n${RED}WARNING! \nApache2 was not configured properly, you can do this manually.${NC}" ;;
esac




#-----------------------------------
#downloading WordPress, unpacking, adding basic pack of plugins, creating .htaccess with optimal & secure configuration
echo -e "${YELLOW}On this step we going to download latest version of WordPress with EN or RUS language, set optimal & secure configuration and add basic set of plugins...${NC}"
read -r -p "Do you want to install WordPress & automatically configuration with basic set of plugins? [y/N] " response
case $response in
	[yY][eE][sS]|[yY]) 

while true; do
	echo -e -n "${GREEN}Please, choose WordPress language you need (set RUS or ENG): ${NC}\n\t 1. WordPress language English  [ENG]\n\t 2. WordPress language RUSSION  [RUS]\n\t 3. WordPress language DEFAULT  [ENG]\n\n CHOOSE: ";
	read rsn
	case $rsn in
		[1]* ) wordpress_lang='ENG';echo -e "${YELLOW} WordPress language [English] ${NC}"; break;;
		[2]* ) wordpress_lang='RUS';echo -e "${YELLOW} WordPress language [Russion] ${NC}"; break;;
		[3]* ) wordpress_lang='ENG';echo -e "${YELLOW} Default WordPress language [English] ${NC}"; break;;
		"" ) wordpress_lang='ENG'; echo -e "${YELLOW} WordPress language [English] ${NC}"; break;;
		* ) wordpress_lang='ENG'; echo -e "${YELLOW}Default [ENG] ${NC}";;
	esac
done

	if [ "$wordpress_lang" == 'RUS' ]; then
		wget https://ru.wordpress.org/latest-ru_RU.zip -O /tmp/$wordpress_lang.zip;
	elif [ "$wordpress_lang" == 'ENG' ]; then
		wget https://wordpress.org/latest.zip -O /tmp/$wordpress_lang.zip;
	fi;

	echo -e "Unpacking WordPress into website home directory..."
	sleep 5
	unzip /tmp/$wordpress_lang.zip -d /var/www/$domain/
	mv /var/www/$domain/wordpress/* /var/www/$domain
	rm -rf /var/www/$domain/wordpress
	rm /tmp/$wordpress_lang.zip
	mkdir /var/www/$domain/wp-content/uploads
	chmod -R 777 /var/www/$domain/wp-content/uploads


	echo -e "
--------------------------------------------
Now we going to download some useful plugins:
--------------------------------------------
\t 1. Google XML Sitemap generator
\t 2. Social Networks Auto Poster
\t 3. Add to Any
\t 4. Easy Watermark
--------------------------------------------
";
	sleep 3
	#------------
	SITEMAP="`curl https://wordpress.org/plugins/google-sitemap-generator/ | grep https://downloads.wordpress.org/plugin/google-sitemap-generator.*.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
	wget $SITEMAP -O /tmp/sitemap.zip;
	unzip /tmp/sitemap.zip -d /tmp/sitemap;
	mv /tmp/sitemap/* /var/www/$domain/wp-content/plugins/

	#------------
	wget https://downloads.wordpress.org/plugin/social-networks-auto-poster-facebook-twitter-g.zip -O /tmp/snap.zip
	unzip /tmp/snap.zip -d /tmp/snap
	mv /tmp/snap/* /var/www/$domain/wp-content/plugins/

	#------------
	ADDTOANY="`curl https://wordpress.org/plugins/add-to-any/ | grep https://downloads.wordpress.org/plugin/add-to-any.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
	wget $ADDTOANY -O /tmp/addtoany.zip
	unzip /tmp/addtoany.zip -d /tmp/addtoany
	mv /tmp/addtoany/* /var/www/$domain/wp-content/plugins/

	#------------
	WATERMARK="`curl https://wordpress.org/plugins/easy-watermark/ | grep https://downloads.wordpress.org/plugin/easy-watermark.*.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
	wget $WATERMARK -O /tmp/watermark.zip
	unzip /tmp/watermark.zip -d /tmp/watermark
	mv /tmp/watermark/* /var/www/$domain/wp-content/plugins/

	rm /tmp/sitemap.zip /tmp/snap.zip /tmp/addtoany.zip /tmp/watermark.zip
	rm -rf /tmp/sitemap/ /tmp/snap/ /tmp/addtoany/ /tmp/watermark/
	echo -e "Downloading of plugins finished! All plugins were transfered into /wp-content/plugins directory.${NC}" ;;
	
	*) echo -e "${RED}WordPress and plugins were not downloaded & installed. You can do this manually or re run this script.${NC}" ;;
esac




#-----------------------------------
#        CREATING OF SWAP
#-----------------------------------

function CREATING_SWAP() {
	echo -e "On next step we going to create SWAP (it should be your RAM x2)..."

	RAM="`free -m | grep Mem | awk '{print $2}'`"
	swap_allowed=$(($RAM * 2))
	swap=$swap_allowed"M"
	fallocate -l $swap /var/swap.img
	chmod 600 /var/swap.img
	mkswap /var/swap.img
	swapon /var/swap.img;
	echo -e "${GREEN}\n==========  RAM  ==========\nRAM detected:     $RAM\nSWAP was created: $swap${NC}"
	sleep 5
}


read -r -p "Do you need SWAP? [y/N] " response
case $response in
	[yY][eE][sS]|[yY]) CREATING_SWAP ;;
	*) echo -e "${RED}Swap didn't create for system working.\nYou can do this manually or re run this script.${NC}";;
esac




#-----------------------------------
#   creation of secure .htaccess
#-----------------------------------
echo -e "${YELLOW}Creation of secure .htaccess file...${NC}"
sleep 3
cat >/var/www/$domain/.htaccess <<EOL
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

chmod 644 /var/www/$domain/.htaccess

echo -e "${GREEN}.htaccess file was succesfully created!${NC}"




#-----------------------------------
#      cration of robots.txt
#-----------------------------------
echo -e "${YELLOW}Creation of robots.txt file...${NC}"
sleep 3
cat >/var/www/$domain/robots.txt <<EOL
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

echo -en "${GREEN}File robots.txt was succesfully created! \n Setting correct rights on user's home directory and 755 rights on robots.txt${NC}"
sleep 3
chmod 755 /var/www/$domain/robots.txt



#-----------------------------------
echo -e "${GREEN}Configuring fail2ban...${NC}"
sleep 3
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf-old
cat >/etc/fail2ban/jail.conf <<EOL
[DEFAULT]

ignoreip = 127.0.0.1/8
ignorecommand =
bantime	= 1200
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
enabled	= true
port		 = ssh
filter	 = sshd
logpath	= /var/log/auth.log
maxretry = 5

[ssh-ddos]
enabled	= true
port		 = ssh
filter	 = sshd-ddos
logpath	= /var/log/auth.log
maxretry = 5

[apache-overflows]
enabled	= true
port		 = http,https
filter	 = apache-overflows
logpath	= /var/log/apache*/*error.log
maxretry = 5
EOL

service fail2ban restart

echo -e "${GREEN}fail2ban configuration finished! \n fail2ban service was restarted, default confige backuped at /etc/fail2ban/jail.conf-old \n Jails were set for: ssh bruteforce, ssh ddos, apache overflows${NC}"
sleep 5



#-----------------------------------
echo -e "${GREEN} Configuring apache2 prefork & worker modules...${NC}"
sleep 3
cat >/etc/apache2/mods-available/mpm_prefork.conf <<EOL
<IfModule mpm_prefork_module>
	StartServers			 1
	MinSpareServers			1
	MaxSpareServers		 3
	MaxRequestWorkers		10
	MaxConnectionsPerChild	 3000
</IfModule>
EOL

cat > /etc/apache2/mods-available/mpm_worker.conf <<EOL
<IfModule mpm_worker_module>
	StartServers			 1
	MinSpareThreads		 5
	MaxSpareThreads		 15
	ThreadLimit			 25
	ThreadsPerChild		 5
	MaxRequestWorkers		25
	MaxConnectionsPerChild	 200
</IfModule>
EOL

a2dismod status
echo -e "${GREEN}Configuration of apache mods was succesfully finished! \nRestarting Apache & MySQL services...${NC}"
service apache2 restart
service mysql restart || systemctl restart mysql && systemctl enable mysql
service mysql start && service mysql enable


echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3


echo -e "${GREEN}Adding user & database for WordPress, setting wp-config.php...${NC}"
# echo -e "Please, set username for database: " && read db_user
# echo -e "Please, set password for database user: " && read db_pass

#===============================
# 
# mysql -u root -p <<EOF
# CREATE USER '$db_user'@${Host} IDENTIFIED BY '$db_pass';
# CREATE DATABASE IF NOT EXISTS $db_user;
# GRANT ALL PRIVILEGES ON $db_user.* TO '$db_user'@${Host};
# ALTER DATABASE $db_user CHARACTER SET utf8 COLLATE utf8_general_ci;
# EOF
# 
#===============================

echo "Reusing credentials" && sleep 3
$authorization -e "
CREATE USER 'root'@${Host} IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@${Host} WITH GRANT OPTION;
DROP USER 'root'@'localhost';"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
db_pass=${db_pass} >/dev/null 2>/dev/null
db_pass=${db_pass} > /tmp/${db_pass}
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl \
&& curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /tmp/wp-cli.phar \
&& mv /tmp/wp-cli.phar /usr/local/bin/wp \
&& wp core download --path=/var/www/${domain} --locale=en_US --allow-root \
&& wp config create --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check \
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=alina.m.giese@gmail.com --allow-root --path=/var/www/${domain}

mkdir -p /var/www/$domain/wp-content/uploads
chmod 775 -R /var/www/$domain/ ###wp-content/uploads
chown www-data:www-data -R /var/www/$domain

#----------------------------

cat >/var/www/$domain/wp-config.2.php <<EOL
<?php

define('DB_NAME', '$db_user');
define('DB_USER', '$db_user');
define('DB_PASSWORD', '$db_pass');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

define('AUTH_KEY',				 '$db_user');
define('SECURE_AUTH_KEY',	'$db_user');
define('LOGGED_IN_KEY',		'$db_user');
define('NONCE_KEY',				'$db_user');
define('AUTH_SALT',				'$db_user');
define('SECURE_AUTH_SALT', '$db_user');
define('LOGGED_IN_SALT',	 '$db_user');
define('NONCE_SALT',			 '$db_user');

\$table_prefix	= 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL

chown -R $username:$username /var/www
echo -e "${GREEN}Database user, database and wp-config.php were succesfully created & configured!${NC}"
sleep 3


cat "/var/www/$domain/wp-config.php"

echo "
====================================================
                    INFO
====================================================
Domainame:    ${domain}
DATE:         $( date +%Y-%m-%d_%k%M%S )
DBRootPass:   ${db_pass}
DBName:       ${db_user}
DBUser:       ${dbNameandUser}
DBPass:       ${db_pass}
WPAdmin:      ${wp_admin}
WPPass:       ${wp_pass}
____________________________________________________

         Installation is complete!
		 
====================================================
Connect DB: mysql -h 127.0.0.1 -u root -p${db_pass}
====================================================
" >> /root/.credentials.txt
cat /root/.credentials.txt
echo -e "Installation & configuration succesfully finished."
