require 'json'

PARTIES = {
  "DEM" => "Democratas",
  "PAN" => "Partido Ação Nacional",
  "PCdoB" => "Partido Comunista do Brasil",
  "PDT" => "Partido Democrático Trabalhista",
  "PEN" => "Partido Ecológico Nacional",
  "PFL" => "Partido da Frente Liberal",
  "PHS" => "Partido Humanosta da Solidariedade",
  "PL" => "Partido Liberal",
  "PMDB" => "Partido do Movimento Democrático Brasileiro",
  "PMN" => "Partido da Mobilização Nacional",
  "PMR" => "Partido Municipalista Renovador",
  "PP" => "Partido Progressista",
  "PPB" => "Partido Progressista Brasileiro",
  "PPL" => "Partido da Pátria Livre",
  "PPS" => "Partido Popular Socialista",
  "PR" => "Partido da República",
  "PRB" => "Partido Republicano Brasileiro",
  "PRONA" => "Partido de Reedificação da Ordem Nacional",
  "PROS" => "Partido Republicano da Ordem Social",
  "PRP" => "Partido Republicano Progressista",
  "PRTB" => "Partido Renovador Trabalhista Brasileiro",
  "PSB" => "Partido Socialista Brasileiro",
  "PSC" => "Partido Social Cristão",
  "PSD" => "Partido Social Democrátivo",
  "PSDB" => "Partido da Social Democracia Brasileira",
  "PSDC" => "Partido Social Democrata Cristão",
  "PSL" => "Partido Social Liberal",
  "PSOL" => "Partido Socialismo e Liberdade",
  "PST" => "Partido Social Trabalhista",
  "PSTU" => "Partido Socialista dos Trabalhadores Unificado",
  "PT" => "Partido dos Trabalhadores",
  "PTB" => "Partido Trabalhista Brasileiro",
  "PTC" => "Partido Trabalhista Cristão",
  "PTN" => "Partido Trabalhista Nacional",
  "PTdoB" => "Partido Trabalhista do Brasil",
  "PV" => "Partido Verde",
  "SDD" => "Solidariedade",
  "Mensaleiros" => "Deputados condenados no mensalão"
}

DATA_PATH = "../app/data"

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
