SELECT 
  page_path, 
  cohort, 
  k1, 
  month, 
  site, 
  revenue_type, 
  amount
FROM `bigquery-1084.content_roi.revenue_combined`
WHERE  
  month >= DATE_SUB(CURRENT_DATE(), INTERVAL 13 MONTH)
  
UNION ALL 

SELECT 
  a.pagepath, 
  DATE('9999-01-01') AS cohort, 
  k.k1, 
  DATE_TRUNC(datept, month) AS month, 
  site, 
  'secondsonsite' as revenue_type, 
  sum(secondsonsite) as amount
FROM `bigquery-1084.maharper.traffic_union` a
LEFT JOIN `bigquery-1084.gino.pagepath_k1_clean_mapping` k
  ON REGEXP_REPLACE(k.pagepath, ".php","") = REGEXP_REPLACE(a.pagepath, ".php","")
GROUP BY 
  1, 2, 3, 4, 5, 6
  
UNION ALL 

SELECT 
  a.pagepath, 
  DATE('9999-01-01') AS cohort, 
  k.k1, 
  DATE_TRUNC(datept, month) AS month, 
  site, 
  'bounces' as revenue_type, 
  sum(bounce) as amount
FROM `bigquery-1084.maharper.traffic_union` a
LEFT JOIN `bigquery-1084.gino.pagepath_k1_clean_mapping` k
  ON REGEXP_REPLACE(k.pagepath, ".php","") = REGEXP_REPLACE(a.pagepath, ".php","")
GROUP BY 
  1, 2, 3, 4, 5, 6
