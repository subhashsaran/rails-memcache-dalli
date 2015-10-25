class Product < ActiveRecord::Base
  attr_accessible :name, :price, :released_on, :category_id
  belongs_to :category
  
  def category_name
    Rails.cache.fetch([:category, category_id, :name], expires_in: 5.minutes) do
      category.name
    end
  end
end
