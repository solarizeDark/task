-- PostgreSQL 14

-- сущности выделенные с первого скрина
-- основные данные: персональные (ФИО, моб телефон, доп телефон, почта)
--                  паспортные данные (серия, номер, дата выдачи, [код подразделения, кем выдан], дата рождения,
--                                      [место рождения], [регион регистрации])
--                  данные о месте работы ([регион], название компании, ИНН, название должности, зп, дата начала работы)

--                  телефоны - отдельная таблица, тк может быть несколько на заявителя
--                  отдел выдачи паспорта, доп услуги, место рождения и регион регистрации выделены в отдельные таблицы
--                          справочники, тк могут быть одинаковыми у многих заявителей, хранить внешний ключ выгоднее по памяти

--                  паспортные данные, данные о компаниях относятся к заявителю,
--                              поэтому первичные ключи совпадают с внешними

--

-- сущности выделенные со второго скрина
-- параметры заявки: параметры ([вид продукта], [цель кредита], сумма, размер ставки, срок)
--                                              / сумма с учетом услуг не хранится, тк ее можно посчитать на лету
--                   доп услуги (вид, стоимость)

--                   поля ввода вида продукта и цели кредита на скринах - выпадающие списки,
--                                  поэтому выделены в таблицы справочники

--

-- data types alignment
-- поля во всех таблицах расположены в очередности по типу:
--                                      атрибуты не null - поля фиксированной длины,
--                                      атрибуты возможные null - поля фиксированной длины,
--                                      атрибуты с нефиксированной длиной

-- для всех полей, которые хранят денежные единицы выбран decimal с 2 знаками после запятой, тк
-- в формах на скринах суммы вводятся с точностью до копейки, аналогично для процентной ставки по кредиту

-- поля паспортных данных: код, серия, номер и тд, а также длина номера телефона фиксированны и содержат
--                           check constraints, тк они фактически фиксированны

create table applicants (

    id bigint,
        constraint applicants_pk primary key(id),

    name varchar not null ,
    surname varchar not null ,
    patronymic varchar not null ,
    email varchar

);

create table phone_numbers (

    id bigint,
        constraint phone_numbers_pk primary key(id),

    applicant_id bigint,
        constraint phone_numbers_applicants_fk foreign key (applicant_id) references applicants(id)
                           on delete restrict on update cascade,

    number varchar(11),
        constraint phone_numbers_number_length check ( length(number) = 11)

);

-- таблица - справочник
create table units (

    -- уникальное значение, поэтому используется как первичный ключ
    unit_code varchar(6) not null ,
        constraint passport_info_unit_code_length check ( length(unit_code) = 6),
        constraint units_pk primary key (unit_code),

    unit_name varchar not null

);

-- таблица - справочник
create table birth_locations (

    id bigint,
        constraint birth_locations_pk primary key (id),

    name varchar not null

);

-- таблица - справочник
create table regions (

    id bigint,
        constraint registration_regions_pk primary key (id),

    name varchar not null

);

create table passport_info (

    applicant_id bigint,
        constraint passport_info_applicant_fk foreign key (applicant_id) references applicants(id)
                          on delete restrict on update cascade,
        constraint passport_info_pk primary key (applicant_id),

    birth_location bigint not null ,
        constraint passport_info_birth_location_fk foreign key (birth_location) references birth_locations(id)
                           on delete restrict on update cascade,

    reg_region bigint not null ,
        constraint passport_info_reg_location_fk foreign key (reg_region) references regions(id)
                          on delete restrict on update cascade,

    birth date not null ,

    series varchar(4) not null ,
        constraint passport_info_series_length check ( length(series) = 4),

    number varchar(6) not null ,
        constraint passport_info_number_length check ( length(number) = 6),

    issue_date date not null,

    unit_code varchar(6) not null ,
        constraint passport_info_unit_code_fk foreign key (unit_code) references units(unit_code)
                           on delete restrict on update cascade

);

create table company_info (

    applicant_id bigint,
        constraint company_info_applicant_fk foreign key (applicant_id) references applicants(id)
                         on delete restrict on update cascade,
        constraint company_info_pk primary key (applicant_id),

    region bigint,
        constraint company_info_region_fk foreign key (region) references regions(id)
                         on delete restrict on update cascade,

    salary decimal(10, 2) not null ,
        constraint company_info_salary_positive check ( salary > 0 ),

    entrance_date date not null ,

    TIN varchar(12) not null ,
        constraint passport_info_number_length check ( length(TIN) = 12),

    name varchar not null ,

    position varchar not null

);

-- таблица - справочник
create table types (

    id bigint,
        constraint types_pk primary key (id),

    type varchar not null

);

-- таблица - справочник
create table aims (

    id bigint,
        constraint aim_pk primary key (id),

    aim varchar not null

);

create table applications (

    id bigint ,
        constraint application_parameters_pk primary key(id),

    applicant_id bigint not null ,
        constraint application_parameters_applicants_fk foreign key (applicant_id) references applicants(id)
                           on delete restrict on update cascade,

    type bigint not null,
        constraint application_parameters_type_fk foreign key (type) references types(id)
                       on delete restrict on update restrict ,

    aim bigint not null,
        constraint application_parameters_aim_fk foreign key (aim) references aims(id)
                        on delete restrict on update restrict ,

    sum decimal(10, 2) not null,
        constraint application_parameters_sum_positive check ( sum > 0 ),

    rate decimal(10, 2) not null,
        constraint application_parameters_rate_positive check ( rate > 0 ),

    term integer not null,

    -- дата заявления
    declaration_date date not null,

    -- дата выдачи кредита, null по дефолту, тк неизвестен статус
    start date default null,

    -- статус заявки, например: рассматривается, принята, отклонена
    status varchar

);

-- справочник
create table additional_services (

    id bigint,
        constraint additional_services_pk primary key (id),

    price decimal(10, 2) not null,

    name varchar not null

);

-- вспомогательная многие ко многим
create table applications_to_services (

    application_id bigint,
        constraint applications_services_applications_fk foreign key (application_id)
            references applications(id)
            on delete cascade on update cascade ,

    service_id bigint,
        constraint applications_services_services_fk foreign key (service_id)
            references additional_services(id)
            on delete cascade on update cascade

);