CREATE OR REPLACE FUNCTION f_veriricaitem(_itemid int)
RETURNS varchar
LANGUAGE plpgsql
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
$function$;