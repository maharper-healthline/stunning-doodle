%sql WITH spanish AS (
  SELECT
    p.website,
    p.post_date,
    t.page_path,
    p.post_title AS title,
    trunc(to_date(cast(date_pt_sk as String), 'yyyyMMdd'), 'month') AS datept,
    country,
    REGEXP_REPLACE(
      regexp_extract(
        LOWER(post_content),
        '(<a href=".*">leer? (el|este) artículo en inglés\\.?</a>)',
        1
      ),
      '<a href="(https?://www.(medicalnewstoday|healthline).com)?|(.php)?(" target="_blank" rel="(noopener noreferrer|noreferrer noopener)|data-type="url" data-id=".*)?">leer? (el|este) artículo en inglés\\.?</a>',
      ''
    ) AS english_path,
    xxhash64(
      REGEXP_REPLACE(
        regexp_extract(
          LOWER(post_content),
          '(<a href=".*">leer? (el|este) artículo en inglés\\.?</a>)',
          1
        ),
        '<a href="(https?://www.(medicalnewstoday|healthline).com)?|(.php)?(" target="_blank" rel="(noopener noreferrer|noreferrer noopener)|data-type="url" data-id=".*)?">leer? (el|este) artículo en inglés\\.?</a>',
        ''
      )
    ) AS path_sk,
    MAX(k1) AS K1,
    SUM(session) AS sessions,
    SUM(timeonsite) AS seconds,
    SUM(bounce) AS bounces
  FROM
    traffic t
    JOIN posts p ON p.id = t.post_id
    AND t.site = p.table_id
  WHERE
    --                         TO_DATE(date_pt_sk::text, 'YYYYMMDD') >= TRUNC(DATEADD(DAY, -120, CURRENT_DATE))
    --                     AND
    page_path like '%/es/%' 
    --                     AND REGEXP_COUNT(page_path like '%/translate_c$|^/search$|wp-|^/health/+[1234567890].+[1234567890]$|^/preview/|%') =
    --                       0
    --                     AND t.site IN ('HL', 'MNT')
    AND p.post_type = 'post' 
    AND p.post_status = 'publish'
  GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
),
english AS (
  SELECT
    p.website,
    p.post_date,
    t.page_path,
    xxhash64(t.page_path) AS path_sk,
    p.post_title AS title,
    trunc(to_date(cast(date_pt_sk as String), 'yyyyMMdd'), 'month') AS datept,
    country,
    SUM(session) AS sessions,
    SUM(timeonsite) AS seconds,
    SUM(bounce) AS bounces
  FROM
    traffic t
     JOIN posts p ON p.id = t.post_id
    AND t.site = p.table_id
  WHERE
    --                    datept >= DATEADD(DAY, -120, CURRENT_DATE)
    --                    AND REGEXP_COUNT(page_path,
    --                                     '/translate_c$|^/search$|wp-|^/health/+[1234567890].+[1234567890]$|^/preview/|%') =
    --                        0
    --                    AND t.site IN ('HL', 'MNT')
    page_path not like '%/es/%'
    AND p.post_type = 'post' 
    AND p.post_status = 'publish'
  GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7
)
SELECT
  s.website,
  s.datept,
  s.K1,
  s.country,
  s.post_date AS spanish_post_date,
  s.page_path AS spanish_pagepath,
  s.title AS spanish_title,
  s.sessions AS spanish_sessions,
  s.seconds AS spanish_seconds,
  s.bounces AS spanish_bounces,
  e.post_date AS english_post_date,
  e.page_path AS english_pagepath,
  e.title AS english_title,
  e.sessions AS english_sessions,
  e.seconds AS english_seconds,
  e.bounces AS english_bounces
FROM
  spanish s
  LEFT JOIN english e ON s.path_sk = e.path_sk
  AND s.datept = e.datept
  AND s.country = e.country
