ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, force: true do |t|
    t.string :text
    t.timestamps null: false
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :text
    t.timestamps null: false
  end
end
