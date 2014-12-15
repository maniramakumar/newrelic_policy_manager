require 'spec_helper'

describe file('/usr/local/bin/delete_stopped') do

  context "permissions" do
    it { should be_mode 744 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  context "inclusions" do
    its(:content) { should match 'asdfasdfasdfasdfasdfasdf' }
  end
end

describe cron do 
  it { should have_entry("0 0 * * 0 bundle exec /usr/local/bin/delete_stopped").with_user('root') }
end