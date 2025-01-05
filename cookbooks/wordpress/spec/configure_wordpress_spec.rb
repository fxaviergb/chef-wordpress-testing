require 'chefspec'
require 'chefspec/berkshelf'

describe 'wordpress::configure_wordpress' do
  before do
    stub_command("sudo -u www-data wp core is-installed --path=/var/www/html/wordpress").and_return(false)
    stub_command("sudo -u www-data wp theme list --path=/var/www/html/wordpress | grep 'astra' | grep 'Active'").and_return(false)
    stub_command("sudo -u www-data wp user list --path=/var/www/html/wordpress | grep jhon_doe").and_return(false)
    stub_command("sudo -u www-data wp term list category --path=/var/www/html/wordpress | grep DEVOPS").and_return(false)
    stub_command("sudo -u www-data wp post list --path=/var/www/html/wordpress | grep 'CHEF: Continuous Configuration Automation'").and_return(false)
  end

  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  # 1. Descarga WP-CLI
  # Este caso de prueba verifica que WP-CLI se descarga en /usr/local/bin/wp con los permisos correctos.
  it 'downloads WP-CLI' do
    expect(chef_run).to create_remote_file('/usr/local/bin/wp').with(
      source: 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar',
      mode: '0755'
    )
  end

  # 2. Instala WordPress usando WP-CLI
  # Este caso de prueba verifica que WordPress se instala usando WP-CLI.
  it 'installs WordPress using WP-CLI' do
    expect(chef_run).to run_bash('install_wordpress').with(
      code: /wp core install/
    )
  end

  # 3. Instala y activa el tema ASTRA
  # Este caso de prueba verifica que el tema ASTRA se instala y se activa usando WP-CLI.
  it 'installs and activates ASTRA theme' do
    expect(chef_run).to run_bash('install_and_activate_astra_theme').with(
      code: /wp theme install astra --activate/
    )
  end

  # 4. Crea un usuario
  # Este caso de prueba verifica que se crea un usuario de WordPress usando WP-CLI.
  it 'creates a WordPress user' do
    expect(chef_run).to run_bash('create_wp_user').with(
      code: /wp user create/
    )
  end

  # 5. Crea una nueva categoría "DEVOPS"
  # Este caso de prueba verifica que se crea una nueva categoría "DEVOPS" en WordPress usando WP-CLI.
  it 'creates a DEVOPS category' do
    expect(chef_run).to run_bash('create_devops_category').with(
      code: /wp term create category DEVOPS/
    )
  end

  # 6. Crea un archivo con contenido HTML para el post
  # Este caso de prueba verifica que se crea un archivo HTML con el contenido del post en /var/www/html/wordpress/post-content.html.
  it 'creates an HTML file for the post content' do
    expect(chef_run).to create_file('/var/www/html/wordpress/post-content.html').with(
      mode: '0644'
    )
  end

  # 7. Crea un post utilizando el archivo HTML
  # Este caso de prueba verifica que se crea un post en WordPress utilizando el archivo HTML.
  it 'creates a WordPress post from the HTML file' do
    expect(chef_run).to run_bash('create_wp_post_from_file').with(
      code: /wp post create/
    )
  end

  # 8. Configura la página de inicio para mostrar las publicaciones del blog
  # Este caso de prueba verifica que la página de inicio se configura para mostrar las publicaciones del blog.
  it 'sets the homepage to display blog posts' do
    expect(chef_run).to run_bash('set_homepage_to_blog').with(
      code: /wp option update show_on_front 'posts'/
    )
  end
end
