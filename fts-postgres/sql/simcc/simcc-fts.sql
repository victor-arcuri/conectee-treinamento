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
create materialized view search_index as
select 
    pesquisadores.nome as autor,
    producoes.issn as issn, 
    producoes.nomeArtigo as nome,
    setweight(to_tsvector(
    	case producoes.idioma
    		when 'en' then 'en'::regconfig
    		when 'pt' then 'pt'::regconfig
    	end, 
    	producoes.nomeArtigo
    ), 'A') ||
    setweight(to_tsvector('simple',producoes.anoArtigo::text), 'C') ||
    setweight(to_tsvector('simple',producoes.issn), 'C') ||
    setweight(to_tsvector('simple',pesquisadores.nome), 'B') ||
    setweight(to_tsvector('simple',pesquisadores.lattes_id), 'C') as document
from producoes 
join
    pesquisadores on producoes.pesquisadores_id = pesquisadores.pesquisadores_id;


refresh materialized view search_index;

create index idx_fts_search on search_index using gin(document);

select autor, issn, nome
from search_index
where document @@ to_tsquery('pt', 'Dengue')
order by ts_rank(document, to_tsquery('pt', 'Dengue')) desc;


-- FUZZY SEARCH
create extension pg_trgm;

create materialized view unique_lexeme as
select word from ts_stat(
    $$
    select
        to_tsvector('simple', public.producoes.nomeArtigo) || ' ' || 
        to_tsvector('simple',public.producoes.anoArtigo::text) || ' ' || 
        to_tsvector('simple',public.producoes.issn)|| ' ' || 
        to_tsvector('simple',public.pesquisadores.nome)|| ' ' || 
        to_tsvector('simple',public.pesquisadores.lattes_id)
    from public.producoes 
    join
        public.pesquisadores on public.producoes.pesquisadores_id = public.pesquisadores.pesquisadores_id
    $$
);

create index words_idx on unique_lexeme using gin(word gin_trgm_ops);

refresh materialized view unique_lexeme;

select word, similarity(word, 'Degue') as similarity
from unique_lexeme
where similarity(word, 'Degue') > 0.2
order by word <-> 'Degue'
limit 3