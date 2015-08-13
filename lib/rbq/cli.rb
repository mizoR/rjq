require 'rbq'
require 'rbq/option_parser'

module Rbq
  class CLI
    class << self
      def start(argv=ARGV)
        new(argv.dup).run
      rescue Rbq::Error => e
        $stderr.puts e.message
      end
    end

    def initialize(argv)
      parser = Rbq::OptionParser.new
      @script, *@files, @options = parser.parse(argv)
    end

    def run
      from = @options[:from]
      to   = @options[:to]

      each_run do |input, output|
        script = Rbq::Script.new(@script) do |rbq|
          rbq.use Rbq::Middleware::Deserialize[from[:format]], from[:options]
          rbq.use Rbq::Middleware::Serialize[to[:format]], to[:options]
          rbq.use Rbq::Middleware::Colorize, lang: to[:format] if output.tty?
          rbq.use Rbq::Middleware::Redirect, to: output
        end

        script.run input.read
      end
    end

    def each_run
      return yield($stdin, $stdout) unless $stdin.tty?

      @files.each do |file|
        open(file) {|input| yield(input, $stdout)}
      end
    rescue SystemCallError => e
      raise Rbq::Error, "Cannot open file. -- #{e.message}"
    end
  end
end
