select 
    id as payment_id,
    orderid as order_id,
    paymentmethod,
    status,
    amount,
    created as _etl_loaded_at
from {{ source('stripe', 'payment') }}