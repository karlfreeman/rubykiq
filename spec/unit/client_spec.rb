require "spec_helper"

describe Rubykiq::Client do

  before(:all) do
    Timecop.freeze
  end

  after(:all) do
    Timecop.return
  end

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

      context "with an incorrect message type" do
        it "raises an ArgumentError" do
          expect{ client.push([]) }.to raise_error(ArgumentError, /Message must be a Hash/)
          expect{ client.push("{}") }.to raise_error(ArgumentError, /Message must be a Hash/)
          expect{ client.push(DummyClass.new) }.to raise_error(ArgumentError, /Message must be a Hash/)
        end
      end

      context "without a class" do
        it "raises an ArgumentError" do
          expect{ client.push(:args => ['foo', 1, { :bat => "bar" }]) }.to raise_error(ArgumentError, /Message must include a class/)
        end
      end

      context "with an incorrect args type" do
        it "raises an ArgumentError" do
          expect{ client.push(:class => "MyWorker", :args => { :bat => "bar" }) }.to raise_error(ArgumentError, /Message args must be an Array/)
        end
      end

      context "with an incorrect class type" do
        it "raises an ArgumentError" do
          expect{ client.push(:class => DummyClass, :args => ["foo", 1, { :bat => "bar" }]) }.to raise_error(ArgumentError, /Message class must be a String representation of the class name/)
        end
      end

    end

    # eg singular and batch
    args = [[{:bat => "bar"}],[[{:bat => "bar"}],[{:bat => "foo"}]]]
    args.each do |args|

      context "with args #{args}" do

        before(:each) do
          Rubykiq.connection_pool do |connection|
            connection.flushdb
          end
        end

        it "should create #{args.length} job(s)" do
          expect { client.push(:class => "MyWorker", :args => args) }.to change { Rubykiq.connection_pool do |connection| connection.llen("queue:default"); end }.from(0).to(args.length)
          raw_jobs = Rubykiq.connection_pool do |connection| connection.lrange("queue:default", 0, args.length); end
          raw_jobs.each do |job|
            job = MultiJson.decode(job, :symbolize_keys => true)  
            expect(job).to have_key(:jid)
          end
        end

        # eg with a variety of different time types
        times = [ Time.now, DateTime.now, Time.now.utc.iso8601, Time.now.to_f ]
        times.each do |time|

          context "with time #{time} ( #{time.class} )" do

            it "should create #{args.length} job(s)" do
              expect { client.push(:class => "MyWorker", :args => args, :at => time) }.to change { Rubykiq.connection_pool do |connection| connection.zcard("schedule"); end }.from(0).to(args.length)
              raw_jobs = Rubykiq.connection_pool do |connection| connection.zrange("schedule", 0, args.length); end
              raw_jobs.each do |job|
                job = MultiJson.decode(job, :symbolize_keys => true)  
                expect(job).to have_key(:at)
                expect(job[:at]).to be_within(1).of(Time.now.to_f)
              end
              
            end

          end

        end

      end

    end

  end

end