require 'open-uri'
require 'nokogiri'

nba_teams_page = Nokogiri::HTML(open("http://espn.go.com/nba/players"))

nba_teams_links = nba_teams_page.css("a")

def isolateTeamname(team)
	if !team.nil?
		teamname = team.split("/")

		if teamname.length == 9
			if teamname[4] == "team"
				return teamname[7]
			end
		end
	end

	return nil   #team not found
end

def isolatePlayersOnTeam(players)
	players.each do |player|
		linkToPlayerPage = player['href']
		
		playerpage = Nokogiri::HTML(open("#{linkToPlayerPage}"))

		isolatePlayerData(playerpage)

	end
end

def isolatePlayerData(playerData)

	playerBioData = playerData.css("ul.player-metadata")

	if !playerBioData.css("span")[0].nil?

		newPlayer = Player.new

		firstName, lastName = isolatePlayerNames(playerData)
		newPlayer.first_name = firstName
		newPlayer.last_name = lastName

		if !playerData.css("div.main-headshot img")[0].nil?
			newPlayer.image_url = playerData.css("div.main-headshot img")[0]['src']
		end

		bio = playerBioData.css("li")[0].text

		# isolate city and state
		if bio.include?("in")  # test if contains birthplace
			city, state, country = isolatePlayerBirthplace(bio)

			newPlayer.city = city
			newPlayer.state = state
			newPlayer.country = country

		end

		newPlayer.save
	end
end

def isolatePlayerNames(data)
	nameString = data.css("h1")[1].text

	names = nameString.split(" ")
	firstName = names[0]
	lastName = names[1]

	return firstName, lastName
end

def isolatePlayerBirthplace(bio)
	bio = parseBirthplaceString(bio)

	city, state, country = nil

	if bio.include?(",")   # if true, player from US and bio includes city and state
		bio = bio.split(",")  # parse bio to isolate city and state
		city = bio[0]
		state = bio[1]
		country = "USA"

	else					# non-US player and ESPN only provides country of origin (city not provided)
		country = bio
	end

	return city, state, country
end

def parseBirthplaceString(bio)
	bio = bio.split("in ")
	bio = bio[1].split("(")
	bio = bio[0]

	return bio
end

nba_teams_links.each do |team|

	teamname = isolateTeamname(team['href'])

	if !teamname.nil?

		teampage = Nokogiri::HTML(open("http://espn.go.com/nba/team/roster/_/name/#{teamname}"))

		isolatePlayersOnTeam(teampage.css("td a"))

	end
end