"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import axios from "axios";

type item = {
  itemid: number;
  categoryid: number;
  description: string;
  price: number;
  active: boolean;
};

const DeleteItem = ({ item }: { item: item }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const router = useRouter();

  const handleDelete = async (itemid: number) => {
    setIsLoading(true);
    await axios.delete(`/api/item/${itemid}`);
    setIsLoading(false);
    router.refresh();
    setIsOpen(false);
  };

  const handleModal = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div>
      <button className="btn btn-error btn-sm" onClick={handleModal}>
        Deletar
      </button>

      <div className={isOpen ? "modal modal-open" : "modal"}>
        <div className="modal-box">
          <h3 className="font-bold text-lg">
            Tem certeza deseja deletar: {item.description}?
          </h3>

          <div className="modal-action">
            <button type="button" className="btn" onClick={handleModal}>
              Não
            </button>
            {!isLoading ? (
              <button
                type="button"
                onClick={() => handleDelete(item.itemid)}
                className="btn btn-primary"
              >
                Sim
              </button>
            ) : (
              <button type="button" className="btn loading">
                Deletando...
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DeleteItem;
