CREATE TABLE category (
  categoryid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  description varchar(100) NOT NULL
);

CREATE TABLE item (
  itemid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  categoryid integer NOT NULL,
  description varchar(100) NOT NULL,
  price numeric(15,2) NOT NULL,
  active booelan NOT NULL DEFAULT True
);

CREATE TABLE table (
  tableid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  ocuppied boolean NOT NULL DEFAULT False
);

CREATE TABLE customer (
  customerid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name varchar(100) NOT NULL,
  phone varchar(15),
  email varchar(100),
  cpf varchar(11)
);

CREATE TABLE customerorder (
  orderid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  customerid integer NOT NULL,
  tableid integer NOT NULL,
  total integer NOT NULL,
  date timestamp NOT NULL
);

CREATE TABLE orderitem (
  orderitemid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  orderid integer NOT NULL,
  itemid integer NOT NULL,
  total_price numeric(15,2) NOT NULL,
  quantity integer NOT NULL
);

CREATE TABLE payment (
  paymentid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  customerid integer NOT NULL,
  orderid integer NOT NULL,
  value numeric(15,2) NOT NULL,
  date timestamp NOT NULL
);

CREATE TABLE cache (
  cacheid INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  total numeric(15,2) NOT NULL,
  date timestamp NOT NULL
);

ALTER TABLE item ADD CONSTRAINT fk_item__category FOREIGN KEY (categoryid) REFERENCES category (categoryid);

ALTER TABLE customerorder ADD CONSTRAINT fk_customerorder__table FOREIGN KEY (tableid) REFERENCES table (tableid);

ALTER TABLE customerorder ADD CONSTRAINT fk_customerorder__customer FOREIGN KEY (customerid) REFERENCES customer (customerid);

ALTER TABLE orderitem ADD CONSTRAINT fk_orderitem__customerorder FOREIGN KEY (orderid) REFERENCES customerorder (orderid);

ALTER TABLE orderitem ADD CONSTRAINT fk_orderitem__item FOREIGN KEY (itemid) REFERENCES item (itemid);

ALTER TABLE payment ADD CONSTRAINT fk_payment__customer FOREIGN KEY (customerid) REFERENCES customer (customerid);

ALTER TABLE payment ADD CONSTRAINT fk_payment__customerorder FOREIGN KEY (orderid) REFERENCES customerorder (orderid);
