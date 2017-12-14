json.array!(@emails) do |email|
  json.extract! email, 'source', 'destinations'
  json.email "#{email['source']}@#{@email_domain}"
end
