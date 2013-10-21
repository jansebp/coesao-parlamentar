class Proposicao
  BASE_URL = "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx"

  attr_reader :dados, :votacoes

  def initialize(codigo)
    @dados = {}
    @votacoes = []

    get_details(codigo)
    get_votes
  end

  def nome
    "#{@dados['tipo'].strip} #{@dados['numero']}/#{@dados['ano']}"
  end

private
  def get_details(codigo)
    response = RequestWrapper.get(url_details(codigo))["proposicao"]
    @dados.merge!(response)
  end

  def get_votes
    response = RequestWrapper.get(url_votes)["proposicao"]

    if response["Votacoes"]
      response["Votacoes"]["Votacao"].map{ |r| @votacoes << r }
    end

  rescue IOError, MultiXml::ParseError
    return
  end

  def url_details(id)
    return "#{BASE_URL}/ObterProposicaoPorID?IdProp=#{id}"
  end

  def url_votes
    return "#{BASE_URL}/ObterVotacaoProposicao?tipo=#{@dados['tipo'].strip}&numero=#{@dados['numero']}&ano=#{@dados['ano']}"
  end
end
