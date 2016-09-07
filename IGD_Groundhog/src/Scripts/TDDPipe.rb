module IGD
    module Groundhog

        class TDDPipe < Task

            def initialize(target)
                @target = target #the name of the TDD

                @proc = Proc.new { |options|
                    tdd_name = Utilities.fix_name(target)					
                    sender = "TDDs/#{tdd_name}_bottom.rad"
                    receiver = "TDDs/0-#{tdd_name}.top"
                    pipe = "TDDs/0-#{tdd_name}.pipe"
                    File.open(sender,'w'){|b|
                        b.puts "\#@rfluxmtx h=kf u=Y\n"
                        b.puts File.open("TDDs/0-#{tdd_name}.bottom", "rb").read
                    }
                    next ["rfluxmtx #{options["tdd_pipe_parameters"]} #{sender} #{receiver} #{pipe} > DC/#{tdd_name}-pipe.mtx"]                
                }

            end

        end
    end
end