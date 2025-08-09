import { use } from "react";

import { Pesquisador } from "@/core/pesquisadores";
import {getPesquisadores, getProducesDoPesquisador} from "@/services/pesquisadores";
import { Artigo } from "@/core/artigos";

export default function Pesquisadores() {
    const pesquisadores = use(getPesquisadores());

    return (
        <div>
            <h1 className="text-2xl font-bold">Pesquisadores</h1>
            <ul className="flex flex-col gap-3 mt-7">
                {pesquisadores.map((pesquisador: Pesquisador) => (
                    <li
                        className="flex flex-col gap-3 bg-slate-300 px-3 py-2 rounded-md transition-all text-white"
                        key={pesquisador.lattes_id}
                    >
                        <p className="flex justify-between items-center bg-slate-400 rounded-md p-2 mt-2">
                            <span className="text-lg font-semibold">Pesquisador: <span className="font-normal">
                                {pesquisador.nome}
                                </span>
                            </span>
                            <span className="text-lg font-semibold">ID Lattes: <span className="font-normal">
                                {pesquisador.lattes_id}
                                </span>
                            </span>
                        </p>
                        <ul className="items-center justify-between bg-slate-400 rounded-md p-2 mt-2">
                            <p className="text-lg font-semibold">
                                Artigos:
                            </p>
                            <ul className="flex flex-col gap-3 mt-7">
                                    {
                                        use(getProducesDoPesquisador(pesquisador.lattes_id)).map((artigo: Artigo) => (
                                            <li key={artigo.producoes_id}>
                                                <p className="text-lg font-semibold">
                                                    {artigo.nomeartigo}
                                                </p>
                                                <p className="font-semibold">
                                                    Ano: <span className="font-normal"> {artigo.anoartigo}</span>
                                                </p>
                                                <p className="font-semibold">
                                                    Issn: <span className="font-normal"> {artigo.issn}</span>
                                                </p>
                                            </li>
                                        ))
                                    }
                                    
                                </ul>
                        </ul>
                    </li>
                    
                ))}
            </ul>
        </div>
    );
}