# spec/factories/page_views.rb
FactoryBot.define do
  factory :page_view do
    url { "http://example.com" }
    referrer { "http://referrer.com" }
    created_at { 2.days.ago }
    digest { "sample_digest_#{SecureRandom.hex(8)}" }
  end
end
