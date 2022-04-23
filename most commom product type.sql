with most_common_type_id as (

    select type as type_id, count(type) as amount
        from applications
        where start >= '01.01.2022'::date
    group by type
    order by amount desc
    limit 1

)
select type as "most_common_type"
    from types where id = (select type_id from most_common_type_id);