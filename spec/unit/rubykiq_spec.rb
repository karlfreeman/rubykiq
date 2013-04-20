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

end