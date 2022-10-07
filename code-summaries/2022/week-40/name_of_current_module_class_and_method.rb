# How to get current class name

class User
  def call = puts self.class.name
end
User.new.call #=> User

# Works with namespaced classes too
module Authenticated
  class Visitor
    def call = puts self.class.name
  end
end
Authenticated::Visitor.new.call #=> Authenticated::Visitor

# How to get the current method name
class Admin
  def call(...) = puts __method__
end
Admin.new.call # "call"

# What about a module?
module Authenticated
  def self.call = puts self.class.name
end
Authenticated.call # will return Module!!

module Visitors
  def self.call = puts self.name
end
Visitors.call # will return Visitors
# Yes there is a constant `name` defined on a Module

# But you can redefine that if you want
module Guest
  def self.name = "Another name"
  def self.call = puts self.name
end
Guest.call # will return "Another name"
