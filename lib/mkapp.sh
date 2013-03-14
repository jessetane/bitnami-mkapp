#!/usr/bin/env bash
#
# mkapp.sh - scaffold up a new app for bitnami
#

mkapp() {
  
  # settings
  local STACK="/opt/bitnami"
  
  # vars
  local app="$1"
  local names=("$@")
  local home="$STACK"/apps/"$app"
  
  # sanity checks
  [ "$(whoami)" != "root" ] && echo "you must be root (sudo)" >&2 && return 1
  [ -z "$app" ] && echo "please specify an app name" >&2 && return 1
  [ -d "$home" ] && echo "cannot create $app: app exists" >&2 && return 1
  
  # do stuff
  __mkapp_create_dirs || return 1
  __mkapp_create_vhosts || return 1
  __mkapp_link_vhosts || return 1
  __mkapp_chown_app || return 1
  __mkapp_reload_apache || return 1
}

__mkapp_create_dirs() {
  mkdir -p "$home"/conf
  mkdir -p "$home"/htdocs
}

__mkapp_create_vhosts() {
  for name in "${names[@]}"
  do
    echo "<VirtualHost *:*>
  DocumentRoot $home/htdocs
  ServerName $name
  <Directory $home/htdocs>
    Options +FollowSymLinks
    AllowOverride All
    <IfVersion < 2.3 >
      Order allow,deny
      Allow from all
    </IfVersion>
    <IfVersion >= 2.3>
      Require all granted
    </IfVersion>
  </Directory>
</VirtualHost>" >> "$home"/conf/httpd.conf
  done
}

__mkapp_link_vhosts() {
  echo -e "Include \"$home/conf/httpd.conf\"" >> "$STACK"/apache2/conf/httpd.conf
}

__mkapp_chown_app() {
  chown -R bitnami:bitnami "$home"
}

__mkapp_reload_apache() {
  "$STACK"/ctlscript.sh restart apache
}
