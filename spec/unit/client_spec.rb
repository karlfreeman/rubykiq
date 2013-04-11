require "spec_helper"

describe Rubykiq::Client do

  describe :defaults do
    subject { Rubykiq::Client.new }
    its(:namespace) { should be_nil }
    its(:driver) { should be :ruby }
    its(:retry) { should be_true }
    its(:queue) { should eq "default" }
  end

  describe :push do
    let (:client) { Rubykiq::Client.new }

    context :validations do
    end

    context "with a simple job" do
      # it "should not raise an exception" do
      #   client.push(:class => 'MyWorker', :args => ['foo', 1, :bat => 'bar'])
      # end
    end

  end

end