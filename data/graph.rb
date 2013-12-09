require "date"
require "./db"

YEAR = "2004"
UNIXTIME = Date.parse("#{YEAR}-01-01").to_time.to_i
FILEPATH = "edges-#{YEAR}.gdf"


def generate_nodes
  db = DB.open
  deputados = db.execute("SELECT * FROM votos GROUP BY nome")

  f = File.open(FILEPATH, 'w')
  f.write("nodedef>name VARCHAR, partido VARCHAR, estado VARCHAR\n")

  for deputado in deputados
    f.write("#{deputado[2]},#{deputado[3]},#{deputado[4]}\n")
  end

  f.close
end

def generate_edges
  db = DB.open

  f = File.open(FILEPATH, 'a')
  # f.write("Weight;Type;Source;Target;Voto\n")
  f.write("edgedef>node1 VARCHAR, node2 VARCHAR, weight DOUBLE, time INTEGER\n")

  votos = db.execute <<-eos
    SELECT * FROM votos AND votacao_id IN
      (SELECT id FROM votacoes WHERE
       data > date("#{YEAR}-01-01") AND data < date("#{YEAR}-12-31"));
  eos
  # Cria tuplas ["Deputado", "Voto"] e
  tuplas = votos.map{|v| [v[2], v[5]]}

  # Faz combinação
  pares_votos = tuplas.combination(2)

  deputados = {}
  # Itera combinação e se votou igual, escreve no grafo
  for par_voto in pares_votos
    voto0 = par_voto[0][1]
    voto1 = par_voto[1][1]
    next unless ["Sim", "Não"].include?(voto0) and ["Sim", "Não"].include?(voto1)
    deputados[par_voto[0][0]] ||= {}
    deputados[par_voto[0][0]][par_voto[1][0]] ||= 0
    if par_voto[0][1] == par_voto[1][1] and
      deputados[par_voto[0][0]][par_voto[1][0]] += 1
      # f.write("\"#{par_voto[0][0]}\",\"#{par_voto[1][0]}\",#{par_voto[0][1]}\n")
    else
      deputados[par_voto[0][0]][par_voto[1][0]] -= 1
    end
  end

  min_value = 99999999999999999999
  max_value = -99999999999
  count = 0
  deputados.each_pair do |source, values|
    values.each_pair do |target, value|
      min_value = value if value < min_value
      max_value = value if value > max_value
      f.write("\"#{source}\",\"#{target}\",#{value},#{UNIXTIME}\n") if value > 0
      count += 1 if value <= 0
    end
  end
    
  STDERR.puts deputados.length
  STDERR.puts min_value
  STDERR.puts max_value
  STDERR.puts count
  f.close
end

generate_nodes
generate_edges
