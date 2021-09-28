WITH traffic AS (
                SELECT
                    site
                    , RTRIM(page_path, '/')                                             AS page_path
                    , TRUNC(DATE_TRUNC('month', TO_DATE(date_pt_sk::text, 'YYYYMMDD'))) AS month_year
                    , SUM(session)                                                      AS sessions
                FROM hl.reporting.mv_traffic
                WHERE
                    date_pt_sk BETWEEN 20210101 AND 20210731
                GROUP BY 1, 2, 3
                ),
    revenue  AS (
                SELECT
                    site
                    , page_path
                    , TRUNC(month_year)                                                                 AS month_year
                    , SUM(CASE
                              WHEN revenue_category IN ('Activation', 'Amazon Affiliates') THEN estimated_revenue
                          END)                                                                          AS activation_rev
                    , SUM(CASE WHEN revenue_category LIKE '%DAS%' THEN estimated_revenue END)           AS das_rev
                    , SUM(CASE
                              WHEN revenue_category ILIKE '%programmatic%' THEN estimated_revenue
                          END)                                                                          AS programmatic_rev
                FROM hl.reporting.mv_estimated_revenue_combined
                WHERE
                    TRUNC(month_year) BETWEEN '2021-01-01' AND '2021-07-01'
                GROUP BY 1, 2, 3
                )
SELECT
    t.month_year
    , wf.post_id
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
               ON LOWER(wf.table_id) = LOWER(t.site) AND RTRIM(wf.page_path, '/') = RTRIM(t.page_path, '/')
    INNER JOIN revenue rev
               ON LOWER(wf.table_id) = LOWER(rev.site) AND RTRIM(wf.page_path, '/') = RTRIM(rev.page_path, '/') AND
                  t.month_year = rev.month_year
