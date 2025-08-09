import Image from "next/image";

export default function Home() {

  const codigoPesquisador = `
    export default interface Pesquisador {
      lattes_id: string;
      lattes_update: string;
      matric: string;
      name: string;
      openalex: string;
      orcid: string;
      patent: number;
      progressao: string;
    }
  `

  return (
    <div>
      <div className="flex flex-col gap-3 bg-green-400 rounded-md p-3 mb-4">
        <h1 className="text-3xl">Aplicação básica Next para tutorial web</h1>
        <p>Clique nos items do menu para ver os exemplos</p>
        <p>Esta é uma aplicação simples onde temos somente as requisições sendo feitas para o backend e exibindo os resultados na tela. O principal é que você olhe como está a estrutura de diretórios e arquivos.</p>
        <p>Todos os arquivos que tem o código responsável pelas requisições estão na pasta <code className="bg-zinc-500 px-2 py-1 rounded-md">services</code> e organizados de acordo com suas responsabilidades. Por exemplo, as chamadas para os pesquisadores está no arquivo <code className="bg-zinc-500 px-2 py-1 rounded-md">pesquisadores.ts</code> e as chamadas para os artigos no arquivo <code className="bg-zinc-500 px-2 py-1 rounded-md">artigos.ts</code>.</p>
      </div>

      <div className="flex flex-col gap-3 mt-5 bg-green-400 rounded-md p-3">
        <h2 className="text-2xl">Modelagem</h2>
        <p>A pasta <code>core</code> é onde contém toda modelagem de todos elementos envolvidos na aplicação, onde temos os atributos de cada elemento e etc.</p>
        <p>Esses atributos nesses arquivos terão os mesmos nome que os atributos recebidos por json da api. Veja:</p>
        <br />

        <figure className="px-2 py-4 bg-white rounded-md -mt-6">
          <Image src={"/image.png"} alt="Exemplo" width={430} height={70} />
        </figure>

        <p>A modelagem para o pesquisador deveria ser algo como:</p>

        <pre className="bg-black p-2 rounded-md">{codigoPesquisador}</pre>

        <p>Mas isso é apenas um recorte da modelagem, pois o backend retorna mais informações. Podemos fazer a modelagem com todos os dados retornados do backend, porém não necessariamente precisaremos de todos, dependendo da aplicação. Para este tutorial, a modelagem foi reduzida.</p>
      </div>
    </div>
  );
}
