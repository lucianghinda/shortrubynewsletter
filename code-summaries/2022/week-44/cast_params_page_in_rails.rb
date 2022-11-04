# frozen_string_literal: true

# If you try to cast params[:page] in Rails to Integer and set default to 1
puts RUBY_VERSION # => 3.1.2

DEFAULT_PAGE = 1

# ❌ Do NOT do this

def cast_page_one(params)
  params[:page].to_i || DEFAULT_PAGE
end

# In case params[:page] contains a string will return 0!
puts cast_page_one({ page: "a12" }) # => 0 !!!

# ✅ Do this

def page(params)
  Integer(params[:page], exception: false) || DEFAULT_PAGE
end

puts page({ page: "a12" }) # => 1

# Solution proposed by @jaredwhite@indieweb.social at https://ruby.social/web/@jaredwhite@indieweb.social/109282609587841078

def brief_page(params)
  [params[:page].to_i, DEFAULT_PAGE].max
end

puts brief_page({ page: "a12" })


# If I want to raise, I would do something like this

module Pagination
  Error = Module.new
  TypeError = Class.new(NameError) { include Error }
  ArgumentError = Class.new(ArgumentError) { include Error }
end

def page(params)
  Integer(params)
rescue ArgumentError
  raise Pagination::ArgumentError
rescue TypeError
  raise Pagination::TypeError
end

# Then, in ApplicationController, I would do something like this:

class ApplicationController
  rescue_from Pagination::Error, with: -> (error) { render_pagination_error(error) }
end

# Where rendering an error could be something like this
def render_pagination_error(error)
  case error
  when Pagination::ArgumentError
    flash[:alert] = "Pagination should be a number"
  when Pagination::TypeError
    flash[:alert] = "`page` params is required."
  end
  # render ...
end
