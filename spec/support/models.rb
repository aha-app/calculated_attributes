class Post < ActiveRecord::Base
  calculated :comments, -> { "select count(*) from comments where comments.post_id = posts.id" }
  calculated :comments_two, -> { "select count(*) from comments where comments.post_id = posts.id" }
  calculated :comments_arel, -> { Comment.where(Comment.arel_table[:post_id].eq(Post.arel_table[:id])).select(Arel.sql("count(*)")) }
end

class Tutorial < Post
  
end

class Article < Post
  calculated :sub_comments, -> { "select count(*) from comments where comments.post_id = posts.id" }
end

class Comment < ActiveRecord::Base
  
end