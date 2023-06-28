import { NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";
import type { item } from "@prisma/client";
const prisma = new PrismaClient();

export const PATCH = async (request: Request, {params}: {params: {itemid: string}}) =>{
    const body: item = await request.json();
    const item = await prisma.item.update({
        where:{
            itemid: Number(params.itemid)
        },
        data:{
            categoryid: body.categoryid,
            description: body.description,
            price: body.price,
            active: body.active
        }
    });
    return NextResponse.json(item, {status: 200});
}

export const DELETE = async (request: Request, {params}: {params: {itemid: string}}) =>{
    const item = await prisma.item.delete({
        where:{
            itemid: Number(params.itemid)
        }
    });
    return NextResponse.json(item, {status: 200});
}