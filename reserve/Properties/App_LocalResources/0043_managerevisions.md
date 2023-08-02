* Create info_projects_client_invites_revisions
* Add revision_name to info_projects_revisions

CREATE procedure [dbo].[sp_app_delete_project_revision] @firm smallint, @project nvarchar(10), @revision smallint as

BEGIN TRANSACTION

delete from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_projects_revisions where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_component_categories where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_components where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_components_images where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_projections_intervals where firm_id=@firm and project_id=@project and revision_id=@revision
delete from info_projects_client_invites_revisions where firm_id=@firm and project_id=@project and revision_id=@revision

COMMIT TRANSACTION

GO

----------------------------------------------

CREATE procedure [dbo].[sp_app_manage_revisions] @firm smallint, @project nvarchar(10) as
select ipr.revision_id, ipr.revision_name, ipr.revision_desc, au.first_name + ' ' + au.last_name as created_by, ipr.revision_created_date, case when ipcir.project_id is null then 0 else 1 end as isthere
from info_projects_revisions ipr 
left join info_projects_client_invites_revisions ipcir on ipr.firm_id=ipcir.firm_id and ipr.project_id=ipcir.project_id and ipr.revision_id=ipcir.revision_id
left join app_users au on ipr.firm_id=au.firm_id and ipr.revision_created_by=au.user_id 
where ipr.firm_id=@firm and ipr.project_id=@project

GO

----------------------------------------------

ALTER procedure [dbo].[sp_app_create_revision] @firm smallint, @project_id nvarchar(10), @current_revision_id smallint, @revision_name nvarchar(150), @revision_desc nvarchar(max), @user smallint as

declare @status nvarchar(50)
declare @new_revision_id smallint
set @new_revision_id = isnull((select max(revision_id) from info_project_info where firm_id=@firm and project_id=@project_id),1)+1

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
				insert into info_projects_revisions (firm_id, project_id, revision_id, revision_name, revision_desc, revision_created_date, revision_created_by) 
					select @firm, @project_id, @new_revision_id, @revision_name, @revision_desc, GETDATE(), @user
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

-----------------------------------------------------
ALTER procedure [dbo].[sp_app_send_project_to_client] @firm smallint, @pid nvarchar(10), @email nvarchar(100), @invite_by smallint as

if exists(select * from info_projects_client_invites where firm_id=@firm and project_id=@pid and client_email=@email)
	select 'AlreadySent' as status_desc
else
	begin
		insert into info_projects_client_invites (firm_id, project_id, client_email, data_generated, invite_sent, invited_by) select @firm, @pid, @email, 0, getdate(), @invite_by
		if exists(select * from info_projects where firm_id=@firm and project_id=@pid)
			select 'NoCloneNeeded' as status_desc
		else
			select 'CloneNeeded' as status_desc
	end

GO
-------------------------------------------------------
CREATE procedure sp_app_add_revision_to_client @firm smallint, @project nvarchar(10), @revision smallint, @user smallint as

DECLARE @clientproject nvarchar(15) = 'C' + @project

if not exists(select * from info_projects_client_invites_revisions where firm_id=@firm and project_id=@clientproject and revision_id=@revision)
BEGIN

	insert into info_projects_revisions (firm_id, project_id, revision_id, revision_name, revision_desc, revision_created_date, revision_created_by) 
		select @firm, @clientproject, @revision, 'Client Invite', '', GETDATE(), @user
	insert into info_projects_client_invites_revisions (firm_id, project_id, revision_id) 
		select @firm, @clientproject, @revision
	insert into info_project_info (firm_id, project_id, revision_id, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation, current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, last_updated_by, last_updated_date, threshold_used, threshold_value)
		select firm_id, @clientproject, @revision, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation, current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, @user, getdate(), threshold_used, threshold_value from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision
	insert into info_component_categories (firm_id, project_id, revision_id, category_id, category_desc, last_updated_by, last_updated_date) 
		select firm_id, @clientproject, @revision, category_id, category_desc, @user, getdate() from info_component_categories where firm_id=@firm and project_id=@project and revision_id=@revision
	insert into info_components (firm_id, project_id, revision_id, year_id, category_id, component_id, order_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date) 
		select firm_id, @clientproject, @revision, year_id, category_id, component_id, order_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, @user, getdate() from info_components where firm_id=@firm and project_id=@project and revision_id=@revision
	insert into info_components_images (firm_id, project_id, revision_id, category_id, component_id, image_id, image_bytes, image_comments, last_updated_by, last_updated_date) 
		select firm_id, @clientproject, @revision, category_id, component_id, image_id, image_bytes, image_comments, @user, getdate() from info_components_images where firm_id=@firm and project_id=@project and revision_id=@revision
	insert into info_projections_intervals (firm_id, project_id, revision_id, interval_id, interval_value) 
		select firm_id, @clientproject, @revision, interval_id, interval_value from info_projections_intervals where firm_id=@firm and project_id=@project and revision_id=@revision
	insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr_user_entered, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, generated_by, generated_date) 
		select firm_id, @clientproject, @revision, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr_user_entered, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, @user, getdate() from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision

END
--------------------------------------------------------
ALTER procedure [dbo].[sp_app_clone_project] @firm smallint, @from_pid nvarchar(10), @to_pid nvarchar(10), @new_pname nvarchar(50), @user smallint as

declare @status nvarchar(50)

if exists(select * from info_projects where firm_id=@firm and project_id=@to_pid)
	select 'Error' as status_info, 'The Project ID you attempted to clone to already exists.' as error_desc
else
	begin
		begin transaction
			begin try
				insert into info_projects (firm_id, project_id, project_name, cloned_from, last_updated_by, last_updated_date) 
					select @firm, @to_pid, @new_pname, @from_pid, @user, getdate()
				insert into info_projects_revisions (firm_id, project_id, revision_id, revision_desc, revision_created_date, revision_created_by) 
					select @firm, @to_pid, revision_id, 'Initial clone', getdate(), @user from info_projects_revisions where firm_id=@firm and project_id=@from_pid
				insert into info_project_info (firm_id, project_id, revision_id, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation, current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, last_updated_by, last_updated_date, threshold_used, threshold_value)
					select firm_id, @to_pid, revision_id, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation,  current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, @user, getdate(), threshold_used, threshold_value from info_project_info where firm_id=@firm and project_id=@from_pid
				insert into info_component_categories (firm_id, project_id, revision_id, category_id, category_desc, last_updated_by, last_updated_date) 
					select @firm, @to_pid, revision_id, category_id, category_desc, @user, getdate() from info_component_categories where firm_id=@firm and project_id=@from_pid
				insert into info_components (firm_id, project_id, revision_id, year_id, category_id, component_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date) 
					select firm_id, @to_pid, revision_id, year_id, category_id, component_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, @user, getdate() from info_components where firm_id=@firm and project_id=@from_pid
				insert into info_components_images (firm_id, project_id, revision_id, category_id, component_id, image_id, image_bytes, image_comments, last_updated_by, last_updated_date) 
					select firm_id, @to_pid, revision_id, category_id, component_id, image_id, image_bytes, image_comments, @user, getdate() from info_components_images where firm_id=@firm and project_id=@from_pid
				insert into info_projections_intervals (firm_id, project_id, revision_id, interval_id, interval_value) 
					select firm_id, @to_pid, revision_id, interval_id, interval_value from info_projections_intervals where firm_id=@firm and project_id=@from_pid
				insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, generated_by, generated_date) 
					select firm_id, @to_pid, revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, @user, getdate() from info_projections where firm_id=@firm and project_id=@from_pid
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
