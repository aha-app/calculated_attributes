require 'spec_helper'

def model_scoped(klass)
  if klass.respond_to? :scoped
    klass.scoped
  else
    klass.all
  end
end

describe 'calculated_attributes' do
  it 'includes calculated attributes' do
    expect(model_scoped(Post).calculated(:comments_count).first.comments_count).to eq(1)
  end

  it 'includes multiple calculated attributes' do
    post = model_scoped(Post).calculated(:comments_count, :comments_two).first
    expect(post.comments_count).to eq(1)
    expect(post.comments_two).to eq(1)
  end

  it 'includes chained calculated attributes' do
    post = model_scoped(Post).calculated(:comments_count).calculated(:comments_two).first
    expect(post.comments_count).to eq(1)
    expect(post.comments_two).to eq(1)
  end

  it 'nests with where query' do
    expect(Post.where(id: 1).calculated(:comments_count).first.comments_count).to eq(1)
  end

  it 'nests with order query' do
    expect(Post.order('id DESC').calculated(:comments_count).first.id).to eq(Post.count)
  end

  it 'allows access via model instance method' do
    expect(Post.first.calculated(:comments_count).comments_count).to eq(1)
  end

  it 'allows anonymous access via model instance method' do
    expect(Post.first.comments_count).to eq(1)
  end

  it 'allows anonymous access via model instance method with STI and lambda on base class' do
    expect(Tutorial.first.comments_count).to eq(1)
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
    post = Post.first.calculated(:comments_count, :comments_two)
    expect(post.comments_count).to eq(1)
    expect(post.comments_two).to eq(1)
  end

  it 'allows attributes to be defined using AREL' do
    expect(model_scoped(Post).calculated(:comments_arel).first.comments_arel).to eq(1)
  end

  it 'allows attributes to be defined using class that responds to to_sql' do
    expect(model_scoped(Post).calculated(:comments_to_sql).first.comments_to_sql).to eq(1)
  end

  it 'maintains previous scope' do
    expect(Post.where(text: 'First post!').calculated(:comments_count).first.comments_count).to eq(1)
    expect(Post.where("posts.text = 'First post!'").calculated(:comments_count).first.comments_count).to eq(1)
  end

  it 'maintains subsequent scope' do
    expect(model_scoped(Post).calculated(:comments_count).where(text: 'First post!').first.comments_count).to eq(1)
    expect(model_scoped(Post).calculated(:comments_count).where("posts.text = 'First post!'").first.comments_count).to eq(1)
  end

  it 'includes calculated attributes with STI and lambda on base class' do
    expect(model_scoped(Tutorial).calculated(:comments_count).first.comments_count).to eq(1)
  end

  it 'includes calculated attributes with STI and lambda on subclass' do
    expect(model_scoped(Article).calculated(:sub_comments).first.sub_comments).to eq(1)
  end

  context 'when joining models' do
    it 'includes calculated attributes' do
      expect(model_scoped(Post).joins(:comments).calculated(:comments_count).first.comments_count).to eq(1)
    end

    context 'when conditions are specified on the joined table' do
      it 'includes calculated models' do
        scope = model_scoped(Post).joins(:comments)
        expect(scope.first.comments_count).to eq(1)
      end
    end
  end

  context 'when eager loading models' do
    it 'includes calculated attributes' do
      scope = case ActiveRecord::VERSION::MAJOR
      when 4 then model_scoped(Post).includes(:comments).references(:comments)
      when 3 then model_scoped(Post).eager_load(:comments)
      end
      expect(scope.first.comments_count).to eq(1)
    end
  end
end
