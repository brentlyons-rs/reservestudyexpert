------------------------------
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

	update @Components set est_rem_useful_life=dbo.fn_est_rem_use_life(@firm,@project, year_id,category_id,component_id)
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

