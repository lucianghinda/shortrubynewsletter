require 'byebug'
# How to use Ruby forward arguments notation ...

class Provider
  def report(message, object, *args, **kwargs, &)
    # uploading message for object to provider
  end
end

# Forward arguments notation helps forward all arguments to a method call
module User
  # here we named the first param to be used inside the method
  def self.log(message, ...)
    puts message # here we want to use the first param
    before(...)
    console_logging(message, ...)
    error_reporting(...)
  end

  # Here only the &block is needed so everything else is ignored
  def self.before(*_, **_, &block)
    block&.call("#{self.name}##{__method__}")
  end

  # Here we want to use all params
  def self.console_logging(message, object, *args, **kwargs, &block)
    puts "#{message}: #{object} with args: #{args} and kwargs: #{kwargs} with block: #{block}"
  end

  # Here we just want to forward all params further
  def self.error_reporting(...)
    Provider.new.report(...)
  end
end

# Sample usage
Admin = Struct.new(:name, keyword_init: true)
admin = Admin.new(name: "Alex")
step = 3

User.log("Test message", admin, step, config: { app: true }) do
  puts "Excuting this around logging"
end

# Here is a Service example
module User
  class CreateService
    def call(object, ...)
      User.log("starting service", object, ...)

      Validate.new(object).call(...)
              .then { Converter.new(object).call(...) }
              .then { Repo.new(object).update(...) }

      User.log("finished service", object, ...)
    end
  end
end

# This is how I define more things

module User
  class Validate
    def initialize(object) = @object = object

    def call(*args, **kwargs, &block)
      User.log("validate", @object, *args, **kwargs)
      block&.call("#{self.class}##{__method__}")
    end
  end

  class Converter
    def initialize(object) = @object = object

    def call(*args, **kwargs, &block)
      User.log("converter", @object, *args, **kwargs)
      block&.call("#{self.class}##{__method__}")
    end
  end

  class Repo
    def initialize(object) = @object = object

    def update(*args, **kwargs, &block)
      User.log("Repo", @object, *args, **kwargs)
      block&.call("#{self.class}##{__method__}")
    end
  end
end

user = Admin.new(name: "Siri")
repeat = 2

User::CreateService.new.call(user, repeat, config: { app: true })

User::CreateService.new.call(user, repeat, config: { app: true }) do |method_name|
  puts "executed from #{method_name}"
end
