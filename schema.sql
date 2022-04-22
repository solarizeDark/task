-- основные данные: персональные(ФИО, моб телефон, доп мобила, почта)
--                  паспортные данные(серия, номер, дата выдачи, код подразделения, кем выдан, дата рождения, место рождения, регион регистрации)
--                  данные о месте работы(регион, название компании, ИНН, название должности, зп, дата начала работы)

-- параметры заявки: параметры (вид продукта, цель кредита, сумма, размер ставки, срок)
--                                              / сумма с учетом услуг не хранится, тк ее можно посчитать на лету
--                   доп услуги (вид, стоимость)
--

-- data types alignment
-- поля во всех таблицах расположены в очередности по типу:
--                                      атрибуты не null - поля фиксированной длины,
--                                      атрибуты возможные null - поля фиксированной длины,
--                                      атрибуты с нефиксированной длиной

-- applicants (name, surname, patronymic, phone number, additional phone number, email)
create table applicants (

    id bigint,
        constraint applicants_pk primary key(id),

    name varchar not null ,
    surname varchar not null ,
    patronymic varchar not null ,
    email varchar

);

create table phone_numbers (

    applicant_id bigint,
        constraint phone_numbers_applicants_fk foreign key (applicant_id) references applicants(id)
                           on delete restrict on update cascade,
        constraint phone_numbers_pk primary key(applicant_id),

    number varchar(11),
        constraint phone_numbers_number_length check ( length(number) = 11)

);

-- отделы выдачи паспорта, отдельная таблица - справочник
create table units (

    unit_code varchar(6) not null ,
        constraint passport_info_unit_code_length check ( length(unit_code) = 6),
        constraint units_pk primary key (unit_code),

    unit_name varchar not null

);

-- отдельная таблица - справочник
create table birth_locations (

    id bigint,
        constraint birth_locations_pk primary key (id),

    name varchar not null

);

create table registration_regions (

    id bigint,
        constraint registration_regions_pk primary key (id),

    name varchar not null

);

-- passports (series, number, issue_date, unit_code, unit_name, birth, birth_location, registration_region)
create table passport_info (

    applicant_id bigint,
        constraint passport_info_applicant_fk foreign key (applicant_id) references applicants(id)
                          on delete restrict on update cascade,
        constraint passport_info_pk primary key (applicant_id),

    birth_location bigint not null ,
        constraint passport_info_birth_location_fk foreign key (birth_location) references birth_locations(id)
                           on delete restrict on update cascade,

    reg_region bigint not null ,
        constraint passport_info_reg_location_fk foreign key (reg_region) references registration_regions(id)
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

-- company_info (region, name, TIN(ИНН), position, salary, entrance_date)
create table company_info (

    applicant_id bigint,
        constraint passport_info_applicant_fk foreign key (applicant_id) references applicants(id)
                         on delete restrict on update cascade,
        constraint company_info_pk primary key (applicant_id),

    salary integer not null ,
        constraint company_info_salary_positive check ( salary > 0 ),

    entrance_date date not null,

    TIN varchar(12) not null ,
        constraint passport_info_number_length check ( length(TIN) = 12),

    name varchar not null ,

    position varchar not null

);

-- types (name)
-- отдельные таблицы - справочники, тк на скриншотах вид и цель кредита - выпадающие списки
create table types (

    id bigint,
        constraint types_pk primary key (id),

    type varchar not null
);

-- aims (name)
create table aims (

    id bigint,
        constraint aim_pk primary key (id),

    aim varchar not null
);

-- application_parameters (type, aim, sum, rate, term)
create table application_parameters (

    id bigint,
        constraint application_parameters_pk primary key (id),

    type bigint not null,
        constraint application_parameters_type_fk foreign key (type) references types(id)
                       on delete restrict on update restrict ,

    aim bigint not null,
        constraint application_parameters_aim_fk foreign key (aim) references aims(id)
                        on delete restrict on update restrict ,

    sum bigint not null,
        constraint application_parameters_sum_positive check ( sum > 0 ),

    term integer not null

);