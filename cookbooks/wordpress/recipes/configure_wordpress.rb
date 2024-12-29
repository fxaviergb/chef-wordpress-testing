# Definición de variables comunes
wordpress_path = '/var/www/html/wordpress'
admin_user = 'admin'
admin_password = 'adminpassword'
admin_email = 'fxaviergb@gmail.com'
editor_user = 'jhon_doe'
editor_email = 'jhon_doe@example.com'
editor_password = 'jhon_doepassword'
site_url = 'http://192.168.33.10'

# Descarga WP-CLI
remote_file '/usr/local/bin/wp' do
  source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  mode '0755'
  action :create
end

# Instala WordPress usando WP-CLI
bash 'install_wordpress' do
  cwd wordpress_path
  code <<-EOH
    sudo -u www-data wp core install \
      --url="#{site_url}" \
      --title="Blog Grupal" \
      --admin_user="#{admin_user}" \
      --admin_password="#{admin_password}" \
      --admin_email="#{admin_email}" \
      --path=#{wordpress_path}
  EOH
  not_if "sudo -u www-data wp core is-installed --path=#{wordpress_path}"
end

# Instala y activa el tema ASTRA
bash 'install_and_activate_astra_theme' do
  cwd wordpress_path
  code <<-EOH
    sudo -u www-data wp theme install astra --activate --path=#{wordpress_path}
  EOH
  not_if "sudo -u www-data wp theme list --path=#{wordpress_path} | grep 'astra' | grep 'Active'"
end

# Crea un usuario
bash 'create_wp_user' do
  cwd wordpress_path
  code <<-EOH
    sudo -u www-data wp user create #{editor_user} #{editor_email} \
      --role=editor --user_pass=#{editor_password} --path=#{wordpress_path}
  EOH
  not_if "sudo -u www-data wp user list --path=#{wordpress_path} | grep #{editor_user}"
end

# Crea una nueva categoría "DEVOPS"
bash 'create_devops_category' do
  cwd wordpress_path
  code <<-EOH
    sudo -u www-data wp term create category DEVOPS --path=#{wordpress_path}
  EOH
  not_if "sudo -u www-data wp term list category --path=#{wordpress_path} | grep DEVOPS"
end

# Crea un archivo con contenido HTML para el post
file '/var/www/html/wordpress/post-content.html' do
  content <<-HTML
  <style>
      .container {
          display: flex;
          flex-wrap: wrap;
          background-color: #fff;
          border-radius: 8px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          overflow: hidden;
          margin: 20px auto;
          max-width: 800px;
          padding: 20px;
      }
      .image-container img {
          border-radius: 8px;
          width: 100%;
          max-width: 100%;
          height: auto;
          margin-bottom: 20px;
      }
      .text-container {
          flex: 1;
          padding: 10px;
          color: #333;
      }
      .text-container h1 {
          font-size: 24px;
          color: #f39c12;
          margin-bottom: 15px;
      }
      .text-container ul {
          list-style-type: disc;
          margin-left: 20px;
          line-height: 1.8;
      }
      .back-button {
          margin-top: 20px;
          padding: 10px 20px;
          font-size: 16px;
          color: #fff;
          background-color: #007bff;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          text-decoration: none;
      }
      .back-button:hover {
          background-color: #000000;
          color: #fff;
      }
  </style>
  <div class="container">
      <div class="image-container">
          <img src="https://media.licdn.com/dms/image/v2/C5612AQHwpNrU87Zf1Q/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1614250182636?e=2147483647&v=beta&t=B8Eg6AHSi9khFTC2sjgeRyfVJvQKJ3HQJNY4kyvzuyA" alt="Chef Image">
      </div>
      <div class="text-container">
          <h1>Continuous Configuration Automation to Enforce Desired State at Scale</h1>
          <p>Extend DevOps Value with Cloud-to-Edge Security and Compliance.

          Ensure configurations are applied consistently in every environment with secure infrastructure automation solutions from Chef.</p>
          <br>
              <h1>Infrastructure Management Automation Tools</h1>
          <ul>
              <li>Test Driven Development: Configuration change testing becomes parallel to application change testing.</li>
              <li>AIOps Support: IT operations can confidently scale with data consolidations and 3rd party integrations.</li>
              <li>Self-Service: Agile delivery teams can provision and deploy infrastructure on-demand.</li>
              <li>Infrastructure automation solutions for Multi-OS, multi-cloud, on-prem, hybrid and complex legacy architectures.</li>
          </ul>
          <br>
          <p>Content taken from the <a href="https://www.chef.io/" target="_blank" rel="noopener noreferrer">Chef Official Website</a>. Automated deployment and configuration by: Jhon Doe</p>
          <br>
          <a href="/" class="back-button">Back to Posts</a>
      </div>
  </div>
    HTML
    mode '0644'
    action :create
  end

# Crea un post utilizando el archivo HTML
bash 'create_wp_post_from_file' do
  cwd wordpress_path
  code <<-EOH
    POST_ID=$(sudo -u www-data wp post create #{wordpress_path}/post-content.html \
      --post_title="CHEF: Continuous Configuration Automation" \
      --post_status=publish \
      --post_author=$(sudo -u www-data wp user get #{editor_user} --field=ID --path=#{wordpress_path}) \
      --post_type=post \
      --porcelain --path=#{wordpress_path})
    sudo -u www-data wp post term set $POST_ID category DEVOPS --path=#{wordpress_path}
  EOH
  not_if "sudo -u www-data wp post list --path=#{wordpress_path} | grep 'CHEF: Continuous Configuration Automation'"
end

# Configura la página de inicio para mostrar las publicaciones del blog
bash 'set_homepage_to_blog' do
  cwd wordpress_path
  code <<-EOH
    sudo -u www-data wp option update show_on_front 'posts' --path=#{wordpress_path}
  EOH
end
