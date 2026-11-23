-- =====================================================================
-- Panigalli RH Consultoria - Script 02: carga de dados
-- Gera os registros com generate_series a partir de listas de nomes,
-- cidades, cargos etc. A função HASHTEXT() embaralha as escolhas de forma
-- fixa (rodar de novo gera exatamente os mesmos dados).
-- Os dados seguem as regras de negócio:
--   * todo candidato tem 1 currículo e pelo menos 1 telefone
--   * a data da candidatura é sempre depois da abertura da vaga
--   * vaga "Preenchida" tem exatamente 1 candidato "Aprovado"
--   * candidato "Inscrito" ainda não tem nota de entrevista
-- Rode DEPOIS do 01_criacao_tabelas.sql (com as tabelas vazias).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) EMPRESA_CLIENTE - 500 registros
-- ---------------------------------------------------------------------
INSERT INTO empresa_cliente
    (razao_social, cnpj, ramo_atividade, email_contato,
     logradouro, numero, bairro, cidade, uf, cep, data_cadastro)
SELECT
    n1[1 + (i - 1) % 25] || ' ' || n2[1 + ((i - 1) / 25) % 20] || ' Ltda',
    LPAD(((i::BIGINT * 2654435761) % 100000000)::TEXT, 8, '0') || '0001' || LPAD((10 + (i * 37) % 90)::TEXT, 2, '0'),
    ramo[1 + ABS(HASHTEXT(i || 's1')::BIGINT) % 10],
    'rh@empresa' || LPAD(i::TEXT, 3, '0') || '.com.br',
    rua[1 + ABS(HASHTEXT(i || 's2')::BIGINT) % 15],
    (10 + ABS(HASHTEXT(i || 'num')::BIGINT) % 1990)::TEXT,
    bairro[1 + ABS(HASHTEXT(i || 's3')::BIGINT) % 12],
    cid[1 + ABS(HASHTEXT(i || 's4')::BIGINT) % 15],
    uf[1 + ABS(HASHTEXT(i || 's4')::BIGINT) % 15],
    (10000000 + (i::BIGINT * 2654435761) % 89999999)::TEXT,
    DATE '2023-01-02' + (ABS(HASHTEXT(i || 'cad')::BIGINT) % 850)::INT
FROM generate_series(1, 500) AS i,
LATERAL (SELECT
    ARRAY['Alfa','Nova','Prime','Vértice','Horizonte','Atlas','Solaris','Ômega','Delta','Integra',
          'Vale','Sigma','Aurora','Rota','Brasil','Nexus','Ponto','Zênite','Fortis','Lumen',
          'Tríade','Ágil','Polo','Vetor','Rumo']                                         AS n1,
    ARRAY['Tecnologia','Alimentos','Logística','Serviços','Comércio','Engenharia','Saúde','Varejo',
          'Indústria','Transportes','Distribuidora','Construtora','Energia','Educação','Química',
          'Têxtil','Agro','Seguros','Telecom','Metalúrgica']                              AS n2,
    ARRAY['Tecnologia','Varejo','Indústria','Saúde','Logística','Educação','Construção civil',
          'Agronegócio','Serviços financeiros','Alimentação']                             AS ramo,
    ARRAY['Rua das Flores','Av. Paulista','Rua XV de Novembro','Av. Brasil','Rua Sete de Setembro',
          'Av. Independência','Rua São José','Rua Tiradentes','Av. Getúlio Vargas','Rua Dom Pedro II',
          'Rua Santos Dumont','Av. das Nações','Rua Rui Barbosa','Av. Rio Branco','Rua Marechal Deodoro'] AS rua,
    ARRAY['Centro','Jardim América','Vila Nova','Santa Cruz','Boa Vista','Jardim Paulista',
          'Vila Mariana','São Bernardo','Parque Industrial','Cidade Nova','Bela Vista','Alto da Glória'] AS bairro,
    ARRAY['São Paulo','Campinas','Ribeirão Preto','Sorocaba','Santos','Curitiba','Belo Horizonte',
          'Rio de Janeiro','Porto Alegre','Florianópolis','Goiânia','Salvador','Recife','Londrina','Uberlândia'] AS cid,
    ARRAY['SP','SP','SP','SP','SP','PR','MG','RJ','RS','SC','GO','BA','PE','PR','MG']        AS uf
) AS listas
ORDER BY i;

-- ---------------------------------------------------------------------
-- 2) CONSULTOR - 500 registros
-- ---------------------------------------------------------------------
INSERT INTO consultor
    (nome, cpf, email, especialidade, salario, data_contratacao)
SELECT
    pn[1 + ABS(HASHTEXT(i || 's6')::BIGINT) % 40] || ' ' || sn[1 + ABS(HASHTEXT(i || 's7')::BIGINT) % 30] || ' ' || sn[1 + (ABS(HASHTEXT(i || 's7')::BIGINT) + 1 + ABS(HASHTEXT(i || 's8')::BIGINT) % 29) % 30],
    LPAD(((i::BIGINT * 2654435761 + 7) % 100000000000)::TEXT, 11, '0'),
    'consultor' || LPAD(i::TEXT, 4, '0') || '@panigallirh.com.br',
    esp[1 + ABS(HASHTEXT(i || 's9')::BIGINT) % 8],
    4500 + (ABS(HASHTEXT(i || 'sal')::BIGINT) % 60) * 100,
    DATE '2015-01-05' + (ABS(HASHTEXT(i || 'adm')::BIGINT) % 3700)::INT
FROM generate_series(1, 500) AS i,
LATERAL (SELECT
    ARRAY['Ana','Bruno','Camila','Diego','Eduarda','Felipe','Gabriela','Henrique','Isabela','João',
          'Karina','Lucas','Mariana','Nicolas','Olívia','Pedro','Rafaela','Samuel','Tatiane','Vinícius',
          'Amanda','Bernardo','Carolina','Daniel','Elaine','Fábio','Giovana','Gustavo','Helena','Igor',
          'Juliana','Kevin','Larissa','Matheus','Natália','Otávio','Patrícia','Rodrigo','Sabrina','Thiago'] AS pn,
    ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Ferreira','Rodrigues','Almeida',
          'Nascimento','Carvalho','Gomes','Martins','Araújo','Ribeiro','Barbosa','Rocha','Dias','Teixeira',
          'Moreira','Cardoso','Mendes','Freitas','Castro','Pinto','Campos','Monteiro','Vieira','Ramos'] AS sn,
    ARRAY['Recrutamento e Seleção','Tecnologia','Executive Search','Operacional','Saúde',
          'Varejo','Financeiro','Engenharia']                                             AS esp
) AS listas
ORDER BY i;

-- ---------------------------------------------------------------------
-- 3) CANDIDATO - 1000 registros
-- ---------------------------------------------------------------------
INSERT INTO candidato
    (nome, cpf, email, data_nascimento,
     logradouro, numero, bairro, cidade, uf, cep)
SELECT
    pn[1 + ABS(HASHTEXT(i || 's10')::BIGINT) % 40] || ' ' || sn[1 + ABS(HASHTEXT(i || 's11')::BIGINT) % 30] || ' ' || sn[1 + (ABS(HASHTEXT(i || 's11')::BIGINT) + 1 + ABS(HASHTEXT(i || 's12')::BIGINT) % 29) % 30],
    LPAD(((i::BIGINT * 3486784401 + 13) % 100000000000)::TEXT, 11, '0'),
    TRANSLATE(LOWER(pn[1 + ABS(HASHTEXT(i || 's10')::BIGINT) % 40] || '.' || sn[1 + (ABS(HASHTEXT(i || 's11')::BIGINT) + 1 + ABS(HASHTEXT(i || 's12')::BIGINT) % 29) % 30]),
              'áàâãéêíóôõúç', 'aaaaeeiooouc') || i || '@email.com',
    DATE '1970-01-01' + (ABS(HASHTEXT(i || 'nasc')::BIGINT) % 12400)::INT,
    rua[1 + ABS(HASHTEXT(i || 's15')::BIGINT) % 15],
    (1 + ABS(HASHTEXT(i || 'num')::BIGINT) % 2500)::TEXT,
    bairro[1 + ABS(HASHTEXT(i || 's16')::BIGINT) % 12],
    cid[1 + ABS(HASHTEXT(i || 's17')::BIGINT) % 15],
    uf[1 + ABS(HASHTEXT(i || 's17')::BIGINT) % 15],
    (10000000 + (i::BIGINT * 3486784401) % 89999999)::TEXT
FROM generate_series(1, 1000) AS i,
LATERAL (SELECT
    ARRAY['Ana','Bruno','Camila','Diego','Eduarda','Felipe','Gabriela','Henrique','Isabela','João',
          'Karina','Lucas','Mariana','Nicolas','Olívia','Pedro','Rafaela','Samuel','Tatiane','Vinícius',
          'Amanda','Bernardo','Carolina','Daniel','Elaine','Fábio','Giovana','Gustavo','Helena','Igor',
          'Juliana','Kevin','Larissa','Matheus','Natália','Otávio','Patrícia','Rodrigo','Sabrina','Thiago'] AS pn,
    ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Ferreira','Rodrigues','Almeida',
          'Nascimento','Carvalho','Gomes','Martins','Araújo','Ribeiro','Barbosa','Rocha','Dias','Teixeira',
          'Moreira','Cardoso','Mendes','Freitas','Castro','Pinto','Campos','Monteiro','Vieira','Ramos'] AS sn,
    ARRAY['Rua das Flores','Av. Paulista','Rua XV de Novembro','Av. Brasil','Rua Sete de Setembro',
          'Av. Independência','Rua São José','Rua Tiradentes','Av. Getúlio Vargas','Rua Dom Pedro II',
          'Rua Santos Dumont','Av. das Nações','Rua Rui Barbosa','Av. Rio Branco','Rua Marechal Deodoro'] AS rua,
    ARRAY['Centro','Jardim América','Vila Nova','Santa Cruz','Boa Vista','Jardim Paulista',
          'Vila Mariana','São Bernardo','Parque Industrial','Cidade Nova','Bela Vista','Alto da Glória'] AS bairro,
    ARRAY['São Paulo','Campinas','Ribeirão Preto','Sorocaba','Santos','Curitiba','Belo Horizonte',
          'Rio de Janeiro','Porto Alegre','Florianópolis','Goiânia','Salvador','Recife','Londrina','Uberlândia'] AS cid,
    ARRAY['SP','SP','SP','SP','SP','PR','MG','RJ','RS','SC','GO','BA','PE','PR','MG']        AS uf
) AS listas
ORDER BY i;

-- ---------------------------------------------------------------------
-- 4) CANDIDATO_TELEFONE (multivalorado) - 1700 registros
--    todos têm celular; metade tem residencial; 1 em cada 5 tem recado
-- ---------------------------------------------------------------------
INSERT INTO candidato_telefone (id_candidato, telefone, tipo)
SELECT c.id_candidato, t.telefone, t.tipo
FROM candidato c
CROSS JOIN LATERAL (SELECT
    LPAD(((c.id_candidato::BIGINT * 2654435761) % 100000000)::TEXT, 8, '0')      AS cel,
    LPAD(((c.id_candidato::BIGINT * 3486784401) % 10000000)::TEXT, 7, '0')       AS res,
    LPAD(((c.id_candidato::BIGINT * 1103515245 + 12345) % 100000000)::TEXT, 8, '0') AS rec
) AS n
CROSS JOIN LATERAL (
    VALUES
      ('(' || (11 + ABS(HASHTEXT(c.id_candidato || 'ddd')::BIGINT) % 89) || ') 9' || SUBSTR(cel, 1, 4) || '-' || SUBSTR(cel, 5, 4), 'Celular', TRUE),
      ('(' || (11 + ABS(HASHTEXT(c.id_candidato || 'ddd')::BIGINT) % 89) || ') 3' || SUBSTR(res, 1, 3) || '-' || SUBSTR(res, 4, 4), 'Residencial', c.id_candidato % 2 = 0),
      ('(' || (11 + ABS(HASHTEXT(c.id_candidato || 'ddd')::BIGINT) % 89) || ') 9' || SUBSTR(rec, 1, 4) || '-' || SUBSTR(rec, 5, 4), 'Recado', c.id_candidato % 5 = 0)
) AS t(telefone, tipo, incluir)
WHERE t.incluir
ORDER BY c.id_candidato;

-- ---------------------------------------------------------------------
-- 5) CURRICULO (1:1 com candidato) - 1000 registros
--    anos de experiência nunca passam de (idade - 18)
-- ---------------------------------------------------------------------
INSERT INTO curriculo
    (id_candidato, escolaridade, area_formacao, anos_experiencia,
     pretensao_salarial, data_atualizacao)
SELECT
    c.id_candidato,
    esc[1 + nivel],
    area[1 + ABS(HASHTEXT(c.id_candidato || 's19')::BIGINT) % 10],
    exp_anos,
    1800 + exp_anos * 250 + nivel * 600,
    DATE '2025-01-02' + (ABS(HASHTEXT(c.id_candidato || 'atu')::BIGINT) % 600)::INT
FROM candidato c,
LATERAL (SELECT
    ABS(HASHTEXT(c.id_candidato || 'esc')::BIGINT) % 6 AS nivel,
    LEAST(ABS(HASHTEXT(c.id_candidato || 'exp')::BIGINT) % 25,
          DATE_PART('year', AGE(DATE '2026-11-01', c.data_nascimento))::INT - 18) AS exp_anos,
    ARRAY['Ensino Médio','Técnico','Superior Incompleto','Superior Completo','Pós-graduação','Mestrado'] AS esc,
    ARRAY['Administração','Tecnologia da Informação','Recursos Humanos','Contabilidade','Engenharia',
          'Enfermagem','Marketing','Logística','Direito','Vendas']                     AS area
) AS x
ORDER BY c.id_candidato;

-- ---------------------------------------------------------------------
-- 6) VAGA - 600 registros
--    toda empresa tem pelo menos 1 vaga e todo consultor cuida de pelo menos 1
-- ---------------------------------------------------------------------
INSERT INTO vaga
    (id_empresa, id_consultor, titulo, area, salario, modalidade, data_abertura, status)
SELECT
    1 + (i - 1) % 500,
    1 + (i * 7 - 1) % 500,
    tit[k],
    area[k],
    base[k] + (ABS(HASHTEXT(i || 'sal')::BIGINT) % 15) * 100,
    (ARRAY['Presencial','Remoto','Híbrido'])[1 + ABS(HASHTEXT(i || 's20')::BIGINT) % 3],
    DATE '2025-06-02' + (ABS(HASHTEXT(i || 'abe')::BIGINT) % 520)::INT,
    (ARRAY['Aberta','Aberta','Aberta','Aberta','Em seleção','Em seleção',
           'Preenchida','Preenchida','Preenchida','Cancelada'])[1 + ABS(HASHTEXT(i || 's21')::BIGINT) % 10]
FROM generate_series(1, 600) AS i,
LATERAL (SELECT
    1 + ABS(HASHTEXT(i || 'cargo')::BIGINT) % 20 AS k,
    ARRAY['Analista de RH','Desenvolvedor Back-end','Desenvolvedor Front-end','Assistente Administrativo',
          'Auxiliar de Logística','Vendedor Interno','Analista Financeiro','Enfermeiro','Técnico de Enfermagem',
          'Engenheiro Civil','Analista de Marketing','Recepcionista','Operador de Produção','Supervisor de Vendas',
          'Analista de Dados','Contador','Advogado Trabalhista','Motorista Entregador','Gerente de Loja','Suporte Técnico'] AS tit,
    ARRAY['Recursos Humanos','Tecnologia','Tecnologia','Administrativo','Logística','Comercial','Financeiro',
          'Saúde','Saúde','Engenharia','Marketing','Administrativo','Indústria','Comercial','Tecnologia',
          'Financeiro','Jurídico','Logística','Varejo','Tecnologia']                    AS area,
    ARRAY[3800,6500,6000,2300,2000,2500,4800,5200,3100,9000,4200,1900,2200,4500,7000,5500,7500,2600,5000,2800]::DECIMAL[] AS base
) AS listas
ORDER BY i;

-- ---------------------------------------------------------------------
-- 7) CANDIDATURA (N:N candidato x vaga) - 2000 registros
--    cada candidato se candidata a 2 vagas diferentes
-- ---------------------------------------------------------------------
INSERT INTO candidatura
    (id_candidato, id_vaga, data_candidatura, status, nota_entrevista)
WITH base AS (
    SELECT c.id_candidato,
           v.id_vaga,
           v.status AS status_vaga,
           v.data_abertura + (ABS(HASHTEXT(c.id_candidato || '-' || k)::BIGINT) % 20)::INT AS data_cand,
           ROUND((4 + (ABS(HASHTEXT(c.id_candidato || 'nota' || k)::BIGINT) % 61) / 10.0)::NUMERIC, 2) AS nota,
           k
    FROM candidato c
    CROSS JOIN generate_series(0, 1) AS k
    -- k = 0: (id * 7) % 600 percorre as 600 vagas (toda vaga recebe candidatos)
    -- k = 1: outra vaga sorteada, sempre diferente da primeira
    JOIN vaga v ON v.id_vaga = 1 + ((c.id_candidato * 7) % 600
                                    + k * (1 + ABS(HASHTEXT(c.id_candidato || 'vg')::BIGINT) % 599)) % 600
),
ranqueada AS (
    SELECT b.*,
           ROW_NUMBER() OVER (PARTITION BY id_vaga ORDER BY nota DESC, id_candidato) AS posicao
    FROM base b
)
SELECT id_candidato,
       id_vaga,
       data_cand,
       CASE
         WHEN status_vaga = 'Aberta'     AND (id_candidato + k) % 2 = 0 THEN 'Inscrito'
         WHEN status_vaga = 'Aberta'                                    THEN 'Entrevista'
         WHEN status_vaga = 'Em seleção'                                THEN 'Entrevista'
         WHEN status_vaga = 'Preenchida' AND posicao = 1                THEN 'Aprovado'
         ELSE 'Reprovado'
       END,
       CASE
         WHEN status_vaga = 'Aberta' AND (id_candidato + k) % 2 = 0 THEN NULL
         WHEN status_vaga = 'Cancelada'                             THEN NULL
         ELSE nota
       END
FROM ranqueada
ORDER BY id_candidato, k;

-- Conferência da quantidade de registros por tabela
SELECT 'empresa_cliente'    AS tabela, COUNT(*) AS registros FROM empresa_cliente
UNION ALL SELECT 'consultor',          COUNT(*) FROM consultor
UNION ALL SELECT 'candidato',          COUNT(*) FROM candidato
UNION ALL SELECT 'candidato_telefone', COUNT(*) FROM candidato_telefone
UNION ALL SELECT 'curriculo',          COUNT(*) FROM curriculo
UNION ALL SELECT 'vaga',               COUNT(*) FROM vaga
UNION ALL SELECT 'candidatura',        COUNT(*) FROM candidatura;
