WITH tasked_articles AS (
  SELECT 
    a.website, 
    a.object_id, 
    last_ie, 
    first_mr, 
    last_ie > first_mr AS tasked_back
  FROM (
    SELECT
      website,
      object_id, 
      MAX(created) AS last_ie
    FROM
      `bigquery-1084.maharper.logs_union`
    WHERE 
      action = 'task_complete'
      AND (meta LIKE '%initial-edit%' OR meta LIKE '%scoping%' OR (meta LIKE '%create-assignment%' AND meta LIKE '%diabetes%'))
    GROUP BY 
      1, 2
  ) a 
  JOIN (
    SELECT
      website, 
      object_id, 
      MIN(created) AS first_mr
    FROM
      `bigquery-1084.maharper.logs_union`
    WHERE 
      action = 'task_complete'
      AND (meta LIKE '%medical-review%' OR meta lIKE '%fact-check%')
    GROUP BY 
      1, 2
  ) b
    ON a.object_id = b.object_id 
    AND a.website = b.website
  WHERE 
    first_mr BETWEEN '2020-01-01' AND '2020-06-17'
)

SELECT 
  website, 
  object_id AS post_id, 
  user_id, 
  action, 
  REGEXP_REPLACE(REGEXP_EXTRACT(meta, r'\"workflow\":"[^"]+'), '(")|(\"?workflow\"?:)', '') AS workflow, 
  REGEXP_REPLACE(REGEXP_EXTRACT(meta, r'\"task\":"[^"]+'), '(")|(\"?task\"?:)', '') AS task,
  created AS timestamp
FROM `bigquery-1084.maharper.logs_union` 
WHERE 
  CONCAT(website, object_id) IN (
    SELECT DISTINCT
      CONCAT(website, object_id)
    FROM tasked_articles 
    WHERE 
      tasked_back = true 
  )
  AND action IN ('task_activated', 'task_completed')
ORDER BY 
  website, object_id, created

