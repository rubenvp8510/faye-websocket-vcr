require 'rspec/em'
require 'faye/websocket'
require 'faye-websocket-vcr'

WebsocketSteps = RSpec::EM.async_steps do

  def open_socket(url, &callback)
    done = false

    resume = lambda do |open|
      unless done
        done = true
        @open = open
        callback.call
      end
    end
    creds = {
      username: 'jdoe',
      password: 'password'
    }
    base64_creds = ["#{creds[:username]}:#{creds[:password]}"].pack('m').delete("\r\n")

    ws_options = {
      headers: {
        'Authorization' => 'Basic ' + base64_creds,
        'Hawkular-Tenant' => 'hawkular',
        'Accept' => 'application/json'
      }
    }
      @ws = Faye::WebSocket::Client.new(url, [], ws_options)
      @ws.on(:message){ |e| p e
      resume.call(true) }
    end
  end

describe 'VCR for WS' do
  include WebsocketSteps
  HOST = '127.0.0.1:8080'.freeze
  ON_TRAVIS = ENV['TRAVIS'] == 'true'

  let(:example) do |e|
    e
  end

  it 'should record the very first message caught on the client yielded by the connect method' do
    WebSocketVCR.configure do |c|
      c.hook_uris = [HOST]
    end
    url = "ws://#{HOST}/hawkular/command-gateway/ui/ws"
    WebSocketVCR.record(example, self) do
      open_socket url
      sleep 20
    end
  end
end