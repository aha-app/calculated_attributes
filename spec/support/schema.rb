ActiveRecord::Schema.define do
  self.verbose = false

  %i[posts comments users].each do |table|
    drop_table table
  rescue ActiveRecord::StatementInvalid
    # Ignore errors if the table does not exist
  end

  create_table :posts do |t|
    t.string :text
    t.references :user
    t.timestamps null: false
  end

  create_table :comments do |t|
    t.integer :post_id
    t.string :text
    t.references :user
    t.timestamps null: false
  end

  create_table :users do |t|
    t.string :username
  end
end
