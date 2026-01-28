{{ config(materialized='table') }}

with customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

     select * from {{ ref('stg_jaffle_shop__orders') }}

),

customer_orders as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,

        count(order_id) as total_number_of_orders,

        count_if(status = 'completed') as completed_orders,
        count_if(status != 'completed') as non_completed_orders

    from orders
    group by customer_id

),

final as (

    select 
        c.customer_id,
        c.first_name,
        c.last_name,

        co.first_order_date,
        co.most_recent_order_date,

        coalesce(co.total_number_of_orders, 0) as total_number_of_orders,
        coalesce(co.completed_orders, 0) as completed_orders,
        coalesce(co.non_completed_orders, 0) as non_completed_orders,

        case 
            when coalesce(co.total_number_of_orders, 0) = 0 then 'no_orders'
            when coalesce(co.total_number_of_orders, 0) = 1 then 'one_time_customer'
            when coalesce(co.total_number_of_orders, 0) between 2 and 4 then 'repeat_customer'
            else 'loyal_customer'
        end as customer_segment

    from customers c
    left join customer_orders co
        on c.customer_id = co.customer_id

)

select *
from final
