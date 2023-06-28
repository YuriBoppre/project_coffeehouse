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
  const [Active, setActive] = useState(item.active);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const router = useRouter();

  const handleUpdate = async (e: SyntheticEvent) => {
    e.preventDefault();
    setIsLoading(true);
    await axios.patch(`/api/item/${item.itemid}`, {
      categoryid: Number(Category),
      description: Description,
      price: Number(Price),
      active: Boolean(Active)
    });
    setIsLoading(false);
    router.refresh();
    setIsOpen(false);
  };

  const handleModal = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div>
      <button className="btn btn-info btn-sm" onClick={handleModal}>
        Edit
      </button>

      <div className={isOpen ? "modal modal-open" : "modal"}>
        <div className="modal-box">
          <h3 className="font-bold text-lg">Update {item.description}</h3>
          <form onSubmit={handleUpdate}>
            <div className="form-control w-full">
              <label className="label font-bold">Product Name</label>
              <input
                type="text"
                value={Description}
                onChange={(e) => setDescription(e.target.value)}
                className="input input-bordered"
                placeholder="Product Name"
              />
            </div>
            <div className="form-control w-full">
              <label className="label font-bold">Price</label>
              <input
                type="text"
                value={Price}
                onChange={(e) => setPrice(Number(e.target.value))}
                className="input input-bordered"
                placeholder="Price"
              />
            </div>
            <div className="form-control w-full">
              <label className="label font-bold">Brand</label>
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
                Close
              </button>
              {!isLoading ? (
                <button type="submit" className="btn btn-primary">
                  Update
                </button>
              ) : (
                <button type="button" className="btn loading">
                  Updating...
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
