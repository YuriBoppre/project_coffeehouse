"use client";
import { useState, SyntheticEvent } from "react";
import type { category } from "@prisma/client";
import { useRouter } from "next/navigation";
import axios from "axios";

type item = {
  itemid: number;
  categoryid: number;
  description: string;
  price: number;
  active: boolean;
};

const UpdateItem = ({
  category,
  item,
}: {
  category: category[];
  item: item;
}) => {
  const [Description, setDescription] = useState(item.description);
  const [Price, setPrice] = useState(item.price);
  const [Category, setCategory] = useState(item.categoryid);
  const [activeItem, setActiveItem] = useState(item.active);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const router = useRouter();

  const handleUpdate = async (e: SyntheticEvent) => {
    e.preventDefault();
    setIsLoading(true);
    await axios.patch(`/api/products/${item.itemid}`, {
      categoryid: Number(Category),
      description: Description,
      price: Number(Price),
      active: Boolean(activeItem)
    });
    setIsLoading(false);
    router.refresh();
    setIsOpen(false);
  };

  const handleModal = () => {
    setIsOpen(!isOpen);
  };


  const handleUpdateActive = (value: string) => {
    if (value === 'true') {
      return setActiveItem(true)
    }

    setActiveItem(false)
  }

  return (
    <div>
      <button className="btn btn-info btn-sm" onClick={handleModal}>
        Edição
      </button>

      <div className={isOpen ? "modal modal-open" : "modal"}>
        <div className="modal-box">
          <h3 className="font-bold text-lg">Editando {item.description}</h3>
          <form onSubmit={handleUpdate}>
            <div className="form-control w-full">
              <label className="label font-bold">Nome do produto</label>
              <input
                type="text"
                value={Description}
                onChange={(e) => setDescription(e.target.value)}
                className="input input-bordered"
                placeholder="Product Name"
              />
            </div>
            <div className="form-control w-full">
              <label className="label font-bold">Preço</label>
              <input
                type="text"
                value={Price}
                onChange={(e) => setPrice(Number(e.target.value))}
                className="input input-bordered"
                placeholder="Price"
              />
            </div>
            <div className="form-control w-full">
              <label className="label font-bold">Status</label>
              <select 
                value={activeItem === true ? 'true' : 'false'}
                onChange={(e) => handleUpdateActive(e.target.value)} 
                className="select select-bordered">
                  <option value={'true'}>Ativo</option>
                  <option value={'false'}>Inativo</option>
              </select>
            </div>
            <div className="form-control w-full">
              <label className="label font-bold">Categoria</label>
              <select
                value={Category}
                onChange={(e) => setCategory(Number(e.target.value))}
                className="select select-bordered"
              >
                {category.map((i) => (
                  <option value={i.categoryid} key={i.categoryid}>
                    {i.description}
                  </option>
                ))}
              </select>
            </div>
            <div className="modal-action">
              <button type="button" className="btn" onClick={handleModal}>
                Fechar
              </button>
              {!isLoading ? (
                <button type="submit" className="btn btn-primary">
                  Atualizar
                </button>
              ) : (
                <button type="button" className="btn loading">
                  Atualizar...
                </button>
              )}
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default UpdateItem;
