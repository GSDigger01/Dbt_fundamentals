select
    o.order_id,
    o.customer_id,
    sum(case when p.status = 'success' then p.amount else 0 end) as amount_paid,
    sum(case when p.status = 'failed' then p.amount else 0 end) as amount_failed

from {{ ref('stg_jaffle_shop__orders') }} o
left join {{ ref('stg_stripe__payments') }} p
    on p.order_id = o.order_id
   
group by
    o.order_id,
    o.customer_id
order by order_id 