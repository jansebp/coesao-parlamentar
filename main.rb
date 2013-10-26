require "nokogiri"
require "httparty"

require "./request_wrapper"
require "./db"

require "./models/proposicao"
require "./models/votacoes"

def url_lista_proposicoes(ano)
  return "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=#{ano}&tipo="
end

def get_proposicoes_ano(ano)
  # Make request to get list
  response = RequestWrapper.get(url_lista_proposicoes(ano))
  parsed_proposicoes = response["proposicoes"]["proposicao"]

  puts "* Lista de proposições #{ano}"

  for p in parsed_proposicoes
    begin
      proposicao = Proposicao.new(p["codProposicao"])
    rescue IOError, MultiXml::ParseError => e
      puts "!!! Problema proposição. Pulando proposição ID: #{p["codProposicao"]} #{e}"
      next
    end

    begin
      votacoes = Votacoes.new(proposicao)
    rescue IOError, MultiXml::ParseError => e
      puts "!!! Problema votações. Pulando proposição ID: #{p["codProposicao"]} #{e}"
      next
    end
  end
end

DB.setup

# 1998.. 2013
for ano in (1998 .. 2013)
  get_proposicoes_ano(ano)
end

