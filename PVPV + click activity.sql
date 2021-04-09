WITH clicks AS (
  SELECT
    CASE 
      WHEN LOWER(EventAction) IN ('title click', 'widget related stories', 'bottom page content promo click') THEN EventAction 
      WHEN EventCategory = 'Article Body - Internal Link Click' THEN EventCategory
    END AS event, 
    platform, 
    CASE 
      WHEN pagepath IN (
        SELECT 
          *
        FROM `bigquery-1084.maharper.content_marketing_articles_temp`
      ) THEN 'Content Marketing'  ELSE 'Non Content Marketing' 
    END AS click_source, 
    SUM(EventCount) AS clicks, 
  FROM `dataeng-214618.PROD_Audience.events_hl` events 
  WHERE
    DATE_TRUNC(DatePT, year) = '2020-01-01' 
    AND (LOWER(EventAction) IN ('title click', 'widget related stories', 'bottom page content promo click') 
          OR EventCategory = 'Article Body - Internal Link Click')
  GROUP BY 
    1, 2, 3
), 

pageviews AS (
  SELECT 
    platform, 
    CASE 
      WHEN pagepath IN (
        SELECT 
          *
        FROM `bigquery-1084.maharper.content_marketing_articles_temp`      
      ) THEN 'Content Marketing' ELSE 'Non Content Marketing' 
    END AS click_source, 
    SUM(PageViews) AS pageviews
  FROM `dataeng-214618.PROD_Audience.traffic_hl`
  WHERE 
    DATE_TRUNC(DatePT, year) = '2020-01-01' 
  GROUP BY 
    1, 2
)

SELECT 
  clicks.event, 
  clicks.click_source, 
  clicks.platform,
  clicks.clicks, 
  pageviews.pageviews, 
  clicks.clicks / pageviews.pageviews AS CTR 
FROM clicks 
LEFT JOIN pageviews 
  ON clicks.click_source = pageviews.click_source
  AND clicks.platform = pageviews.platform 
ORDER BY 
  event
  
