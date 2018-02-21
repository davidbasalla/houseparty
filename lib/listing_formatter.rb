class ListingFormatter
  INTERESTING_PROPERTIES = [
    "description",
    "num_bedrooms",
    "available_from_date",
    "first_published_date",
    "agent_name",
  ]

  attr_reader :source

  def initialize(source)
    @source = source
  end

  def payload
    {
      name: name,
      desc: description,
    }
  end

private

  def name
    address = source.fetch('displayable_address')
    price = source.fetch('rental_prices').fetch('per_month')
    area = source.fetch('area')
    from = source['available_from_date']
    "#{address} - £#{price} (#{area}#{formatted_from_date(from)})"
  end

  def description
    [
      "### " + source.fetch('details_url'),
      source.slice(*INTERESTING_PROPERTIES).map { |k,v| "**#{k}**: #{v}" },
      "**Google Maps**: https://www.google.co.uk/maps/place/#{url_safe_location}",
      "https://www.google.com/maps/dir/Queen+Square+Private+Consulting+Rooms,+Queen+Square,+London/#{url_safe_location}",
      "https://www.google.com/maps/dir/Chalfont+Centre+for+Epilepsy,+Chalfont+Saint+Peter,+Gerrards+Cross/#{url_safe_location}",
      "https://www.google.com/maps/dir/Red+Badger,+London/#{url_safe_location}",
      "https://www.google.com/maps/dir/Blue+Fin+Building,+110+Southwark+St,+London+SE1+0TA/#{url_safe_location}",
    ].flatten.join("\n\n")
  end

  def url_safe_location
    source.fetch('displayable_address').gsub(' ', '+')
  end

  def formatted_from_date(date)
    if date
      ", from #{date}"
    end
  end
end
