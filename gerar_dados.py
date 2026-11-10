"""Gera dados SINTÉTICOS de uma choperia fictícia (nenhum dado real)."""
import numpy as np, pandas as pd
rng = np.random.default_rng(7)

produtos = pd.DataFrame([
    (1,"Pilsen Artesanal 300ml","Chopp",0.3,9.0,3.2),
    (2,"Pilsen Artesanal 500ml","Chopp",0.5,14.0,5.3),
    (3,"IPA 300ml","Chopp",0.3,13.0,4.8),
    (4,"IPA 500ml","Chopp",0.5,20.0,8.0),
    (5,"Weiss 500ml","Chopp",0.5,18.0,7.0),
    (6,"Growler Pilsen 1L","Chopp",1.0,26.0,10.5),
    (7,"Porção de Batata","Comida",0,28.0,9.0),
    (8,"Porção de Calabresa","Comida",0,32.0,12.0),
    (9,"Refrigerante","Bebida",0,7.0,2.5),
], columns=["produto_id","produto","categoria","litros","preco","custo"])
pesos = np.array([.22,.20,.12,.14,.10,.04,.08,.06,.04]); pesos/=pesos.sum()

pagamentos = ["Pix","Cartão de Crédito","Cartão de Débito","Dinheiro"]
pp = [.38,.30,.22,.10]

datas = pd.date_range("2025-01-01","2025-12-31")
ped, itens = [], []
pid = 0
for d in datas:
    base = {0:0,1:15,2:18,3:22,4:45,5:70,6:55}[d.dayofweek]
    if d.month in (11,12): base *= 1.25
    if d.month in (6,7): base *= .85
    for _ in range(int(rng.poisson(base/2.2))):
        pid += 1
        ped.append((pid, d.strftime("%Y-%m-%d"), rng.choice(pagamentos,p=pp)))
        for _ in range(rng.integers(1,5)):
            prod = rng.choice(produtos.produto_id,p=pesos)
            itens.append((pid, int(prod), int(rng.integers(1,4))))
pedidos = pd.DataFrame(ped,columns=["pedido_id","data_pedido","forma_pagamento"])
itens = pd.DataFrame(itens,columns=["pedido_id","produto_id","quantidade"])

insumos = pd.DataFrame([
    (1,"Barril Pilsen 50L","L",50,6,320.0),(2,"Barril IPA 50L","L",50,4,480.0),
    (3,"Barril Weiss 50L","L",50,3,420.0),(4,"Batata congelada 2kg","kg",2,10,22.0),
    (5,"Calabresa 1kg","kg",1,8,28.0),(6,"Refrigerante lata","un",1,48,3.0),
],columns=["insumo_id","insumo","unidade","qtd_embalagem","estoque_minimo","custo_unitario"])
mov=[]
for m in pd.date_range("2025-01-01","2025-12-01",freq="MS"):
    for i in insumos.insumo_id:
        mov.append((m.strftime("%Y-%m-%d"),int(i),"Entrada",int(rng.integers(8,14))))
        mov.append(((m+pd.Timedelta(days=int(rng.integers(10,28)))).strftime("%Y-%m-%d"),int(i),"Saída",int(rng.integers(3,9))))
mov = pd.DataFrame(mov,columns=["data_mov","insumo_id","tipo","quantidade"])
mov.insert(0,"mov_id",range(1,len(mov)+1))

cal = pd.DataFrame({"data":datas})
cal["ano"]=cal.data.dt.year; cal["mes"]=cal.data.dt.month
cal["mes_nome"]=cal.data.dt.strftime("%b"); cal["dia_semana"]=cal.data.dt.dayofweek+1
cal["data"]=cal.data.dt.strftime("%Y-%m-%d")

for n,df in dict(produtos=produtos,pedidos=pedidos,itens_pedido=itens,insumos=insumos,movimentacao_estoque=mov,calendario=cal).items():
    df.to_csv(f"dados/{n}.csv",index=False,encoding="utf-8")
print(len(pedidos),"pedidos;",len(itens),"itens")
