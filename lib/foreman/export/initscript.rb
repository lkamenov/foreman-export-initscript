require "erb"
require "foreman/export"

class Foreman::Export::Initscript < Foreman::Export::Base
    
    def initialize(location, engine, options={})
        newoptions = options.dup
        newoptions[:template] = template_root
        super(location, engine, newoptions)
    end
    
    def export
        super
        
        error("Must specify a location") unless location
        
        # clean init script folder
        Dir["#{location}/#{app}*"].each do |file|
            clean file
        end
                                
        engine.each_process do |name, process|
            1.upto(engine.formation[name]) do |num|
                port = engine.port_for(process, num)
                process_name = "#{app}-#{name}-#{num}"
                pid_dir = "/var/run/#{app}-#{name}"
                write_template "initscript/initscript.erb", process_name, binding
                FileUtils.chmod 0744, File.join(location, process_name)
            end
        end
    end
    
    private
    def template_root
        @template_root ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data', 'export', 'initscript'))
    end
end

