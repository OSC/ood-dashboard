namespace :validate do
    namespace :clusters do
        task :selector , [:filepath] do |task, args|
            is_failed = false
            if !args.filepath
                Pathname.glob((Pathname.new(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').expand_path).join("*.yml")).map{|c| c.to_s }.each do |file|
                    begin  
                      Rake::Task["validate:clusters:#{file}"].invoke
                    rescue
                      is_failed = true
                      next
                    end
                end
            else
                config = Pathname.new(args[:filepath].to_s).expand_path
                if config.file?
                    desc "Validate the cluster config: #{config}"
                    config_json = YAML.safe_load(config.read).to_json
                    puts "Validating cluster config: #{config}..."
                    if (JSON.parse(config_json)["v2"]["metadata"]["title"]).downcase.include?('quick')
                        schema = File.read((File.dirname(__FILE__) +'/quick_config_schema.json'))
                    else
                        schema = File.read((File.dirname(__FILE__) +'/config_schema.json'))
                    end
                    
                    if !JSON::Validator.validate(schema, config_json)
                      puts "Test for '#{config}' FAILED!"
                      puts JSON::Validator.fully_validate(schema, config_json)
                      is_failed = true
                    end
                    
                    puts "Finished validating cluster config: #{config}"
                    
                elsif config.directory?
                  Pathname.glob(config.join("*.yml")).each do |p|
                    desc "Validate the cluster config: #{config}"
                    config_json = YAML.safe_load(p.read).to_json
                    puts "Validating cluster config: #{config}..."
                    if (JSON.parse(config_json)["v2"]["metadata"]["title"]).downcase.include?('quick')
                        schema = File.read((File.dirname(__FILE__) +'/quick_config_schema.json'))
                    else
                        schema = File.read((File.dirname(__FILE__) +'/config_schema.json'))
                    end
                    
                    if !JSON::Validator.validate(schema, config_json)
                      puts "Test for '#{config}' FAILED!"
                      puts JSON::Validator.fully_validate(schema, config_json)
                      is_failed = true
                    end
                    
                    puts "Finished validating cluster config: #{config}"
                  end
                else
                  puts "configuration file '#{config}' does not exist"
                end 
            end
            raise 'One or more cluster configurations are invalid.' if is_failed
        end
       
        Pathname.glob((Pathname.new(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').expand_path).join("*.yml")).each do |config|
            desc "Validate the cluster config: #{config}"
            task (config.to_s).to_sym do
                config_json = YAML.safe_load(config.read).to_json
                puts "Validating cluster config: #{config}..."
                if (JSON.parse(config_json)["v2"]["metadata"]["title"]).downcase.include?('quick')
                    schema = File.read((File.dirname(__FILE__) +'/quick_config_schema.json'))
                else
                    schema = File.read((File.dirname(__FILE__) +'/config_schema.json'))
                end
                
                if !JSON::Validator.validate(schema, config_json)
                  puts "Test for '#{config}' FAILED!"
                  puts JSON::Validator.fully_validate(schema, config_json)
                  raise 'One or more cluster configurations are invalid.'
                end
                
                puts "Finished validating cluster config: #{config}"
            end
        end
   
    end
    desc "Validate all cluster configs"
    task :clusters, [:filepath] => "clusters:selector"
end
