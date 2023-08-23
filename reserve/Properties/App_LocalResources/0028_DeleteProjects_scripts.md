ALTER procedure [dbo].[sp_app_create_project] @firm smallint, @projectId nvarchar(10), @projectName nvarchar(100), @user smallint as

if exists (select * from info_projects where firm_id=@firm and project_id=@projectId)
	select 'ValidationError' as result, 'ProjectAlreadyExists' as error
else
	BEGIN
		BEGIN TRANSACTION
			insert into info_projects (firm_id, project_id, project_name, last_updated_by, last_updated_date) select @firm, @projectId, @projectName, @user, GetDate()
			insert into info_projects_revisions (firm_id, project_id, revision_id, revision_name, revision_created_date, revision_created_by) select @firm, @projectId, 1, 'Initial Project Init', GetDate(), @user
			insert into info_project_info (firm_id, project_id, revision_id, last_updated_by, last_updated_date) select @firm, @projectId, 1, @user, GetDate()
		COMMIT TRANSACTION
		select 'Success' as result, '' as error
	END
