WITH terms AS (
    SELECT
        *
        , 'healthline' AS website
    FROM hl.wordpress.v_wp_terms
    UNION ALL
    SELECT
        *
        , 'greatist' AS website
    FROM hl.wordpress.v_wp_2_terms
    UNION ALL
    SELECT
        *
        , 'medicalnewstoday' AS website
    FROM hl.wordpress.v_wp_3_terms
    UNION ALL
    SELECT
        *
        , 'psychcentral' AS website
    FROM hl.wordpress.v_wp_4_terms
),

article_meta AS (
    SELECT
        website
        , post_id
        , MAX(CASE WHEN meta_key = 'all_assets_delivered' THEN meta_value END) AS asset_delivery_status
    FROM hl.wordpress.wp_postmeta
    GROUP BY
        1, 2
    )

SELECT article_meta.asset_delivery_status,
       posts.post_type,
       posts.post_status,
       pm.website,
       pm.post_id,
       pm.linked_post_id,
       users1.display_name AS editor_requested,
       pm.creation_date    AS asset_created_date,
       pm.due_date         AS asset_due_date,
       users2.display_name AS asset_mr,
       terms.name          AS asset_type
FROM (
         SELECT
            website,
            post_id,
            MAX(CASE WHEN meta_key = 'requester_id' AND meta_value != '' THEN meta_value END::integer) AS                requester_id,
            MAX(CASE WHEN meta_key = 'linked_post_id' AND meta_value != '' THEN meta_value END::integer) AS              linked_post_id,
            MAX(CASE WHEN meta_key = 'creation_date' AND meta_value != '' THEN DATE_ADD('s', meta_value::integer,'1970-01-01') END::timestamp) AS creation_date,
            MAX(CASE WHEN meta_key = 'due_date' AND meta_value != '' THEN DATE_ADD('s', meta_value::integer, '1970-01-01') END::timestamp) AS due_date,
            MAX(CASE WHEN meta_key = 'med_reviewer_id' AND meta_value != '' THEN meta_value END::integer) AS             med_reviewer_id,
            MAX(CASE WHEN meta_key = 'asset_type_id' AND meta_value != '' THEN meta_value END::integer) AS               asset_type_id
         FROM hl.wordpress.wp_postmeta
         GROUP BY 1, 2
) pm
LEFT JOIN hl.wordpress.wp_post posts
    ON posts.id = pm.post_id
    AND posts.website = pm.website
LEFT JOIN terms
    ON pm.website = terms.website
    AND pm.asset_type_id = terms.term_id
LEFT JOIN article_meta
    ON article_meta.website = pm.website
    AND article_meta.post_id::varchar(100) = pm.linked_post_id
LEFT JOIN hl.wordpress.v_wp_users users1
    ON pm.requester_id = users1.id
LEFT JOIN hl.wordpress.v_wp_users users2
    ON pm.med_reviewer_id = users2.id
WHERE
  posts.post_type = 'asset-request'
  AND posts.post_status != 'trash'
