# Llama a la receta que instala WordPress
include_recipe 'wordpress::install_wordpress'

# Llama a la receta que configura WordPress con WP-CLI
include_recipe 'wordpress::configure_wordpress'
