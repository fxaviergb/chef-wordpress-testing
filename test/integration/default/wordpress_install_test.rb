# inspec.rb
title 'WordPress Installation Test'

control 'wordpress_installation' do
  impact 1.0
  title 'Ensure WordPress is installed correctly'

  describe file('/var/www/html/wordpress/wp-config.php') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0755' }
  end

end