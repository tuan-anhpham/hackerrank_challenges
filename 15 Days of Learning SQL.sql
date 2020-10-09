WITH sub_dist_hacker AS
(
    SELECT s.submission_date, 
           s.hacker_id,
           COUNT(s.hacker_id) AS num_sub,
           h.Name
      FROM Submissions s
     INNER JOIN Hackers h ON s.hacker_id = h.hacker_id
     GROUP BY s.submission_date, s.hacker_id, h.Name
),
sub_hacker_uni_days AS
(
    SELECT m.submission_date, m.hacker_id
      FROM sub_dist_hacker m,
           sub_dist_hacker s
     WHERE m.submission_date >= s.submission_date 
           AND
           m.hacker_id = s.hacker_id
     GROUP BY m.submission_date, m.hacker_id
    HAVING COUNT(*) = (DATEDIFF(day, '2016-03-01', m.submission_date) + 1)
),
sub_uni_user AS -- Find total number of unique hackers who made at least 1 submission each day 
(
    SELECT submission_date, 
           COUNT(*) AS num_uni_users 
      FROM sub_hacker_uni_days
     GROUP BY submission_date
),
max_num_submission AS -- Find maximum number of submissions each day
(
    SELECT submission_date,
           MAX(num_sub) AS max_sub
      FROM sub_dist_hacker
     GROUP BY submission_date
),
num_name_rank AS
(
SELECT s.submission_date,
       su.num_uni_users,
       s.hacker_id,
       s.Name,
       ROW_NUMBER () OVER (PARTITION BY s.submission_date ORDER BY s.hacker_id) as rnk
  FROM sub_dist_hacker s
 INNER JOIN max_num_submission m ON s.submission_date = m.submission_date
 INNER JOIN sub_uni_user su ON s.submission_date = su.submission_date
 WHERE m.max_sub = s.num_sub
)
SELECT submission_date,
       num_uni_users,
       hacker_id,
       Name
  FROM num_name_rank
 WHERE rnk = 1