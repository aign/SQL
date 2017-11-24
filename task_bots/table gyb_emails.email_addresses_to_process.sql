
create table gyb_emails.email_addresses_to_process (
id serial,
address text,
CONSTRAINT email_addresses_to_process_pk PRIMARY KEY (id)
);

insert into gyb_emails.email_addresses_to_process (address) values ('udgift@revisor1.dk');
insert into gyb_emails.email_addresses_to_process (address) values ('indtaegt@revisor1.dk');
insert into gyb_emails.email_addresses_to_process (address) values ('indtÃ¦gt@revisor1.dk');
insert into gyb_emails.email_addresses_to_process (address) values ('indtægt@revisor1.dk');

