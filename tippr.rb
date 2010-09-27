require 'pp'
require 'savon'

client = Savon::Client.new "http://www.openligadb.de/Webservices/Sportsdata.asmx?WSDL"

teams = {}
resp = client.get_teams_by_league_saison{|soap| soap.body = {'wsdl:leagueShortcut' => 'bl1', 'wsdl:leagueSaison' => '2010'}}
resp.to_hash[:get_teams_by_league_saison_response][:get_teams_by_league_saison_result][:team].each {|t| teams[t[:team_id]] = t[:team_name] }

resp = client.get_current_group_order_id{|soap| soap.body = {'wsdl:leagueShortcut' => 'bl1'}}
days = resp.to_hash[:get_current_group_order_id_response][:get_current_group_order_id_result].to_i - 1

team_goals = Hash.new(0)
start = days > 3 ? days - 3 : days
(start..days).each do |current_day|
  resp = client.get_matchdata_by_group_league_saison{|soap| soap.body = {'wsdl:groupOrderID' => current_day, 'wsdl:leagueShortcut' => 'bl1', 'wsdl:leagueSaison' => '2010'}}
  matches = resp.to_hash[:get_matchdata_by_group_league_saison_response][:get_matchdata_by_group_league_saison_result][:matchdata]
  matches.each do |d|
    points_team1 = d[:points_team1].to_i
    points_team2 = d[:points_team2].to_i
    # if days - 3 <= current_day
    #   points_team1 += (points_team1 > points_team2 ? 2 : points_team1 < points_team2 ? -2 : 0)
    #   points_team2 += (points_team2 > points_team1 ? 2 : points_team2 < points_team1 ? -2 : 0)
    # end
    team_goals[d[:id_team1]] += points_team1
    team_goals[d[:id_team2]] += points_team2
  end
end

puts "results based on #{days} playing days:"
teams.each do|team_id, team_name|
  goals = team_goals[team_id]
  goals_even = (goals * 1.0 / (days - start)).round
  puts format("%1$*2$s %3$*4$s <<< %5$s goals (teamID=%6$s)", goals_even, 3, team_name, -20, goals, team_id)
end