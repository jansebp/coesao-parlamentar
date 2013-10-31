require "./db"

FILEPATH = "edges.gdf"


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
  votacoes = db.execute("SELECT * FROM votacoes ORDER BY id DESC LIMIT 40")

  f = File.open(FILEPATH, 'a')
  # f.write("Weight;Type;Source;Target;Voto\n")
  f.write("edgedef>node1 VARCHAR, node2 VARCHAR, voto VARCHAR\n")

  for votacao in votacoes
    votos = db.execute("SELECT * FROM votos WHERE votacao_id = ?", votacao[0])

    # Cria tuplas ["Deputado", "Voto"] e 
    tuplas = votos.map{|v| [v[2], v[5]]}
    
    # Faz combinação
    pares_votos = tuplas.combination(2)

    # Itera combinação e se votou igual, escreve no grafo
    for par_voto in pares_votos
      if par_voto[0][1] == par_voto[1][1]
        f.write("\"#{par_voto[0][0]}\",\"#{par_voto[1][0]}\",#{par_voto[0][1]}\n")
      end
    end
  end
    
  f.close
end

generate_nodes
generate_edges