import Logo from "./Logo";

export default function Cabecalho() {
    return (
        <header
            className="
                flex justify-between items-center
                px-6 py-3 bg-zinc-300
            "
        >
            <h1 className="text-2xl">Pesquisadores NPAI</h1>
            <Logo />
        </header>
    );
}