require 'pp'
require 'savon'

client = Savon::Client.new "http://www.openligadb.de/Webservices/Sportsdata.asmx?WSDL"
teams = {}
resp = client.get_teams_by_league_saison{|soap| soap.body = {'wsdl:leagueShortcut' => 'bl1', 'wsdl:leagueSaison' => '2010'}}
resp.to_hash[:get_teams_by_league_saison_response][:get_teams_by_league_saison_result][:team].each {|t| teams[t[:team_id]] = t[:team_name] }

resp = client.get_matchdata_by_group_league_saison{|soap| soap.body = {'wsdl:groupOrderID' => 1, 'wsdl:leagueShortcut' => 'bl1', 'wsdl:leagueSaison' => '2010'}}
team_goals = Hash.new(0)
days = {}
matches = resp.to_hash[:get_matchdata_by_group_league_saison_response][:get_matchdata_by_group_league_saison_result][:matchdata]
matches.each do |d| 
  days[d[:group_id]] = true
  team_goals[d[:id_team1]] += d[:points_team1].to_i
  team_goals[d[:id_team2]] += d[:points_team2].to_i
end

days = days.keys.size

teams.each do|team_id, team_name|
  goals = team_goals[team_id]
  goals_even = goals / days
  puts format("%1$*2$s %3$*4$s <<< %5$s goals for %6$s on %7$s days", goals_even, 3, team_name, -20, goals, team_id, days)
end