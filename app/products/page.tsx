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
        <AddProduct items={items} />
      </div>

      <table className="table w-full">
        <thead>
          <tr>
            <th>#</th>
            <th>Product Name</th>
            <th>Price</th>
            <th>Brand</th>
            <th className="text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map((i, index) => (
            <tr key={i.itemid}>
              <td>{index + 1}</td>
              <td>{item.description}</td>
              <td>{item.price}</td>
              <td>{item.category.description}</td>
              <td className="flex justify-center space-x-1">
                <UpdateProduct categorys={categorys} items={items} />
                <DeleteProduct items={items} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default getItems;
