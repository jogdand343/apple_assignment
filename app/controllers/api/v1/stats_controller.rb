module Api
  module V1
    class StatsController < ApplicationController
      def top_urls
        # Cache key: Use the date range for the past 5 days, grouped by day
        start_date = (Date.today - 7).beginning_of_day  # 5 days ago at midnight (created this database 2 days ago so using 7)
        end_date = Date.today.end_of_day                # Today at 23:59:59

        # Cache key using the date range for the last 5 full days
        cache_key = "top_urls_#{start_date.to_date}_to_#{end_date.to_date}"

        # Try to fetch the result from the cache
        @stats = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
            # Querying the page views between 5 days ago and today
            PageView
            .where('created_at >= ? AND created_at <= ?', start_date, end_date)
            .group('DATE(created_at), url')  # Group by date and URL
            .select('DATE(created_at) AS date, url, COUNT(*) AS visit_count')
            .order('date DESC, visit_count DESC')  # Order by date and visit count
            .pluck('DATE(created_at)', :url, Arel.sql('COUNT(*) AS visit_count')) # Plucking results
        end

        # Post-process the result into a structured format
        formatted_stats = @stats.group_by(&:first).transform_values do |entries|
            entries.map do |_, url, visit_count|
            { url: url, visits: visit_count }
            end
        end

        # Format the stats into a JSON response
        render json: formatted_stats
      end

      def top_referrers
        # Date range: Last 5 days
        start_date = 6.days.ago.to_date
        end_date = Date.today

        # Cache key: Cache the result for the last 5 days
        cache_key = "top_referrers_#{start_date}_to_#{end_date}"

        # Fetch from cache first
        @stats = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          result = {}

          # Step 1: Get the top 10 URLs for each day within the last 5 days
          # Query all URLs and group them by day, ordering by visit count
          top_urls_per_day = PageView
          .where('created_at >= ? AND created_at <= ?', start_date, end_date)
          .group('DATE(created_at)', :url)
          .order(Arel.sql('DATE(created_at) DESC, COUNT(*) DESC'))
          .pluck('DATE(created_at)', :url)

          # Group URLs by date
          top_urls_by_day = top_urls_per_day.group_by { |entry| entry[0] }

          # Step 2: For each day, get the top 10 URLs
          top_urls_by_day.each do |date, urls|
          # Limit to the top 10 URLs for this specific day
          top_10_urls_for_day = urls.uniq.first(10).map { |entry| entry[1] }

          # Step 3: Get the top 5 referrers for each URL on this day
          referrers_for_day = PageView
            .where('created_at >= ? AND created_at <= ?', start_date, end_date)
            .where('referrer IS NOT NULL')
            .where('DATE(created_at) = ?', date)  # Filter by the specific date
            .where(url: top_10_urls_for_day)  # Filter by the selected top URLs for this day
            .group('DATE(page_views.created_at)', 'page_views.url', 'page_views.referrer')
            .select(
            'DATE(page_views.created_at) as date',
            'page_views.url',
            'page_views.referrer',
            'COUNT(*) as referrer_visits'
            )
            .order(Arel.sql('COUNT(*) DESC'))  # Order by referrer visits (top referrers first)

          # Group the referrers by URL
          referrers_grouped_by_url = {}

          referrers_for_day.each do |entry|
            url = entry.url
            referrer = entry.referrer
            visits = entry.referrer_visits

            # Group referrers by URL
            referrers_grouped_by_url[url] ||= { visits: 0, referrers: [] }
            referrers_grouped_by_url[url][:visits] += visits

            # Add referrer data to the list of referrers for this URL
            referrers_grouped_by_url[url][:referrers] << { url: referrer, visits: visits }
          end

          # Step 4: Limit referrers to top 5 for each URL
          referrers_grouped_by_url.each do |url, data|
            data[:referrers] = data[:referrers].sort_by { |r| -r[:visits] }.first(5)
          end

          # Step 5: Store result for the day
          result[date] = referrers_grouped_by_url
        end

        result
        end

        # Return the final response
        render json: @stats
      end





      private

      # Format the data for top URLs
      def format_top_urls_response(stats)
        stats.group_by { |s| s.date.to_s }.transform_values do |daily_stats|
          daily_stats.map do |stat|
            { url: stat.url, visits: stat.visits }
          end
        end
      end

      # Format the data for top referrers
    # Helper method to format the result in the expected structure
    def format_top_referrers_response(referrers)
    # Group the results by date and url
    referrers_grouped_by_date_and_url = referrers.group_by(&:date).transform_values do |entries|
        entries.group_by(&:url).transform_values do |url_entries|
        # Limit to top 5 referrers per URL
        top_referrers = url_entries.sort_by { |entry| -entry.referrer_visits }.take(5)

        # Format each entry with the referrer URL and visit count
        {
            visits: url_entries.sum(&:referrer_visits),
            referrers: top_referrers.map { |entry| { url: entry.referrer, visits: entry.referrer_visits } }
        }
        end
    end

    # Return the grouped and formatted data
    referrers_grouped_by_date_and_url
    end
    end
  end
end
