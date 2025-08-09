# controller/pesquisador_controller.py
from fastapi import APIRouter, HTTPException
from typing import List
from model.pesquisador import Pesquisador
from model.producao import Producao
from controller.dao.pesquisador_dao import (
    apagar_por_lattes_id,
    listar_todos,
    salvar_novo_pesquisador,
    atualizar_por_id,
    pegar_pesquisador_por_id,
    pegar_pesquisador_por_id_tabela
)
from controller.dao.producao_dao import (
    listar_todas_producoes
)

# Criação de um router chamado 'pesquisador_router'
pesquisador_router = APIRouter()

# Rota para salvar um novo pesquisador
@pesquisador_router.post("/pesquisadores", response_model = Pesquisador)
def adicionar(pesquisador: Pesquisador):
    print(pesquisador)
    resposta = salvar_novo_pesquisador(
        nome = pesquisador.nome,
        lattes_id = pesquisador.lattes_id,
    )
    
    if 'duplicate' in resposta:
        raise HTTPException(status_code=409, detail=resposta)
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return pesquisador

# Rota para listar todos os pesquisadores
@pesquisador_router.get("/pesquisadores", response_model = List[Pesquisador])
def listar():
    pesquisadores = listar_todos()
    return pesquisadores

# Rota para apagar um pesquisador com base no lattes_id
@pesquisador_router.delete("/pesquisadores/{lattes_id}", response_model=str)
def apagar(lattes_id: str):
    resposta = apagar_por_lattes_id(lattes_id)
    
    if 'inválido' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return resposta

# Rota para atualizar um pesquisador
@pesquisador_router.put("/pesquisadores", response_model=Pesquisador)
def atualizar(pesquisador: Pesquisador):
    resposta = atualizar_por_id(
        nome = pesquisador.nome,
        pesquisadores_id = pesquisador.pesquisadores_id,
        lattes_id = pesquisador.lattes_id
    )
    
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return pesquisador

# Rota para listar as produções de um pesquisador por seu lattes_id
@pesquisador_router.get("/pesquisadores/{lattes_id}/producoes", response_model = List[Producao])
def listar(lattes_id: str):
    producoes = listar_todas_producoes()
    respostaPesquisadores = pegar_pesquisador_por_id(lattes_id) 
    if 'inválido' in respostaPesquisadores:
        raise HTTPException(status_code=400, detail=respostaPesquisadores)
    
    producoes = [producao for producao in producoes if producao["pesquisadores_id"] ==  respostaPesquisadores["pesquisadores_id"]]
    
    return producoes


# Rota para retomar um pesquisador específico por pesquisadores_id
@pesquisador_router.get("/pesquisadores/{pesquisadores_id}", response_model=Pesquisador)
def retomar_pesquisador_id(pesquisadores_id: str):
    resposta = pegar_pesquisador_por_id_tabela(pesquisadores_id);
    
    if 'Erro' in resposta:
        raise HTTPException(status_code=400, detail=resposta)
    
    return resposta
