-- 1. Faturamento, custo e margem por mês
SELECT c.mes, SUM(i.quantidade*p.preco) AS faturamento,
       SUM(i.quantidade*p.custo) AS custo,
       SUM(i.quantidade*(p.preco-p.custo)) AS margem
FROM itens_pedido i
JOIN pedidos pe ON pe.pedido_id=i.pedido_id
JOIN produtos p ON p.produto_id=i.produto_id
JOIN calendario c ON c.data=pe.data_pedido
GROUP BY c.mes ORDER BY c.mes;

-- 2. Faturamento por forma de pagamento (% do total)
SELECT pe.forma_pagamento, SUM(i.quantidade*p.preco) AS faturamento,
       ROUND(100.0*SUM(i.quantidade*p.preco)/SUM(SUM(i.quantidade*p.preco)) OVER (),1) AS pct
FROM itens_pedido i JOIN pedidos pe ON pe.pedido_id=i.pedido_id
JOIN produtos p ON p.produto_id=i.produto_id
GROUP BY pe.forma_pagamento ORDER BY faturamento DESC;

-- 3. Litros de chopp vendidos por mês
SELECT c.mes, ROUND(SUM(i.quantidade*p.litros),1) AS litros
FROM itens_pedido i JOIN pedidos pe ON pe.pedido_id=i.pedido_id
JOIN produtos p ON p.produto_id=i.produto_id
JOIN calendario c ON c.data=pe.data_pedido
WHERE p.categoria='Chopp' GROUP BY c.mes ORDER BY c.mes;

-- 4. Ranking de produtos por margem
SELECT p.produto, SUM(i.quantidade) AS qtd,
       SUM(i.quantidade*(p.preco-p.custo)) AS margem,
       RANK() OVER (ORDER BY SUM(i.quantidade*(p.preco-p.custo)) DESC) AS posicao
FROM itens_pedido i JOIN produtos p ON p.produto_id=i.produto_id
GROUP BY p.produto;

-- 5. Ticket médio por dia da semana (1=segunda)
SELECT c.dia_semana, COUNT(DISTINCT pe.pedido_id) AS pedidos,
       ROUND(SUM(i.quantidade*p.preco)*1.0/COUNT(DISTINCT pe.pedido_id),2) AS ticket_medio
FROM itens_pedido i JOIN pedidos pe ON pe.pedido_id=i.pedido_id
JOIN produtos p ON p.produto_id=i.produto_id
JOIN calendario c ON c.data=pe.data_pedido
GROUP BY c.dia_semana ORDER BY c.dia_semana;

-- 6. Saldo de estoque por insumo e alerta de estoque mínimo
SELECT n.insumo,
       SUM(CASE WHEN m.tipo='Entrada' THEN m.quantidade ELSE -m.quantidade END) AS saldo,
       n.estoque_minimo,
       CASE WHEN SUM(CASE WHEN m.tipo='Entrada' THEN m.quantidade ELSE -m.quantidade END) < n.estoque_minimo
            THEN 'REPOR' ELSE 'OK' END AS situacao
FROM insumos n LEFT JOIN movimentacao_estoque m ON m.insumo_id=n.insumo_id
GROUP BY n.insumo, n.estoque_minimo;

-- 7. Crescimento mês a mês do faturamento (CTE + LAG)
WITH mensal AS (
  SELECT c.mes, SUM(i.quantidade*p.preco) AS fat
  FROM itens_pedido i JOIN pedidos pe ON pe.pedido_id=i.pedido_id
  JOIN produtos p ON p.produto_id=i.produto_id
  JOIN calendario c ON c.data=pe.data_pedido GROUP BY c.mes)
SELECT mes, fat, ROUND(100.0*(fat-LAG(fat) OVER (ORDER BY mes))/LAG(fat) OVER (ORDER BY mes),1) AS var_pct
FROM mensal ORDER BY mes;
