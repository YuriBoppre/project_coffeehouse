import { NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";
import type { item } from "@prisma/client";
const prisma = new PrismaClient();

export const POST = async (request: Request) =>{
    const body: item = await request.json();
    const item = await prisma.item.create({
        data:{
            categoryid: body.categoryid,
            description: body.description,
            price: body.price,
            active: body.active
        }
    });
    return NextResponse.json(item, {status: 201});
}