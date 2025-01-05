# inspec.rb
title 'Apache2 Installation Test'

describe package('apache2') do
  it { should be_installed }
end