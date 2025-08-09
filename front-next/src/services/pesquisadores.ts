const url: string =
  "http://localhost:8000/pesquisadores/";

export const getPesquisadores = async () => {
  const resposta = await fetch(url, {
    method: "GET",
    mode: "cors",
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!resposta.ok) {
    throw new Error("Não foi possível buscar os pesquisadores");
  }

  return resposta.json();
};


export const getProducesDoPesquisador = async (lattes_id:string) => {
  const resposta = await fetch(url+lattes_id+'/producoes', {
    method: "GET",
    mode: "cors",
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!resposta.ok) {
    throw new Error("Não foi possível buscar as produções do pesquisador");
  }

  return resposta.json();
};

export const getPesquisador = async (lattes_id:string) => {
  const resposta = await fetch(url+lattes_id, {
    method: "GET",
    mode: "cors",
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!resposta.ok) {
    throw new Error("Não foi possível buscar o pesquisador");
  }

  return resposta.json();
};
