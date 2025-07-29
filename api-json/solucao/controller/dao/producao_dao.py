# Importa o model de Produção
from model.producao import Producao

# Importa a conexão Singleton do banco de dados
from banco import conexao_singleton as cs

# Obtém uma instância de conexão com o banco de dados
conexao = cs.Conexao().get_conexao()

# Função para salvar uma nova produçãoo no banco de dados
def salvar_nova_producao(issn: str, nomeartigo: str, anoartigo: int, pesquisadores_id: str) -> str:
    # SQL para inserir um novo registro na tabela "pesquisadores"
    sql = """
            INSERT INTO producoes (issn, nomeartigo, anoartigo, pesquisadores_id)
            VALUES (%s, %s, %s, %s)
        """
    
    try:
        # Utiliza a conexão para abrir um cursor e executar o SQL
        with conexao.cursor() as cursor:
            cursor.execute(sql, (issn, nomeartigo, anoartigo, pesquisadores_id))
            # Confirma a transação no banco
            conexao.commit()
            
            return "Nova produção salva com sucesso!"
    except Exception as e:
        # Se ocorrer uma exceção, reverte a transação
        conexao.rollback()
        return f"Erro ao salvar: {e}"
    
# Função para listar todas as produções do banco de dados
def listar_todas_producoes() -> str:
    # SQL para selecionar todos os registros da tabela "pesquisadores"
    sql: str = "SELECT * FROM producoes"
    # Utiliza a conexão para abrir um cursor e executar o SQL
    with conexao.cursor() as cursor:
        cursor.execute(sql)
        # Obtém todos os resultados da consulta
        resultado = cursor.fetchall()
        
        # Cria uma lista das colunas retornadas pela consulta
        colunas = [desc[0] for desc in cursor.description]
        # Mapeia os resultados em dicionários com chave-valor
        dados = [dict(zip(colunas, linha)) for linha in resultado]
        return dados

# Função para atualizar uma producao no banco de dados
def atualizar_producao(producao:Producao) -> str:
    # SQL para atualizar os dados de uma produção específica
    sql = """
            UPDATE producoes
            SET pesquisadores_id = %s, issn = %s, nomeartigo = %s, anoartigo = %s
            WHERE producoes_id = %s
        """
    
    try:
        # Utiliza a conexão para abrir um cursor e executar o SQL
        with conexao.cursor() as cursor:
            cursor.execute(sql, (producao.pesquisadores_id, producao.issn, producao.nomeartigo, producao.anoartigo, producao.producoes_id))
            
            if (cursor.rowcount < 0):
                raise Exception()
            
            # Confirma a transação no banco
            conexao.commit()
            
            return "Produção atualizada com sucesso!"
    except Exception as e:
        # Se ocorrer uma exceção, reverte a transação
        conexao.rollback()
        return f"Erro ao atualizar produção: {e}"

# Função para apagar uma produção do banco de dados com base em "producoes_id"
def apagar_producao(producoes_id: str) -> str:
    
    # SQL para excluir uma produção específica com base em "producoes_id"

    sql = """
            DELETE FROM producoes
            WHERE producoes_id = %s
        """
    
    try:
        # Utiliza a conexão para abrir um cursor e executar o SQL
        with conexao.cursor() as cursor:
            
            cursor.execute(sql, (producoes_id, ))
            
            if (cursor.rowcount > 0):
                # Confirma a transação no banco
                conexao.commit()
            else:
                raise Exception()
            
            return "Produção apagada com sucesso!"
    except Exception as e:
        # Se ocorrer uma exceção, reverte a transação
        conexao.rollback()
        return f"Erro ao apagar produção. Produção inexistente ou ID inválido."

