class Post < ActiveRecord::Base
  has_many :comments
  belongs_to :user

  calculated :comments_by_user, ->(user) { "select count(*) from comments where comments.post_id = posts.id and comments.user_id = #{user.id}" }
  calculated :comments_count, -> { 'select count(*) from comments where comments.post_id = posts.id' }
  calculated :comments_two, -> { 'select count(*) from comments where comments.post_id = posts.id' }
  calculated :comments_arel, -> { Comment.where(Comment.arel_table[:post_id].eq(Post.arel_table[:id])).select(Arel.sql('count(*)')) }
  calculated :comments_to_sql, -> { Comment.where('comments.post_id = posts.id').select('count(*)') }

  scope :recent, -> {
    where(created_at: (Time.now - 1.day)..Time.now)
  }

  calculated :recent_comment_count, requires_scopes: [:recent] do
    'select count(*) from comments where comments.post_id = posts.id'
  end
end

class Tutorial < Post
end

class Article < Post
  calculated :sub_comments, -> { 'select count(*) from comments where comments.post_id = posts.id' }
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :comments
  has_many :posts
end
