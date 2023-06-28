-- CreateTable
CREATE TABLE "category" (
    "categoryid" SERIAL NOT NULL,
    "description" TEXT NOT NULL,

    CONSTRAINT "category_pkey" PRIMARY KEY ("categoryid")
);

-- CreateTable
CREATE TABLE "item" (
    "itemid" SERIAL NOT NULL,
    "categoryid" INTEGER NOT NULL,
    "description" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "active" BOOLEAN NOT NULL,

    CONSTRAINT "item_pkey" PRIMARY KEY ("itemid")
);

-- AddForeignKey
ALTER TABLE "item" ADD CONSTRAINT "item_categoryid_fkey" FOREIGN KEY ("categoryid") REFERENCES "category"("categoryid") ON DELETE RESTRICT ON UPDATE CASCADE;
