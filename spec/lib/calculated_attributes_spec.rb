require "spec_helper"

describe "calculated_attributes" do
  it "includes calculated attributes" do
    expect(Post.scoped.calculated(:comments).first.comments).to eq(1)
  end
  
  it "includes multiple calculated attributes" do
    post = Post.scoped.calculated(:comments, :comments_two).first
    expect(post.comments).to eq(1)
    expect(post.comments_two).to eq(1)
  end
  
  it "nests with other query options" do
    expect(Post.where(id: 1).calculated(:comments).first.comments).to eq(1)
  end
end