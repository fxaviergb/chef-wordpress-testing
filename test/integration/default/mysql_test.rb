# inspec.rb
title 'MySQL Installation Test'

control 'mysql_service' do
  impact 1.0
  title 'Ensure MySQL service is running'

  describe service('mysql') do
    it { should be_running }
    it { should be_enabled }
  end
end
