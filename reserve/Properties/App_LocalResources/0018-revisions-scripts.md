------------------------------
CREATE TABLE [dbo].[info_projects_revisions](
	[firm_id] [smallint] NOT NULL,
	[project_id] [nvarchar](10) NOT NULL,
	[revision_id] [smallint] NOT NULL,
	[revision_desc] [nvarchar](MAX) NULL,
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

------------------------------
insert into info_projects_revisions (firm_id, project_id, revision_id, revision_name, revision_created_date, revision_created_by)
select firm_id, project_id, 1, 'System init', GETDATE(), last_updated_by from info_projects

------------------------------
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


------------------------------
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
					select firm_id, project_id, @new_revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr_user_entered, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, @user, getdate() from info_projections where firm_id=@firm and project_id=@project_id and revision_id=@current_revision_id
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
------------------------------
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
create procedure [dbo].[sp_app_revision_info] (@firmid smallint, @projid nvarchar(15), @revisionid smallint) as

select ipr.revision_id, ipr.revision_desc, au.first_name + ' ' + au.last_name as created_by, ipr.revision_created_date
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
dbo.fn_est_rem_use_life(ic.firm_id, ic.project_id,ic.revision_id, @year, ic.category_id, ic.component_id) as est_remain_useful_life,
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

------------------------------
ALTER procedure [dbo].[sp_app_rvw_comp1] @firm smallint, @project nvarchar(10), @revision smallint, @detail bit, @cat smallint=-1 as

SET nocount ON

declare @infl float
select @infl=isnull(inflation,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Components TABLE (category_id smallint, category_desc varchar(50), component_id smallint, order_id smallint, component_desc varchar(75), comp_quantity int, comp_unit varchar(2), unit_cost float, res_req_pres_dols float, begin_bal float, begin_bal_calcd float, est_useful_life smallint, est_rem_useful_life smallint, annual_res_fund_req float, full_fund_bal float, comp_note nvarchar(10))

BEGIN TRANSACTION

	insert into @Components (category_id, category_desc, component_id, order_id, component_desc, comp_quantity, comp_unit, unit_cost, res_req_pres_dols, est_useful_life, est_rem_useful_life, begin_bal, full_fund_bal, comp_note)

	select icc.category_id, icc.category_desc, ic.component_id, isnull(ic.order_id, component_id), ic.component_desc, ic.comp_quantity, ic.comp_unit, ic.unit_cost, 
	case when ic.year_id=1 then isnull(ic.comp_quantity,0)*ic.unit_cost else isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1) end as res_req_pres_dols, 
	ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	case when ic.year_id=1 then ((isnull(ic.comp_quantity,0)*ic.unit_cost)/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) else ((isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) end as full_fund_bal, ic.comp_note
	 from 
	info_component_categories icc
	inner join info_components ic on icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where ic.firm_id=@firm and ic.project_id=@project and ic.revision_id=@revision and ic.year_id=1

	update @Components set begin_bal_calcd=0 where full_fund_bal=0
	update @Components set begin_bal_calcd=(full_fund_bal/(select sum(full_fund_bal) from @Components))*begin_bal where begin_bal_calcd is null
	update @Components set annual_res_fund_req=(res_req_pres_dols-begin_bal_calcd)/est_rem_useful_life

COMMIT TRANSACTION

if @detail=1
	select * from @Components where category_id=case when @cat=-1 then category_id else @cat end order by order_id
else
	select category_id, category_desc, sum(res_req_pres_dols) as res_req_pres_dols, sum(begin_bal_calcd) as begin_bal, sum(annual_res_fund_req) as annual_res_fund_req, sum(full_fund_bal) as full_fund_bal from @Components where category_id=case when @cat=-1 then category_id else @cat end group by category_id, category_desc order by category_id
GO

------------------------------
ALTER procedure [dbo].[sp_app_rvw_expend] @firm smallint, @project nvarchar(10), @revision smallint as

SET nocount ON

declare @rpt_effective smallint, @rem_use_life smallint, @begin_bal float, @int float, @infl float
select @rpt_effective=year(report_effective), @begin_bal=begin_balance, @infl=isnull(inflation,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Components TABLE (year_id smallint, category_id smallint, category_desc varchar(50), component_id smallint, component_desc varchar(75), comp_quantity int, comp_unit varchar(2), unit_cost float, res_req_pres_dols float, begin_bal float, begin_bal_calcd float, est_useful_life smallint, est_rem_useful_life smallint, annual_res_fund_req float, annual_res_fund_req_year2 float, full_fund_bal float, comp_note smallint, adjustment float, existing_reserve_fund float, expensed float, current_contrib float, primary key (year_id, category_id, component_id))

BEGIN TRANSACTION

	insert into @Components (year_id, category_id, category_desc, component_id, component_desc, comp_quantity, comp_unit, unit_cost, res_req_pres_dols, est_useful_life, est_rem_useful_life, begin_bal, full_fund_bal, current_contrib)

	select ly.year_id+1 as year_id, icc.category_id, icc.category_desc, ic.component_id, ic.component_desc, ic.comp_quantity, ic.comp_unit, dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1) as unit_cost, isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1), ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	((ic.comp_quantity*dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) as full_fund_bal,
	ipi.current_contrib
	from
	lkup_years ly inner join
	info_component_categories icc on icc.firm_id=@firm and icc.project_id=@project and icc.revision_id=@revision
	inner join info_components ic on ic.year_id=1 and icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	left join info_components ic_fut on ic_fut.year_id>1 and ly.year_id=ic_fut.year_id and ic.firm_id=ic_fut.firm_id and ic.project_id=ic_fut.project_id and ic.revision_id=ic_fut.revision_id and ic.category_id=ic_fut.category_id and ic.component_id=ic_fut.component_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where ic_fut.firm_id is null

	union

	select ic.year_id+1, icc.category_id, icc.category_desc, ic.component_id, ic.component_desc, ic.comp_quantity, ic.comp_unit, dbo.fn_comp_int(@int,ic.unit_cost,ic.year_id-1) as unit_cost, isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@int,ic.unit_cost,ic.year_id-1), ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	((ic.comp_quantity*dbo.fn_comp_int(@int,ic.unit_cost,ic.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) as full_fund_bal,
	ipi.current_contrib
	from
	info_component_categories icc
	inner join info_components ic on icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where icc.firm_id=@firm and icc.project_id=@project and icc.revision_id=@revision and ic.year_id>1

	order by year_id

	update @Components set est_rem_useful_life=dbo.fn_est_rem_use_life(@firm,@project,@revision, year_id,category_id,component_id)
	update @Components set begin_bal_calcd=0 from @Components c where begin_bal=0 or (select sum(full_fund_bal) from @Components where year_id=c.year_id)=0 
	update @Components set begin_bal_calcd=(full_fund_bal/(select sum(full_fund_bal) from @Components where year_id=c.year_id))*begin_bal from @Components c where begin_bal_calcd is null
	update @Components set expensed=case when est_useful_life=est_rem_useful_life then res_req_pres_dols else 0 end

COMMIT TRANSACTION

select year_id, component_desc, expensed as ttl from @Components where expensed<>0
GO

------------------------------
ALTER procedure [dbo].[sp_app_rvw_fullfunding] (@firm smallint, @project nvarchar(10), @revision smallint) AS

declare @infl float
select @infl=isnull(inflation,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

select sum(((isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life)) as full_fund_bal
from info_components ic where firm_id=@firm and project_id=@project and revision_id=@revision
GO


------------------------------
CREATE TYPE [dbo].[ProjectionType2] AS TABLE(
	[firm_id] [smallint] NULL,
	[project_id] [varchar](10) NULL,
	[revision_id] [smallint] NULL,
	[year_id] [smallint] NULL,
	[annual_exp] [float] NULL,
	[pct_increase] [float] NULL,
	[cfa_annual_contrib] [float] NULL,
	[cfa_reserve_fund_bal] [float] NULL,
	[ffa_req_annual_contr] [float] NULL,
	[ffa_avg_req_annual_contr] [float] NULL,
	[ffa_res_fund_bal] [float] NULL,
	[bfa_annual_contr] [float] NULL,
	[ext_res_cur_year] [float] NULL,
	[bfa_res_fund_bal] [float] NULL,
	[tfa_annual_contr] [float] NULL,
	[tfa_res_fund_bal] [float] NULL,
	[generated_by] [smallint] NULL,
	[generated_date] [datetime] NULL
)
GO

------------------------------
ALTER procedure [dbo].[sp_add_projections_threshold1_highspeed]
@ProjectionData ProjectionType2 READONLY
as

update info_projections 
set tfa_annual_contr=p.tfa_annual_contr, tfa_res_fund_bal=p.tfa_res_fund_bal, generated_by=p.generated_by, generated_date=getdate()
from info_projections i
inner join @ProjectionData p
on i.firm_id=p.firm_id and i.project_id=p.project_id and i.year_id=p.year_id
GO

------------------------------
ALTER procedure [dbo].[sp_add_projections_highspeed]
@ProjectionData ProjectionType2 READONLY,
@interest float
as

update info_projections 
set cfa_annual_contrib=p.cfa_annual_contrib, cfa_reserve_fund_bal=p.cfa_reserve_fund_bal, ffa_res_fund_bal=p.ffa_res_fund_bal, ffa_avg_req_annual_contr=p.ffa_avg_req_annual_contr, bfa_annual_contr=p.bfa_annual_contr, bfa_res_fund_bal=p.bfa_res_fund_bal, generated_by=p.generated_by, tfa_annual_contr=p.tfa_annual_contr, tfa2_annual_contr=p.tfa_annual_contr, tfa_res_fund_bal=p.tfa_res_fund_bal, tfa2_res_fund_bal=p.tfa_res_fund_bal, generated_date=getdate()
from info_projections i
inner join @ProjectionData p
on i.firm_id=p.firm_id and i.project_id=p.project_id and i.year_id=p.year_id
GO

------------------------------
DROP TYPE dbo.ProjectionType

------------------------------
CREATE TYPE [dbo].[ProjectionType] AS TABLE(
	[firm_id] [smallint] NULL,
	[project_id] [varchar](10) NULL,
	[revision_id] [smallint] NULL,
	[year_id] [smallint] NULL,
	[annual_exp] [float] NULL,
	[pct_increase] [float] NULL,
	[cfa_annual_contrib] [float] NULL,
	[cfa_reserve_fund_bal] [float] NULL,
	[ffa_req_annual_contr] [float] NULL,
	[ffa_avg_req_annual_contr] [float] NULL,
	[ffa_res_fund_bal] [float] NULL,
	[bfa_annual_contr] [float] NULL,
	[ext_res_cur_year] [float] NULL,
	[bfa_res_fund_bal] [float] NULL,
	[tfa_annual_contr] [float] NULL,
	[tfa_res_fund_bal] [float] NULL,
	[generated_by] [smallint] NULL,
	[generated_date] [datetime] NULL
)
GO

------------------------------
ALTER procedure [dbo].[sp_add_projections_threshold1_highspeed]
@ProjectionData ProjectionType READONLY
as

update info_projections 
set tfa_annual_contr=p.tfa_annual_contr, tfa_res_fund_bal=p.tfa_res_fund_bal, generated_by=p.generated_by, generated_date=getdate()
from info_projections i
inner join @ProjectionData p
on i.firm_id=p.firm_id and i.project_id=p.project_id and i.revision_id=p.revision_id and i.year_id=p.year_id
GO

------------------------------
ALTER procedure [dbo].[sp_add_projections_highspeed]
@ProjectionData ProjectionType READONLY,
@interest float
as

update info_projections 
set cfa_annual_contrib=p.cfa_annual_contrib, cfa_reserve_fund_bal=p.cfa_reserve_fund_bal, ffa_res_fund_bal=p.ffa_res_fund_bal, ffa_avg_req_annual_contr=p.ffa_avg_req_annual_contr, bfa_annual_contr=p.bfa_annual_contr, bfa_res_fund_bal=p.bfa_res_fund_bal, generated_by=p.generated_by, tfa_annual_contr=p.tfa_annual_contr, tfa2_annual_contr=p.tfa_annual_contr, tfa_res_fund_bal=p.tfa_res_fund_bal, tfa2_res_fund_bal=p.tfa_res_fund_bal, generated_date=getdate()
from info_projections i
inner join @ProjectionData p
on i.firm_id=p.firm_id and i.project_id=p.project_id and i.revision_id=p.revision_id and i.year_id=p.year_id
GO

------------------------------
DROP TYPE dbo.ProjectionType2

------------------------------

ALTER procedure [dbo].[sp_app_rvw_graph_threshold] @firm smallint, @project varchar(10), @revision smallint, @change_year smallint, @new_contr float as

declare @first_year smallint
declare @int float
declare @beginbal float
select @first_year=year(report_effective), @int=interest, @beginbal=begin_balance from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Totals TABLE (firm_id smallint, project_id varchar(10), year_id smallint, interest float, annual_exp float, tfa2_annual_contrib float, tfa2_reserve_fund_bal float, primary key (year_id))

insert into @Totals (year_id, interest, annual_exp, tfa2_annual_contrib, tfa2_reserve_fund_bal)
select i.year_id, ipi.interest, i.annual_exp, i.tfa2_annual_contr, i.tfa2_res_fund_bal 
	from info_projections i 
	inner join info_project_info ipi on i.firm_id=ipi.firm_id and i.project_id=ipi.project_id and i.revision_id=ipi.revision_id
	where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision

declare @yr int
set @yr = @change_year;
WHILE @yr < @first_year+31
BEGIN
	if @yr=@change_year --this is the one we need to update
		if @yr=@first_year
			update @Totals set tfa2_annual_contrib=@new_contr, tfa2_reserve_fund_bal=(@beginbal*(1+(@int/100)))+@new_contr-annual_exp where year_id=@yr
		else
			update @Totals set tfa2_annual_contrib=@new_contr, tfa2_reserve_fund_bal=((select tfa2_reserve_fund_bal from @Totals where year_id=@yr-1)*(1+(@int/100)))+@new_contr-annual_exp where year_id=@yr
	else if @yr=@first_year
		update @Totals set tfa2_reserve_fund_bal=(@beginbal*(1+(@int/100)))+tfa2_annual_contrib-annual_exp where year_id=@yr
	else
		update @Totals set tfa2_reserve_fund_bal=((select tfa2_reserve_fund_bal from @Totals where year_id=@yr-1)*(1+(@int/100)))+tfa2_annual_contrib-annual_exp where year_id=@yr
	set @yr=@yr+1
end

update info_projections set tfa2_annual_contr=t.tfa2_annual_contrib, tfa2_res_fund_bal=t.tfa2_reserve_fund_bal
from info_projections i
inner join @Totals t on i.year_id=t.year_id
where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision

select year_id, convert(decimal(18,0),tfa2_reserve_fund_bal) as bal from @Totals
GO

------------------------------
ALTER procedure [dbo].[sp_app_proj_cfa] @firm smallint, @project varchar(10), @revision smallint as

declare @first_year smallint
declare @interest float
declare @beginbal float
select @first_year = year(report_effective), @interest=isnull(interest,0), @beginbal=isnull(begin_balance,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Totals TABLE (year_id smallint, annual_exp float, cfa_annual_contr float, cfa_annual_contr_user_entered bit, cfa_reserve_fund_bal float, primary key (year_id))

insert into @Totals (year_id, annual_exp, cfa_annual_contr, cfa_annual_contr_user_entered, cfa_reserve_fund_bal)
select i.year_id, i.annual_exp, i.cfa_annual_contrib, i.cfa_annual_contrib_user_entered, i.cfa_reserve_fund_bal
	from info_projections i 
	inner join info_project_info ipi on i.firm_id=ipi.firm_id and i.project_id=ipi.project_id and i.revision_id=ipi.revision_id
	where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision

declare @tmpval float
declare @yr int
declare @prevContr float
declare @prevBal float
set @yr = @first_year
WHILE @yr < @first_year+31
BEGIN
	if @yr=@first_year
		begin
			update @Totals set 
				cfa_reserve_fund_bal=(cfa_annual_contr+@beginbal-annual_exp)
			where year_id=@yr
		end
	else
		begin
			select @prevContr = cfa_annual_contr, @prevBal = cfa_reserve_fund_bal from @Totals where year_id=@yr-1
			update @Totals set 
				cfa_reserve_fund_bal=(case when cfa_annual_contr_user_entered=1 then cfa_annual_contr else @prevContr end +
					@prevBal-annual_exp)*(1+(@interest/100))
			where year_id=@yr
		end
		
	set @yr=@yr+1
end

update info_projections set cfa_reserve_fund_bal=t.cfa_reserve_fund_bal
from info_projections i
inner join @Totals t on i.year_id=t.year_id
where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision

select year_id, format(cfa_reserve_fund_bal,'$#,##0; -$#,##0') as cfa_bal from @Totals
GO

------------------------------
ALTER function [dbo].[fn_est_rem_use_life] 
(
	@firm smallint,
	@project varchar(10),
	@revision smallint,
	@year smallint,
	@cat smallint,
	@comp smallint
)
RETURNS smallint
AS
BEGIN
	declare @y smallint
	declare @out smallint
	declare @est_useful_life smallint
	declare @rem_useful_life smallint --Get the most recently entered remaining useful life for this component
	declare @modified_year smallint
	
	select top 1 @rem_useful_life=est_remain_useful_life, @modified_year=year_id, @est_useful_life=est_useful_life from info_components where firm_id=@firm and project_id=@project and revision_id=@revision and category_id=@cat and component_id=@comp and year_id<@year order by year_id desc

	if @year-@modified_year=@rem_useful_life
		set @out=@est_useful_life
	else if @rem_useful_life-(@year-@modified_year)+1>0
		set @out=(@rem_useful_life-(@year-@modified_year))
	else
		begin
			set @y=((@rem_useful_life-@year+1)) 
			if @y<0 set @y=@y*-1
			--set @y=@y-1

			if (@y=0) or (@y%@est_useful_life=0) set @out=@est_useful_life
			else if @y < @est_useful_life set @out=@est_useful_life-@y
			else
				begin
					set @out=@est_useful_life + (@est_useful_life * (@y/@est_useful_life))
					set @out=@out-@y
				end
		end

	RETURN @out

END
GO

------------------------------
ALTER view [dbo].[vw_app_rvw_fullfundbal] as
select ic.firm_id, ic.project_id, ic.revision_id, ly.year_id, ic.category_id, ic.component_id, ic.component_desc, ic.comp_quantity, ic.plus_pct, ic.comp_unit, ic.base_unit_cost, ic.geo_factor, ic.unit_cost, ic.est_useful_life,
dbo.fn_est_rem_use_life(ic.firm_id, ic.project_id, ic.revision_id, ly.year_id, ic.category_id, ic.component_id) as est_remain_useful_life
from info_components ic
cross join (
	select year_id from lkup_years
	union select 31 as year_id
	) ly
left join info_components ic_fut on ic.firm_id=ic_fut.firm_id and ic.project_id=ic_fut.project_id and ic.revision_id=ic_fut.revision_id and ic.category_id=ic_fut.category_id and ic.component_id=ic_fut.component_id and ic_fut.year_id=ly.year_id
where ic.year_id=1
and ic_fut.firm_id is null

union

select ic.firm_id, ic.project_id, ic.revision_id, ly.year_id, ic.category_id, ic.component_id, ic.component_desc, ic.comp_quantity, ic.plus_pct, ic.comp_unit, ic.base_unit_cost, ic.geo_factor, ic.unit_cost, ic.est_useful_life, 
ic.est_remain_useful_life
from info_components ic, lkup_years ly
where ic.year_id=ly.year_id
GO

------------------------------
ALTER procedure [dbo].[sp_app_rvw_proj1] @firm smallint, @project nvarchar(10), @revision smallint as

SET nocount ON

declare @rpt_effective smallint, @rem_use_life smallint, @begin_bal float, @int float, @infl float
select @rpt_effective=year(report_effective), @begin_bal=begin_balance, @int=isnull(interest,0), @infl=isnull(inflation,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Components TABLE (year_id smallint, category_id smallint, category_desc varchar(50), component_id smallint, component_desc varchar(75), comp_quantity int, comp_unit varchar(2), unit_cost float, res_req_pres_dols float, begin_bal float, begin_bal_calcd float, est_useful_life smallint, est_rem_useful_life smallint, annual_res_fund_req float, annual_res_fund_req_year2 float, full_fund_bal float, comp_note smallint, adjustment float, existing_reserve_fund float, expensed float, current_contrib float, primary key (year_id, category_id, component_id))

BEGIN TRANSACTION

	insert into @Components (year_id, category_id, category_desc, component_id, component_desc, comp_quantity, comp_unit, unit_cost, res_req_pres_dols, est_useful_life, est_rem_useful_life, begin_bal, full_fund_bal, current_contrib)

	select ly.year_id+1 as year_id, icc.category_id, icc.category_desc, ic.component_id, ic.component_desc, ic.comp_quantity, ic.comp_unit, dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1) as unit_cost, isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1), ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	((ic.comp_quantity*dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) as full_fund_bal,
	ipi.current_contrib
	from
	lkup_years ly inner join
	info_component_categories icc on icc.firm_id=@firm and icc.project_id=@project and icc.revision_id=@revision
	inner join info_components ic on ic.year_id=1 and icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	left join info_components ic_fut on ic_fut.year_id>1 and ly.year_id=ic_fut.year_id and ic.firm_id=ic_fut.firm_id and ic.project_id=ic_fut.project_id and ic.revision_id=ic_fut.revision_id and ic.category_id=ic_fut.category_id and ic.component_id=ic_fut.component_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where ic_fut.firm_id is null

	union

	select ic.year_id+1, icc.category_id, icc.category_desc, ic.component_id, ic.component_desc, ic.comp_quantity, ic.comp_unit, dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1) as unit_cost, isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1), ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	((ic.comp_quantity*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) as full_fund_bal,
	ipi.current_contrib
	from
	info_component_categories icc
	inner join info_components ic on icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where icc.firm_id=@firm and icc.project_id=@project and icc.revision_id=@revision and ic.year_id>1

	order by year_id

	update @Components set est_rem_useful_life=dbo.fn_est_rem_use_life(@firm,@project,@revision,year_id,category_id,component_id)
	update @Components set begin_bal_calcd=0 from @Components c where begin_bal=0 or (select sum(full_fund_bal) from @Components where year_id=c.year_id)=0 
	update @Components set begin_bal_calcd=(full_fund_bal/(select sum(full_fund_bal) from @Components where year_id=c.year_id))*begin_bal from @Components c where begin_bal_calcd is null
	update @Components set expensed=case when est_useful_life=est_rem_useful_life then res_req_pres_dols else 0 end
	
	update @Components set adjustment=(res_req_pres_dols/est_useful_life)*(est_useful_life-est_rem_useful_life)

	--Year 2 calc only
	update @Components set annual_res_fund_req_year2=(res_req_pres_dols-begin_bal_calcd)/case when est_rem_useful_life+1>est_useful_life then 1 else est_rem_useful_life+1 end where year_id=2
	update @Components set existing_reserve_fund=(adjustment/(select sum(adjustment) from @Components where year_id=2))*((select sum(annual_res_fund_req_year2) from @Components where year_id=2)+begin_bal-(select sum(expensed) from @components where year_id=2)) where year_id=2
	update @Components set annual_res_fund_req=(res_req_pres_dols-existing_reserve_fund)/est_rem_useful_life where year_id=2

COMMIT TRANSACTION

DECLARE @Totals TABLE (year_id smallint, annual_exp int, interest float, cfa_annual_contrib int, cfa_reserve_fund_bal int, ffa_req_annual_contr int, ffa_avg_req_annual_contr int, ffa_res_fund_bal int, bfa_annual_contr int, ext_res_cur_year int, bfa_res_fund_bal int, full_fund_bal int, primary key (year_id))

begin transaction

insert into @Totals (year_id, annual_exp, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ext_res_cur_year)

select year_id, sum(expensed) as annual_exp, current_contrib as cfa_annual_contrib, 
case when year_id=2 then begin_bal+current_contrib-sum(expensed) end as cfa_reserve_fund_bal, 
sum(annual_res_fund_req_year2) as ffa_req_annual_contr,
case when year_id=2 then ((select sum(annual_res_fund_req_year2) from @Components where year_id=2)+begin_bal-(select sum(expensed) from @components where year_id=2)) end
from @Components group by year_id, current_contrib, begin_bal, current_contrib order by year_id

commit transaction

update @Totals set cfa_reserve_fund_bal=(select cfa_reserve_fund_bal from @Totals where year_id=t.year_id-1) from @Totals t where year_id>2
update @Totals set ffa_req_annual_contr=(select sum(annual_res_fund_req)*POWER(1+(@infl/100),1) from @Components where year_id=2) where year_id=3

DECLARE @yr smallint = 3;
WHILE @yr < 32
BEGIN
	update @Components set existing_reserve_fund=
		dbo.fn_rvw_comp_zeroval(adjustment,(select sum(adjustment) from @Components where year_id=@yr))
		* ((select sum(annual_res_fund_req) from @Components where year_id=@yr-1)
		  +(select ext_res_cur_year from @Totals where year_id=@yr-1)
		  -(select sum(expensed) from @Components where year_id=@yr)) 
	where year_id=@yr

	update @Components set annual_res_fund_req=(res_req_pres_dols-existing_reserve_fund)/est_rem_useful_life where year_id=@yr
	
	update @Totals set cfa_reserve_fund_bal=((select cfa_reserve_fund_bal from @Totals where year_id=@yr-1)+cfa_annual_contrib-annual_exp),
		ffa_req_annual_contr=case when @yr=3 then ffa_req_annual_contr else (select sum(annual_res_fund_req) from @Components where year_id=@yr-1) end,
		ext_res_cur_year=((select sum(annual_res_fund_req) from @Components where year_id=@yr-1)+(select ext_res_cur_year from @Totals where year_id=@yr-1)-(select sum(expensed) from @Components where year_id=@yr))
		where year_id=@yr

	set @yr=@yr+1;
END;

update @Totals set ffa_avg_req_annual_contr=(select avg(ffa_req_annual_contr) from @Totals)
--Interest
update @Totals set ffa_res_fund_bal=(@begin_bal+ffa_avg_req_annual_contr-annual_exp), cfa_reserve_fund_bal=(@begin_bal+cfa_annual_contrib-annual_exp) where year_id=2
update @Totals set ffa_res_fund_bal=(select ffa_res_fund_bal from @Totals where year_id=t.year_id-1)+ffa_avg_req_annual_contr-annual_exp from @Totals t where t.year_id=4
--Full fund bal for each year
update @Totals set full_fund_bal=(select sum(((
		isnull(vw.comp_quantity,0)
		*dbo.fn_comp_int(@infl,vw.unit_cost,year_id))/vw.est_useful_life)
		*(vw.est_useful_life-vw.est_remain_useful_life))
	from vw_app_rvw_fullfundbal vw
	where vw.firm_id=@firm and vw.project_id=@project and vw.revision_id=@revision and vw.year_id=t.year_id
	group by vw.year_id)
	from @Totals t

set @yr = 3;
WHILE @yr < 32
BEGIN
	update @Totals set ffa_res_fund_bal=((select ffa_res_fund_bal from @Totals where year_id=@yr-1)+ffa_avg_req_annual_contr-annual_exp)*(1+(@int/100)),
	cfa_reserve_fund_bal=((select cfa_reserve_fund_bal from @Totals where year_id=@yr-1)+cfa_annual_contrib-annual_exp)*(1+(@int/100))
	where year_id=@yr
	set @yr=@yr+1
end;

update @Totals set year_id=year_id+@rpt_effective-2

delete from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision
insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, ext_res_cur_year, full_fund_bal)
select @firm, @project, @revision, year_id, annual_exp, interest, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, ext_res_cur_year, full_fund_bal from @Totals
GO

------------------------------
ALTER procedure [dbo].[sp_app_proj_adj_threshold] @firm smallint, @project varchar(10), @revision smallint as

declare @first_year smallint
declare @interest float
declare @beginbal float
declare @currentcontrib float
select @first_year = year(report_effective), @currentcontrib=current_contrib, @interest=isnull(interest,0), @beginbal=isnull(begin_balance,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Totals TABLE (year_id smallint, pct_increase float, annual_exp float, tfa_annual_contr float, tfa2_annual_contr float, tfa2_annual_contr_user_entered bit, tfa2_res_fund_bal float, primary key (year_id))

insert into @Totals (year_id, pct_increase, annual_exp, tfa_annual_contr, tfa2_annual_contr, tfa2_annual_contr_user_entered, tfa2_res_fund_bal)
select i.year_id, i.pct_increase, i.annual_exp, i.tfa_annual_contr, i.tfa2_annual_contr, i.tfa2_annual_contr_user_entered, tfa2_res_fund_bal
	from info_projections i 
	inner join info_project_info ipi on i.firm_id=ipi.firm_id and i.project_id=ipi.project_id and i.revision_id=ipi.revision_id
	where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision


declare @tmpval float
declare @yr int
declare @prevContr float
declare @prevBal float
set @yr = @first_year
WHILE @yr < @first_year+31
BEGIN
	if @yr=@first_year
		begin
			update @Totals set 
			tfa2_res_fund_bal=(case when tfa2_annual_contr_user_entered=1 then tfa2_annual_contr else @currentcontrib end
				+(case when tfa2_annual_contr_user_entered=1 then tfa2_annual_contr else @currentcontrib end
				*(isnull(pct_increase,0)/100))+@beginbal-annual_exp)*(1+(@interest/100)),
			tfa2_annual_contr=case when tfa2_annual_contr_user_entered=1 then tfa2_annual_contr else @currentcontrib end
				+(case when tfa2_annual_contr_user_entered=1 then tfa2_annual_contr else @currentcontrib end
				*(isnull(pct_increase,0)/100))
			where year_id=@yr
		end
	else
		begin
			select @prevContr = tfa2_annual_contr, @prevBal = tfa2_res_fund_bal from @Totals where year_id=@yr-1
			update @Totals set 
				tfa2_annual_contr=case when tfa2_annual_contr_user_entered=1 then tfa2_annual_contr else @prevContr+(@prevContr*(isnull(pct_increase,0)/100)) end, 
				tfa2_res_fund_bal=(case when tfa2_annual_contr_user_entered=1 then tfa2_annual_contr else @prevContr+(@prevContr*(isnull(pct_increase,0)/100)) end +
					(select tfa2_res_fund_bal from @Totals where year_id=@yr-1)-annual_exp)*(1+(@interest/100))
			where year_id=@yr
		end
		
	set @yr=@yr+1
end

update info_projections set tfa2_annual_contr=t.tfa2_annual_contr, tfa2_res_fund_bal=t.tfa2_res_fund_bal
from info_projections i
inner join @Totals t on i.year_id=t.year_id
where i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision

select year_id, convert(decimal(10,2),pct_increase) as pct_increase, format(tfa2_annual_contr,'C0') as contrib, format(tfa2_res_fund_bal,'$#,##0; -$#,##0') as bal from @Totals
GO


------------------------------
ALTER procedure [dbo].[sp_app_pre_finalize] @firm smallint, @project nvarchar(10), @revision smallint as

select ipi.project_type_id, lpt.template_name,
	case when (select firm_id from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision) is null then 'Missing' else 'Present' end as project_info,
	case when (select top 1 firm_id from info_components where firm_id=@firm and project_id=@project and revision_id=@revision) is null then 'Missing' else 'Present' end as component_info,
	case when (select top 1 firm_id from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision) is null then 'Missing' else 'Present' end as projection_info,
	case when ipi.threshold1_used=1 and ipi.threshold2_used=1 then 'MultiThresholds' else 'Good' end as threshold_types
	from info_project_info ipi 
	left join lkup_project_types lpt on ipi.firm_id=lpt.firm_id and ipi.project_type_id=lpt.project_type_id
	where ipi.firm_id=@firm and ipi.project_id=@project and ipi.revision_id=@revision
GO

------------------------------
ALTER procedure [dbo].[sp_app_create_word] @firm smallint, @project nvarchar(10), @revision smallint as

select 
lf.firm_name_word, i.project_name, lpt.friendly_desc as project_type_desc, ipi.inspection_date, ipi.site_city, ls2.state_name as site_state, ipi.prev_date, ipi.source_begin_balance,
ipi.project_id, ipi.project_mgr, ipi.project_type_id, ipi.contact_prefix, ipi.contact_name, ipi.association_name, ipi.client_addr1, ipi.client_city, ls.state_name as client_state, ipi.client_zip, ipi.contact_prefix, ipi.age_community, ipi.num_units, ipi.num_bldgs, ipi.num_floors, ipi.inspection_date, ipi.contact_title, ipi.prev_preparer,
ipi.current_contrib, ipi.begin_balance, ipi.prev_recomm_cont, 
case when isnull(ipi.threshold1_used,0)=1 or isnull(ipi.threshold2_used,0)=1 then convert(bit,1) else convert(bit,0) end as threshold_used, 
isnull(ipi.threshold1_used,0) as threshold1_used, 
isnull(ipi.threshold2_used,0) as threshold2_used,
ipi.threshold1_value, ipi.report_effective,
isnull(ipi.current_funding_hidden,convert(bit,0)) as current_funding_hidden, isnull(ipi.full_funding_hidden,convert(bit,0)) as full_funding_hidden, isnull(ipi.baseline_funding_hidden,convert(bit,0)) as baseline_funding_hidden,
(select sum(((ic.comp_quantity*ic.unit_cost)/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life)) from info_components ic where firm_id=@firm and project_id=@project and revision_id=@revision and year_id=1) as full_fund_bal,
iprj.cfa_annual_contrib, iprj.ffa_avg_req_annual_contr, iprj.bfa_annual_contr, 
case when ipi.threshold1_used=1 then isnull(iprj.tfa_annual_contr,0) else isnull(iprj.tfa2_annual_contr,0) end as tfa_annual_contr,
(select min(year_id) from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision and year_id<>year(ipi.report_effective)) as year2, 
iprj30.year_id as year30, iprj30.ffa_avg_req_annual_contr as year30avgcontr, iprj29.ffa_req_annual_contr as year29contr, iprj30.ffa_req_annual_contr as year30contr,
(select min(cfa_reserve_fund_bal) from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision) as min_cfa_bal,
(select min(ffa_res_fund_bal) from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision) as min_ffa_bal,
isnull((select case when ipi.threshold1_used=1 then min(tfa_res_fund_bal) else min(tfa2_res_fund_bal) end from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision),0) as min_tfa_bal,
lpt.template_name,
isnull(ipi.interest,0) as interest, isnull(ipi.inflation,0) as inflation
from info_project_info ipi
inner join info_projects i on ipi.firm_id=i.firm_id and ipi.project_id=i.project_id
inner join lkup_firms lf on ipi.firm_id=lf.firm_id
left join info_projections iprj on i.firm_id=iprj.firm_id and i.project_id=iprj.project_id and iprj.revision_id=@revision and iprj.year_id=year(ipi.report_effective)
left join info_projections iprj29 on i.firm_id=iprj29.firm_id and i.project_id=iprj29.project_id and iprj29.revision_id=@revision and iprj29.year_id=(select max(year_id) from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision)-1
left join info_projections iprj30 on i.firm_id=iprj30.firm_id and i.project_id=iprj30.project_id and iprj30.revision_id=@revision and iprj30.year_id=(select max(year_id) from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision)
left join lkup_project_types lpt on ipi.firm_id=lpt.firm_id and ipi.project_type_id=lpt.project_type_id
left join lkup_states ls on ipi.firm_id=ls.firm_id and ipi.client_state=ls.state_abbr
left join lkup_states ls2 on ipi.firm_id=ls2.firm_id and ipi.site_state=ls2.state_abbr
where ipi.firm_id=@firm and ipi.project_id=@project and ipi.revision_id=@revision
GO

------------------------------
ALTER procedure [dbo].[sp_app_word_projections] @firm smallint, @project nvarchar(10), @revision smallint, @threshold_type smallint as

select year_id, annual_exp, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_res_fund_bal, bfa_annual_contr,
case when @threshold_type=1 then tfa_annual_contr else tfa2_annual_contr end as tfa_annual_contr,
case when @threshold_type=1 then tfa_res_fund_bal else tfa2_res_fund_bal end as tfa_res_fund_bal
from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision
GO

------------------------------
ALTER procedure [dbo].[sp_app_notes] @firm smallint, @project nvarchar(10), @revision smallint, @category smallint as

if @category=-1
	select  ici.image_bytes, ici.image_comments, isnull(len(ici.image_bytes),0) as img_size, isnull(ic.comp_note,'') as comp_note
	from info_components_images ici
	left join info_components ic on ici.firm_id=ic.firm_id and ici.project_id=ic.project_id and ici.revision_id=ic.revision_id and ici.category_id=ic.category_id and ici.component_id=ic.component_id
	where ici.firm_id=@firm and ici.project_id=@project and ici.revision_id=@revision
	order by ici.category_id
else
	select  ici.image_bytes, ici.image_comments, isnull(len(ici.image_bytes),0) as img_size, isnull(ic.comp_note,'') as comp_note
	from info_components_images ici
	left join info_components ic on ici.firm_id=ic.firm_id and ici.project_id=ic.project_id and ici.revision_id=ic.revision_id and ici.category_id=ic.category_id and ici.component_id=ic.component_id
	where ici.firm_id=@firm and ici.project_id=@project and ici.revision_id=@revision and ici.category_id=@category

------------------------------
