require 'httparty'
require 'rufus-scheduler'
require 'vonage'


def get_quote
  r = HTTParty.get('https://morbotron.com/api/random')
  # Check if our request had a valid response.
  if r.code == 200
      json = r.parsed_response
      # Extract the episode number and timestamp from the API response.
      _, episode, timestamp = json["Frame"].values

      # Build a proper URL
      image_url = "https://morbotron.com/meme/" + episode + "/" + timestamp.to_s

      # Combine each line of subtitles into one string, seperated by newlines.
      caption = json["Subtitles"].map{|subtitle| subtitle["Content"]}.join("\n")

      return image_url, caption
  end
end

def start_scheduler(time)
  scheduler = Rufus::Scheduler.new

  scheduler.every time do
    send_sms
  end
  scheduler.join
end

def send_sms
  client = Vonage::Client.new(api_key: 'YOUR_API_KEY', api_secret: 'YOUR_API_SECRET')
  client.sms.send(from: 'TelephoneNumber', to: 'TelephoneNumber', text: get_quote.to_s)
end

start_scheduler('2s')
