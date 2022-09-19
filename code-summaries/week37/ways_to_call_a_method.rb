# ruby 3.1.2

# Code Summary for https://www.notonlycode.org/12-ways-to-call-a-method-in-ruby

class Client
  def send(message) = puts message
end

class TweetService
  def initialize(client = Client.new) = @client = client
  def post(message) = @client.send(message)
  def hello_world = @client.send("Hello world 8!")
  def method_missing(name, ...) = post(tweet_from_method_name(name.to_s))

  private

  def tweet_from_method_name(name) = sentence(name.gsub(/exclamation_mark/,'!').split("_"))
  def sentence(words) = words.map(&:capitalize).join(" ")
  def private_post(message) = @client.send(message)
end

service = TweetService.new

# The obvious way
service.post("Hello World 1!")
service.post "Hello World 2!"

# Using send and public_send
service.send(:private_post, "Hello World 3!") # works on private too
service.public_send(:post, "Hello World 4!")

# Using "method" and "call"
service.method(:post).call("Hello world 5!")
service.method(:post).("Hello world 6!")

# Using "tap"
service.tap { _1.post("Hello world 7!") }
service.tap(&:hello_world)

# Using "to_proc" on function name
:post.to_proc.call(service, "Hello world 9!")

# Using method missing
service.hello_world_10_exclamation_mark
service.yes_exclamation_mark_it_works_dont_do_it_in_production

# Using eval
eval("service.post('Hello World 11!')")

# ------------------------------------------------------------------------
# Extras (not present in the article)

# with __send__
service.__send__(:post, "Extra #1!")

# Using [] shorthand syntax for call
service.method(:post)["Extra #2!"]

# With lambda
service.tap(&->(object) { object.post("Extra #3!")})
# or
post_lambda = ->(service) { service.post("Extra #4!")}
service.tap(&post_lambda)

# With proc
service.tap(&(Proc.new { _1.post("Extra #5!")}))
# or
post_proc = Proc.new { _1.post("Extra #6!")}
service.tap(&post_proc)

# It works with then too
service.then { _1.post("Extra #7!") }

# Using bind
method = TweetService.instance_method(:post)
method.bind(service).call("Extra #8!")

# changing the context

class ClientOauthV2
  def send(message) = puts "[OauthV2] #{message}"
end

class TweetServiceV2 < TweetService
  def initialize(client = ClientOauthV2.new) = super
end
new_service = TweetServiceV2.new
method.bind(new_service).call("Extra #9!")

class TweetServiceV2 < TweetService
  def get_binding = binding
end

context = new_service.get_binding
context.eval("post('Extra #10!')")
# or
eval("post('Extra #11!')", context)
