# inspec.rb
title 'WordPress HTTP Response Test'

control 'wordpress_http_response' do
  impact 1.0
  title 'Ensure WordPress is serving the correct content'

  describe command('curl http://localhost') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /WordPress/ }
  end
end