ALTER procedure [dbo].[sp_app_clone_project] @firm smallint, @from_pid nvarchar(10), @to_pid nvarchar(10), @new_pname nvarchar(50), @user smallint, @revision_id smallint as

declare @status nvarchar(50)

if exists(select * from info_projects where firm_id=@firm and project_id=@to_pid)
	select 'Error' as status_info, 'The Project ID you attempted to clone to already exists.' as error_desc
else
	begin
		begin transaction
			begin try
				insert into info_projects (firm_id, project_id, project_name, cloned_from, last_updated_by, last_updated_date) select @firm, @to_pid, @new_pname, @from_pid, @user, getdate()
				insert into info_projects_revisions (firm_id, project_id, revision_id, revision_desc, revision_created_date, revision_created_by) select @firm, @to_pid, 1, 'Initial clone', getdate(), @user
				insert into info_project_info (firm_id, project_id, revision_id, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation, current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, last_updated_by, last_updated_date, threshold_used, threshold_value)
					select firm_id, @to_pid, 1, project_mgr, project_type_id, dept_mgr, contract_value, inspection_date, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, source_prefix, source_name, source_title, source_begin_balance, prev_preparer, prev_recomm_cont, prev_date, interest, inflation,  current_funding_hidden, full_funding_hidden, baseline_funding_hidden, current_pct_funded_hidden, full_pct_funded_hidden, baseline_pct_funded_hidden, threshold1_pct_funded_hidden, threshold2_pct_funded_hidden, threshold1_used, threshold1_value, threshold2_used, @user, getdate(), threshold_used, threshold_value from info_project_info where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_component_categories (firm_id, project_id, revision_id, category_id, category_desc, last_updated_by, last_updated_date) select @firm, @to_pid, 1, category_id, category_desc, @user, getdate() from info_component_categories where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_components (firm_id, project_id, revision_id, year_id, category_id, component_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, last_updated_by, last_updated_date) select firm_id, @to_pid, 1, year_id, category_id, component_id, component_desc, comp_quantity, plus_pct, comp_unit, base_unit_cost, geo_factor, unit_cost, est_useful_life, est_remain_useful_life, comp_note, comp_value, comp_comments, @user, getdate() from info_components where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_components_images (firm_id, project_id, revision_id, category_id, component_id, image_id, image_bytes, image_comments, last_updated_by, last_updated_date) select firm_id, @to_pid, 1, category_id, component_id, image_id, image_bytes, image_comments, @user, getdate() from info_components_images where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_projections_intervals (firm_id, project_id, revision_id, interval_id, interval_value) select firm_id, @to_pid, 1, interval_id, interval_value from info_projections_intervals where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
				insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, generated_by, generated_date) 
					select firm_id, @to_pid, 1, year_id, annual_exp, interest, cfa_annual_contrib_user_entered, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, bfa_annual_contr, ext_res_cur_year, bfa_res_fund_bal, tfa_annual_contr, tfa_res_fund_bal, pct_increase, tfa2_annual_contr, tfa2_res_fund_bal, full_fund_bal, @user, getdate() from info_projections where firm_id=@firm and project_id=@from_pid and revision_id=@revision_id
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
