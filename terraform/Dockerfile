# Use the official HTTPD (Apache) image as the base
FROM httpd:alpine

# Set the working directory to Apache's default document root
WORKDIR /usr/local/apache2/htdocs/

# Copy the HTML files into the Apache server's document root
COPY ./static/* .

# Expose a different port (8080)
EXPOSE 8080

# Start Apache server in the foreground
CMD ["httpd", "-D", "FOREGROUND"]
