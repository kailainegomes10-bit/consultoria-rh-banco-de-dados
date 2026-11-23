-- =====================================================================
-- Panigalli RH Consultoria - Script 03: operações CRUD
-- Rode cada bloco separadamente no SQL Editor do Supabase.
-- =====================================================================

-- ---------------------------------------------------------------------
-- C - CREATE (INSERT)
-- Cadastro de uma nova candidata, com currículo, telefone e candidatura
-- ---------------------------------------------------------------------
INSERT INTO candidato (nome, cpf, email, data_nascimento,
                       logradouro, numero, bairro, cidade, uf, cep)
VALUES ('Letícia Moraes Prado', '98765432100', 'leticia.prado@email.com', '2004-03-15',
        'Rua das Palmeiras', '250', 'Centro', 'São Paulo', 'SP', '01001000')
RETURNING *;

INSERT INTO curriculo (id_candidato, escolaridade, area_formacao, anos_experiencia,
                       pretensao_salarial, data_atualizacao)
SELECT id_candidato, 'Superior Incompleto', 'Tecnologia da Informação', 1, 2800.00, CURRENT_DATE
FROM candidato WHERE cpf = '98765432100'
RETURNING *;

INSERT INTO candidato_telefone (id_candidato, telefone, tipo)
SELECT id_candidato, '(11) 91234-5678', 'Celular'
FROM candidato WHERE cpf = '98765432100'
RETURNING *;

INSERT INTO candidatura (id_candidato, id_vaga, data_candidatura, status)
SELECT c.id_candidato, 5, CURRENT_DATE, 'Inscrito'
FROM candidato c WHERE c.cpf = '98765432100'
RETURNING *;

-- ---------------------------------------------------------------------
-- R - READ (SELECT)
-- Consulta da candidata cadastrada com currículo e telefone
-- ---------------------------------------------------------------------
SELECT c.id_candidato, c.nome, c.email, c.cidade, c.uf,
       cv.escolaridade, cv.area_formacao, cv.pretensao_salarial,
       t.telefone, t.tipo
FROM candidato c
JOIN curriculo cv           ON cv.id_candidato = c.id_candidato
JOIN candidato_telefone t   ON t.id_candidato  = c.id_candidato
WHERE c.cpf = '98765432100';

-- ---------------------------------------------------------------------
-- U - UPDATE
-- A candidata foi chamada para entrevista e atualizou a pretensão salarial
-- ---------------------------------------------------------------------
UPDATE candidatura
SET status = 'Entrevista',
    nota_entrevista = 8.50
WHERE id_candidato = (SELECT id_candidato FROM candidato WHERE cpf = '98765432100')
  AND id_vaga = 5
RETURNING *;

UPDATE curriculo
SET pretensao_salarial = 3200.00,
    data_atualizacao   = CURRENT_DATE
WHERE id_candidato = (SELECT id_candidato FROM candidato WHERE cpf = '98765432100')
RETURNING *;

-- ---------------------------------------------------------------------
-- D - DELETE
-- A candidata pediu para sair do banco de talentos (LGPD).
-- Por causa do ON DELETE CASCADE, currículo, telefones e candidaturas
-- dela também são apagados automaticamente.
-- ---------------------------------------------------------------------
DELETE FROM candidato
WHERE cpf = '98765432100'
RETURNING id_candidato, nome;

-- Conferência: não deve retornar nenhuma linha
SELECT * FROM candidato WHERE cpf = '98765432100';
