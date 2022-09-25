# Code Summary for https://dev.to/ayushn21/remote-debugging-in-rails-7-49nh

# How to start Rails debugger when using multiple processes in Development

# config/application.rb
require "rails/all"

if defined?(Rails::Server) && Rails.env.development?
  require "debug/open_nonstop"
end

# --------------

# run to start Rails and all other processes that you need
bin/dev

# and then run:
bundle exec rdbg -a # This will connect to Rails if that is the only debuggable process

# Use Ctrl+D to exit the debugger and keep Rails running
