create or REPLACE function f_veriricaitem(_itemid int)
returns varchar
language plpgsql
AS $function$
declare _opened boolean;
declare _closed boolean;
begin
	select count(orderitem.orderid) > 0
	into _opened
	from orderitem 
	join customerorder ON (orderitem.orderid = customerorder.orderid) 
	where itemid = _itemid and opened;
	
	select count(orderitem.orderid) > 0
	into _closed
	from orderitem 
	join customerorder ON (orderitem.orderid = customerorder.orderid) 
	where itemid = _itemid and not opened;
	
	if _opened then
		return 'Bloqueado';
	elseif _closed then
		return 'Pode Inativar';
	else 
		return 'Pode Deletar';
	end if;
END;$function$;

---------------------------------------------------------------------------------------------------------------------

CREATE or REPLACE FUNCTION all_order_closed(_tableid integer)
RETURNS boolean
language plpgsql AS $$
declare result boolean;
begin
	select count(1) = 0 into result
	from customerorder c
	where tableid = _tableid and opened;
	return result;
END;
$$;

------------------------------------------------------------------------

CREATE TYPE t_visits AS (
	"Cliente" varchar,
	"Dias visitados" numeric,
	"Quantia gasta" numeric);

CREATE OR REPLACE FUNCTION f_visits()
RETURNS TABLE (visit t_visits)
LANGUAGE plpgsql
as $$
begin
	return query
	with visits as(
		select c.name, count(1) as visits_day, sum(co.total) as total
		from customerorder co
		join customer c on (c.customerid = co.customerid)
		group by c.name, cast(co.date as date))
	select v.name, sum(v.visits_day), sum(v.total)
	from visits v
	group by v.name;
END;$$;

select *
from f_visits();

-----------------------------------------------------------------------
create or replace function f_cardapio(include_inactive boolean = false)
returns table ("CATEGORIA" varchar, "DESCRIÇÃO" varchar, "PREÇO" numeric)
language plpgsql
as $$
begin
	return query 
	select category.description as "CATEGORIA", item.description as "DESCRIÇÃO", item.price as "PREÇO" 
	from item
	INNER JOIN category ON item.categoryid = category.categoryid
	WHERE item.active or include_inactive
	order by category.description asc;
end;$$;

select *
from f_cardapio();

select *
from f_cardapio(true);
	
-------------------------------------------------------------------

create or replace function f_orders(customername varchar, itemdescription varchar, categorydescription varchar, startdate date, finaldate date)
returns setof record
language plpgsql
as $$
declare i record;
begin
	for i in
		select customer.name, item.description, category.description, sum(orderitem.quantity) as quantity
		from customerorder
		inner join customer on customerorder.customerid = customer.customerid
		inner join orderitem on customerorder.orderid = orderitem.orderid 
		inner join item on orderitem.itemid = item.itemid
		inner join category on item.categoryid = category.categoryid
		where (customer.name = customername or '' = customername) and 
			  (item.description = itemdescription or '' = itemdescription) and 
			  (category.description = categorydescription or '' = categorydescription) and 
			  customerorder.date between startdate and finaldate
		group by customer.name, item.description, category.description
		order by quantity desc
	loop
		return next i;
	end loop;
end;$$;

select *
from f_orders('', '', '', '23-06-03 09:30', '23-06-24 09:30') as (customer varchar, item varchar, category varchar, quantity bigint);

select customer, category, sum(quantity)
from f_orders('', '', '', '23-06-03 09:30', '23-06-24 09:30') as (customer varchar, item varchar, category varchar, quantity bigint)
group by customer, category
order by 3 desc;

-------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE p_rel_itens_by_qnt(startdate date, finaldate date, _itemid integer, OUT _rel record)
LANGUAGE plpgsql AS
$$
BEGIN
    SELECT c.description as category, i.description as item, i.price, SUM(oi.quantity) as quantity
    FROM item i
    JOIN orderitem oi on (i.itemid = oi.itemid)
    JOIN customerorder o on (o.orderid = oi.orderid)
    JOIN category c on (i.categoryid = c.categoryid)
    WHERE i.itemid = _itemid and o.date between startdate and finaldate
    GROUP BY c.description, i.description, i.price
    INTO _rel;

    IF _rel is null THEN
        SELECT c.description as category, i.description as item, i.price as price, cast(0 as bigint) as quantity
        FROM item i
        JOIN category c on (i.categoryid = c.categoryid)
        WHERE i.itemid = _itemid
        GROUP BY c.description, i.description, i.price
        INTO _rel;
    END IF;
END;$$;

CREATE OR REPLACE FUNCTION f_rel_itens_by_qnt(startdate date = '2023-01-01 00:00', finaldate date = '2023-12-31 23:59')
RETURNS TABLE ("Categoria" varchar, "Item" varchar, "Preço" numeric, "Quantidade" bigint)
LANGUAGE plpgsql AS $$
DECLARE rel record;
DECLARE i record;
BEGIN
	CREATE TEMPORARY TABLE temp_rel (
		category varchar,
		item varchar,
		price numeric,
		quantity bigint
	);
	FOR i IN
	SELECT itemid
	FROM item
	WHERE active
	LOOP
		CALL p_rel_itens_by_qnt(startdate, finaldate, i.itemid, rel);
		INSERT INTO temp_rel VALUES (rel.category, rel.item, rel.price, rel.quantity);
	END LOOP;
	RETURN QUERY SELECT * FROM temp_rel ORDER BY quantity DESC;
	DROP TABLE temp_rel;
END;$$;

select *
from f_rel_itens_by_qnt('23-06-22 09:30', '23-06-24 09:30');

select *
from f_rel_itens_by_qnt();

-------------------------------------------------------------------
