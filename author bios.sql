SELECT
    display_name
     , articles
    , CASE WHEN has_bio_page = '1' then 'TRUE' ELSE '-' END AS has_bio_page
    , CASE WHEN has_bio_page = '1' THEN 'https://greatist.com/authors/' || regexp_replace(LOWER(display_name), ' ', '-') ELSE '-' END AS bio_page
FROM (
         select
                user_id
              , u.display_name
              , MAX(CASE WHEN meta_key = 'wp_2_capabilities' THEN meta_value_trunc END)  AS grt_role
              , MAX(CASE WHEN meta_key = 'enable_author_page' THEN meta_value_trunc END) AS has_bio_page
              , MAX(CASE WHEN meta_key = 'description' THEN meta_value_trunc END) AS bio_page
         from hl.wordpress.v_wp_usermeta um
         join hl.wordpress.v_wp_users u
            ON um.user_id = u.id
         GROUP BY
            1, 2
     ) meta
JOIN (
    SELECT
        writer
        , count(distinct post_id) AS articles
    FROM hl.wordpress.wp_workflow
    WHERE
        website = 'greatist'
    GROUP BY
        1
) wf
    ON wf.writer = meta.display_name
WHERE
    grt_role ilike '%contributor%'
ORDER BY
    2 DESC
