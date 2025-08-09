const url: string =
  "http://localhost:8000/producoes/";

const getArtigos = async () => {
  const resposta = await fetch(url, {
    method: "GET",
    mode: "cors",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (!resposta.ok) {
    throw new Error("Nao foi possivel buscar os artigos");
  }
  return resposta.json();
};

export default getArtigos;
