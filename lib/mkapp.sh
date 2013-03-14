#!/usr/bin/env bash
#
# mkapp.sh - scaffold up a new app for bitnami
#

mkapp() {
  
  # own dir
  cd "$(dirname "$BASH_SOURCE")"
  
  # settings
  STACK="/opt/bitnami"
  
  # vars
  app="$1"
  names=("$@")
  home="$STACK"/apps/"$app"
  
  # dep
  source argue/0.0.1/lib/argue.sh
  
  # options
  args=("$@")
  argue "-d, --delete" || return 1
  
  # sanity checks
  [ -z "$app" ] && echo "please specify an app name" >&2 && return 1
  
  if [ -z "${opts[0]}" ]
  then
    
    # sanity
    [ -d "$home" ] && echo "cannot create $app: app exists" >&2 && return 1
  
    # create stuff
    __mkapp_create_dirs || return 1
    __mkapp_create_vhosts || return 1
    __mkapp_link_vhosts || return 1
    __mkapp_chown_app || return 1
    __mkapp_reload_apache || return 1
  else
    
    # delete stuff
    __mkapp_unlink_vhosts || return 1
    __mkapp_delete_app || return 1
    __mkapp_reload_apache || return 1
  fi
}

__mkapp_create_dirs() {
  sudo mkdir -p "$home"/conf
  sudo mkdir -p "$home"/htdocs
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
</VirtualHost>" | sudo tee -a "$home"/conf/httpd.conf > /dev/null
  done
}

__mkapp_link_vhosts() {
  echo -e "Include \"$home/conf/httpd.conf\"" | sudo tee -a "$STACK"/apache2/conf/httpd.conf > /dev/null
}

__mkapp_unlink_vhosts() {
  line="$(cat "$STACK"/apache2/conf/httpd.conf | grep -n "Include \"$home/conf/httpd.conf\"" | sed "s/\(.*\):Include.*/\1/")"
  [ -n "$line" ] && sed -i "${line}d;" "$STACK"/apache2/conf/httpd.conf
}

__mkapp_chown_app() {
  sudo chown -R bitnami:bitnami "$home"
}

__mkapp_delete_app() {
  sudo rm -rf "$home"
}

__mkapp_reload_apache() {
  sudo "$STACK"/ctlscript.sh restart apache
}
