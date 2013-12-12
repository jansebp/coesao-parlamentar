require "pry"
require "csv"
require "json"
require "./db"

YEARS = (2000..2008)
PARTIES = %w(PT PMDB PSOL)

FILEPATH = "../app/data/PARTY-YEAR.json"

def generate_json(party, year)
  db = DB.open

  deputados = []
  deputados_index = {}
  links = {}

  votos = db.execute <<-eos
    SELECT * FROM votos WHERE partido='#{party}' AND voto IN ("Sim", "Não") AND
      votacao_id IN
      (SELECT id FROM votacoes WHERE
       data > date("#{year}-01-01") AND data < date("#{year}-12-31"));
  eos

  if votos.empty?
    puts "[Matrix] Empty matrix for #{party} in #{year}. No file created."
    return
  else
    puts "[Matrix] Generating matrix for #{party} in #{year}"
  end

  votacoes_deputados = votos.group_by { |voto| voto[2] } # nome
  votacoes = votos.group_by { |voto| voto[1] } # votacao_id
  votacoes.each_pair { |key, votacao| votacoes[key] = votacao.group_by { |v| v[5] } }

  # deputados_comunidades = {}
  # CSV.read('/tmp/edges.csv').each { |dep| deputados_comunidades[dep[0]] = dep[5] }

  votacoes_deputados.each_pair do |nome, voto|
    deputados_index[nome] = deputados.length
    deputados << { "name" => nome }
  end

  links = {}
  votacoes_deputados.each_pair do |nome, votos|
    index = deputados_index[nome]
    votos.each do |voto|
      votacao_id = voto[1]
      votacao = votacoes[votacao_id]
      escolha = voto[5]
      links[index] ||= {}
      if escolha == "Sim"
        votacao.fetch("Sim", []).each do |outro_deputado|
          outro_index = deputados_index[outro_deputado[2]]
          links[index][outro_index] ||= 0
          links[index][outro_index] += 1
        end
      else
        votacao.fetch("Não", []).each do |outro_deputado|
          outro_index = deputados_index[outro_deputado[2]]
          links[index][outro_index] ||= 0
          links[index][outro_index] += 1
        end
      end
    end
  end

  formatted_links = []
  links.each_pair do |source, values|
    values.each_pair do |target, value|
      deputado1 = deputados[source]['name']
      deputado2 = deputados[target]['name']
      votos_deputado1 = votacoes_deputados[deputado1]
      votos_deputado2 = votacoes_deputados[deputado2]
      votacoes1 = votos_deputado1.map { |x| x[1] }
      votacoes2 = votos_deputado2.map { |x| x[1] }
      votacoes_em_conjunto = (votacoes1 & votacoes2).length

      v = (value/votacoes_em_conjunto.to_f).round(3)

      formatted_links << { 'source' => source, 'target' => target, 'value' => v }
    end
  end

  stats = { 'voting_sessions' => votacoes.size }

  json = { 'links' => formatted_links, 'nodes' => deputados, 'stats' => stats }
  
  filepath = FILEPATH.gsub("PARTY", party.downcase).gsub("YEAR", year.to_s)

  File.open(filepath, 'w+') do |file|
    file.write JSON.dump(json)
  end
end


PARTIES.each do |p|
  YEARS.each do |y|
    generate_json(p, y)
  end
end
