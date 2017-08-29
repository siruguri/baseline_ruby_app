module App
  class App
    def parse_cli_args
      @args = Trollop::options do
        opt :commands, "commands defined in code...", long: 'commands', short: 'c', type: :string
      end
    end
  end
end

