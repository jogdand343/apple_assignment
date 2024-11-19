namespace :data do
  desc 'Generate test dataset with 1 million records'
  task generate: :environment do
    REQUIRED_URLS = [
      'http://apple.com',
      'https://apple.com',
      'https://www.apple.com',
      'http://developer.apple.com',
      'http://en.wikipedia.org',
      'http://opensource.org'
    ]
    
    REQUIRED_REFERRERS = [
      'http://apple.com',
      'https://apple.com',
      'https://www.apple.com',
      'http://developer.apple.com',
      nil
    ]
    
    def generate_random_url
      [REQUIRED_URLS, Array.new(10) { Faker::Internet.url }].flatten.sample
    end
    
    def generate_random_referrer
      [REQUIRED_REFERRERS, Array.new(10) { Faker::Internet.url }].flatten.sample
    end
    
    # Ensure we have data for at least 10 sequential days
    base_date = 10.days.ago.beginning_of_day
    
    puts "Generating required URL and referrer combinations..."
    
    # First, insert required combinations to ensure they exist
    REQUIRED_URLS.each do |url|
      REQUIRED_REFERRERS.each do |referrer|
        PageView.create!(
          url: url,
          referrer: referrer,
          created_at: base_date + rand(10).days + rand(24).hours
        )
      end
    end
    
    puts "Generating remaining records..."
    
    # Fetch all existing digests from the database to avoid duplicates
    existing_digests = PageView.pluck(:digest).to_set
    
    # Generate remaining records in batches
    remaining_count = 1_000_000 - (REQUIRED_URLS.size * REQUIRED_REFERRERS.size)
    batch_size = 1000
    
    (remaining_count / batch_size).times do |i|
      records = []
      
      batch_size.times do
        url = generate_random_url
        referrer = generate_random_referrer
        created_at = base_date + rand(10).days + rand(24).hours
        
        # Manually generate the digest for each record
        digest = Digest::MD5.hexdigest({ url: url, referrer: referrer, created_at: created_at.utc }.compact.to_s)
        
        # Ensure the digest is unique before adding it to the batch
        while existing_digests.include?(digest)
          # If the digest exists, regenerate the record with a new value
          url = generate_random_url
          referrer = generate_random_referrer
          created_at = base_date + rand(10).days + rand(24).hours
          
          digest = Digest::MD5.hexdigest({ url: url, referrer: referrer, created_at: created_at.utc }.compact.to_s)
        end
        
        # Add the new digest to the set of existing digests
        existing_digests.add(digest)
        
        # Create the record
        records << {
          url: url,
          referrer: referrer,
          created_at: created_at,
          digest: digest
        }
      end

      # Insert the records into the database using ActiveRecord, ensuring validation
      PageView.create!(records)
      puts "Inserted batch #{i + 1} of #{remaining_count / batch_size}"
    end
    
    puts "Data generation complete!"
  end
end
