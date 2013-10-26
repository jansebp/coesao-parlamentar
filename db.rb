require "sqlite3"

class DB
  FILEPATH = "db.sqlite3"

  def self.open
    @@db ||= SQLite3::Database.new(FILEPATH)
  end

  def self.setup
    File.delete(FILEPATH) if File.exists?(FILEPATH)

    db = SQLite3::Database.new(FILEPATH)

    # Create a database
    db.execute_batch <<-SQL
      create table proposicoes (
        id integer,
        nome varchar(30),

        PRIMARY KEY(id)
      );
      CREATE UNIQUE INDEX proposicao_id ON proposicoes(id);


      create table partidos (
        sigla varchar(30),
        PRIMARY KEY(sigla)
      );
      CREATE UNIQUE INDEX partido_sigla ON partidos(sigla);


      create table deputados (
        id integer,
        PRIMARY KEY(id)
      );

      create table votacoes (
        id integer PRIMARY KEY AUTOINCREMENT,
        resumo text,
        objetivo text,
        data text
      );
      CREATE UNIQUE INDEX votacao_id ON votacoes(id);


      create table votos (
        id integer PRIMARY KEY AUTOINCREMENT,
        votacao_id integer,
        nome varchar(30),
        partido varchar(5),
        uf varchar(2),
        voto varchar(10)
      );
      CREATE UNIQUE INDEX voto_id ON votos(id);


      create table orientacoes_bancada (
        id integer PRIMARY KEY AUTOINCREMENT,
        votacao_id integer,
        sigla varchar(20),
        voto varchar(10)
      );
      CREATE UNIQUE INDEX orientacao_bancada_id ON orientacoes_bancada(id);
    SQL
  end
end