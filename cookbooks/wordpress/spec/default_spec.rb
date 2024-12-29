require 'chefspec'

describe 'wordpress::default' do
  # Especificar el entorno simulado.
  platform 'ubuntu', '22.04'

  # Simular comandos de shell utilizados en la receta. Ayuda a que las llamadas a "not_if" 
  # evaluen las pre-condiciones como falsas para que Chef pueda ejecutar los comandos.
  before do
    # Simula que no aún no existe la base de datos 'wordpress'.
    stub_command("mysql -uroot -e 'SHOW DATABASES;' | grep wordpress").and_return(false)
    # Simula que no aún no se instala Wordpress.
    stub_command("sudo -u www-data wp core is-installed --path=/var/www/html/wordpress").and_return(false)
    # Simula que no aún no se activa el tema.
    stub_command("sudo -u www-data wp theme list --path=/var/www/html/wordpress | grep 'astra' | grep 'Active'").and_return(false)
    # Simula que no aún no se crea el usuario.
    stub_command("sudo -u www-data wp user list --path=/var/www/html/wordpress | grep jhon_doe").and_return(false)
    # Simula que no aún no se crea la categoría.
    stub_command("sudo -u www-data wp term list category --path=/var/www/html/wordpress | grep DEVOPS").and_return(false)
    # Simula que no aún no se crea el post.
    stub_command("sudo -u www-data wp post list --path=/var/www/html/wordpress | grep 'CHEF: Continuous Configuration Automation'").and_return(false)
  end

  # Verifica que la receta principal incluye la receta 'install_wordpress'.
  it 'includes the install_wordpress recipe' do
    expect(chef_run).to include_recipe('wordpress::install_wordpress')
  end

  # Verifica que la receta principal incluye la receta 'configure_wordpress'.
  it 'includes the configure_wordpress recipe' do
   expect(chef_run).to include_recipe('wordpress::configure_wordpress')
  end
end
