class Proposicao
  BASE_URL = "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx"

  attr_reader :dados, :votacoes, :id

  def initialize(codigo)
    @dados = {}
    @votacoes = []

    get_details(codigo)

    puts "** #{nome} (#{@dados["idProposicao"]}) "

    save
  end

  def nome
    "#{@dados['tipo'].strip} #{@dados['numero']}/#{@dados['ano']}"
  end

private
  def save
    DB.open.execute("INSERT OR REPLACE INTO proposicoes (id, nome) 
            VALUES (?, ?)", [@dados["idProposicao"], @dados["nomeProposicao"]])

    @id = DB.open.last_insert_row_id
  end

  def get_details(codigo)
    response = RequestWrapper.get(url_details(codigo))["proposicao"]
    @dados.merge!(response)
  end

  def url_details(id)
    return "#{BASE_URL}/ObterProposicaoPorID?IdProp=#{id}"
  end
end
