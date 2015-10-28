ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, force: true do |t|
    t.string :text
    t.references :user
    t.timestamps null: false
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :text
    t.references :user
    t.timestamps null: false
  end

  create_table :users, force: true do |t|
    t.string :username
  end
end
