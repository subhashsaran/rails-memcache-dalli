class Category < ActiveRecord::Base
  attr_accessible :name
  has_many :products
  after_update :flush_name_cache

  def flush_name_cache
    Rails.cache.delete([:category, id, :name]) if name_changed?
  end
end
