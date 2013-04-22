require "spec_helper"

describe Rubykiq::Connection do

  describe :defaults do
    subject { Rubykiq::Connection.new }
    its(:namespace) { should be_nil }
    its(:host) { should eq "localhost" }
    its(:port) { should be 6379 }
    its(:db) { should be 0 }
    its(:password) { should be_nil }
  end

  describe :options do

    context :custom do
      subject { Rubykiq::Connection.new(:namespace => "yyy") }
      its(:namespace) { should eq "yyy" }
    end

    context :inherited_settings do
      it "should work" do
        client = Rubykiq::Client.new(:namespace => "xxx")
        client.connection_pool do |connection|
          expect(connection.namespace).to eq "xxx"
        end
      end
    end

  end

  describe :env do
    subject { Rubykiq::Connection.new }

    [{:name => "REDISTOGO_URL", :value => "redistogo"}, {:name => "REDIS_PROVIDER", :value => "redisprovider"}, {:name => "REDIS_URL", :value => "redisurl"} ].each do | test_case |
      context "with ENV[#{test_case[:name]}]" do
        before do
          ENV[test_case[:name]] = "redis://#{test_case[:value]}:6379/0"
        end
        after do
          ENV[test_case[:name]] = nil
        end
        its(:host) { should eq test_case[:value] }
      end
    end

  end

end