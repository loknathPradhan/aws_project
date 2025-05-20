#!/bin/bash -xe

# Update and install NGINX
until apt-get update -y; do echo "Retrying apt-get update..."; sleep 5; done
apt-get install -y nginx

# Start and enable NGINX
systemctl start nginx
systemctl enable nginx

# Replace the default index.html
echo '<h1>Hello from Auto Scaling Group on Ubuntu!</h1>' > /var/www/html/index.html
