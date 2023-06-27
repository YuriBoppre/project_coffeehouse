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

---------------------------------------------------------------------------------------------------------------------

CREATE or REPLACE FUNCTION f_payment_bi() RETURNS trigger AS $$
declare payment_cacheid int;
declare payment_tableid int;
declare total_order numeric; 
declare total_value numeric;
declare free_table boolean;
declare close_order boolean;
begin
	select cacheid into payment_cacheid from cache where cache.date = cast(new.date as date);
	if payment_cacheid is null then
		insert into cache(total, date) values(new.value, new.date);
	else
		update cache set total = total + new.value where cacheid = payment_cacheid;
	end if;

	select total into total_order from customerorder where customerorder.orderid = new.orderid;
	select sum(value) into total_value from payment where payment.orderid = new.orderid;
	if total_value is null then
		close_order := not (new.value <> total_order);
	else
		close_order := not (total_value + new.value <> total_order);
	end if;

	if close_order then
		update customerorder set opened = false where orderid = new.orderid;
	end if;
  
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payment_bi BEFORE insert ON payment for each row EXECUTE FUNCTION f_payment_bi();


