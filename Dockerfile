FROM amazonlinux:2023

# Apache install
RUN yum update -y && \
    yum install -y httpd

# Copy application files
COPY index.html /var/www/html/

# Expose Apache port
EXPOSE 80

# Start Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]0
