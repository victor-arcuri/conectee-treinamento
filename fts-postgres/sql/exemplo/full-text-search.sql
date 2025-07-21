-- DOCUMENTO
select post.title || ' ' || post.content || ' ' || author.name || ' ' || coalesce(string_agg(tag.name, ' '), '') as document 
from post
join author on author.id = post.author_id
join posts_tags on posts_tags.post_id = post.id
join tag on tag.id = posts_tags.tag_id
group by post.id, post.title, post.content, author.name;


-- DOCUMENTO EM TS_VECTOR

select to_tsvector(post.title) || ' ' || to_tsvector(post.content) || ' ' || to_tsvector(author.name) || ' ' || to_tsvector(coalesce(string_agg(tag.name, ' '), '')) as document 
from post
join author on author.id = post.author_id
join posts_tags on posts_tags.post_id = post.id
join tag on tag.id = posts_tags.tag_id
group by post.id, post.title, post.content, author.name;


-- CONSULTA DE POSTS NO DOCUMENTO

select p_id, p_title
from (
	select post.id as p_id, post.title as p_title, 
	to_tsvector(post.title) || ' ' || 
	to_tsvector(post.content) || ' ' || 
	to_tsvector(author.name) || ' ' || 
	to_tsvector(coalesce(string_agg(tag.name, ' '), '')) as document 
	from post
	join author on author.id = post.author_id
	join posts_tags on posts_tags.post_id = post.id
	join tag on tag.id = posts_tags.tag_id
	group by post.id, post.title, post.content, author.name
) p_search
where p_search."document" @@ to_tsquery('Endangered & Species');


-- SUPORTE PARA IDIOMAS
alter table post add language text not null default('english');

select p_id, p_title
from (
	select post.id as p_id, post.title as p_title, 
	to_tsvector(post.language::regconfig, post.title) || ' ' || 
	to_tsvector(post.language::regconfig,post.content) || ' ' || 
	to_tsvector('simple',author.name) || ' ' || 
	to_tsvector('simple',coalesce(string_agg(tag.name, ' '), '')) as document 
	from post
	join author on author.id = post.author_id
	join posts_tags on posts_tags.post_id = post.id
	join tag on tag.id = posts_tags.tag_id
	group by post.id, post.title, post.content, author.name
) p_search
where p_search."document" @@ to_tsquery('Endangered & Species');


--- SUPORTE À ACENTUAÇÃO
-- opção lenta e falha
CREATE EXTENSION unaccent;


select post.id as p_id, post.title as p_title, 
    to_tsvector(post.language::regconfig, unaccent(post.title)) || ' ' || 
    to_tsvector(post.language::regconfig,unaccent(post.content)) || ' ' || 
    to_tsvector('simple',unaccent(author.name)) || ' ' || 
    to_tsvector('simple',unaccent(coalesce(string_agg(tag.name, ' '), ''))) as document 
from post
join author on author.id = post.author_id
join posts_tags on posts_tags.post_id = post.id
join tag on tag.id = posts_tags.tag_id
group by post.id, post.title, post.content, author.name


-- opção otimizada (criação de configurações de idioma suportados)

CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french );
ALTER TEXT SEARCH CONFIGURATION fr ALTER MAPPING
FOR hword, hword_part, word WITH unaccent, french_stem;

select post.id as p_id, post.title as p_title, 
    to_tsvector(post.language, post.title) || ' ' || 
    to_tsvector(post.language,post.content) || ' ' || 
    to_tsvector('simple',author.name) || ' ' || 
    to_tsvector('simple',coalesce(string_agg(tag.name, ' '), '')) as document 
from post
join author on author.id = post.author_id
join posts_tags on posts_tags.post_id = post.id
join tag on tag.id = posts_tags.tag_id
group by post.id, post.title, post.content, author.name

-- CLASSIFICAÇÃO DE DOCUMENTOS
SELECT pid, p_title
FROM (SELECT post.id as pid,
         	post.title as p_title,
         	setweight(to_tsvector(post.language::regconfig, post.title), 'A') ||
         	setweight(to_tsvector(post.language::regconfig, post.content), 'B') ||
         	setweight(to_tsvector('simple', author.name), 'C') ||
         	setweight(to_tsvector('simple', coalesce(string_agg(tag.name, ' '))), 'B') as document
  	FROM post
  	JOIN author ON author.id = post.author_id
  	JOIN posts_tags ON posts_tags.post_id = posts_tags.tag_id
  	JOIN tag ON tag.id = posts_tags.tag_id
  	GROUP BY post.id, author.id) p_search
WHERE p_search.document @@ to_tsquery('english', 'Endangered & Species')
ORDER BY ts_rank(p_search.document, to_tsquery('english', 'Endangered & Species')) DESC;



-- CRIA VISÃO MATERIALIZADA DOS POSTS

CREATE MATERIALIZED VIEW search_index AS
SELECT post.id,
   	post.title,
   	setweight(to_tsvector(post.language::regconfig, post.title), 'A') ||
   	setweight(to_tsvector(post.language::regconfig, post.content), 'B') ||
   	setweight(to_tsvector('simple', author.name), 'C') ||
   	setweight(to_tsvector('simple', coalesce(string_agg(tag.name, ' '))), 'A') as document
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = posts_tags.tag_id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id


-- ATUALIZA A VISÃO 
REFRESH MATERIALIZED VIEW search_index

-- INDEXA A VISÃO
CREATE INDEX idx_fts_search ON search_index USING gin(document);

-- CONSULTA COM RANQUEAMENTO

SELECT id as post_id, title
FROM search_index
WHERE document @@ to_tsquery('english', 'Endangered & Species')
ORDER BY ts_rank(p_search.document, to_tsquery('english', 'Endangered & Species')) DESC;


-- FUZZY SEARCH

CREATE EXTENSION pg_trgm;

CREATE MATERIALIZED VIEW unique_lexeme AS
SELECT word FROM ts_stat(
'SELECT to_tsvector('simple', post.title) ||
	to_tsvector('simple', post.content) ||
	to_tsvector('simple', author.name) ||
	to_tsvector('simple', coalesce(string_agg(tag.name, ' ')))
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = posts_tags.tag_id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id');

CREATE INDEX words_idx ON search_words USING gin(word gin_trgm_ops);

REFRESH MATERIALIZED VIEW unique_lexeme;

SELECT word
WHERE similarity(word, 'samething') > 0.5
ORDER BY word <-> 'samething'
LIMIT 1;

