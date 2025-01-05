require 'chefspec'
require 'chefspec/berkshelf'

describe 'wordpress::install_wordpress' do
  before do
    stub_command("mysql -uroot -e 'SHOW DATABASES;' | grep wordpress").and_return(false)
  end

  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  # 1. Actualiza apt
  # Este caso de prueba verifica que el recurso execute 'update_apt' ejecuta el comando 'apt update -y'.
  it 'updates apt' do
    expect(chef_run).to run_execute('update_apt').with(command: 'apt update -y')
  end

  # 2. Instala paquetes necesarios
  # Este caso de prueba verifica que los paquetes necesarios (apache2, mysql-server, php, php-mysql, libapache2-mod-php, curl, unzip) se instalan.
  it 'installs necessary packages' do
    %w( apache2 mysql-server php php-mysql libapache2-mod-php curl unzip ).each do |pkg|
      expect(chef_run).to install_package(pkg)
    end
  end

  # 3. Habilita y arranca el servicio apache2
  # Este caso de prueba verifica que el servicio apache2 está habilitado y recargado.
  it 'enables and starts apache2 service' do
    expect(chef_run).to enable_service('apache2')
    expect(chef_run).to reload_service('apache2')
  end

  # 4. Configura la base de datos MySQL para WordPress
  # Este caso de prueba verifica que el recurso bash 'setup_mysql' se ejecuta para configurar la base de datos MySQL para WordPress.
  it 'sets up MySQL database for WordPress' do
    expect(chef_run).to run_bash('setup_mysql')
  end

  # 5. Descarga WordPress
  # Este caso de prueba verifica que el archivo tar de WordPress se descarga en /tmp/latest.tar.gz.
  it 'downloads WordPress' do
    expect(chef_run).to create_remote_file('/tmp/latest.tar.gz').with(source: 'https://wordpress.org/latest.tar.gz')
  end

  # 6. Extrae WordPress
  # Este caso de prueba verifica que el archivo tar de WordPress se extrae en /var/www/html/wordpress.
  it 'extracts WordPress' do
    expect(chef_run).to run_bash('extract_wordpress')
  end

  # 7. Configura WordPress
  # Este caso de prueba verifica que se crea la plantilla wp-config.php con la configuración correcta de la base de datos.
  it 'configures WordPress' do
    expect(chef_run).to create_template('/var/www/html/wordpress/wp-config.php').with(
      source: 'wp-config.php.erb',
      variables: {
        db_name: 'wordpress',
        db_user: 'wpuser',
        db_password: 'wppassword',
        db_host: 'localhost'
      }
    )
  end

  # 8. Cambia permisos del directorio de WordPress
  # Este caso de prueba verifica que se cambian los permisos del directorio de WordPress correctamente.
  it 'sets permissions for WordPress directory' do
    expect(chef_run).to run_bash('set_permissions')
  end

  # 9. Deshabilita el sitio por defecto de Apache
  # Este caso de prueba verifica que se deshabilita el sitio por defecto de Apache.
  it 'disables default Apache site' do
    expect(chef_run).to run_execute('disable_default_site').with(command: 'a2dissite 000-default.conf')
  end

  # 10. Crea la configuración del sitio de WordPress
  # Este caso de prueba verifica que se crea la configuración de Apache para el sitio de WordPress.
  it 'creates WordPress site configuration' do
    expect(chef_run).to create_template('/etc/apache2/sites-available/wordpress.conf').with(source: 'wordpress.conf.erb')
  end

  # 11. Habilita el sitio de WordPress
  # Este caso de prueba verifica que se habilita el sitio de WordPress en Apache.
  it 'enables WordPress site' do
    expect(chef_run).to run_execute('enable_wordpress_site').with(command: 'a2ensite wordpress.conf')
  end

  # 12. Habilita el módulo de reescritura de Apache
  # Este caso de prueba verifica que se habilita el módulo de reescritura de Apache.
  it 'enables Apache rewrite module' do
    expect(chef_run).to run_execute('enable_rewrite_module').with(command: 'a2enmod rewrite')
  end
end
