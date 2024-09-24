with user_first_event as (

-- identify the first event for each user based on the user_first_touch_timestamp
    select
        user_pseudo_id,
        source_source as first_user_source,
        source_medium as first_user_medium,
        user_first_touch_timestamp,
        row_number() over (partition by user_pseudo_id order by user_first_touch_timestamp) as rn

    from {{ ref('stg_ga4_export__event') }}
    where user_first_touch_timestamp is not null
)

-- select the first row for each user
select
    user_pseudo_id,
    first_user_source,
    first_user_medium
from user_first_event
where rn = 1
