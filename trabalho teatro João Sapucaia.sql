create schema Teatro; 
use teatro;

create table pecas_teatro(
id_peca int auto_increment Primary key,
nome_peca VARCHAR(100),
descricao TEXT,
duracao INT,
data_peca DATE,
genero VARCHAR(100),
autor VARCHAR(100),
faixas_etarias VARCHAR(100),
constraint id_pecapk primary key (id_peca));

insert into pecas_teatro (nome_peca, descricao, duracao, data_peca, genero, autor, faixas_etarias)
Values("la casa de papel","assalto a casa da moeda",90,20241125,"suspense","ale horas","18 anos");

select * from pecas_teatro;

DELIMITER $$
CREATE FUNCTION calcular_duracao(
p_id_peca INT
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_duracao INT;

    SELECT duracao INTO v_duracao
    FROM pecas_teatro
    WHERE id_peca = p_id_peca;
    RETURN v_duracao;
END$$

DELIMITER;
SELECT calcular_duracao_peca(3);


DELIMITER $$
CREATE FUNCTION calcular_media_duracao()
RETURNS DECIMAL(10,2)
DETERMINISTIC

BEGIN
DECLARE v_media_duracao DECIMAL(10,2);
SELECT AVG (duracao) INTO v_media_duracao
FROM pecas_teatro;
RETURN v_media_duracao;
END$$

DELIMITER ;
SELECT calcular_media_duracao();


DELIMITER $$
CREATE FUNCTION verificar_disponibilidade(
p_data DATE
)

RETURNS INT
DETERMINISTIC

BEGIN
DECLARE v_existe INT;
SELECT COUNT(*)
INTO v_existe
FROM pecas_teatro
WHERE DATE(data_peca) = p_data;

    RETURN CASE
	WHEN v_existe > 0 THEN 0
	ELSE 1
    END;
END$$

DELIMITER;
SELECT verificar_disponibilidade('2024-10-31');


DELIMITER $$
CREATE PROCEDURE agendar_peca(
    IN p_nome_peca VARCHAR(100),
    IN p_descricao VARCHAR(100),
    IN p_duracao INT,
    IN p_data_peca DATE,
    IN p_autor varchar(100)
)

BEGIN
DECLARE v_disponibilidade BOOLEAN;
DECLARE v_media_duracao DECIMAL(10,2);

   
SET v_disponibilidade = verificar_disponibilidade(p_data_peca);
    IF v_disponibilidade = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data escolhida esta indisponivel.';
    END IF;

    INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_peca, autor)
    VALUES (p_nome_peca, p_descricao, p_duracao, p_data_peca, p_autor);

    SET v_media_duracao = calcular_media_duracao();

    SELECT 
	CONCAT('Peça agendada com exito: ', p_nome_peca) AS Mensagem,
	CONCAT('A média de duração da peça é de: ', v_media_duracao, ' minutos') AS Media_Duracao;
END$$


DELIMITER ;
CALL agendar_peca(
    'Minions',
    'A partir de 10 anos',
    240,                  
    '2024-11-05',        
    35.00                
);