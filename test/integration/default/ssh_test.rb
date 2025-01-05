# inspec.rb
title 'SSH Accessibility Test'

control 'ssh_service' do
  impact 1.0
  title 'Ensure SSH service is running'

  describe service('ssh') do
    it { should be_running }
    it { should be_enabled }
  end
end

control 'ssh_port' do
  impact 1.0
  title 'Ensure SSH port is open'

  describe port(22) do
    it { should be_listening }
  end
end
