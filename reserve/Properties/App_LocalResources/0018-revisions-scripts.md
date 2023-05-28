CREATE TABLE [dbo].[info_projects_revisions](
	[firm_id] [smallint] NOT NULL,
	[project_id] [nvarchar](10) NOT NULL,
	[revision_id] [smallint] NOT NULL,
	[revision_name] [nvarchar](50) NULL,
	[revision_created_date] [datetime] NULL,
	[revision_created_by] [smallint] NULL,
 CONSTRAINT [PK_info_projects_revisions] PRIMARY KEY CLUSTERED 
(
	[firm_id] ASC,
	[project_id] ASC,
	[revision_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-----------------------------
insert into info_projects_revisions (firm_id, project_id, revision_id, revision_name, revision_created_date, revision_created_by)
select firm_id, project_id, 1, 'System init', GETDATE(), last_updated_by from info_projects

-----------------------------
update hist_info_component_categories set revision_id=1
update hist_info_components set revision_id=1
update hist_info_components_deletes set revision_id=1
update hist_info_project_info set revision_id=1
update hist_info_projects set revision_id=1
update info_component_categories set revision_id=1
update info_components set revision_id=1
update info_components_images set revision_id=1
update info_project_info set revision_id=1
update info_projections set revision_id=1
update info_projections_intervals set revision_id=1

-----------------------------
CREATE procedure [dbo].[sp_app_create_revision] @firm smallint, @project_id nvarchar(10), @current_revision_id smallint, @revision_name nvarchar(50), @user smallint as

declare @status nvarchar(50)
declare @new_revision_id smallint
set @new_revision_id = @current_revision_id+1

if not exists(select * from info_projects_revisions where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id)
	begin
		select 'Error' as status_info, 'Could not locate the requested project+revision.' as error_desc
	end
else if exists(select * from info_projects_revisions where firm_id=@firm and project_id=@project_id and revision_id=@new_revision_id)
	begin
		select 'Error' as status_info, 'New revision already exists.' as error_desc
	end
else
	begin
		begin transaction
			begin try
				insert into info_projects_revisions (firm_id, project_id, revision_id, revision_name, revision_created_date, revision_created_by) 
					select @firm, @project_id, @new_revision_id, @revision_name, GETDATE(), @user
				insert into info_project_info (firm_id, project_id, revision_id, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation, current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, last_updated_by, last_updated_date, threshold_used, threshold_value)
					select firm_id, project_id, @new_revision_id, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation, current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, @user, getdate(), threshold_used, threshold_value from info_project_info where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id
				insert into info_component_categories (firm_id, project_id, revision_id, category_id, category_desc, last_updated_by, last_updated_date) 
					select firm_id, project_id, @new_revision_id, category_id, category_desc, @user, getdate() from info_component_categories where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id
				insert into info_components (firm_id, project_id, revision_id, year_id, category_id, component_id, order_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date) 
					select firm_id, project_id, @new_revision_id, year_id, category_id, component_id, order_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, @user, getdate() from info_components where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id
				insert into info_components_images (firm_id, project_id, revision_id, category_id, component_id, image_id, image_bytes, image_comments, last_updated_by, last_updated_date) 
					select firm_id, project_id, @new_revision_id, category_id, component_id, image_id, image_bytes, image_comments, @user, getdate() from info_components_images where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id
				insert into info_projections_intervals (firm_id, project_id, revision_id, interval_id, interval_value) 
					select firm_id, project_id, @new_revision_id, interval_id, interval_value from info_projections_intervals where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id
				insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr_user_entered, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, generated_by, generated_date) 
					select firm_id, project_id, @new_revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr_user_entered, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, @user, getdate() from info_projections where firm_id=@firm and project_id=project_id and revision_id=@current_revision_id
			end try
			begin catch
				SELECT 'Error' as status_info, ERROR_MESSAGE() AS error_desc;
				IF @@TRANCOUNT > 0  
						ROLLBACK TRANSACTION; 
			end catch

		IF @@TRANCOUNT > 0  
			begin
				COMMIT TRANSACTION;  
				select 'Success' as status_info, '' as error_desc, @new_revision_id as revision_id
			end
	END
GO

-----------------------------
ALTER procedure [dbo].[sp_app_project_info] (@firmid smallint, @projid nvarchar(15), @revisionid smallint) as

select ipr.project_name, ipi.*
from info_projects ipr
inner join info_project_info ipi on ipr.firm_id=ipi.firm_id and ipr.project_id=ipi.project_id and ipi.revision_id=@revisionid
where ipr.firm_id=@firmid and ipr.project_id=@projid

------------------------------
ALTER procedure [dbo].[sp_app_clone_project] @firm smallint, @from_pid nvarchar(10), @revision_id smallint, @to_pid nvarchar(10), @new_pname nvarchar(50), @user smallint as

declare @status nvarchar(50)

if exists(select * from info_projects where firm_id=@firm and project_id=@to_pid)
	select 'Error' as status_info, 'The Project ID you attempted to clone to already exists.' as error_desc
else
	begin
		begin transaction
			begin try
				insert into info_projects (firm_id, project_id, project_name, cloned_from, last_updated_by, last_updated_date) select @firm, @to_pid, @new_pname, @from_pid, @user, getdate()
				insert into info_project_info (firm_id, project_id, revision_id, project_mgr, project_type_id, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, prev_preparer, prev_recomm_cont, inspection_date, interest, inflation, source_prefix, source_name, source_title, last_updated_by, last_updated_date, prev_date, source_begin_balance)
					select firm_id, @to_pid, 1, project_mgr, project_type_id, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, prev_preparer, prev_recomm_cont, inspection_date, interest, inflation, source_prefix, source_name, source_title, @user, getdate(), prev_date, source_begin_balance from info_project_info where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_component_categories (firm_id, project_id, revision_id, category_id, category_desc, last_updated_by, last_updated_date) select @firm, @to_pid, 1, category_id, category_desc, @user, getdate() from info_component_categories where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_components (firm_id, project_id, revision_id, year_id, category_id, component_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date) select firm_id, @to_pid, 1, year_id, category_id, component_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, @user, getdate() from info_components where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_components_images (firm_id, project_id, revision_id, category_id, component_id, image_id, image_bytes, image_comments, last_updated_by, last_updated_date) select firm_id, @to_pid, 1, category_id, component_id, image_id, image_bytes, image_comments, @user, getdate() from info_components_images where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_projections_intervals (firm_id, project_id, revision_id, interval_id, interval_value) select firm_id, @to_pid, 1, interval_id, interval_value from info_projections_intervals where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, tfa2_annual_contr, tfa2_res_fund_bal, generated_by, generated_date) select firm_id, @to_pid, 1, year_id, annual_exp, interest, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, tfa2_annual_contr, tfa2_res_fund_bal, @user, getdate() from info_projections where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
			end try
			begin catch
				SELECT 'Error' as status_info, ERROR_MESSAGE() AS error_desc;
				IF @@TRANCOUNT > 0  
						ROLLBACK TRANSACTION; 
			end catch

		IF @@TRANCOUNT > 0  
			begin
			    COMMIT TRANSACTION;  
				select 'Success' as status_info, '' as error_desc, (select project_name from info_projects where firm_id=@firm and project_id=@to_pid) as proj_name
			end
	end

------------------------------
CREATE procedure [dbo].[sp_app_revision_info] (@firmid smallint, @projid nvarchar(15), @revisionid smallint) as

select ipr.revision_id, ipr.revision_name, au.first_name + ' ' + au.last_name as created_by, ipr.revision_created_date
from info_projects_revisions ipr
left join app_users au on ipr.firm_id=au.firm_id and ipr.revision_created_by=au.user_id
where ipr.firm_id=@firmid and ipr.project_id=@projid and ipr.revision_id=@revisionid

GO


------------------------------
ALTER procedure [dbo].[sp_app_component_reorder] @firm smallint, @project nvarchar(10), @revision smallint, @category smallint, @year smallint, @json nvarchar(max) as

with json_data as (
select [Id], [newOrder] from OPENJSON(@json) WITH (Id int, newOrder int)
)

update i set order_id=jd.newOrder
from info_components i
inner join json_data as jd on i.component_id=jd.Id
where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision and i.category_id=@category and i.year_id=@year
GO

------------------------------
ALTER procedure [dbo].[sp_app_components] @firm smallint, @project nvarchar(10), @revision smallint, @year smallint, @category smallint as

declare @int float
select @int=isnull(interest,0) from info_project_info where firm_id=@firm and project_id=@project

select ic.firm_id, ic.project_id, ic.year_id, ic.category_id, ic.component_id, isnull(ic.order_id, ic.component_id) as order_id, ic.component_desc, ic.comp_quantity, ic.plus_pct, ic.comp_unit, format(dbo.fn_comp_int(@int,ic.base_unit_cost,@year-1),'N2') as base_unit_cost, ic.geo_factor, format(dbo.fn_comp_int(@int,ic.unit_cost,@year-1),'N2') as unit_cost, ic.est_useful_life,
dbo.fn_est_rem_use_life(ic.firm_id, ic.project_id, @year, ic.category_id, ic.component_id) as est_remain_useful_life,
ic.comp_note, isnull(ic.comp_value,0) as comp_value, ic.comp_comments, ic.last_updated_by, ic.last_updated_date,
(select count(*) from info_components_images where firm_id=@firm and project_id=@project and revision_id=@revision and category_id=@category and component_id=ic.component_id) as ttl_images
from info_components ic 
left join info_components ic_fut on ic.firm_id=ic_fut.firm_id and ic.project_id=ic_fut.project_id and ic.revision_id=ic_fut.revision_id and ic.category_id=ic_fut.category_id and ic.component_id=ic_fut.component_id and ic_fut.year_id=@year
where ic.firm_id=@firm and ic.project_id=@project and ic.revision_id=@revision and ic.category_id=@category and ic.year_id=(select max(year_id) from info_components where firm_id=@firm and project_id=@project and revision_id=@revision and category_id=@category and component_id=ic.component_id and year_id<=@year)
and ic_fut.firm_id is null

union all

select ic.firm_id, ic.project_id, ic.year_id, ic.category_id, ic.component_id, isnull(ic.order_id, ic.component_id) as order_id, ic.component_desc, ic.comp_quantity, ic.plus_pct, ic.comp_unit, format(ic.base_unit_cost,'N2'), ic.geo_factor, format(ic.unit_cost,'N2'), ic.est_useful_life, ic.est_remain_useful_life, ic.comp_note, isnull(ic.comp_value,0) as comp_value, ic.comp_comments, ic.last_updated_by, ic.last_updated_date, (select count(*) from info_components_images where firm_id=@firm and project_id=@project and revision_id=@revision and category_id=@category and component_id=ic.component_id) as ttl_images
from info_components ic 
where ic.firm_id=@firm and ic.project_id=@project and ic.revision_id=@revision and ic.category_id=@category and ic.year_id=@year

order by isnull(ic.order_id, ic.component_id)
