# Bitnami on EC2

## Provisioning
* Log in to your AWS control panel
* Create an instance in your desired location with your desired ssh key from the image: ami-7b9f0b12

## Local SSH configuration
Create a file in ~/.ssh/config
```
Host myserver
  User bitnami
  HostName ec2-XX-XX-XX-XX.compute-1.amazonaws.com/
  IdentityFile ~/.ssh/<ssh-key>
```

## Setup postfix for sending mail
```
ssh myserver 
sudo apt-get install postfix
sudo "$(which postfix)" start
```

## Setup postfix for receiving mail
* Create a subdomain `mail.domain` using an A record to the server's IP
* Create an MX record `1 mail.domain` that points to `mail.domain`

## Deploy the mkapp script
You only have to do this once: `rsync mkapp.sh myserver:mkapp`

## Deploying an app
* Use the mkapp script to scaffold directories and create apache vhost entries  
* Copy over your app's files with rsync  

```
ssh myserver "sudo ./mkapp <domain> [alias1] [alias2]"  # add as many aliases (like www.domain) as you want...  
rsync -auvz local/files/ myserver:apps/appname/htdocs/
```

## Accessing phpMyAdmin
* Create an ssh tunnel `ssh -N -L 9999:127.0.0.1:80 myserver`
* Navigate to localhost:9999/phpmyadmin u: root p: bitnami
