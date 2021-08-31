WITH traffic AS (
                SELECT
                    site
                    , post_id
                    , SUM(session) AS sessions
                FROM hl.reporting.mv_traffic
                WHERE
                    date_pt_sk BETWEEN 20210701 AND 20210731
                GROUP BY 1, 2
                ),
    revenue  AS (
                SELECT
                    site
                    , page_path
                    , SUM(CASE WHEN revenue_category IN ('Activation', 'Amazon Affiliates') THEN estimated_revenue END)         AS activation_rev
                    , SUM(CASE WHEN revenue_category LIKE '%DAS%' THEN estimated_revenue END)           AS das_rev
                    , SUM(CASE
                              WHEN revenue_category ILIKE '%programmatic%' THEN estimated_revenue
                          END)                                                                          AS programmatic_rev
                FROM hl.reporting.mv_estimated_revenue_combined
                WHERE
                    TRUNC(month_year) = '2021-07-01'
                GROUP BY 1, 2
                )
SELECT
    wf.post_id
    , wf.website
    , RTRIM(wf.page_path, '/') AS page_path
    , wf.meta_title
    , TRUNC(wf.post_date)      AS pub_date
    , wf.editor
    , wf.content_form
    , wf.k1value
    , wf.subvertical
    , wf.workflow
    , wf.microid
    , t.sessions
    , rev.activation_rev
    , rev.das_rev
    , rev.programmatic_rev
FROM hl.wordpress.wp_workflow wf
    INNER JOIN traffic t
               ON LOWER(wf.table_id) = LOWER(t.site) AND wf.post_id = REGEXP_SUBSTR(t.post_id, '\\d+')
    INNER JOIN revenue rev
               ON LOWER(wf.table_id) = LOWER(rev.site) AND RTRIM(wf.page_path, '/') = RTRIM(rev.page_path, '/')
