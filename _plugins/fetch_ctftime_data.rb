require 'net/http'
require 'json'
require 'uri'

module Jekyll
  class CTFTimeFetcher < Generator
    safe true
    priority :low

    TEAM_ID = 280084
    CACHE_FILENAME = "ctftime_data.json"
    CACHE_DIR = "_data"
    CACHE_FILE = CACHE_DIR + "/" + CACHE_FILENAME

    def generate_results_urls()
      curr_year = Time.now.year
      urls = []
      [curr_year].each do |year| # Fetch from just this year
        urls.push("https://ctftime.org/api/v1/results/#{year}/")
      end

      return urls
    end

    def generate_weight_url()
      start_of_year = Time.new(Time.now.year, 1, 1).to_i - 10518984 # Minus 4 months
      return "https://ctftime.org/api/v1/events/?limit=500&start=#{start_of_year}&finish=#{Time.now.to_i}"
    end

    def prepare_weight_data(data) # Converts list of event data to hash indexed by event id (no idea why it isnt done this way in the first place)
      events_by_id = {}
      data.each do |event|
        events_by_id[event["id"]] = event
      end

      return events_by_id
    end

    def fetch_json(url)
        uri = URI(url)
        puts "[CTFTime] Fetching data from #{url}"

        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
            return JSON.parse(response.body)
        else
            puts "[CTFTime] Failed to fetch data: #{response.code} #{response.message}"
        end
    rescue => e
      puts "[CTFTime] Error: #{e.message}"
    end

    def filter_scores_for_team(result) # Filters a list of scores to only those with the needed team id
      return result["scores"].filter { |score| score["team_id"] == TEAM_ID }
    end

    def get_best_points(result)
      return result["scores"].first["points"].to_i
    end

    def get_team_participation(result)
      return result["scores"].length
    end

    def generate(site)
      score_data = nil
      
      if !File.exist?(CACHE_FILE) || Time.now - File.mtime(CACHE_FILE) > 86000 # One day minus a few minutes to not interfere with the cron job
        weight_data = prepare_weight_data(fetch_json(generate_weight_url())) # Info about events (mainly used to get event weight for later calculation)
        
        score_data = []
        generate_results_urls().each do |results_url|
          results_json = fetch_json(results_url)

          results_json.each do |event_id, event_result|
            team_scores = filter_scores_for_team(event_result)
            if team_scores.length > 0
              score = team_scores.first
              score["points"] = score["points"].to_f
              score["title"] = event_result["title"]
              score["event_id"] = event_id.to_i
              score["time"] = event_result["time"]
              score["weight"] = weight_data.key?(event_id.to_i) ? weight_data[event_id.to_i]["weight"] : 0
              # Calculate rating points
              points_coef = score["points"] / get_best_points(event_result)
              place_coef = 1.0 / score["place"]
              score["rating"] = ((points_coef + place_coef) * score["weight"]) / (1.0 / (1.0 + (score["place"] / get_team_participation(event_result))))

              score_data.push(score)
            end
          end
        end
        FileUtils.mkdir_p(CACHE_DIR) unless Dir.exist?(CACHE_DIR)
        File.write(CACHE_FILE, JSON.pretty_generate(score_data))
      else
        age = Time.now - File.mtime(CACHE_FILE)
        puts "[CTFTime] Using cached data (#{(age / 60).round} minutes old)"
        score_data = JSON.parse(File.read(CACHE_FILE))
      end

      score_data.sort_by! { |result| result["time"] } # These are both in-place, sorting from recent to not
      score_data.reverse!

      # Inject into site.data
      site.data['ctftime_data'] = score_data

      puts "[CTFTime] Success!"
    end
  end
end