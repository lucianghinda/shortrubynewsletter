# Code Summary for https://cirw.in/blog/constant-lookup
# All examples are run with Ruby 3.1.2

# Part 1/4 Module nesting

# > "Ruby looks for constants attached to modules and classes in the surrounding lexical scope of your code"

module User
  module Auth; end
  module Steps
    module Progress
      def self.check = Auth == User::Auth
      def self.stack = Module.nesting
    end
  end
end

puts User::Steps::Progress.check # true
puts User::Steps::Progress.stack # [User::Steps::Progress, User::Steps, User]

# How does it work?

# To search for Auth inside Progress it will construct the following lookups:
#  - User::Steps::Progress::Auth
#  - User::Steps::Auth
#  - User::Auth


# Part 2/4 Shortcut notation

module User
  module Auth; end
end

# How does the nesting look like when using shortcut notation
module User::Steps
  puts Module.nesting # [User::Steps]
end

# So if you try to call Auth
module User::Steps
  Auth # ❌ => uninitialized constant User::Steps::Auth (NameError)
end
# Will try [User::Steps::Auth] and that does not exists

# Why? Because nesting only contains [User::Steps] Ruby will just append it to
# the only element there and look for User::Steps::Auth, which does not exist.

# To access Auth from inside Steps, you need to use the nested module definition:
module User
  module Steps
    puts Module.nesting # [User::Steps, User]
  end
end

# So then it will try to look for User::Steps::Auth and then User::Auth

# Part 3/4 Ancestors

# > "If the constant cannot be found by looking at any of the modules in `Module.nesting`, Ruby takes the currently open module or class, and looks at its ancestors." 
# > "Where the currently open class or module is the innermost class or module statement in the code"

class User
  module Auth
    def self.call = true
  end
end

# This works:
class Admin < User
  Auth.call
end

# While the following example will not work:
class User
  def authentication = Auth.call
end

class Admin < User
  module Auth
    def self.call = true
  end
end

Admin::Auth.call # ✅
Admin.new.authentication # ❌ uninitialized constant User::Auth (NameError)

# Part 4/4 Object

# > "While there’s no `class` or `module` statement that you can see, it is taken for granted that at the top level of a ruby file, the currently open class is Object"

# > "Almost all classes in Ruby inherit from Object, so Object is almost always included in the list of ancestors of the currently open class, and thus its constants are almost always available."

module Progress
end

Object::Progress == Progress

# When in singleton you don't have access to constants defined in class itself
class User
  module Auth; end
end

class << User
  Auth # uninitialized constant #<Class:User>::Auth (NameError)
end

# This will work as it will look at the current open module or class
class User
  module Auth; end

  class << self
    Auth
  end
end

# Extra: Using module or class as namespace in Rails

# If you are in Rails and say you want to use the name of a model as a namespace

class User < ActiveRecord
end

module User # ❌ will raise "User is not a module (TypeError)"
  class Auth
  end
end


# How to make it work

class User::Auth # ✅ this works
end

# Because actually the following works:
class User
  class Auth
  end
end