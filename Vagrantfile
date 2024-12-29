# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuración principal de Vagrant
Vagrant.configure("2") do |config|

  # Especifica la box base
  # La máquina virtual utilizará Ubuntu 22.04 (Jammy Jellyfish) como sistema operativo base.
  config.vm.box = "bento/ubuntu-22.04"

  # Configuración de red
  # Redirección de puertos: El puerto 80 en la máquina virtual se expone como el puerto 8080 en el host.
  config.vm.network "forwarded_port", guest: 80, host: 8080

  
  # Red privada: La máquina virtual se asigna a una red privada con la IP estática 192.168.33.40.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Configuración específica del proveedor VirtualBox
  config.vm.provider "virtualbox" do |vb|
    # Habilitar GUI (descomentando la línea) para mostrar la ventana de VirtualBox al iniciar la VM.
    # vb.gui = true
    
    # Configura la cantidad de memoria RAM asignada a la máquina virtual.
    vb.memory = "1024"
    vb.cpus = 2
  end
  
  # Provisión con un script de shell
  # Actualiza los repositorios del sistema e instala Chef utilizando un script Bash en línea.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    curl -L https://chef.io/chef/install.sh | sudo bash
  SHELL

  # Provisión con Chef Solo
  # Configura la máquina virtual utilizando Chef Solo para instalar y configurar Apache.
  config.vm.provision :chef_solo do |chef|
    # Especifica la ruta local donde se encuentran los cookbooks.
    chef.cookbooks_path = "cookbooks"
    
    # Añade la receta "wordpress" a la lista de ejecución.
    chef.add_recipe "wordpress"
    
    # Acepta automáticamente la licencia de Chef.
    chef.arguments = "--chef-license accept"
    
    # No instala Chef, ya que ya se instaló mediante el script de shell.
    chef.install = false
  end

end
