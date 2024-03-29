json.array!(@players) do |player|
  json.extract! player, :id, :first_name, :last_name, :city, :state, :country, :image_url, :team
  json.url player_url(player, format: :json)
end
