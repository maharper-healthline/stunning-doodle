with pm AS (
  SELECT
    website,
    post_id,
    MAX(CASE WHEN meta_key = 'k1value' THEN NULLIF(meta_value, '') END) AS k1,
    MAX(CASE WHEN meta_key = 'fc-hours' THEN NULLIF(meta_value, '') END) AS fc_hours,
    MAX(CASE WHEN meta_key = 'mr-hours' THEN NULLIF(meta_value, '') END) AS mr_hours,
    MAX(CASE WHEN meta_key = 'permalink' THEN meta_value END) AS url
  FROM hl.wordpress.wp_postmeta
  GROUP BY
    1, 2
)


SELECT
  date(complete_post_pub_date) as pub_date,
  wf.post_id,
  wf.website,
  wf.workflow,
  wf.wf_category as category,
  NULLIF(pay_rate, '') as writer_pay_rate,
  NULLIF(fc_rate, ''),
  pm.fc_hours,
  NULLIF(mr_rate, ''),
  pm.mr_hours,
  pm.k1,
  url
FROM hl.wordpress.wp_workflow wf
LEFT JOIN pm
  ON wf.post_id = pm.post_id
  AND wf.website = pm.website
WHERE
  lower(workflow) NOT IN ('updates', 'migrate')
  AND date_trunc('year', complete_post_pub_date) = '2020-01-01'
  AND (migrated_on is null or migrated_on = '')
order by
  pub_date desc
