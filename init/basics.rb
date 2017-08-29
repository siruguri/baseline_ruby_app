module App
  class App
    attr_reader :args

    def self.multiplex(inst)
      sequence = inst.args[:commands]
      syms = sequence.split(',').map { |s| s.to_sym }
      syms.each do |s|
        if inst.respond_to? s
          inst.send s
        else
          $stderr.puts "This app does not respond to #{s}. Ignoring."
        end
      end
    end
    
    def self.config(cfg=nil)
      if cfg.nil?
        return @_cfg
      else
        @_cfg={}
        cfg.keys.each do |k|
          @_cfg[k]=cfg[k]
        end
      end
    end
  end
end
