p = Post.create(text: "First post!")
Comment.create(post_id: p.id, text: "First comment!")