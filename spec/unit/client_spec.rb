require "spec_helper"

describe Rubykiq::Client do

  describe :defaults do
    subject { Rubykiq::Client.new }
    its(:namespace) { should be_nil }
    its(:driver) { should be :ruby }
  end

  describe :push do

    let (:client) { Rubykiq::Client.new }

  end

end