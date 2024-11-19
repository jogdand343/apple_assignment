require 'rails_helper'

RSpec.describe "Stats API", type: :request do
  describe "GET /api/v1/top_urls" do
    it "returns page views per URL for the past 5 days" do
      # Create page views using the factory
      create(:page_view, url: "http://apple.com", referrer: "http://apple.com", created_at: 2.days.ago)
      create(:page_view, url: "http://apple.com", referrer: "http://apple.com", created_at: 1.day.ago)
      create(:page_view, url: "http://google.com", referrer: "http://google.com", created_at: 1.day.ago)
      create(:page_view, url: "http://apple.com", referrer: "http://google.com", created_at: 4.days.ago)

      # Send the request
      get "/api/v1/top_urls"
      
      # Test response status
      expect(response).to have_http_status(200)
      
      # Parse the JSON response
      json = JSON.parse(response.body)
      
      # Check the first key matches a date format (YYYY-MM-DD)
      expect(json.keys.first).to match(/^\d{4}-\d{2}-\d{2}$/)
      
      # Test that the first URL object contains the keys 'url' and 'visits'
      first_url = json.values.first.first
      expect(first_url).to include('url', 'visits')
    end
  end
  
  describe "GET /api/v1/top_referrers" do
    it "returns top referrers for top URLs in the past 5 days" do
      # Create page views using the factory
      create(:page_view, url: "http://apple.com", referrer: "http://apple.com", created_at: 2.days.ago)
      create(:page_view, url: "http://apple.com", referrer: "http://apple.com", created_at: 1.day.ago)
      create(:page_view, url: "http://google.com", referrer: "http://google.com", created_at: 1.day.ago)
      create(:page_view, url: "http://apple.com", referrer: "http://google.com", created_at: 4.days.ago)

      # Send the request
      get "/api/v1/top_referrers"
      
      # Test response status
      expect(response).to have_http_status(200)
      
      # Parse the JSON response
      json = JSON.parse(response.body)

      # Get the first URL's data
      first_url_data = json.values.first.first

      # Check that the first_url_data is an array and contains the expected structure
      expect(first_url_data).to be_a(Array)
      expect(first_url_data.size).to eq(2)  # The array should have two elements (URL and data)

      # Ensure the first element is the URL
      expect(first_url_data[0]).to eq('http://apple.com')

      # Ensure the second element (hash) has the 'visits' and 'referrers' keys
      expect(first_url_data[1]).to include('visits', 'referrers')

      # Ensure 'referrers' is an array and contains the correct data
      expect(first_url_data[1]['referrers']).to be_a(Array)
      expect(first_url_data[1]['referrers'].first).to include('url', 'visits')

      # Ensure visits is correct
      expect(first_url_data[1]['visits']).to eq(1)

      # Ensure that referrer data is correct
      expect(first_url_data[1]['referrers'].first['url']).to eq('http://apple.com')
      expect(first_url_data[1]['referrers'].first['visits']).to eq(1)
    end
  end
end
