require 'net/http'
require 'json'
require 'uri'
require 'date'

module Jekyll
  class APIFetcher < Generator
    safe true
    priority :low

    TEAM_ID = 280084
    CACHE_FILENAME = "ctftime_data.json"
    CACHE_DIR = "_data"
    CACHE_FILE = CACHE_DIR + "/" + CACHE_FILENAME

    def generate_results_urls()
      curr_year = Date.today.year
      urls = []
      [curr_year, curr_year-1].each do |year| # Fetch from this and last year
        urls.push("https://ctftime.org/api/v1/results/" + year.to_s + "/")
      end

      return urls
    end

    def fetch_json(url)
        uri = URI(url)
        puts "[API Fetcher] Fetching data from #{url}"

        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
            return JSON.parse(response.body)
        else
            puts "[CTFTime] Failed to fetch data: #{response.code} #{response.message}"
        end
    rescue => e
      puts "[CTFTime] Error: #{e.message}"
    end

    def result_has_team(result)
      return result["scores"].filter { |score| score["team_id"] == TEAM_ID }
    end

    def generate(site)
      relevant_results = nil
      
      if !File.exist?(CACHE_FILE) || Time.now - File.mtime(CACHE_FILE) > 86000 # One day minus a few minutes to not interfere with the cron job
        relevant_results = []
        generate_results_urls().each do |results_url|
          results_json = fetch_json(results_url)

          results_json.each do |key, value|
            relevant_result = result_has_team(value)
            if relevant_result.length > 0
              result = relevant_result.first
              result["title"] = value["title"]
              result["event_id"] = key
              result["time"] = value["time"]
              relevant_results.push(result)
            end
          end
        end
        FileUtils.mkdir_p(CACHE_DIR) unless Dir.exist?(CACHE_DIR)
        File.write(CACHE_FILE, JSON.pretty_generate(relevant_results))
      else
        age = Time.now - File.mtime(CACHE_FILE)
        puts "[CTFTime] Using cached data (#{(age / 60).round} minutes old)"
        relevant_results = JSON.parse(File.read(CACHE_FILE))
      end

      relevant_results.sort_by! { |result| result["time"] } # These are both in-place, sorting from recent to not
      relevant_results.reverse!

      # Inject into site.data
      site.data['ctftime_data'] = relevant_results

      puts "[CTFTime] Success!"
    end
  end
end