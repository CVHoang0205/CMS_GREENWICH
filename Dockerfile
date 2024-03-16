# Sử dụng hình ảnh PHP-FPM chứa PHP 8 trở lên
FROM php:8-fpm

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Cài đặt Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Thiết lập thư mục làm việc
WORKDIR /var/www/html

# Sao chép mã nguồn Laravel vào hình ảnh
COPY . /var/www/html

# Cài đặt các phụ thuộc PHP bằng Composer
RUN composer install --no-dev --no-scripts

# Tạo khóa ứng dụng (app key)
RUN php artisan key:generate

RUN php artisan migrate --force

# Thiết lập quyền cho các tệp và thư mục Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Sử dụng hình ảnh nginx làm máy chủ web
FROM nginx:alpine

# Sao chép cấu hình Nginx vào hình ảnh
COPY nginx.conf /etc/nginx/nginx.conf

# Sao chép tệp index.html để Nginx có thể sử dụng mặc định
COPY index.html /usr/share/nginx/html

# Expose cổng 80
EXPOSE 80

# Khởi động nginx
CMD ["nginx", "-g", "daemon off;"]
