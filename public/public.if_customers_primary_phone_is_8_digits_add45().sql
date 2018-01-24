create or replace function public.if_customers_primary_phone_is_8_digits_add45()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
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

create trigger if_customers_primary_phone_is_8_digits_add45 BEFORE INSERT OR UPDATE
        on public.customers
         for each row
         execute procedure if_customers_primary_phone_is_8_digits_add45();
