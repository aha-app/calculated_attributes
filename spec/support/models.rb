class Post < ActiveRecord::Base
  calculated :comments, -> { "select count(*) from comments where comments.post_id = posts.id" }
  calculated :comments_two, -> { "select count(*) from comments where comments.post_id = posts.id" }
end

class Comment < ActiveRecord::Base
  
end