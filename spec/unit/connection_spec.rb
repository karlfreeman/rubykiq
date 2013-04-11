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

  describe :namespace do

    context :custom do
      subject { Rubykiq::Connection.new(:namespace => "yyyy") }
      its(:namespace) { should eq "yyyy" }
    end

    context :inherited_settings do
      subject {
        Rubykiq.namespace = "xxx"
        Rubykiq.connection
      }
      its(:namespace) { should eq "xxx" }
    end

  end

end