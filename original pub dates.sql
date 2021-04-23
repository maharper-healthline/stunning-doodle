WITH postmeta AS (
    SELECT website
         , post_id
         , MAX(CASE WHEN meta_key = 'updates_root_version_id' AND meta_value != '' THEN meta_value END) AS root_id
    FROM hl.wordpress.wp_postmeta
    GROUP BY 1, 2
)

SELECT
    a.website
    , post_id
    , a.post_date AS pubdate
    , b.post_date AS root_pubdate
    , COALESCE(b.post_date, a.post_date) og_pubdate
FROM hl.wordpress.wp_post a
LEFT JOIN postmeta pm
    ON a.id = pm.post_id
    AND a.website = pm.website
LEFT JOIN hl.wordpress.wp_post b
    ON b.id::varchar(100) = pm.root_id
    AND b.website = pm.website
WHERE
    a.post_type = 'post'

