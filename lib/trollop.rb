module App
  class App
    def parse_cli_args
      @args = Trollop::options do
        opt :popular, "Use popular search not live"                    # flag --monkey, default false
        opt :query, "search for this", type: :string        # string --name <s>, default nil
        opt :commands, "hmm....", type: :string
      end
      p @args
    end
  end
end

