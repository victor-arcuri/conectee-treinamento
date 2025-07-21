import psycopg2
from langdetect import detect

connection = psycopg2.connect(
    database="BD_PESQUISADOR", 
    user="postgres", 
    password="postgres", 
    host="localhost", 
    port=5437)

cursor = connection.cursor()

cursor.execute("SELECT producoes_id, nomeartigo from producoes;")

records = cursor.fetchall()

for record in records:

    pid = record[0]
    lang = detect(record[1])
    if (lang == 'pt'):
        lang = 'pt'
    else:
        lang = 'en'

    cursor.execute(
        "UPDATE producoes SET idioma= %s WHERE producoes_id= %s", (lang, pid)
    )

connection.commit()

cursor.close()
connection.close()