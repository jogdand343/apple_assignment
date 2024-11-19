# spec/models/page_view_spec.rb
require 'rails_helper'

RSpec.describe PageView, type: :model do
  it "is valid with valid attributes" do
    page_view = PageView.new(
      url: 'http://apple.com',
      referrer: 'http://developer.apple.com',
      created_at: Time.now
    )
    expect(page_view).to be_valid
  end

  it "is invalid without a URL" do
    page_view = PageView.new(url: nil)
    expect(page_view).to_not be_valid
  end

  it "is invalid without a created_at" do
    page_view = PageView.new(created_at: nil)
    expect(page_view).to_not be_valid
  end

  it "is invalid without a digest" do
    page_view = PageView.new(digest: nil)
    expect(page_view).to_not be_valid
  end

  it "generates a digest before validation" do
    page_view = PageView.create!(
      url: 'http://apple.com',
      referrer: 'http://developer.apple.com',
      created_at: Time.now
    )
    expect(page_view.digest).to_not be_nil
  end
end
