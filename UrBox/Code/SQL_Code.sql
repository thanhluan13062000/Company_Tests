WITH CTE_filter_data AS (
	SELECT
		*,
		RANK() OVER (PARTITION BY mdt.user_id ORDER BY mdt.Min_redeemed_time) 'Redeemed_time_rank'
	FROM
		(
		SELECT
			user_id,
			brand_id,
			MIN(voucher_redeemed_at) 'Min_redeemed_time',
			MAX(voucher_redeemed_at) 'Max_redeemed_time'
		FROM
			dbo.UrBox_Tbl
		GROUP BY
			user_id,brand_id
		) mdt
)
SELECT
	user_id,
	MAX(CASE
		WHEN cte.Redeemed_time_rank = 1 THEN cte.brand_id
	END) AS 'first_brand_id',
	MAX(CASE
		WHEN cte.Redeemed_time_rank = 2 THEN cte.brand_id
	END) AS 'second_brand_id',
	MAX(CASE
		WHEN cte.Redeemed_time_rank = 1 THEN cte.Min_redeemed_time
	END) AS 'first_brand_redeemed_date',
	MAX(CASE
		WHEN cte.Redeemed_time_rank = 2 THEN cte.Min_redeemed_time
	END) AS 'second_brand_redeemed_date',
	MAX(CASE
		WHEN cte.Redeemed_time_rank >= 1 THEN cte.brand_id
	END) AS 'last_brand_id',
	MAX(CASE
		WHEN cte.Redeemed_time_rank >= 1 THEN cte.Max_redeemed_time
	END) AS 'last_redeemed_date',
	COUNT(cte.brand_id) 'number_of_brands'
FROM
	CTE_filter_data cte
GROUP BY
	user_id
