[![Gem Version](https://badge.fury.io/rb/calculated_attributes.svg)](https://badge.fury.io/rb/calculated_attributes)

# CalculatedAttributes

Automatically add calculated attributes from accessory select queries to ActiveRecord models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'calculated_attributes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install calculated_attributes

## Usage

Add each calculated attribute to your model using the `calculated` keyword. It accepts two parameters: a symbol representing the name of the calculated attribute, and a lambda containing a string to calculate the attribute.

For example, if we have two models, `Post` and `Comment`, and `Comment` has a `post_id` attribute, we might write the following code to add a comments count to each `Post` record in a relation:

```ruby
class Post < ActiveRecord::Base
...
  calculated :comments_count, -> { "select count(*) from comments where comments.post_id = posts.id" }
...
end
```
    
Then, the comments count may be accessed as follows:

```ruby
Post.scoped.calculated(:comments_count).first.comments_count
#=> 5
```
    
Multiple calculated attributes may be attached to each model. If we add a `Tag` model that also has a `post_id`, we can update the Post model as following:

```ruby
class Post < ActiveRecord::Base
...
  calculated :comments_count, -> { "select count(*) from comments where comments.post_id = posts.id" }
  calculated :tags_count, -> { "select count(*) from tags where tags.post_id = posts.id" }
...
end
```

And then access both the `comments_count` and `tags_count` like so:

```ruby
post = Post.scoped.calculated(:comments_count, :tags_count).first
post.comments_count
#=> 5
post.tags_count
#=> 2
```

Note that you must call `calculated` on a relation in order to get the desired result. `Post.calculated(:comments_count)` will give you the currently defined lambda for calculating the comments count. `Post.scoped.calculated(:comments_count)` (Rails 3) or `Post.all.calculated(:comments_count)` (Rails 4) will give you an ActiveRecord relation including the calculated attribute.

You may also use the `calculated` method on a single model instance, like so:

```ruby
Post.first.calculated(:comments_count).comments_count
#=> 5
```

If you have defined a `calculated` method, results of that method will be returned rather than throwing a method missing error even if you don't explicitly use the `calculated()` call on the instance:

```ruby
Post.first.comments_count
#=> 5
```

If you like, you may define `calculated` lambdas using Arel syntax:

```ruby
class Post < ActiveRecord::Base
...
  calculated :comments_count, -> { Comment.select(Arel::Nodes::NamedFunction.new("COUNT", [Comment.arel_table[:id]])).where(Comment.arel_table[:post_id].eq(Post.arel_table[:id])) }
...
end
```

## Known Issues

In Rails 4.x, you cannot call `count` on a relation with calculated attributes, e.g.

```ruby
Post.scoped.calculated(:comments_count).count
```

will error. This is because of an [ActiveRecord issue](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/calculations.rb#L368-L375) that does not permit Arel nodes in the count method.

## Contributing

1. Fork it ( https://github.com/aha-app/calculated_attributes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits

Written by Zach Schneider based on ideas from Chris Waters.