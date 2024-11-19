class CreatePageViews < ActiveRecord::Migration[7.1]
  def change
    create_table :page_views do |t|
      t.text :url, null: false
      t.text :referrer
      t.datetime :created_at, null: false
      t.string :digest, limit: 32, null: false  # Note: using digest, not hash
    end

    add_index :page_views, :digest, unique: true
    add_index :page_views, :created_at
    add_index :page_views, [:url, :created_at]
    add_index :page_views, [:referrer, :url, :created_at]
    add_index :page_views, :url
    add_index :page_views, :referrer
  end
end
