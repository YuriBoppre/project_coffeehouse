"use client";
import { useState, SyntheticEvent } from "react";
import type { category } from "@prisma/client";
import { useRouter } from "next/navigation";
import axios from "axios";

const AddProduct = ({ categorys }: { categorys: category[] }) => {
  const [description, setDescription] = useState("");
  const [price, setPrice] = useState("");
  const [category, setCategory] = useState("");
  const [activeItem, setActiveItem] = useState(true);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const router = useRouter();

  const handleSubmit = async (e: SyntheticEvent) => {
    e.preventDefault();
    setIsLoading(true);
    await axios.post("/api/products", {
      categoryid: Number(category),
      description: description,
      price: Number(price),
      active: Boolean(activeItem)
    });
    setIsLoading(false);
    setDescription("");
    setPrice("");
    setCategory("");
    setActiveItem(true);
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
      <button className="btn" onClick={handleModal}>
        Adicionar produto
      </button>

      <div className={isOpen ? "modal modal-open" : "modal"}>
        <div className="modal-box">
          <h3 className="font-bold text-lg">Novo produto</h3>
          <form onSubmit={handleSubmit}>
            <div className="form-control w-full">
              <label className="label font-bold">Nome do produto</label>
              <input
                type="text"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="input input-bordered"
                placeholder="Nome..."
              />
            </div>
            <div className="form-control w-full">
              <label className="label font-bold">Preço</label>
              <input
                type="text"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                className="input input-bordered"
                placeholder="Preço"
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
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="select select-bordered"
              >
                <option value="" disabled>
                  Selecione uma categoria
                </option>
                {categorys.map((icategory) => (
                  <option value={icategory.categoryid} key={icategory.categoryid}>
                    {icategory.description}
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
                  Salvar
                </button>
              ) : (
                <button type="button" className="btn loading">
                  Salvando...
                </button>
              )}
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default AddProduct;
