# WordPress Deployment with Chef and Vagrant

This project automates the deployment of a WordPress environment on an Ubuntu-based virtual machine using Vagrant and Chef. The objective is to provide a seamless, reproducible setup for WordPress development or testing.

## Project Structure

The repository includes:

- **Vagrantfile**: Configuration file for setting up the virtual machine.
- **Cookbooks**: Chef recipes and templates for installing and configuring WordPress.
- **Templates**: Configuration files for WordPress (e.g., `wordpress.conf.erb`, `wp-config.php.erb`).
- **Recipes**: Specific Chef scripts for tasks like installing and configuring WordPress.

## Prerequisites

To use this project, ensure your system meets the following requirements:

- **Vagrant**: Installed on your local machine. [Download Vagrant](https://www.vagrantup.com/downloads).
- **VirtualBox**: Installed as the default provider for Vagrant. [Download VirtualBox](https://www.virtualbox.org/).
- **ChefDK** (optional): Installed if you want to customize the recipes. [Download ChefDK](https://downloads.chef.io/chefdk).

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd chef-vagrant-wordpress
   ```

2. **Start the Virtual Machine**
   Run the following command to spin up the virtual machine:
   ```bash
   vagrant up
   ```
   This command will:
   - Download the base Ubuntu image (if not already available).
   - Provision the virtual machine using Chef recipes to install and configure WordPress.

3. **Access the Virtual Machine**
   Once the VM is up, you can access it via SSH:
   ```bash
   vagrant ssh
   ```

## Verifying the Setup

1. **WordPress Access**
   - Open a browser on your host machine.
   - Navigate to `http://192.168.33.10` (or the port specified in the `Vagrantfile`).

2. **Login Details**
   - Default WordPress admin credentials are set during provisioning. Refer to the `wp-config.php.erb` template for details or customize it before provisioning.

## Customization

To customize the setup:
- Modify the `Vagrantfile` to adjust virtual machine settings (e.g., memory, CPU).
- Edit the Chef recipes in the `cookbooks/wordpress/recipes` directory.
- Update templates in the `cookbooks/wordpress/templates` directory for WordPress configuration.

## Troubleshooting

- If the provisioning fails, retry with:
  ```bash
  vagrant provision
  ```
- To destroy and recreate the VM, use:
  ```bash
  vagrant destroy -f
  vagrant up
  ```
## Unit Tests

### Location of Unit Tests
- The unit tests are located in the `spec` directory under the cookbook `wordpress`:
  ```
  cookbooks/wordpress/spec/
  ```
- The primary test file is `default_spec.rb`.
- The additional recipes are included in unit tests too: `configure_wordpress_spec.rb` and `install_wordpress_spec.rb`.

### Running the Tests
To run the unit tests, follow these steps:
1. Ensure you have ChefDK or Chef Workstation installed.
2. Navigate to the cookbook directory:
   ```bash
   cd cookbooks/wordpress
   ```
3. Run the tests using the following command:
   ```bash
   chef exec rspec spec
   ```
4. If the tests pass, you should see output indicating all examples succeeded:
   ```
   Finished in 0.1234 seconds
   8 examples, 0 failures
   ```

### What the Tests Validate
- The unit tests verify:
  1. The `apache2`, `php` and `mysql-server` packages are installed.
  2. The `wordpress` package is installed.
  3. The bash commands to configure Wordpress are defined and configured correctly.

## Integration Testing with Kitchen

The project uses Test Kitchen to automate and verify the configuration of the WordPress environment. The following briefly outlines the Kitchen setup and steps to run the integration tests:

### Kitchen Configuration

- **Driver**: Vagrant is used as the virtualization provider.
- **Provisioner**: Chef Zero is employed to apply the Chef cookbooks.
- **Platforms**: The tests run on Ubuntu 22.04.
- **Suites**: The default suite applies the `wordpress::default` recipe and runs integration tests located in:
  - `test/integration/default/wordpress_install_test.rb`
  - `test/integration/default/wordpress_site_test.rb`

### Steps to Execute Integration Tests

1. **Create the Test Environment**:
   Create the virtual machine and apply the configuration:
   ```bash
   kitchen create
   kitchen converge
   ```

2. **Run the Integration Tests**:
   Execute the tests:
   ```bash
   kitchen verify
   ```

3. **Clean Up**:
   Destroy the test environment when done:
   ```bash
   kitchen destroy
   ```

4. **Debugging** (if needed):
   - Connect to the test environment:
     ```bash
     kitchen login
     ```
   - Check the logs in `.kitchen/logs` for more details.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
