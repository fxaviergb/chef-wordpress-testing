require 'chefspec'
require 'chefspec/berkshelf'

describe 'wordpress::default' do
  before do
    stub_command("mysql -uroot -e 'SHOW DATABASES;' | grep wordpress").and_return(false)
    stub_command("sudo -u www-data wp core is-installed --path=/var/www/html/wordpress").and_return(false)
    stub_command("sudo -u www-data wp theme list --path=/var/www/html/wordpress | grep 'astra' | grep 'Active'").and_return(false)
    stub_command("sudo -u www-data wp user list --path=/var/www/html/wordpress | grep jhon_doe").and_return(false)
    stub_command("sudo -u www-data wp term list category --path=/var/www/html/wordpress | grep DEVOPS").and_return(false)
    stub_command("sudo -u www-data wp post list --path=/var/www/html/wordpress | grep 'CHEF: Continuous Configuration Automation'").and_return(false)
  end

  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  # 1. Llama a la receta que instala WordPress
  # Este caso de prueba verifica que la receta 'wordpress::install_wordpress' se incluye en la receta 'default'.
  it 'includes the install_wordpress recipe' do
    expect(chef_run).to include_recipe('wordpress::install_wordpress')
  end

  # 2. Llama a la receta que configura WordPress con WP-CLI
  # Este caso de prueba verifica que la receta 'wordpress::configure_wordpress' se incluye en la receta 'default'.
  it 'includes the configure_wordpress recipe' do
    expect(chef_run).to include_recipe('wordpress::configure_wordpress')
  end
end
