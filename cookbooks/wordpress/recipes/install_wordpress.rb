# Actualiza el sistema
execute 'update_apt' do
  command 'apt update -y'
end

# Instala paquetes necesarios
%w( apache2 mysql-server php php-mysql libapache2-mod-php curl unzip ).each do |pkg|
  package pkg do
    action :install
  end
end

# Habilita y arranca Apache
service 'apache2' do
  supports :status => true
  action :nothing
end

# Configura MySQL y crea la base de datos para WordPress
bash 'setup_mysql' do
  code <<-EOH
    mysql -uroot -e "CREATE DATABASE wordpress;"
    mysql -uroot -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
    mysql -uroot -e "FLUSH PRIVILEGES;"
  EOH
  action :run
  not_if "mysql -uroot -e 'SHOW DATABASES;' | grep wordpress"
end

# Descarga WordPress
remote_file '/tmp/latest.tar.gz' do
  source 'https://wordpress.org/latest.tar.gz'
  action :create
end

# Extrae WordPress
bash 'extract_wordpress' do
  cwd '/tmp'
  code <<-EOH
    mkdir -p /var/www/html/wordpress
    tar -xzf latest.tar.gz
    mv wordpress/* /var/www/html/wordpress/
  EOH
  not_if { ::File.exist?('/var/www/html/wordpress/wp-config.php') }
end

# Configura WordPress
template '/var/www/html/wordpress/wp-config.php' do
  source 'wp-config.php.erb'
  variables(
    db_name: 'wordpress',
    db_user: 'wpuser',
    db_password: 'wppassword',
    db_host: 'localhost'
  )
end

# Cambia permisos
bash 'set_permissions' do
  code <<-EOH
    chown -R www-data:www-data /var/www/html/wordpress
    chmod -R 755 /var/www/html/wordpress
  EOH
end

# Deshabilita el sitio por defecto de Apache
execute 'disable_default_site' do
  command 'a2dissite 000-default.conf'
  action :run
  notifies :restart, resources(:service => "apache2")
end

# Crea el archivo de configuración para el sitio de WordPress
template '/etc/apache2/sites-available/wordpress.conf' do
  source 'wordpress.conf.erb'
  notifies :restart, resources(:service => "apache2")
end

# Habilita el sitio de WordPress
execute 'enable_wordpress_site' do
  command 'a2ensite wordpress.conf'
  action :run
  notifies :restart, resources(:service => "apache2")
end

# Habilita el módulo de reescritura de Apache
execute 'enable_rewrite_module' do
  command 'a2enmod rewrite'
  action :run
  notifies :restart, resources(:service => "apache2")
end

# Recarga Apache para asegurarse de que todos los cambios se aplican
service 'apache2' do
  action [:enable, :reload]
end