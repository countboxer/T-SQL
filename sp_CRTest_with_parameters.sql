CREATE PROCEDURE dbo.sp_CRTest_with_parameters
(
	@fund_family_name varchar(50) = NULL
)
AS
	DECLARE @qe_dates	varchar(max)
	SET @qe_dates = dbo.uf_GetPriorQuarterEnds(GetDate(), 5)

    BEGIN
		SELECT
			fund_family_name,
			fund_name,
			product_high_level,
			line,
			eoq_after_date_value,
			net_assets,
			net_flow,
			quarter_name
		FROM
			FundsManagementWarehouse.dbo.v_MergedDetailMonthlyFact_Trees v_MergedDetailMonthlyFact_Trees
		WHERE
			product_code = product_tree_node_name AND
			COALESCE(fund_family_name,'') LIKE CASE WHEN @fund_family_name IS NULL THEN '%' ELSE @fund_family_name END AND
			CHARINDEX(convert(varchar, eoq_after_date_value, 20), @qe_dates) > 0
    END