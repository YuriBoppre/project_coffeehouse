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