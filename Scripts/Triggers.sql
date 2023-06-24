CREATE OR REPLACE FUNCTION f_customerorder_bi()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
	update coffeetable set ocuppied = true 
   		where tableid = new.tableid;
	RETURN NEW;
END;
$function$
;

create trigger customerorder_bi before insert on customerorder for each row execute procedure f_customerorder_bi();

---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_orderitem_aiu()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
declare item_price numeric;
declare total_order numeric;
begin
	select price into item_price from item where itemid = new.itemid; 
	new.total_price := item_price * new.quantity;

	select SUM(total_price) into total_order from orderitem where orderid = new.orderid;
	update customerorder set total = total_order where orderid = new.orderid;

	RETURN NEW;
END;
$function$;

create trigger orderitem_aiu after INSERT OR UPDATE on orderitem for each row execute function f_orderitem_aiu();
