require 'spec_helper'

describe Rubykiq do
  describe :client do
    it 'should return a Client' do
      expect(Rubykiq.client).to be_kind_of(Rubykiq::Client)
    end

    it 'should be thread safe' do
      t1 = Thread.new { client = Rubykiq.client; sleep 0.1; client }
      t2 = Thread.new { Rubykiq.client }
      expect(t1.value).to eql t2.value
    end
  end

  describe :connection_pool do
    it 'should return a ConnectionPool' do
      expect(Rubykiq.connection_pool).to be_kind_of(::ConnectionPool)
    end
    it 'should be thread safe' do
      t1 = Thread.new { connection_pool = Rubykiq.connection_pool; sleep 0.1; connection_pool }
      t2 = Thread.new { Rubykiq.connection_pool }
      expect(t1.value).to eql t2.value
    end
  end

  # for every valid option
  Rubykiq::Client::VALID_OPTIONS_KEYS.each do |key|
    describe key do
      subject { Rubykiq }
      it { should respond_to key }
      it { should respond_to "#{key}=".to_sym }
    end
  end
end
