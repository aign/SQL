create or replace function temp.check_if_primary_phone_is_8_digits()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_address_in_table int;
	_primary_phone text;
begin		 
		select new.primary_phone into _primary_phone;
		if length(_primary_phone) = 8 then
			new.primary_phone = '45'||new.primary_phone;
		end if;
		return new;
	exception when others then
		return new;
end;
$function$;

create trigger check_if_primary_phone_is_8_digits BEFORE INSERT OR UPDATE
        on temp.customers_test
         for each row
         execute procedure check_if_primary_phone_is_8_digits();

