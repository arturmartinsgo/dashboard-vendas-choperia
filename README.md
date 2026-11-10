# Dashboard de Vendas e Estoque — Choperia (SQL + Power BI)

Análise de vendas, margem, formas de pagamento e estoque de uma **choperia artesanal fictícia**, com banco SQL e dashboard em Power BI. O tema vem da minha experiência prévia com controles de vendas, estoque e financeiro em Excel; **todos os dados aqui são sintéticos** (gerados por `gerar_dados.py`, sem relação com nenhuma empresa real).

## Perguntas de negócio
1. Quanto a choperia fatura e qual a margem por mês?
2. Como o faturamento se divide entre Pix, cartão e dinheiro?
3. Quantos litros de chopp são vendidos por mês?
4. Quais produtos dão mais margem, não só mais volume?
5. Em quais dias da semana o ticket médio é maior?
6. Quais insumos estão abaixo do estoque mínimo e precisam de reposição?

## Estrutura
```
├── dados/            # CSVs sintéticos (produtos, pedidos, itens, insumos, estoque, calendário)
├── sql/
│   ├── 01_schema.sql     # criação das tabelas
│   └── 02_consultas.sql  # 7 consultas analíticas
├── gerar_dados.py    # gera os dados fictícios (seed fixa, reproduzível)
└── docs/             # prints do dashboard
```

## Modelo de dados
`pedidos` 1—N `itens_pedido` N—1 `produtos`; `insumos` 1—N `movimentacao_estoque`; `calendario` ligada a `pedidos.data_pedido`.

## Técnicas de SQL usadas
JOINs múltiplos · agregações · `CASE WHEN` · funções de janela (`RANK`, `LAG`, `SUM() OVER`) · CTE · tabela calendário

## Como reproduzir
```bash
pip install pandas numpy
python gerar_dados.py
sqlite3 choperia.db < sql/01_schema.sql      # ou execute no SQL Server / PostgreSQL
# importe os CSVs de /dados e rode sql/02_consultas.sql
```
As consultas usam SQL padrão e foram testadas em SQLite; ajustes mínimos para SQL Server/PostgreSQL (ex.: tipos e `CAST`).

## Dashboard Power BI (sugestão de páginas)
1. **Vendas**: faturamento, margem, litros, ticket médio; linha mensal; barras por produto.
2. **Pagamentos**: pizza/rosca por forma de pagamento, dia da semana × ticket.
3. **Estoque**: saldo por insumo com alerta de reposição.

Medidas DAX principais:
```DAX
Faturamento = SUMX(itens_pedido, itens_pedido[quantidade] * RELATED(produtos[preco]))
Custo = SUMX(itens_pedido, itens_pedido[quantidade] * RELATED(produtos[custo]))
Margem = [Faturamento] - [Custo]
Margem % = DIVIDE([Margem], [Faturamento])
Litros = SUMX(FILTER(itens_pedido, RELATED(produtos[categoria]) = "Chopp"),
              itens_pedido[quantidade] * RELATED(produtos[litros]))
Ticket Médio = DIVIDE([Faturamento], DISTINCTCOUNT(itens_pedido[pedido_id]))
```

## Observações sobre os dados
Sazonalidade e movimento por dia da semana foram simulados (fim de semana mais forte, segunda fechada, picos em novembro e dezembro). Os resultados não representam nenhum negócio real.

## Autor
**Artur Martins** · [LinkedIn](https://www.linkedin.com/in/artur-martins) · [GitHub](https://github.com/arturmartinsgo)
