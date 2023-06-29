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
END;
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
		join customer c on (co.orderid = c.customerid)
		where c.customerid = co.customerid
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
from f_cardapio()

select *
from f_cardapio(true)
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
$function$;
