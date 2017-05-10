require 'json'
require 'yaml'
require 'faye/websocket'
require 'faye-websocket-vcr/cassette'
require 'faye-websocket-vcr/cassette'
require 'faye-websocket-vcr/configuration'
require 'faye-websocket-vcr/errors'
require 'faye-websocket-vcr/version'
require 'faye-websocket-vcr/monkey_patch'

module WebSocketVCR
  extend self
  attr_accessor :cassette

  # @return [String] the current version.
  # @note This string also has singleton methods:
  #
  #   * `major` [Integer] The major version.
  #   * `minor` [Integer] The minor version.
  #   * `patch` [Integer] The patch version.
  #   * `parts` [Array<Integer>] List of the version parts.
  def version
    @version ||= begin
      string = WebSocketVCR::VERSION

      def string.parts
        split('.').map(&:to_i)
      end

      def string.major
        parts[0]
      end

      def string.minor
        parts[1]
      end

      def string.patch
        parts[2]
      end

      string
    end
  end

  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def disabled
    @disabled || false
  end

  def disabled=(v)
    @disabled = v
  end

  def save_session
  end

  # Use the specified cassette for either recording the real communication or replaying it during the tests.
  # @param name [String] the cassette
  # @param options [Hash] options for the cassette
  # @option options [Symbol] :record if set to :none there will be no recording; :all means record all the time
  # @option options [Symbol] :erb a sub-hash with variables used for ERB substitution in given cassette
  # @option options [Boolean] :reverse_substitution if true, the values of :erb hash will be replaced by their names in
  #                                                 the cassette. It's turned-off by default.
  def use_cassette(name, options = {})
    fail ArgumentError, '`VCR.use_cassette` requires a block.' unless block_given?
    self.cassette = Cassette.new(name, options)
    yield
    self.cassette.save
    self.cassette = nil
  end

  def record(example, context, options = {}, &block)
    fail ArgumentError, '`VCR.record` requires a block.' unless block_given?
    name = filename_helper(example, context)
    use_cassette(name, options, &block)
  end

  def turn_off!(_options = {})
    # TODO: impl
  end

  def turned_on?
    !@cassette.nil?
  end

  def turn_on!
    # TODO: impl
  end

  def live?
    @cassette && @cassette.recording?
  end

  private

  def filename_helper(example, context)
    if context.class.metadata[:parent_example_group].nil?
      example_name = example.description.gsub(/\s+/, '_')
      directory = context.class.metadata[:description].gsub(/\s+/, '_')
    else
      example_name = "#{context.class.metadata[:description]}_#{example.description}".gsub(/\s+/, '_')
      directory = context.class.metadata[:parent_example_group][:description].gsub(/\s+/, '_')
    end
    "#{directory}/#{example_name}"
  end

  module_function :configure, :configuration, :cassette, :cassette=, :disabled, :disabled=, :save_session,
                  :use_cassette, :record, :turn_off!, :turned_on?, :turn_on!, :filename_helper
end
