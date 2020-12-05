WITH wf AS (
  SELECT 
    *, 
    'B631 Healthline.com' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.workflow`
  UNION ALL
  SELECT 
    *,
    'B633 Greatist' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.workflow_wp2`
  UNION ALL
  SELECT 
    *, 
    'B632 MNT' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.workflow_wp3`
),


post_meta AS (
  SELECT 
    *, 
    'B631 Healthline.com' AS Business_Unit  
  FROM `dataeng-214618.wp_dbx.wp_postmeta`
  UNION ALL 
  SELECT 
    *, 
    'B633 Greatist' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.wp_2_postmeta`
  UNION ALL 
  SELECT 
    *, 
    'B632 MNT' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.wp_3_postmeta`
),

posts AS (
  SELECT 
    *, 
    'B631 Healthline.com' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.wp_posts`
  UNION ALL
  SELECT 
    *,
    'B633 Greatist' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.wp_2_posts`
  UNION ALL
  SELECT 
    *,
    'B632 MNT' AS Business_Unit
  FROM `dataeng-214618.wp_dbx.wp_3_posts`
),


t1 AS (
  SELECT
    post_id,
    CASE 
      WHEN MAX(IF(meta_key = '_meta_title', meta_value, NULL)) = '' OR MAX(IF(meta_key = '_meta_title', meta_value, NULL)) IS NULL 
        THEN MAX(IF(meta_key = 'content_push_body', REGEXP_REPLACE(REGEXP_EXTRACT(meta_value, r'\"htmlTitle\":"[^"]+'), '(")|(\"?htmlTitle\"?:)', ''), NULL))
      ELSE MAX(IF(meta_key = '_meta_title', meta_value, NULL))
    END AS Article_Name,
    MAX(IF(meta_key = 'mr-hours', meta_value, NULL)) AS mr_hours,
    MAX(IF(meta_key = 'category', meta_value, NULL)) AS Category,
    MAX(IF(meta_key = 'permalink', meta_value, NULL)) AS URL,
    MAX(IF(meta_key = 'budget_code', meta_value, NULL)) AS Budget_Code,
    MAX(IF(meta_key = 'mr-rate' AND meta_value != '', meta_value, NULL)) AS Cost, 
    MAX(IF(meta_key = 'medical_reviewer', meta_value, NULL)) AS MR_id,
    CASE 
      WHEN MAX(IF(meta_key = 'workflow_type', meta_value, NULL)) = '' 
        THEN MAX(IF(meta_key = 'mercury_active_workflow_slug', meta_value, NULL))
      ELSE MAX(IF(meta_key = 'workflow_type', meta_value, NULL)) 
      END AS Workflow,
    MAX(IF(meta_key = 'marketing-bbr-code', meta_value, NULL)) AS bbr_code,
    MAX(IF(meta_key = 'invoicing_notes', meta_value, NULL)) AS invoicing_notes,
    Business_Unit
  FROM post_meta
  GROUP BY 
    post_id, Business_Unit
), 

supplier_ids AS (
  SELECT 
    *
  FROM (
      SELECT 
        display_name, 
        u.id, 
        MAX(IF(meta_key = 'workday_id', meta_value, NULL)) AS workday_id, 
      FROM `dataeng-214618.wp_dbx.wp_users` u 
      LEFT JOIN `dataeng-214618.wp_dbx.wp_usermeta` um 
        on u.id = um.user_id 
      GROUP BY 
        1, 2 
  )
  WHERE 
    workday_id IS NOT NULL 
)


SELECT DISTINCT
   EXTRACT(Date FROM wf.complete_med_rev_date) AS Completion_Date,
   t1.URL, 
   t1.Article_Name,
   wf.post_id,
   wf.complete_med_rev AS Supplier,
   si1.workday_id AS Supplier_ID, 
   'Raven Shelvin' AS Point_of_Contact, 
   '28396' AS POC_ID, 
   t1.Budget_Code,
   mr_hours AS Qty,
   Cost,
   NULL AS Extended_Amount, 
   'LOC-319 - SF' AS Deliver_to_Location, 
   'D735 Medical Services' AS Cost_Center, 
   wf.Business_Unit, 
   'C000 Admin' AS Channel, 
   bbr_code, 
   invoicing_notes, 
   wf.complete_post_pub_date
FROM wf
LEFT JOIN t1
  ON wf.post_id = t1.post_id
  AND wf.Business_Unit = t1.Business_Unit
LEFT JOIN supplier_ids si1
  on wf.complete_med_rev = si1.display_name 
LEFT JOIN supplier_ids si2
  ON wf.Editor = si2.display_name
LEFT JOIN posts
  ON posts.ID = wf.post_id
  AND posts.business_unit = wf.business_unit
WHERE 
    DATE_TRUNC(DATE(complete_med_rev_date), YEAR) = DATE_TRUNC(CURRENT_DATE(), YEAR) 

ORDER BY 
  Business_Unit, Completion_Date DESC
