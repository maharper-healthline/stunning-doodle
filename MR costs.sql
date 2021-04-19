WITH logs_union AS (
    SELECT
        user_id
        , object_id
        , action
        , meta
        , created
        , mr_rate
        , mr_hours
        , 'healthline'::varchar(100) AS website
    FROM hl.wordpress.v_wp_hlm_logs

    UNION ALL

    SELECT
        user_id
        , object_id
        , action
        , meta
        , created
        , mr_rate
        , mr_hours
        , 'greatist'::varchar(100) AS website
    FROM hl.wordpress.v_wp_2_hlm_logs

    UNION ALL

    SELECT
        user_id
        , object_id
        , action
        , meta
        , created
        , mr_rate
        , mr_hours
        , 'medicalnewstoday'::varchar(100) AS website
    FROM hl.wordpress.v_wp_3_hlm_logs

    UNION ALL

    SELECT
        user_id
        , object_id
        , action
        , meta
        , created
        , mr_rate
        , mr_hours
        , 'psychcentral'::varchar(100) AS website
    FROM hl.wordpress.v_wp_4_hlm_logs

)

SELECT
    l.website
    , u.display_name
    , object_id
    , SUM(mr_rate * mr_hours) AS cost
    , AVG(mr_rate) AS mr_rate
    , SUM(mr_hours) AS mr_hours
FROM logs_union l
LEFT JOIN hl.wordpress.v_wp_users u
    ON l.user_id = u.id
WHERE
    action = 'task_complete'
    AND REGEXP_REPLACE(REGEXP_SUBSTR(meta, '\"task\":"[^"]+'), '(")|(\"?task\"?:)', '') IN ('medical-review', 'outline-review')
GROUP BY
    1, 2, 3
