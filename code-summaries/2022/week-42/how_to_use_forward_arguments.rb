# How to use Ruby forward arguments notation ...

# Part 1: An example of a simple reporting module
puts RUBY_VERSION # 3.1.2

class Provider
  def report(message, object, *args, **kwargs, &) = puts "Provider work"
end

# Forward arguments notation helps forward all arguments to a method call
module Reporting
  # here we named the first param to be used inside the method
  def self.log(message, ...)
    puts message
    before(...)
    console_logging(message, ...)
    error_reporting(...)
  end

  # Here only the &block is needed so everything else is ignored
  def self.before(*_, **_, &block) = block&.call("#{self.name}##{__method__}")

  # Here we want to use all params
  def self.console_logging(message, object, *args, **kwargs, &block)
    puts "Message <#{message}>: #{object} with args: #{args} and kwargs: #{kwargs} with block: #{block}"
  end

  # Here we just want to forward all params further
  def self.error_reporting(...) = Provider.new.report(...)
end

# Sample usage
Admin = Struct.new(:name, keyword_init: true)
admin = Admin.new(name: "Alex")
step = 3

Reporting.log("Test message", admin, step, config: { app: true }) do
  puts "Excuting this around logging"
end

# Part 2: An example of a service calling multiple other objects

module User
  class CreateService
    def call(object, ...)
      Reporting.log("starting service", object, ...)

      Validate.new(object).call(...)
              .then { Converter.new(object).call(...) }
              .then { Repo.new(object).update(...) }

      Reporting.log("finished service", object, ...)
    end
  end
end

# # This is how I define more things

module User
  class Validate
    def initialize(object) = @object = object

    def call(*args, **kwargs, &block) = block&.call("#{self.class}##{__method__}")
  end

  class Converter
    def initialize(object) = @object = object

    def call(*args, **kwargs, &block) = block&.call("#{self.class}##{__method__}")
  end

  class Repo
    def initialize(object) = @object = object

    def update(*args, **kwargs, &block) = block&.call("#{self.class}##{__method__}")
  end
end

# Part 3: Example of usage for the User::CreateService

user = Admin.new(name: "Siri")
payload = 2

# Can be called with positional params
User::CreateService.new.call(user, payload)

# Can be called with positional params and keyword params
User::CreateService.new.call(user, payload, config: { app: true })

# Can be called with positional params, keyword params and block
User::CreateService.new.call(user, payload, config: { app: true }) do |method_name|
  puts "executed from #{method_name}"
end
