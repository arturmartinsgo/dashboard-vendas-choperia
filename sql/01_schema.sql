-- Schema da choperia fictícia (SQL padrão; testado em SQLite, adaptável a SQL Server/PostgreSQL)
CREATE TABLE produtos (
  produto_id INTEGER PRIMARY KEY, produto VARCHAR(60) NOT NULL, categoria VARCHAR(20) NOT NULL,
  litros DECIMAL(4,2) NOT NULL, preco DECIMAL(8,2) NOT NULL, custo DECIMAL(8,2) NOT NULL);
CREATE TABLE pedidos (
  pedido_id INTEGER PRIMARY KEY, data_pedido DATE NOT NULL, forma_pagamento VARCHAR(30) NOT NULL);
CREATE TABLE itens_pedido (
  pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
  produto_id INTEGER NOT NULL REFERENCES produtos(produto_id),
  quantidade INTEGER NOT NULL);
CREATE TABLE insumos (
  insumo_id INTEGER PRIMARY KEY, insumo VARCHAR(60) NOT NULL, unidade VARCHAR(5),
  qtd_embalagem DECIMAL(6,2), estoque_minimo INTEGER, custo_unitario DECIMAL(8,2));
CREATE TABLE movimentacao_estoque (
  mov_id INTEGER PRIMARY KEY, data_mov DATE NOT NULL,
  insumo_id INTEGER NOT NULL REFERENCES insumos(insumo_id),
  tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('Entrada','Saída')), quantidade INTEGER NOT NULL);
CREATE TABLE calendario (
  data DATE PRIMARY KEY, ano INTEGER, mes INTEGER, mes_nome VARCHAR(3), dia_semana INTEGER);
