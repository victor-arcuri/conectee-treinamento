import Link from "next/link";
import React from "react";

export interface MenuItemProps {
    children: React.ReactNode;
    link: string;
    icone?: React.ReactNode;
}

export default function MenuItem(props: MenuItemProps) {
    return (
        <Link href={props.link}>
            <li
                className="
                    flex items-center
                    gap-2 mx-4
                    bg-sky-400 px-3 py-2 rounded-md
                    hover:bg-sky-200 hover:text-black transition-all text-white
                "
            >
                {props.icone ? <span>{props.icone}</span> : null}
                <span className={`${!props.icone ? "ml-2" : ""}`}>{props.children}</span>
            </li>
        </Link>
    )
}