with user_first_data as (
    -- identify the first event for each user based on the minimum event_timestamp
    select
        user_pseudo_id,
        min(event_timestamp) as first_event_timestamp
    from
        {{ ref('stg_ga4_export__event') }}
    where
        event_name = 'session_start'
        and user_pseudo_id is not null
    group by
        user_pseudo_id
),

first_user_source_medium as (
    -- use row_number() to prioritize non-null source/medium, ensuring one record per user
    select
        events.user_pseudo_id,
        events.source_relation,
        lower(events.source_source) as first_user_source,
        lower(events.source_medium) as first_user_medium,
        row_number() over (
            partition by events.user_pseudo_id, events.source_relation
            order by 
                -- just in case, prioritize rows with non-null source_source and source_medium, since there can be multiple events with the same event_timestamp
                case 
                when events.source_source is not null and events.source_medium is not null then 1
                else 2
                end,
                events.event_timestamp
        ) as row_num
    from
        {{ ref('stg_ga4_export__event') }} as events
    join
        user_first_data as ufd
        on events.user_pseudo_id = ufd.user_pseudo_id
        and events.event_timestamp = ufd.first_event_timestamp
    where events.user_pseudo_id is not null
)

select
    user_pseudo_id,
    source_relation,
    first_user_source,
    first_user_medium
from first_user_source_medium
where row_num = 1 -- select only the first record per user
