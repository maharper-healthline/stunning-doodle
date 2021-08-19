SELECT
    TRUNC(DATE_TRUNC('month', wf.post_date)) AS cohort
    , rev.*
FROM hl.reporting.mv_estimated_revenue_combined rev
    JOIN hl.wordpress.wp_workflow wf
         ON LOWER(rev.site) = LOWER(wf.table_id) AND RTRIM(wf.page_path, '/') = rev.page_path
WHERE
    TRUNC(month_year) = '2021-07-01'
    AND cohort = '2021-04-01'
    AND wf.page_path NOT IN ('', '/') 
