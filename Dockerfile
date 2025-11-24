# Start from Ubuntu base image
FROM ubuntu:22.04

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install required packages
RUN apt-get update && \
    apt-get install -y nginx php-fpm php-mysql php-cli php-curl php-zip php-mbstring php-xml php-gd git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Configure Nginx ---
RUN rm /etc/nginx/sites-enabled/default

# Add custom Nginx config file (direct inline config)
RUN echo 'server { \
    listen 80; \
    root /var/www/html; \
    index index.php index.html; \
    server_name _; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    location ~ \.php$ { \
        include snippets/fastcgi-php.conf; \
        fastcgi_pass unix:/run/php/php-fpm.sock; \
    } \
    }' > /etc/nginx/sites-available/default && \
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# --- Clone your Git repository ---
# Replace the below URL with your actual PHP app repo (public or with access token)
#ARG GIT_REPO=https://github.com/example-user/my-php-app.git

# Clone the repo into the web root
#RUN git clone https://github.com/rvmint/nginxapp.git /var/www/html

# Remove default nginx content and clone repo
RUN rm -rf /var/www/html && \
    git clone https://github.com/rvmint/nginxapp.git /var/www/html

# (Optional) Set proper file permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 for HTTP
EXPOSE 80

# Start both PHP-FPM and Nginx when container runs
#CMD service php*-fpm start && nginx -g 'daemon off;'

CMD ["bash", "-c", "service php8.1-fpm start && nginx -g 'daemon off;'"]