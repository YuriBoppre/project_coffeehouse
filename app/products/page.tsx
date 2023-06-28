import { PrismaClient } from "@prisma/client";
import AddProduct from "./addProduct";
import DeleteProduct from "./deleteProduct";
import UpdateProduct from "./updateProduct";
const prisma = new PrismaClient();

const getItems = async () => {
  const res = await prisma.item.findMany({
    select: {
      itemid: true,
      categoryid: true,
      description: true,
      price: true,
      active: true,
      category: true
    },
  });
  return res;
};

const getCategorys = async () => {
  const res = await prisma.category.findMany();
  return res;
};

const Item = async () => {
  const [items, categorys] = await Promise.all([getItems(), getCategorys()]);

  return (
    <div>
      <div className="mb-2">
        <AddProduct categorys={categorys} />
      </div>

      <table className="table w-full">
        <thead>
          <tr>
            <th>#</th>
            <th>Nome do produto</th>
            <th>Descrição</th>
            <th>Preço</th>
            <th>Categoria</th>
            <th className="text-center">Ações</th>
          </tr>
        </thead>
        <tbody>
          {items.map((i, index) => (
            <tr key={i.itemid}>
              <td>{index + 1}</td>
              <td>{i.description}</td>
              <td>{i.price}</td>
              <td>{i.category.description}</td>
              <td className="flex justify-center space-x-1">
                <UpdateProduct category={categorys} item={i} />
                <DeleteProduct item={i} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default getItems;
