require "byebug"

class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        return self.instance_variable_get("@#{name}")
      end
    end
    names.each do |name|
      define_method("#{name}=") do |new|
        self.instance_variable_set("@#{name}", new)
      end
    end
  end
end


# # This phase will get your gears turning on these new metaprogramming concepts 
# before we dive into the project. You already know what the standard Ruby method attr_accessor does. 
# What if Ruby didn't provide this convenient method for you?

# # In the lib/00_attr_accessor_object.rb file, implement a ::my_attr_accessor macro, which should do
#  exactly the same thing as the real attr_accessor: it should define setter/getter methods.

# # To do this, use define_method inside ::my_attr_accessor to define getter and setter instance methods.
#  You'll want to investigate and use the instance_variable_get and instance_variable_set methods described here.

# # There is a corresponding spec/00_attr_accessor_object_spec.rb spec file. Run it using 
# bundle exec rspec to check your work.