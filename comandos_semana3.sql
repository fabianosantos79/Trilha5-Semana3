-- INSERIR NOVO COLABORADOR
INSERT INTO brh.colaborador (
    matricula,
    cpf,
    nome,
    salario,
    departamento,
    cep,
    logradouro,
    complemento_endereco
) VALUES (
    'A124',
    '293.603.947-47',
    'Fulano de Tal',
    8750,
    'SEDES',
    '71111-100',
    'Avenida das Castanheiras',
    'Casa 30'
);

INSERT INTO brh.papel (
    id,
    nome
) VALUES (
    8,
    'Especialista de Neg�cios'
);

INSERT INTO brh.telefone_colaborador (
    colaborador,
    numero,
    tipo
) VALUES (
    'A124',
    '(61) 99999-9999',
    'M'
);

INSERT INTO brh.telefone_colaborador (
    colaborador,
    numero,
    tipo
) VALUES (
    'A124',
    '(61) 3030-4040',
    'R'
);

INSERT INTO brh.telefone_colaborador (
    colaborador,
    numero,
    tipo
) VALUES (
    'A124',
    '(61) 3587-2020',
    'C'
);

INSERT INTO brh.email_colaborador (
    colaborador,
    email,
    tipo
) VALUES (
    'A124',
    'fulano@email.com',
    'P'
);

INSERT INTO brh.email_colaborador (
    colaborador,
    email,
    tipo
) VALUES (
    'A124',
    'fulano.tal@brh.com',
    'T'
);

INSERT INTO brh.dependente (
    cpf,
    colaborador,
    nome,
    parentesco,
    data_nascimento
) VALUES (
    '832.987.154-12',
    'A124',
    'Beltrana de Tal',
    'Filho(a)',
    TO_DATE('2020-07-04', 'yyyy-mm-dd')
);

INSERT INTO brh.dependente (
    cpf,
    colaborador,
    nome,
    parentesco,
    data_nascimento
) VALUES (
    '367.419.374-22',
    'A124',
    'Cicrana de Tal',
    'C�njuge',
    TO_DATE('1987-10-13', 'yyyy-mm-dd')
);

INSERT INTO brh.projeto (
    id,
    nome,
    responsavel,
    inicio,
    fim
) VALUES (
    5,
    'BI',
    'N123',
    TO_DATE('2024-01-01', 'yyyy-mm-dd'),
    TO_DATE('2024-12-31', 'yyyy-mm-dd')
);

INSERT INTO brh.atribuicao (
    projeto,
    colaborador,
    papel
) VALUES (
    5,
    'A124',
    8
);



-- RELAT�RIO DE C�NJUGES
SELECT
    colab.nome AS nome_colaborador,
    depen.nome AS nome_conjuge,
    depen.data_nascimento AS data_nascimento_conjuge
FROM
         brh.colaborador colab
    INNER JOIN brh.dependente depen ON colab.matricula = depen.colaborador
WHERE
    depen.parentesco = 'C�njuge';



-- RELAT�RIO DE CONTATOS TELEF�NICOS
SELECT
    colab.nome,
    fone.numero,
    fone.tipo AS tipo_telefone,
    mail.email,
    mail.tipo AS tipo_email
FROM
         brh.telefone_colaborador fone
    INNER JOIN brh.colaborador colab ON colab.matricula = fone.colaborador
    INNER JOIN brh.email_colaborador mail ON colab.matricula = mail.colaborador
WHERE
        mail.tipo = 'T'
    AND ( fone.tipo = 'M'
          OR fone.tipo = 'C' );



-- COLABORADOR COM SAL�RIO MAIS ALTO
SELECT
    nome,
    salario
FROM
    brh.colaborador
WHERE
    salario = (
        SELECT
            MAX(salario)
        FROM
            brh.colaborador
    );



-- RELAT�RIO DE SENIORIDADE
SELECT
    matricula,
    nome,
    salario,
    (
        CASE
            WHEN salario <= 3000 THEN
                'J�nior'
            WHEN salario > 3000
                 AND salario <= 6000 THEN
                'Pleno'
            WHEN salario > 6000
                 AND salario <= 20000 THEN
                'S�nior'
            ELSE
                'Corpo Diretor'
        END
    ) AS senioridade
FROM
    brh.colaborador
ORDER BY
    senioridade,
    nome;
    
    
    
-- LISTAR COLABORADORES COM MAIS DEPENDENTES
SELECT
    colab.nome AS nome_colaborador,
    COUNT(depen.colaborador) AS quantidade_dependente
FROM
         brh.colaborador colab
    INNER JOIN brh.dependente depen ON colab.matricula = depen.colaborador
HAVING
    COUNT(depen.colaborador) >= 2
GROUP BY
    colab.nome
ORDER BY
    quantidade_dependente DESC,
    colab.nome;
    
    
    
-- RELAT�RIO DE DEPENDENTES MENORES DE IDADE
SELECT
    colab.matricula AS matricula_colaborador,
    depen.nome AS nome_dependente,
    trunc((months_between(sysdate, depen.data_nascimento)) / 12) AS idade_dependente
FROM
         brh.colaborador colab
    INNER JOIN brh.dependente depen ON colab.matricula = depen.colaborador
WHERE
    trunc((months_between(sysdate, depen.data_nascimento)) / 12) < 18;



-- RELAT�RIO ANAL�TICO DE EQUIPES
SELECT
    depto.nome  AS nome_departamento,
    depto.chefe,
    colab.nome  AS nome_colaborador,
    fone.numero AS telefone,
    depen.nome  AS nome_dependente,
    atribuicao.nome_papel,
    atribuicao.nome_projeto
FROM
         brh.departamento depto
    INNER JOIN brh.colaborador colab ON colab.departamento = depto.sigla
    INNER JOIN brh.telefone_colaborador fone ON fone.colaborador = colab.matricula
    INNER JOIN brh.dependente depen ON depen.colaborador = fone.colaborador
    INNER JOIN (
        SELECT
            papel.nome AS nome_papel,
            proj.nome AS nome_projeto,
            atrib.colaborador AS colaborador
        FROM
                 brh.papel papel
            INNER JOIN brh.atribuicao atrib ON atrib.papel = papel.id
            INNER JOIN brh.projeto proj ON atrib.projeto = proj.id
    )                        atribuicao ON depen.colaborador = atribuicao.colaborador
ORDER BY
    atribuicao.nome_projeto,
    colab.nome,
    depen.nome;