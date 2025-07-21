-- Criação da tabela pesquisadores
CREATE TABLE IF NOT EXISTS pesquisadores (
    pesquisadores_id UUID NOT NULL DEFAULT uuid_generate_v4(),
    lattes_id VARCHAR(16) NOT NULL,
    nome VARCHAR(200) NOT NULL,
    PRIMARY KEY (pesquisadores_id)
);

-- Criação da tabela producoes
CREATE TABLE IF NOT EXISTS producoes (
    producoes_id UUID NOT NULL DEFAULT uuid_generate_v4(),
    pesquisadores_id UUID NOT NULL,
    issn VARCHAR(16) NOT NULL,
    nomeArtigo TEXT NOT NULL,
    anoArtigo INTEGER NOT NULL,
    PRIMARY KEY (producoes_id),
    CONSTRAINT fkey FOREIGN KEY (pesquisadores_id)
        REFERENCES pesquisadores (pesquisadores_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);