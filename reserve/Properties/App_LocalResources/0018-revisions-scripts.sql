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
