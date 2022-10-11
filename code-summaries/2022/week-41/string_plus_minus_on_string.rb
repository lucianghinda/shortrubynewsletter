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
