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
        
        Dir["{location}/#{app}*"].each do |file|
            clean file
        end
        
        engine.each_process do |name, process|
            1.upto(engine.formation[name]) do |num|
                port = engine.port_for(process, num)
                write_template "initscript/process-script.erb", "#{app}-#{name}-#{num}", binding
            end
        end
    end
    
    private
    def template_root
        @template_root ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data', 'export', 'initscript'))
    end
end

