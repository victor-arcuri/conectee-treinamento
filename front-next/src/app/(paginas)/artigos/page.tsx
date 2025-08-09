import { Artigo } from "@/core/artigos";
import getArtigos from "@/services/artigos"
import { getPesquisador } from "@/services/pesquisadores";
import { use } from "react"

export default function Artigos() {

    const artigos = use(getArtigos());

    return (
        <div>
            <h1 className="text-2xl font-bold">Artigos</h1>

            <ul>
                {artigos.map((artigo: Artigo) => {
                    const pesquisador = use(getPesquisador(artigo.pesquisadores_id));
                    return <li
                        className="flex flex-col gap-3 bg-slate-300 px-3 py-2 rounded-md transition-all text-white mt-7"
                        key={artigo.issn}
                    >
                        <p className="flex justify-between items-center bg-slate-400 rounded-md p-2 mt-2">
                            <span className="text-lg font-semibold">Título: <span className="font-normal">{artigo.nomeartigo}</span></span>
                            <span className="text-lg font-semibold">Issn: <span className="font-normal">{artigo.issn}</span></span>
                        </p>
                        <div className="bg-slate-400 rounded-md p-2 mt-2">
                            <p className="text-lg font-semibold">Autor: <span className="font-normal">{pesquisador.nome}</span></p>
                            <p className="text-lg font-semibold">Ano de publicação: <span className="font-normal">{artigo.anoartigo}</span></p>
                        </div>
                    </li>
                })}
            </ul>
        </div>
    )
}