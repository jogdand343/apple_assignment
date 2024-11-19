# app/models/page_view.rb
class PageView < ApplicationRecord
  validates :url, presence: true
  validates :created_at, presence: true
  validates :digest, presence: true, uniqueness: true
  
  before_validation :generate_digest, if: -> { digest.blank? }
  
  def generate_digest
    hash_data = {
      url: url,
      referrer: referrer,
      created_at: created_at&.utc
    }.compact
    
    self.digest = Digest::MD5.hexdigest(hash_data.to_s)
  end
end