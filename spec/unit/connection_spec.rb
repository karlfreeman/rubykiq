require "spec_helper"

describe Rubykiq::Connection do

  describe :defaults do
    subject { Rubykiq::Connection.new }
    its(:namespace) { should be_nil }
  end

  describe :namespace do

    context :custom do
      subject { Rubykiq::Connection.new(:namespace => "yyyy") }
      its(:namespace) { should eq "yyyy" }
    end

    context :default do
      subject { Rubykiq::Connection.new }
      its(:namespace) { should be_nil }
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