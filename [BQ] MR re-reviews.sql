WITH tasks_union AS (
  SELECT 
    *, 
    'healthline' AS site
  FROM `dataeng-214618.wp_prod.tasks`
  UNION ALL 
  SELECT 
    *, 
    'greatist' AS site
  FROM `dataeng-214618.wp_prod.tasks_wp2`
  UNION ALL 
  SELECT 
    *, 
    'medicalnewstoday' AS site
  FROM `dataeng-214618.wp_prod.tasks_wp3`
),


assignees AS (
  SELECT 
    site, 
    post_id, 
    display_name, 
    created_date
  FROM tasks_union
  WHERE 
    name = 'Med Review'
    AND status = 'activated'

), 


completers AS (
  SELECT 
    site, 
    post_id, 
    display_name,
    created_date
  FROM tasks_union
  WHERE 
    name = 'Med Review'
    AND status = 'completed'

)


SELECT 
  ass.site, 
  ass.post_id, 
  ass.display_name AS assignee, 
  ass.created_date AS assignee_date, 
  c.display_name AS completer, 
  c.created_date AS completer_date, 
  wf.post_status
  
   
FROM assignees ass
LEFT JOIN completers c 
  ON ass.site = c.site
  AND ass.post_id = c.post_id 
  AND ass.display_name = c.display_name 
LEFT JOIN `bigquery-1084.maharper.workflow_union` wf 
  ON ass.site = wf.website
  AND ass.post_id = wf.post_id 
  
WHERE 
  ass.display_name NOT IN ('cron-job', 'David Bahia', 'Med.Review Manager')
  AND ass.display_name NOT LIKE '%TEST%'
  AND c.display_name IS NULL 
  AND wf.post_status = 'publish'
