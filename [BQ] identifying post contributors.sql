SELECT 
  *
FROM (
  SELECT 
    users.display_name, 
    users.id, 
    users.user_nicename, 
    users.user_email, 
    case
      when hl_role = 'a:1:{s:6:"editor";b:1;}' then 'editor' 
      when hl_role = 'a:1:{s:13:"administrator";b:1;}' then 'admin' 
    end as hl, 
    case 
      when grt_role = 'a:1:{s:6:"editor";b:1;}' then 'editor' 
      when grt_role = 'a:1:{s:13:"administrator";b:1;}' then 'admin' 
    end as grt, 
    case 
      when mnt_role = 'a:1:{s:6:"editor";b:1;}' then 'editor'
      when mnt_role  = 'a:1:{s:13:"administrator";b:1;}' then 'admin'
    end as mnt
  FROM `dataeng-214618.wp_dbx.wp_users` users 
  LEFT JOIN (
    SELECT
      user_id, 
      max(if(meta_key = 'wp_capabilities', meta_value, null)) as hl_role 
    FROM `dataeng-214618.wp_dbx.wp_usermeta`
    GROUP BY 
      1
  ) hl_roles
    ON users.id = hl_roles.user_id
  LEFT JOIN (
    SELECT
      user_id, 
      max(if(meta_key = 'wp_2_capabilities', meta_value, null)) as grt_role 
    FROM `dataeng-214618.wp_dbx.wp_usermeta`
    GROUP BY 
      1
  ) grt_roles
    ON users.id = grt_roles.user_id
  LEFT JOIN (
    SELECT
      user_id, 
      max(if(meta_key = 'wp_3_capabilities', meta_value, null)) as mnt_role 
    FROM `dataeng-214618.wp_dbx.wp_usermeta`
    GROUP BY 
      1
  ) mnt_roles 
    ON users.id = mnt_roles.user_id 
)
WHERE 
  hl IN ('editor', 'admin')
  OR grt IN ('editor', 'admin')
  OR mnt IN ('editor', 'admin')
