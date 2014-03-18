require 'spec_helper'
require 'hiredis'
require 'em-synchrony'

describe Rubykiq::Client do
  before(:all) { Timecop.freeze }
  after(:all) { Timecop.return }
  let(:ruby_client) { Rubykiq::Client.new(driver: :ruby, namespace: :ruby) }
  let(:hiredis_client) { Rubykiq::Client.new(driver: :hiredis, namespace: :hiredis) }
  let(:synchrony_client) { Rubykiq::Client.new(driver: :synchrony, namespace: :synchrony) }

  # eg with a variety of drivers
  [:ruby, :hiredis, :synchrony].each do |driver|
    # skip incompatible drivers when running in JRuby
    next if jruby? && (driver == :hiredis || :synchrony)
    context "using driver '#{driver}'" do
      # make sure the let is the current client being tested
      let(:client) { send("#{driver}_client") }
      describe :defaults do
        subject { client }
        its(:namespace) { should eq driver }
        its(:driver) { should be driver }
        its(:retry) { should be_true }
        its(:queue) { should eq 'default' }
      end

      describe :push do
        context :validations do
          context 'with an incorrect message type' do
            it 'raises an ArgumentError' do
              expect { client.push([]) }.to raise_error(ArgumentError, /Message must be a Hash/)
              expect { client.push('{}') }.to raise_error(ArgumentError, /Message must be a Hash/)
              expect { client.push(Class.new) }.to raise_error(ArgumentError, /Message must be a Hash/)
            end
          end

          context 'without a class' do
            it 'raises an ArgumentError' do
              expect { client.push(args: ['foo', 1, { bat: 'bar' }]) }.to raise_error(ArgumentError, /Message must include a class/)
            end
          end

          context 'with an incorrect args type' do
            it 'raises an ArgumentError' do
              expect { client.push(class: 'MyWorker', args: { bat: 'bar' }) }.to raise_error(ArgumentError, /Message args must be an Array/)
            end
          end

          context 'with an incorrect class type' do
            it 'raises an ArgumentError' do
              expect { client.push(class: Class, args: ['foo', 1, { bat: 'bar' }]) }.to raise_error(ArgumentError, /Message class must be a String representation of the class name/)
            end
          end
        end

        # eg singular and batch
        arguments = [[{ bat: 'bar' }], [[{ bat: 'bar' }], [{ bat: 'foo' }]]]
        arguments.each do |args|
          context "with args #{args}" do
            it "should create #{args.length} job(s)" do
              wrap_in_synchrony?(driver) do
                client.connection_pool do |connection|
                  connection.flushdb
                end

                expect { client.push(class: 'MyWorker', args: args) }.to change {
                  client.connection_pool do |connection| connection.llen('queue:default'); end
                }.from(0).to(args.length)

                raw_jobs = client.connection_pool do |connection| connection.lrange('queue:default', 0, args.length); end
                raw_jobs.each do |job|
                  job = MultiJson.decode(job, symbolize_keys: true)
                  expect(job).to have_key(:jid)
                end
              end
            end

            # eg with a variety of different time types
            times = [Time.now, DateTime.now, Time.now.utc.iso8601, Time.now.to_f]
            times.each do |time|
              context "with time #{time} (#{time.class})" do
                it "should create #{args.length} job(s)" do
                  wrap_in_synchrony?(driver) do
                    client.connection_pool do |connection|
                      connection.flushdb
                    end

                    expect { client.push(class: 'MyWorker', args: args, at: time) }.to change {
                      client.connection_pool do |connection| connection.zcard('schedule'); end
                    }.from(0).to(args.length)

                    raw_jobs = client.connection_pool do |connection| connection.zrange('schedule', 0, args.length); end
                    raw_jobs.each do |job|
                      job = MultiJson.decode(job, symbolize_keys: true)
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
    end
  end
end
