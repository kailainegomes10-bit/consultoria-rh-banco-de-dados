-- =====================================================================
-- Panigalli RH Consultoria - Script 04: relatórios
-- 10 consultas com SELECT, WHERE, ORDER BY e JOIN
-- =====================================================================

-- ---------------------------------------------------------------------
-- Relatório 1: Vagas abertas com a empresa e o consultor responsável
-- Pergunta: quais vagas ainda estão abertas, de qual empresa e quem cuida?
-- ---------------------------------------------------------------------
SELECT v.id_vaga, v.titulo, v.salario, v.modalidade,
       e.razao_social AS empresa, e.cidade,
       co.nome        AS consultor_responsavel
FROM vaga v
JOIN empresa_cliente e ON e.id_empresa   = v.id_empresa
JOIN consultor co      ON co.id_consultor = v.id_consultor
WHERE v.status = 'Aberta'
ORDER BY v.salario DESC;

-- ---------------------------------------------------------------------
-- Relatório 2: Candidatos aprovados e a vaga que conquistaram
-- Pergunta: quem foi aprovado, em qual vaga e em qual empresa?
-- ---------------------------------------------------------------------
SELECT ca.nome AS candidato, v.titulo AS vaga, e.razao_social AS empresa,
       cd.nota_entrevista, cd.data_candidatura
FROM candidatura cd
JOIN candidato ca      ON ca.id_candidato = cd.id_candidato
JOIN vaga v            ON v.id_vaga       = cd.id_vaga
JOIN empresa_cliente e ON e.id_empresa    = v.id_empresa
WHERE cd.status = 'Aprovado'
ORDER BY cd.nota_entrevista DESC, ca.nome;

-- ---------------------------------------------------------------------
-- Relatório 3: Quantidade de candidatos por vaga (atributo derivado)
-- Pergunta: quais vagas em seleção receberam mais candidatos?
-- ---------------------------------------------------------------------
SELECT v.id_vaga, v.titulo, e.razao_social AS empresa,
       COUNT(cd.id_candidatura) AS total_candidatos
FROM vaga v
JOIN empresa_cliente e ON e.id_empresa = v.id_empresa
JOIN candidatura cd    ON cd.id_vaga   = v.id_vaga
WHERE v.status IN ('Aberta', 'Em seleção')
GROUP BY v.id_vaga, v.titulo, e.razao_social
ORDER BY total_candidatos DESC, v.id_vaga;

-- ---------------------------------------------------------------------
-- Relatório 4: Desempenho dos consultores
-- Pergunta: quais consultores mais preencheram vagas?
-- ---------------------------------------------------------------------
SELECT co.nome AS consultor, co.especialidade,
       COUNT(v.id_vaga) AS vagas_preenchidas
FROM consultor co
JOIN vaga v ON v.id_consultor = co.id_consultor
WHERE v.status = 'Preenchida'
GROUP BY co.id_consultor, co.nome, co.especialidade
ORDER BY vagas_preenchidas DESC, co.nome;

-- ---------------------------------------------------------------------
-- Relatório 5: Candidatos com Pós-graduação ou Mestrado e seus telefones
-- Pergunta: como contatar os candidatos mais qualificados? (multivalorado)
-- ---------------------------------------------------------------------
SELECT ca.nome, cv.escolaridade, cv.area_formacao, t.tipo, t.telefone
FROM candidato ca
JOIN curriculo cv          ON cv.id_candidato = ca.id_candidato
JOIN candidato_telefone t  ON t.id_candidato  = ca.id_candidato
WHERE cv.escolaridade IN ('Pós-graduação', 'Mestrado')
ORDER BY ca.nome, t.tipo;

-- ---------------------------------------------------------------------
-- Relatório 6: Candidatos cuja pretensão salarial cabe no salário da vaga
-- Pergunta: em quais candidaturas o salário oferecido atende a pretensão?
-- ---------------------------------------------------------------------
SELECT ca.nome AS candidato, cv.pretensao_salarial,
       v.titulo AS vaga, v.salario AS salario_vaga, cd.status
FROM candidatura cd
JOIN candidato ca ON ca.id_candidato = cd.id_candidato
JOIN curriculo cv ON cv.id_candidato = ca.id_candidato
JOIN vaga v       ON v.id_vaga       = cd.id_vaga
WHERE cv.pretensao_salarial <= v.salario
  AND v.status IN ('Aberta', 'Em seleção')
ORDER BY (v.salario - cv.pretensao_salarial) DESC;

-- ---------------------------------------------------------------------
-- Relatório 7: Média salarial das vagas por área e modalidade
-- Pergunta: quanto pagam, em média, as vagas remotas de cada área?
-- ---------------------------------------------------------------------
SELECT v.area, v.modalidade,
       COUNT(*)                 AS qtd_vagas,
       ROUND(AVG(v.salario), 2) AS media_salarial
FROM vaga v
JOIN empresa_cliente e ON e.id_empresa = v.id_empresa
WHERE v.modalidade = 'Remoto'
GROUP BY v.area, v.modalidade
ORDER BY media_salarial DESC;

-- ---------------------------------------------------------------------
-- Relatório 8: Idade dos candidatos em entrevista (atributo derivado idade)
-- Pergunta: quem está em entrevista, com qual idade e para qual vaga?
-- ---------------------------------------------------------------------
SELECT vi.nome, vi.idade, v.titulo AS vaga, cd.nota_entrevista
FROM vw_candidato_idade vi
JOIN candidatura cd ON cd.id_candidato = vi.id_candidato
JOIN vaga v         ON v.id_vaga       = cd.id_vaga
WHERE cd.status = 'Entrevista'
  AND vi.idade BETWEEN 22 AND 30
ORDER BY vi.idade, cd.nota_entrevista DESC;

-- ---------------------------------------------------------------------
-- Relatório 9: Empresas de São Paulo e quantas vagas abriram
-- Pergunta: quais clientes de SP mais demandam a consultoria?
-- ---------------------------------------------------------------------
SELECT e.razao_social, e.cidade, e.ramo_atividade,
       COUNT(v.id_vaga) AS total_vagas,
       SUM(CASE WHEN v.status = 'Preenchida' THEN 1 ELSE 0 END) AS vagas_preenchidas
FROM empresa_cliente e
JOIN vaga v ON v.id_empresa = e.id_empresa
WHERE e.uf = 'SP'
GROUP BY e.id_empresa, e.razao_social, e.cidade, e.ramo_atividade
ORDER BY total_vagas DESC, e.razao_social;

-- ---------------------------------------------------------------------
-- Relatório 10: Taxa de aprovação por área de formação
-- Pergunta: candidatos de quais formações são mais aprovados?
-- ---------------------------------------------------------------------
SELECT cv.area_formacao,
       COUNT(*) AS candidaturas,
       SUM(CASE WHEN cd.status = 'Aprovado' THEN 1 ELSE 0 END) AS aprovacoes,
       ROUND(100.0 * SUM(CASE WHEN cd.status = 'Aprovado' THEN 1 ELSE 0 END) / COUNT(*), 2) AS taxa_aprovacao
FROM candidatura cd
JOIN curriculo cv ON cv.id_candidato = cd.id_candidato
JOIN vaga v       ON v.id_vaga       = cd.id_vaga
WHERE v.status <> 'Cancelada'
GROUP BY cv.area_formacao
ORDER BY taxa_aprovacao DESC;
