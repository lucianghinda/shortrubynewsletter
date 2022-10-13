# This is a code summary for https://allaboutcoding.ghinda.com/alternative-ways-to-freeze-a-string-in-ruby

puts RUBY_VERSION # 3.1.2

# Part 1: Using freeze on Strings will re-use the object instance

a = "this is a frozen string".freeze
puts a.frozen? # will return true

b = "this is a frozen string".freeze
puts b.frozen? # will return true

puts a.equal?(b) # will return true
puts a.object_id == b.object_id # true

# If `freeze` is not used then even if it is the same string literal
# new objects will be created for each assignment

str1 = "Normal string"
puts "#{str1.object_id}, #{str1.frozen?}" # 80, false

# When re-using the same string literal will create a new object
str2 = "Normal string"
puts "#{str2.object_id}, #{str2.frozen?}" # 100, false

puts str1.equal?(str2) # will return false because they are not the same object
puts str1.object_id == str2.object_id # this is false


# Part 2: Using `String#-@` to freeze strings
# Returns a frozen, possibly pre-existing copy of the string.

str3 = -"Normal string"
puts "#{str3.object_id}, #{str3.frozen?}" # 120, true

# Here for example it will return the same object id
str4 = -"Normal string"
puts "#{str4.object_id}, #{str4.frozen?}" # 120, true

puts str3.equal?(str4) # true => It is the same instance
puts str3.object_id == str3.object_id # true they have the same object_id

# Using `String#+@` to unfreeze strings
# Returns self if self is not frozen.
# Otherwise returns self.dup, which is not frozen.

frozen_string = -"This is a frozen string"
begin
  frozen_string << "and it cannot be modified"
rescue FrozenError => e
  puts e # can't modify frozen String: "This is a frozen string"
end

puts "#{frozen_string.object_id}, #{frozen_string.frozen?}" # 140, true
str5 = +frozen_string
str5 << "and it can be modified"
puts "#{str5.object_id}, #{str5.frozen?}" # 160, false


# Part 3: Exploring Hash keys and values
# Hash key is frozen by default

hash1 = { "Key" => "Value" }
key1 = hash1.keys.first
value1 = hash1.values.first
puts "H1: #{key1.object_id}, #{value1.object_id}" # 180, 200
puts "H1: #{key1.frozen?}, #{value1.frozen?}" # true, false

hash2 = { "Key" => "Value" }
key2 = hash2.keys.first
value2 = hash2.values.first
puts "H2: #{key2.object_id}, #{value2.object_id}" # 180, 220
puts "H2: #{key2.frozen?}, #{value2.frozen?}" # true, true

# Keys are the same object
puts key1.equal?(key2) # true
puts key1.object_id == key2.object_id # true

# Values are different objects
puts value1.equal?(value2) # false
puts value1.object_id == value2.object_id # false

# Part 4: Freezing hash value

# So if you want to use with Hash just add the - to the value
hash3 = { "Key" => -"Value" }
key3 = hash3.keys.first
value3 = hash3.values.first
puts "H3: #{key3.object_id}, #{value3.object_id}" # 180, 240
puts "H3: #{key3.frozen?}, #{value3.frozen?}" # true, true

hash4 = { "Key" => -"Value" }
key4 = hash4.keys.first
value4 = hash4.values.first
puts "H4: #{key4.object_id}, #{value4.object_id}" # 180, 240
puts "H4: #{key4.frozen?}, #{value4.frozen?}" # true, true

puts value3.equal?(value4) # true it is the same object instance
puts value3.object_id == value4.object_id # true it has the same object id

# Part 5: Some possible examples where `String#-@`` could be useful

# When writing a custom SQL that might be re-used in some other places
SolarSystem.planets.order(-"orbit = 'circular' ASC, name ASC")

# When calling an external API where you always define the URL
base = -"http://example.com"
url = URI.join(base, -"/foo")

# When you specify the header
header = { "Content-Type" => -"application/x-www-form-urlencoded" }

# When you log some structured short info
Rails.logger(-"job.start.highpriority")

# In general use `String#-@` when you think the string might be re-used
# later or in some other parts of the system and you cannot use symbols
