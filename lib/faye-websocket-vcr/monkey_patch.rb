module Faye
  class WebSocket
    class Client
      alias_method :real_initialize, :initialize
      alias_method :real_send, :send
      alias_method :real_add_listener, :add_listener
      alias_method :real_dispatch_event, :dispatch_event
      alias_method :real_close, :close
      attr_reader :live
      attr_accessor :session, :is_open, :thread

      def initialize(url, protocols = nil, options = {})
        cassette = WebSocketVCR.cassette
        if WebSocketVCR.configuration.hook_uris.any? { |u| url.include?(u) }
          if cassette.recording?
            @live = true
          else
            @live = false
            @open = true
          end
          @session = cassette.next_session
        end
        real_initialize(url, protocols, options)
      end

      def send(data)
        text_data = data.kind_of? Array ? Base64.encode64(data.dup) : data.dup
        if @live
          real_send(data)
          @session.store(operation: 'write', data: text_data)
        else
          sleep 0.5 if @session.head.operation != 'write'
          record = @session.next
          _ensure_operation('write', record.operation)
          _ensure_data(text_data, record.data)
        end
      end

      def add_listener(event, callable = nil, &block)
        listener = callable || block
        real_add_listener(event, callable, &block)
        _read(event, &listener)
      end

      def dispatch_event(event)
        @session.store(operation: 'read', data: event.data) if event.respond_to?(:data) && @live
        real_dispatch_event(event)
      end

      def close
        if @live
          @session.store(operation: 'close')
          real_close
        else
          sleep 0.5 if @session.head.operation != 'close'
          record = @session.next
          _ensure_operation('close', record.operation)
          Thread.kill @thread if @thread
          @open = false
        end
      end

      private

      def _read(event, &_block)
        if @live
          rec = @session
          real_add_listener(event) do |event|
            rec.store(operation: 'read', type: 'text', data: event.data) if event.respond_to?(:data)
            yield(event)
          end
        else
          wait_for_reads(event)
        end
      end

      def wait_for_reads(event, once = false)
        @thread = Thread.new do
          # if the next recorded operation is a 'read', take all the reads until next write
          # and translate them to the events
          while @open && !@session.empty?
            begin
              if @session.head.operation == 'read'
                record = @session.next
                data = record.data
                data = Base64.decode64(msg) if record.type != 'text'
                emit(event, data)
                break if once
              else
                sleep 0.1 # TODO: config
              end
            end
          end
        end
      end

      def _ensure_operation(desired, actual)
        string = "Expected to '#{desired}' but the next operation in recording was '#{actual}'"
        fail string unless desired == actual
      end

      def _ensure_data(desired, actual)
        string = "Expected data to be '#{desired}' but next data in recording was '#{actual}'"
        fail string unless desired == actual
      end
    end
  end
end