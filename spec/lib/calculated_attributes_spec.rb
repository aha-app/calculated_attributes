require 'spec_helper'

describe 'calculated_attributes' do
  it 'includes calculated attributes' do
    expect(Post.scoped.calculated(:comments).first.comments).to eq(1)
  end

  it 'includes multiple calculated attributes' do
    post = Post.scoped.calculated(:comments, :comments_two).first
    expect(post.comments).to eq(1)
    expect(post.comments_two).to eq(1)
  end

  it 'includes chained calculated attributes' do
    post = Post.scoped.calculated(:comments).calculated(:comments_two).first
    expect(post.comments).to eq(1)
    expect(post.comments_two).to eq(1)
  end

  it 'nests with where query' do
    expect(Post.where(id: 1).calculated(:comments).first.comments).to eq(1)
  end

  it 'nests with order query' do
    expect(Post.order('id DESC').calculated(:comments).first.id).to eq(Post.count)
  end

  it 'allows access via model instance method' do
    expect(Post.first.calculated(:comments).comments).to eq(1)
  end

  it 'allows anonymous access via model instance method' do
    expect(Post.first.comments).to eq(1)
  end

  it 'allows anonymous access via model instance method with STI and lambda on base class' do
    expect(Tutorial.first.comments).to eq(1)
  end

  it 'allows anonymous access via model instance method with STI and lambda on subclass' do
    expect(Article.first.sub_comments).to eq(1)
  end

  it 'does not allow anonymous access for nonexisting calculated block' do
    expect { Post.first.some_attr }.to raise_error(NoMethodError)
  end

  it 'does not allow anonymous access for nonexisting calculated block with STI' do
    expect { Tutorial.first.some_attr }.to raise_error(NoMethodError)
  end

  it 'allows access to multiple calculated attributes via model instance method' do
    post = Post.first.calculated(:comments, :comments_two)
    expect(post.comments).to eq(1)
    expect(post.comments_two).to eq(1)
  end

  it 'allows attributes to be defined using AREL' do
    expect(Post.scoped.calculated(:comments_arel).first.comments_arel).to eq(1)
  end

  it 'maintains previous scope' do
    expect(Post.where(text: 'First post!').calculated(:comments).count).to eq(1)
    expect(Post.where(text: 'First post!').calculated(:comments).first.comments).to eq(1)
    expect(Post.where("posts.text = 'First post!'").calculated(:comments).first.comments).to eq(1)
  end

  it 'maintains subsequent scope' do
    expect(Post.scoped.calculated(:comments).where(text: 'First post!').count).to eq(1)
    expect(Post.scoped.calculated(:comments).where(text: 'First post!').first.comments).to eq(1)
    expect(Post.scoped.calculated(:comments).where("posts.text = 'First post!'").first.comments).to eq(1)
  end

  it 'includes calculated attributes with STI and lambda on base class' do
    expect(Tutorial.scoped.calculated(:comments).first.comments).to eq(1)
  end

  it 'includes calculated attributes with STI and lambda on subclass' do
    expect(Article.scoped.calculated(:sub_comments).first.sub_comments).to eq(1)
  end
end
