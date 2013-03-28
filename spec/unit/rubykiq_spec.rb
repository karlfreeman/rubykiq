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

  describe :connection do
    subject { Rubykiq.connection }
    it { should be_kind_of(Rubykiq::Connection) }
  end

end