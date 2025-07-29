# controller/producao_controller.py
from fastapi import APIRouter, HTTPException
from typing import List
from model.producao import Producao 
from controller.dao.producao_dao import (
    salvar_nova_producao,
    listar_todas_producoes,
    atualizar_producao,
    apagar_producao
)

from controller.dao.pesquisador_dao import (
    pegar_pesquisador_por_id
)

# Criação de um router chamado 'producao_router'
producao_router = APIRouter()

# Rota para salvar uma nova producao
@producao_router.post("/producoes", response_model = Producao)
def adicionar(producao: Producao):
    resposta = salvar_nova_producao(
        nomeartigo=producao.nomeartigo,
        issn=producao.issn,
        anoartigo=producao.anoartigo,
        pesquisadores_id=producao.pesquisadores_id
    )
    
    if 'duplicate' in resposta:
        raise HTTPException(status_code=409, detail=resposta)
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return producao

# Rota para listar todas as producoes
@producao_router.get("/producoes", response_model = List[Producao])
def listar():
    producoes = listar_todas_producoes()
    return producoes

# Rota para apagar uma produção com base no producoes_id
@producao_router.delete("/producoes/{producoes_id}", response_model=str)
def apagar(producoes_id: str):
    resposta = apagar_producao(producoes_id)
    
    if 'inválido' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return resposta

# Rota para atualizar uma produção
@producao_router.put("/producoes", response_model=Producao)
def atualizar(producao: Producao):
    resposta = atualizar_producao(producao)
    
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return producao

# Rota para listar as produções de um pesquisador por seu lattes_id
@producao_router.get("/producoes/{lattes_id}", response_model = List[Producao])
def listar(lattes_id: str):
    producoes = listar_todas_producoes()
    respostaPesquisadores = pegar_pesquisador_por_id(lattes_id) 
    if 'inválido' in respostaPesquisadores:
        raise HTTPException(status_code=400, detail=respostaPesquisadores)
    
    producoes = [producao for producao in producoes if producao["pesquisadores_id"] ==  respostaPesquisadores["pesquisadores_id"]]
    
    return producoes