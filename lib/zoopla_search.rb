class ZooplaSearch
  # Full docs: https://developer.zoopla.co.uk/docs/read/Property_listings
  BASE_QUERY = {
    api_key: Configs.fetch('ZOOPLA_API_KEY'),
    order_by: 'age',
    listing_status: 'rent',
    page_size: 25,
    include_rented: false,
    minimum_price: ((1200 * 12) / 52).to_i,
    maximum_price: ((1600 * 12) / 52).to_i,
    minimum_beds: '1',
  }

  DATE_FROM = "2018-01-01"
  DATE_TO = "2018-05-20"

  SEARCHES = [
    {
      area: 'Finchley Road & Frognal Station, London',
    },
    {
      area: "St John's Wood, London, London",
    },
    {
      area: 'Belsize Park, London',
    },
    {
      area: 'Swiss Cottage, London',
    },
  ]

  BASE_URL = 'https://api.zoopla.co.uk/api/v1/property_listings.json'

  def listings
    SEARCHES.map do |search_query|
      JSON.parse(search_zoopla(search_query))['listing'].each do |source|
        source["area"] = search_query[:area].gsub(', London', '')
        unless source['available_from_date']
          puts "No `available_from_date`, skipping"
          next
        end

        source["from"] = Date.parse(source["available_from_date"])

        unless source["from"] > Date.parse(DATE_FROM) && source["from"] < Date.parse(DATE_TO)
          puts "Not available in specific date range: #{source["from"]}"
          next
        end

        source
      end
    end.flatten.compact
  end

private

  def search_zoopla(search_query)
    query = BASE_QUERY.merge(search_query)
    puts "Executing Zoopla search: #{query}"
    HTTParty.get(BASE_URL, query: query).body
  end
end
