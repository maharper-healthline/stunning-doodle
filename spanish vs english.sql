WITH spanish AS (
                SELECT
                    p.website
                    , p.post_date
                    , t.page_path
                    , p.post_title                          AS title
                    , TO_DATE(date_pt_sk::text, 'YYYYMMDD') AS datept
                    , REGEXP_REPLACE(
                        REGEXP_SUBSTR(LOWER(post_content_trunc), '<a href=".*">leer el artículo en inglés\\.?</a>'),
                        '<a href="(https?://www.medicalnewstoday.com)?|(.php)?(" target="_blank" rel="noopener noreferrer)?">leer el artículo en inglés\.?</a>',
                        '')                                 AS english_path
                    , MAX(k1)                               AS K1
                    , SUM(session)                          AS sessions
                    , SUM(timeonsite)                       AS seconds
                    , SUM(bounce)                           AS bounces
                FROM hl.reporting.mv_traffic t
                JOIN hl.wordpress.wp_post p
                     ON p.id::text = REGEXP_SUBSTR(t.post_id, '\\d+') AND CASE
                                                                              WHEN t.site = 'HL' THEN 'healthline'
                                                                              WHEN t.site = 'GRT' THEN 'greatist'
                                                                              WHEN t.site = 'MNT'
                                                                                  THEN 'medicalnewstoday'
                                                                              WHEN t.site = 'PC' THEN 'psychcentral'
                                                                          END = p.website
                WHERE
                        TO_DATE(date_pt_sk::text, 'YYYYMMDD') >= TRUNC(DATEADD(DAY, -120, CURRENT_DATE))
                    AND REGEXP_COUNT(page_path, '/es/') > 0
                    AND REGEXP_COUNT(page_path,
                                     '/translate_c$|^/search$|wp-|^/health/+[1234567890].+[1234567890]$|^/preview/|%') =
                        0
                    AND p.post_type = 'post'
                    AND p.post_status = 'publish'
                GROUP BY 1, 2, 3, 4, 5, 6
                )
   , english AS (
                SELECT
                    p.website
                    , p.post_date
                    , t.page_path
                    , p.post_title                          AS title
                    , TO_DATE(date_pt_sk::text, 'YYYYMMDD') AS datept
                    , SUM(session)                          AS sessions
                    , SUM(timeonsite)                       AS seconds
                    , SUM(bounce)                           AS bounces
                FROM hl.reporting.mv_traffic t
                LEFT JOIN hl.wordpress.wp_post p
                          ON p.id::text = REGEXP_SUBSTR(t.post_id, '\\d+')
                WHERE
                    datept >= DATEADD(DAY, -120, CURRENT_DATE)
                    AND REGEXP_COUNT(page_path, '/es/') = 0
                    AND REGEXP_COUNT(page_path,
                                     '/translate_c$|^/search$|wp-|^/health/+[1234567890].+[1234567890]$|^/preview/|%') =
                        0
                    AND p.post_type = 'post'
                    AND p.post_status = 'publish'
                GROUP BY 1, 2, 3, 4, 5
                )
SELECT
    s.website
    , s.datept
    , s.K1
    , s.post_date AS spanish_post_date
    , s.page_path AS spanish_pagepath
    , s.title     AS spanish_title
    , s.sessions  AS spanish_sessions
    , s.seconds   AS spanish_seconds
    , s.bounces   AS spanish_bounces
    , e.post_date AS english_post_date
    , e.page_path AS english_pagepath
    , e.title     AS english_title
    , e.sessions  AS english_sessions
    , e.seconds   AS english_seconds
    , e.bounces   AS english_bounces
FROM spanish s
LEFT JOIN english e
          ON s.english_path = e.page_path AND s.datept = e.datept
