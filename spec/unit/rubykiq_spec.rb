require "spec_helper"

describe Rubykiq do

  describe :version do
    subject { Rubykiq::VERSION }
    it { should be_kind_of(String) }
  end

  describe :client do
    subject { Rubykiq.client }
    it { should be_kind_of(Rubykiq::Client) }
  end

  describe :connection_pool do
    subject { Rubykiq.connection_pool }
    it { should be_kind_of(::ConnectionPool) }
  end

  # for every valid option
  Rubykiq::Client::VALID_OPTIONS_KEYS.each do |key|

    describe key do
      subject { Rubykiq }
      it {should respond_to key }
      it {should respond_to "#{key}=".to_sym }
    end

  end

end