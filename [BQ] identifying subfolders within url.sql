WITH page_paths AS (
  SELECT 
    post_id, 
    MAX(IF(meta_key = 'permalink', REGEXP_REPLACE(meta_value, 'https://www.healthline.com', ''), NULL)) AS page_path
  FROM `dataeng-214618.wp_dbx.wp_posts` p
  LEFT JOIN `dataeng-214618.wp_dbx.wp_postmeta` pm
    ON p.id = pm.post_id 
  WHERE 
    p.post_type = 'post'
    AND p.post_status = 'publish' 
  GROUP BY 
    post_id
)

SELECT 
  RTRIM(
    REGEXP_REPLACE(
      page_path, 
      ARRAY_REVERSE(SPLIT(page_path, "/"))[SAFE_OFFSET(1)], 
      ''
    ), 
    '/'
  ) AS subfolder, 
  count(distinct post_id) as articles 
FROM page_paths 
GROUP BY 
  1
ORDER BY 
  2 desc 
