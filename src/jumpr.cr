require "option_parser"
require "json"

VERSION = "0.1.0"

# check the users home directory for config file
Config_file = File.join(Path.home, ".jumpr")

# if config file doesn't exist, create it
unless File.exists?(Config_file)
  File.write(Config_file, "{}")
end

# read the config file
Config = Hash(String, String).from_json(File.read(Config_file))

def save_config
  File.write(Config_file, Config.to_json)
end

def list_aliases
  # list all the aliases in the config file
  Config.each do |name, dir|
    puts "#{name} => #{dir}"
  end
end

def get_alias(name)
  dir = Config[name]?
  if dir
    if File.exists?(dir)
      puts dir
    else
      puts "Directory #{dir} does not exist, deleting alias"
      delete_alias name
    end
  else
    puts "Alias not found for #{name}"
  end
end

def set_alias(name, path)
  # set the alias in the config file
  Config[name] = path
  save_config()
end

def delete_alias(name)
  # delete the alias from the config file
  Config.delete(name)
  save_config()
end

OptionParser.parse do |parser|
  parser.banner = "Jumpr - Quickly jump to directories"

  parser.on "-v", "--version", "Show version" do
    puts "version 1.0"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "-l", "--list", "List all aliases" do
    list_aliases
    exit
  end

  parser.on "-g ALIAS", "--get ALIAS", "" do |name|
    get_alias name
    exit
  end

  parser.on "-s ALIAS", "--set ALIAS", "" do |name|
    set_alias name, Dir.current
    exit
  end

  parser.on "-d ALIAS", "--delete ALIAS", "" do |name|
    delete_alias name
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end
