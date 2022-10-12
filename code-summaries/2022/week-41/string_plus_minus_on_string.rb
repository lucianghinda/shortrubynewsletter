# String#- and String#+ methods

# Using a string literal will create a new String object
str1 = "Normal string"
puts "#{str1.object_id}, #{str1.frozen?}" # 60, false

# When re-using the same string literal will create a new object
str2 = "Normal string"
puts "#{str2.object_id}, #{str2.frozen?}" # 80, false

# String#-
# Returns a frozen, possibly pre-existing copy of the string.

str3 = -"Normal string"
puts "#{str3.object_id}, #{str3.frozen?}" # 100, true

# Here for example it will return the same object id
str4 = -"Normal string"
puts "#{str4.object_id}, #{str4.frozen?}" # 100, true

# String#+
# Returns self if self is not frozen.
# Otherwise. returns self.dup, which is not frozen.

str5 = +"Normal string"
puts "#{str5.object_id}, #{str5.frozen?}" # 120, false


# Exploring some interesting cases

hash1 = { "Key" => "Value" }
key = hash1.keys[0]
value = hash1.values[0]
puts "H1: #{key.object_id}, #{value.object_id}" # 140, 160
puts "H1: #{key.frozen?}, #{value.frozen?}" # true, false

hash2 = { -"Key" => -"Value" }
key = hash2.keys[0]
value = hash2.values[0]
puts "H2: #{key.object_id}, #{value.object_id}" # 140, 180
puts "H2: #{key.frozen?}, #{value.frozen?}" # true, true

# So if you want to use with Hash just add the - to the value
hash3 = { "Key" => -"Value" }
key = hash2.keys[0]
value = hash2.values[0]
puts "H3: #{key.object_id}, #{value.object_id}" # 140, 180
puts "H3: #{key.frozen?}, #{value.frozen?}" # true, true


# Some possible examples String#- could be useful

## 1️⃣ When possible please use symbols and not strings

## 2️⃣ When the string has a high chance of re-use

## 3️⃣ When you think it is short to use -"string" then "string".freeze

## Some examples

# When writing a custom SQL that might be re-used in some other places
SolarSystem.planets.order(-"orbit = 'circular' ASC, name ASC")

# When calling an external API where you always define the URL
base = -"http://example.com"
url = URI.join(base, -"/foo")

# When you specify the header
header = { -"Content-Type" => -"application/x-www-form-urlencoded" }

# When you log some structured short info
Rails.logger(-"job.start.highpriority")
