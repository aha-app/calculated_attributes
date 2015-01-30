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

    class Post < ActiveRecord::Base
    ...
      calculated :comments_count, -> { "select count(*) from comments where comments.post_id = posts.id" }
    ...
    end
    
Then, the comments count may be accessed as follows:

    Post.scoped.calculated(:comments_count).first.comments_count
    #=> 5
    
Multiple calculated attributes may be attached to each model. If we add a `Tag` model that also has a `post_id`, we can update the Post model as following:

    class Post < ActiveRecord::Base
    ...
      calculated :comments_count, -> { "select count(*) from comments where comments.post_id = posts.id" }
      calculated :tags_count, -> { "select count(*) from tags where tags.post_id = posts.id" }
    ...
    end
    
And then access both the `comments_count` and `tags_count` like so:

    post = Post.scoped.calculated(:comments_count, :tags_count).first
    post.comments_count
    #=> 5
    post.tags_count
    #=> 2
    
You may also use the `calculated` method on a single model instance, like so:

    Post.first.calculated(:comments_count).comments_count
    #=> 5
    
If you have defined a `calculated` method, results of that method will be returned rather than throwing a method missing error even if you don't explicitly use the `calculated()` call on the instance:

    Post.first.comments_count
    #=> 5

## Contributing

1. Fork it ( https://github.com/[my-github-username]/calculated_attributes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
