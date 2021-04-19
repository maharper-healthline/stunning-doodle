WITH terms AS (
  SELECT
    *,
    'healthline' AS website
  FROM hl.wordpress.v_wp_terms
  UNION ALL
  SELECT
    *,
    'greatist' AS website
  FROM hl.wordpress.v_wp_2_terms
  UNION ALL
  SELECT
    *,
    'medicalnewstoday' AS website
  FROM hl.wordpress.v_wp_3_terms
  UNION ALL
  SELECT
    *,
    'psychcentral' AS website
  FROM hl.wordpress.v_wp_4_terms
)


SELECT
  meta_data.website,
  meta_data.workflow,
  meta_data.id,
  a.display_name AS requester,
  linked_post_id AS article_id,
  DATE_ADD('s', creation_date, '1970-01-01') AS creation_date,
  DATE_ADD('s', due_date, '1970-01-01') AS due_date,
  b.display_name AS med_reviewer,
  posts.post_title,
  terms.name
FROM (
    SELECT
        posts.website,
        posts.id,
        MAX(CASE WHEN meta_key = 'requester_id' THEN meta_value END) AS requester_id,
        MAX(CASE WHEN meta_key = 'linked_post_id' THEN meta_value END) AS linked_post_id,
        MAX(CASE WHEN meta_key = 'creation_date' AND TRIM(meta_value)!='' THEN meta_value END::integer) AS creation_date,
        MAX(CASE WHEN meta_key = 'due_date' AND TRIM(meta_value)!='' THEN meta_value END::integer) AS due_date,
        MAX(CASE WHEN meta_key = 'med_reviewer_id' THEN meta_value END) AS med_reviewer_id,
        MAX(CASE WHEN meta_key = 'asset_type_id' THEN meta_value END) AS asset_type_id
    FROM hl.wordpress.wp_post posts
    LEFT JOIN hl.wordpress.wp_postmeta postmeta
        ON posts.id = postmeta.post_id
        AND posts.website = postmeta.website
    WHERE
        post_type = 'asset-request'
    GROUP BY
        1, 2
) meta_data
LEFT JOIN hl.wordpress.v_wp_users a
  ON meta_data.requester_id = a.id::varchar(100)
LEFT JOIN hl.wordpress.v_wp_users b
  ON meta_data.med_reviewer_id = b.id::varchar(100)
LEFT JOIN hl.wordpress.wp_post posts
  ON meta_data.linked_post_id = posts.id::varchar(100)
  AND meta_data.website = posts.website
LEFT JOIN terms
  ON meta_data.asset_type_id = terms.term_id::varchar(100)
    AND meta_data.website = terms.website
WHERE
  med_reviewer_id IS NOT NULL
  AND REGEXP_COUNT(terms.name, '\ -\ |\ –\ ') > 0
ORDER BY
  due_date
