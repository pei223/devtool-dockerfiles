CREATE DATABASE keycloak;

CREATE TABLE companies (
    company_id uuid not null,
    display_name varchar(100) not null
);
alter table companies add constraint companies_PKC primary key (company_id);


CREATE TABLE products (
    product_id uuid not null,
    company_id uuid not null,
    display_name varchar(100) not null,
    price integer not null
);
alter table products add constraint products_PKC primary key (product_id);
alter table products add constraint products_FKC foreign key (company_id) references companies(company_id) on delete cascade;
