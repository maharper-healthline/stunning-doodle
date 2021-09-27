WITH postmeta AS (
                 SELECT
                     website
                     , post_id
                     , MAX(CASE
                               WHEN meta_key = 'updates_root_version_id' AND meta_value != '' THEN meta_value
                           END)                                                                           AS root_id
                     , MAX(CASE WHEN meta_key = 'workflow_type' AND meta_value != '' THEN meta_value END) AS workflow
                 FROM hl.wordpress.wp_postmeta
                 GROUP BY 1, 2
                 )
SELECT
    wf.website
    , wf.post_id
    , wf.meta_title
    , wf.workflow
    , pm2.workflow                                                             AS og_workflow
    , CASE WHEN wf.workflow = 'updates' THEN pm2.workflow ELSE wf.workflow END AS workflow_fixed
FROM hl.wordpress.wp_workflow wf
    LEFT JOIN postmeta pm1
              ON wf.website = pm1.website AND wf.post_id = pm1.post_id
    LEFT JOIN postmeta pm2
              ON wf.website = pm2.website AND pm1.root_id = pm2.post_id::text
WHERE
    wf.website = 'medicalnewstoday' AND workflow_fixed = 'news'
