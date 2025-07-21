-- DOCUMENTO
select 
    producoes.nomeArtigo || ' ' || 
    producoes.anoArtigo || ' ' || 
    producoes.issn || ' ' ||
    pesquisadores.nome || ' ' ||
    pesquisadores.lattes_id as document
from producoes 
join
    pesquisadores on producoes.pesquisadores_id = pesquisadores.pesquisadores_id;


-- DOCUMENTO EM TS_VECTOR
select 
    to_tsvector(producoes.nomeArtigo) || ' ' || 
    to_tsvector(producoes.anoArtigo::text) || ' ' || 
    to_tsvector(producoes.issn) || ' ' ||
    to_tsvector(pesquisadores.nome) || ' ' ||
    to_tsvector(pesquisadores.lattes_id) as document
from producoes 
join
    pesquisadores on producoes.pesquisadores_id = pesquisadores.pesquisadores_id;


-- CONSULTA DE ARTIGOS
select autor, issn, nome
from (
    select 
        pesquisadores.nome as autor,
        producoes.issn as issn, 
        producoes.nomeArtigo as nome,
        to_tsvector(producoes.nomeArtigo) || ' ' || 
        to_tsvector(producoes.anoArtigo::text) || ' ' || 
        to_tsvector(producoes.issn) || ' ' ||
        to_tsvector(pesquisadores.nome) || ' ' ||
        to_tsvector(pesquisadores.lattes_id) as document
    from producoes 
    join
        pesquisadores on producoes.pesquisadores_id = pesquisadores.pesquisadores_id
) p_search
where 
    p_search.document @@ to_tsquery('Dengue');


-- SUPORTE PARA IDIOMAS E ACENTUAÇÃO
CREATE EXTENSION unaccent;
alter table producoes add idioma text not null default('pt');

CREATE TEXT SEARCH CONFIGURATION en ( COPY = english );
ALTER TEXT SEARCH CONFIGURATION en ALTER MAPPING
FOR hword, hword_part, word WITH unaccent, english_stem;


CREATE TEXT SEARCH CONFIGURATION pt ( COPY = portuguese );
ALTER TEXT SEARCH CONFIGURATION pt ALTER MAPPING
FOR hword, hword_part, word WITH unaccent, portuguese_stem;

select autor, issn, nome
from (
    select 
        pesquisadores.nome as autor,
        producoes.issn as issn, 
        producoes.nomeArtigo as nome,
        to_tsvector(producoes.idioma::regconfig,producoes.nomeArtigo) || ' ' || 
        to_tsvector('simple',producoes.anoArtigo::text) || ' ' || 
        to_tsvector('simple',producoes.issn) || ' ' ||
        to_tsvector('simple',pesquisadores.nome) || ' ' ||
        to_tsvector('simple',pesquisadores.lattes_id) as document
    from producoes 
    join
        pesquisadores on producoes.pesquisadores_id = pesquisadores.pesquisadores_id
) p_search
where 
    p_search.document @@ to_tsquery('Dengue');


-- OTIMIZAÇÃO E INDEXAÇÃO