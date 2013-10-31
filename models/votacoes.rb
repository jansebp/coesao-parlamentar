class Votacoes
  BASE_URL = "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx"

  attr_reader :id, :proposicao, :dados

  def initialize(proposicao)
    @proposicao = proposicao

    save
  end

  def save
    response = RequestWrapper.get(url_votes)["proposicao"]

    # If response["Votacoes"]["Votacao"] is a hash, it means there is only
    # one "votacao". If there are more than 1, it is an array.
    # WTF, parser? Why not an array with 1 element? :(
    if response["Votacoes"]
      if response["Votacoes"]["Votacao"].class == Hash
        @dados = response["Votacoes"]

        save_votacao(response["Votacoes"]["Votacao"])
      elsif response["Votacoes"]["Votacao"].class == Array
        @dados = response["Votacoes"]["Votacao"]

        for votacao in response["Votacoes"]["Votacao"]
          save_votacao(votacao)
        end
      end
    end

    puts "*** Votações: #{@dados.size}" if @dados.size > 0
  end

  def save_votacao(votacao)
    DB.open.execute("INSERT OR REPLACE INTO votacoes (proposicao_id, resumo, objetivo, data) 
              VALUES (?, ?, ?, ?)", [self.proposicao.id, votacao["Resumo"], votacao["ObjVotacao"], votacao["Data"]])

    @id = DB.open.last_insert_row_id

    transaction do
      if votacao["orientacaoBancada"]
        save_orientacoes_bancada(votacao) 
      end

      if votacao["votos"] # Ex: PRC 5/1999
        save_votos(votacao)
      end
    end
  end

  def save_orientacoes_bancada(votacao)
    sql = "INSERT INTO orientacoes_bancada (votacao_id, sigla, voto) VALUES (?, ?, ?)"
    
    DB.open.prepare(sql) do |stmt|
      for orientacao in votacao["orientacaoBancada"]["bancada"]
        stmt.execute([@id, orientacao["Sigla"], orientacao["orientacao"].strip])
      end
    end
  end

  def save_votos(votacao)
    sql = "INSERT INTO votos (votacao_id, nome, partido, uf, voto) VALUES (?, ?, ?, ?, ?)"
    
    DB.open.prepare(sql) do |stmt|
      for deputado in votacao["votos"]["Deputado"]
        stmt.execute([@id, deputado["Nome"], deputado["Partido"], deputado["UF"], deputado["Voto"]])
      end
    end
  end

  def transaction
    DB.open.execute("BEGIN IMMEDIATE TRANSACTION")
    yield
    DB.open.execute("COMMIT TRANSACTION")
  end

  def url_votes
    return "#{BASE_URL}/ObterVotacaoProposicao?" + 
               "tipo=#{@proposicao.dados['tipo'].strip}&" + 
               "numero=#{@proposicao.dados['numero']}&" + 
               "ano=#{@proposicao.dados['ano']}"
  end
end