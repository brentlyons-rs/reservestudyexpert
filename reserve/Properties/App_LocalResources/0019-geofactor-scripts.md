CREATE procedure [dbo].[sp_app_project_geofactor] (@firmid smallint, @projid nvarchar(15), @revisionid smallint, @newgeofactor float) as

update info_components set unit_cost=CAST(base_unit_cost * @newgeofactor AS DECIMAL(5,2)) 
where firm_id=@firmid and project_id=@projid and revision_id=@revisionid
GO
