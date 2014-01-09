require 'json'

DATA_PATH = "../app/data"
PARTY = "PMDB"
PARTIES = {
  "PT" => "Partido dos Trabalhadores",
  "PSDB" => "Partido da Social Democracia Brasileira",
  "PMDB" => "Partido do Movimento Democrático Brasileiro",
  "PSOL" => "Partido Socialismo e Liberdade",
  "Mensaleiros" => "Deputados condenados no mensalão"
}

def do_it!(party)
  quartiles = {}
  sessions = {}
  deputados = {}
  Dir.glob("#{DATA_PATH}/#{party.downcase}-*.json").each do |path|
    path =~ /([0-9]{4}).json/
    year = $1
    json = JSON.parse File.read(path)
    values = json["links"].map { |l| l["value"] }
    first_quartile = (values.length * 0.25).to_i
    second_quartile = (values.length * 0.5).to_i
    third_quartile = (values.length * 0.75).to_i
    values.sort!
  
    quartiles[year] = [
      values[first_quartile],
      values[second_quartile],
      values[third_quartile]
    ]

    sessions[year] = {
      "total" => json["stats"]["total_voting_sessions"],
      "filtered" => json["stats"]["filtered_voting_sessions"]
    }

    sources = json["links"].map { |l| l["source"] }
    deputados[year] = sources.uniq.length
  end
  
  result = {
    "id" => party.downcase,
    "label" => party,
    "name" => PARTIES[party],
    "years" => quartiles.keys.sort,
    "quartiles" => quartiles,
    "sessions" => sessions,
    "deputados" => deputados
  }
  
  File.open("#{DATA_PATH}/#{party.downcase}.json", "w+") do |f|
    f.puts JSON.dump(result)
  end
end

PARTIES.each_pair do |party, v|
  puts "Generating #{party.downcase}.json..."
  do_it!(party)
end
