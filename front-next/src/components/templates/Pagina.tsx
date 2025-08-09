/* eslint-disable @typescript-eslint/no-explicit-any */
import React from "react";
import Cabecalho from "../Cabecalho";
import Menu from "../Menu";

export default interface PaginaProps {
    children: React.ReactNode;
}

export default function Pagina({ children }: any) {
    return (
        <div className="flex flex-col h-screen overflow-hidden">
            <Cabecalho />

            <div className="flex overflow-hidden">
                <Menu />
                <main className="flex-1 p-7  overflow-y-scroll">
                    {children}
                </main>
            </div>
        </div>
    );
}