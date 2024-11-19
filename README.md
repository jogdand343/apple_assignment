# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 3.3.6

* System dependencies

* Configuration

* Database creation: 
rails db:create
rails db:migrate

* Database initialization
  rails data:generate

* How to run the test suite
  bundle exec rspec --format documentation
  curl -X GET http://localhost:3000/api/v1/top_urls # Wont recommend as it goes through a million records if the dataset is generated
  #### To get top 3 number of page views per URL, grouped by day, for the past 5 days
  curl -X GET http://localhost:3000/api/v1/top_urls | jq 'to_entries | map({date: .key, top_urls: .value | sort_by(.visits) | reverse | .[:3]})'
  #### to retrieve the top 5 referrers for the top 10 URLs grouped by day, for the past 5 days
  curl -X GET http://localhost:3000/api/v1/top_referrers
  

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
