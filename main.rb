require "nokogiri"
require "httparty"

require "./request_wrapper"
require "./proposicao"

def url_lista_proposicoes(ano)
  return "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=#{ano}&tipo="   
end

def get_proposicoes_ano(ano)
  proposicoes = []

  # Make request
  response = RequestWrapper.get(url_lista_proposicoes(ano))
  parsed_proposicoes = response["proposicoes"]["proposicao"]

  puts "* Lista de proposições #{ano}"

  for p in parsed_proposicoes
    # Create object and add to array
    proposicao = Proposicao.new(p["codProposicao"])
    proposicoes << proposicao

    puts "** Votações: #{proposicao.votacoes.size} / #{proposicao.nome} "
  end

  return proposicoes
end

for ano in (1998 .. 2013)
  get_proposicoes_ano(ano)
end

