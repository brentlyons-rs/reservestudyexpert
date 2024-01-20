using System;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;

namespace reserve
{
    public partial class main : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firmid"] == null) Response.Redirect("default.aspx?timeout=1");

            if (Session["client"].ToString() == "1")
            {
                btnNewRevision.Visible = false;
                btnManageRevisions.Visible = false;
            }

            if (txtHdnType.Value=="CreateRevision")
            {
            }
            else if (txtHdnType.Value=="ChangeRevision")
            {
                Session["revisionid"] = cboRevision.Value;
            }
            else if (txtHdnSelected.Value=="selected")
            {
                Session["projectid"] = txtHdnProject.Value;
                loadRevisions();
                cboRevision.SelectedIndex = cboRevision.Items.Count-1;
                Session["revisionid"] = cboRevision.Items[cboRevision.SelectedIndex].Value;
                divPnRevisions.Visible = true;
                txtHdnSelected.Value = "";
                txtPID.Disabled = true;
            }
            else if (txtHdnType.Value=="New")
            {
                Session["projectid"] = "";
                Session["revisionid"] = "";
                divPnRevisions.Visible = false;
                txtPID.Disabled = false;
                txtHdnType.Value = "";
            }
            else if (Session["projectid"] != null)
            {
                if (Session["projectid"].ToString() != "")
                {
                    loadRevisions();
                    txtHdnProject.Value = Session["projectid"].ToString();
                    txtPID.Disabled = true;
                    divPnRevisions.Visible = true;
                }
            }

            //Project types dropdown
            if (cboPT.Items.Count<1)
            {
                var dr = Fn_enc.ExecuteReader("select project_type_id, project_type_desc from lkup_project_types where firm_id=@Param1", new string[] { Session["firmid"].ToString() });
                while (dr.Read())
                {
                    cboPT.Items.Add(new ListItem(dr["project_type_desc"].ToString(), dr["project_type_id"].ToString()));
                }
                dr.Close();
            }
            //Client state dropdown
            if (cboCS.Items.Count < 1)
            {
                var dr = Fn_enc.ExecuteReader("select state_abbr, state_name from lkup_states where firm_id=@Param1", new string[] { Session["firmid"].ToString() });
                while (dr.Read())
                {
                    cboCS.Items.Add(new ListItem(dr["state_name"].ToString(), dr["state_abbr"].ToString()));
                }
                dr.Close();
            }
            //Site state dropdown
            if (cboSS.Items.Count < 1)
            {
                var dr = Fn_enc.ExecuteReader("select state_abbr, state_name from lkup_states where firm_id=@Param1", new string[] { Session["firmid"].ToString() });
                while (dr.Read())
                {
                    cboSS.Items.Add(new ListItem(dr["state_name"].ToString(), dr["state_abbr"].ToString()));
                }
                dr.Close();
            }

            if (IsPostBack)
            {
                if (txtHdnType.Value == "DeleteProject")
                {
                    DeleteProject();
                }
                else if (txtHdnType.Value == "CreateRevision")
                {
                    SaveNewRevision();
                }
                //else if (txtHdnSave.Value == "Save")
                //{
                //    SaveForm();
                //    Session["projectid"] = txtHdnProject.Value;
                //    loadRevisions();
                //    divPnRevisions.Visible = true;
                //    Session["revisionid"] = cboRevision.Value;
                //}
                else if (txtHdnType.Value=="Clone")
                {
                    CloneProject();
                }
                else if (txtHdnType.Value=="SendToClient")
                {
                    SendToClient();
                }
                else if (txtHdnProject.Value == "-1")
                {
                    ClearFields();
                    ToggleProjectButtons(false);
                    lblProject.InnerHtml = "New Project";
                    divCloneStatus.InnerHtml = "";
                    Session["projectid"] = "";
                }
                else if (txtHdnProject.Value != "")
                {
                    ClearFields();
                    LoadFields();
                    ToggleProjectButtons(true);
                    Session["projectid"] = txtHdnProject.Value;
                    divCloneStatus.InnerHtml = "";
                }
                if (Session["admin"].ToString()!="1")
                {
                    cmdDeleteProject.Visible = false;
                }
            }
            else if ((txtHdnProject.Value!="") && (txtHdnProject.Value!="-1"))
            {
                ClearFields();
                LoadFields();
                ToggleProjectButtons(true);
                divCloneStatus.InnerHtml = "";
            }
            else if (txtHdnProject.Value == "-1")
            {
                ClearFields();
                lblProject.InnerHtml = "New Project";
                Session["projectid"] = "";
                Session["revisionid"] = "";
                divPnRevisions.Visible = false;
                divCloneStatus.InnerHtml = "";
            }

            if (Session["client"].ToString() == "1")
            {
                if (Session["revisionid"].ToString()=="" && cboRevision.Items.Count>0)
                {
                    Session["revisionid"] = cboRevision.Items[cboRevision.Items.Count - 1].Value;
                }
                disableControls();
            }

        }



        public void DeleteProject()
        {
            try
            {
                Fn_enc.ExecuteNonQuery("sp_app_delete_project @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["userid"].ToString() });
                divCloneStatus.InnerHtml = "Successfully deleted project.";
                ClearFields();
                Session["projectid"] = "";
                Session["revisionid"] = "";
                txtProject.Value = "";
                txtHdnProject.Value = "-1";
                txtHdnType.Value = "";
                lblProject.InnerHtml = "New Project";
                divPnRevisions.Visible = false;
                ToggleProjectButtons(false);
            }
            catch (Exception ex)
            {
                divCloneStatus.InnerHtml = $"Error deleting project: {ex}";
            }
        }

        public void SaveNewRevision()
        {
            var dr = Fn_enc.ExecuteReader("sp_app_create_revision @Param1, @Param2, @Param3, @Param4, @Param5, @Param6", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), txtRevisionName.Value, txtRevisionDesc.Value, Session["userid"].ToString() });
            if (dr.Read())
            {
                if (dr["status_info"].ToString() == "Error")
                {
                    divCloneStatus.InnerHtml = $"Error creating new revision: {dr["error_desc"]}";
                }
                else
                {
                    Session["revisionid"] = dr["revision_id"].ToString();
                    divCloneStatus.InnerHtml = $"Successfully created revision #{dr["revision_id"]}";
                    loadRevisions();
                }
            }
            dr.Close();
        }

        public void loadRevisions()
        {
            if (Session["projectid"] != null && Session["projectid"].ToString() != "")
            {
                if (cboRevision.Items.Count>0)
                {
                    cboRevision.Items.Clear();
                }

                var dr = Fn_enc.ExecuteReader("select ipr.revision_id, ipr.revision_created_date, au.first_name + ' ' + au.last_name as created_by from info_projects_revisions ipr left join app_users au on ipr.firm_id=au.firm_id and ipr.revision_created_by=au.user_id where ipr.firm_id=@Param1 and ipr.project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
                while (dr.Read())
                {
                    cboRevision.Items.Add(new ListItem($"{dr["revision_id"]}: {DateTime.Parse(dr["revision_created_date"].ToString()):MM/dd/yyyy} ({dr["created_by"]})", dr["revision_id"].ToString()));
                    if (Session["revisionid"].ToString() == dr["revision_id"].ToString())
                    {
                        cboRevision.SelectedIndex = cboRevision.Items.Count - 1;
                    }
                }
                dr.Close();
            }
        }

        public void ToggleProjectButtons(bool isVisible)
        {
            cmdClone.Visible = isVisible;
            cmdSendToClient.Visible = isVisible;
            cmdDeleteProject.Visible = isVisible;
        }

        //public void genClientData()
        //{
        //    SqlDataReader dr = Fn_enc.ExecuteReader("select i.project_name, ipci.* from info_projects_client_invites ipci inner join info_projects i on ipci.firm_id=i.firm_id and ipci.project_id=i.project_id where ipci.firm_id=@Param1 and ipci.project_id=@Param2 and (ipci.data_generated=1)", new string[] { Session["firmid"].ToString(), Session["oldprojectid"].ToString() });
        //    if (!dr.Read())
        //    {
        //        string sProjName = dr["project_name"].ToString();
        //        dr.Close();
        //        dr = Fn_enc.ExecuteReader("sp_app_clone_project @Param1, @Param2, @Param3, @Param4, @Param5, @Param6", new string[] { Session["firmid"].ToString(), Session["oldprojectid"].ToString(), Session["projectid"].ToString(), sProjName, Session["userid"].ToString(), Session["revisionid"].ToString() });
        //        if (dr.Read())
        //        {
        //            if (dr["status_info"].ToString() == "Success")
        //            {
        //                Fn_enc.ExecuteNonQuery("update info_projects_client_invites set data_generated=1 where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["oldprojectid"].ToString() });
        //                txtHdnProject.Value = Session["projectid"].ToString();
        //                lblProject.InnerHtml = dr["proj_name"].ToString();
        //                txtHdnGenClientData.Value = Session["projectid"].ToString();
        //                LoadFields();
        //            }
        //            else
        //            {
        //                divCloneStatus.InnerHtml = "Error cloning project: " + dr["error_desc"].ToString();
        //            }
        //        }

        //    }
        //    else
        //    {
        //        txtHdnGenClientData.Value = Session["projectid"].ToString();
        //    }
        //    dr.Close();
        //}

        public void disableControls()
        {
            divProjManip.Visible = false;
            txtPID.Disabled = true;
            txtPN.Disabled = true;
            txtPM.Disabled = true;
            cboPT.Disabled = true;
            txtRE.Disabled = true;
            txtCC.Disabled = true;
            txtAoC.Disabled = true;
            txtGF.Disabled = true;
            txtNU.Disabled = true;
            txtNB.Disabled = true;
            txtNF.Disabled = true;
            cboCP.Disabled = true;
            txtCN.Disabled = true;
            txtCT.Disabled = true;
            txtCP.Disabled = true;
            txtCoN.Disabled = true;
            txtClC.Disabled = true;
            txtClZ.Disabled = true;
            txtClA1.Disabled = true;
            txtClA2.Disabled = true;
            cboCS.Disabled = true;
            txtSA1.Disabled = true;
            txtSC.Disabled = true;
            txtSZ.Disabled = true;
            txtSA2.Disabled = true;
            cboSS.Disabled = true;
            txtCE.Disabled = true;
            txtInf.Disabled = true;
            txtInt.Disabled = true;
            cboSP.Disabled = true;
            txtSN.Disabled = true;
            txtST.Disabled = true;
            txtPP.Disabled = true;
            txtPRC.Disabled = true;
            txtID.Disabled = true;
            txtSBB.Disabled = true;
            txtPSD.Disabled = true;
        }
        public void CloneProject()
        {
            SqlDataReader dr = Fn_enc.ExecuteReader("sp_app_clone_project @Param1, @Param2, @Param3, @Param4, @Param5", new string[] { Session["firmid"].ToString(), txtHdnProject.Value, txtClonePID.Value, txtClonePName.Value, Session["userid"].ToString() });
            if (dr.Read()) {
                if (dr["status_info"].ToString() == "Success")
                {
                    divCloneStatus.InnerHtml = "Successfully cloned project.";
                    Session["projectid"] = txtClonePID.Value;
                    Session["revisionid"] = "1";
                    txtHdnProject.Value = txtClonePID.Value;
                    lblProject.InnerHtml = txtClonePName.Value;
                    LoadFields();
                }
                else
                {
                    divCloneStatus.InnerHtml = "Error cloning project: " + dr["error_desc"].ToString();
                }
            }
            dr.Close();
        }

        public void SendToClient()
        {
            // Make sure we can iterate through the revisions
            if (!int.TryParse(Request.Form["txtHdnTotalRevs"], out int iTotal))
            {
                divCloneStatus.InnerHtml = "Error sending invite: could not determine revision count. Please notify an administrator if this message continues.";
                return;
            }

            SqlDataReader dr = Fn_enc.ExecuteReader("select firm_id from info_projects_client_invites where firm_id=@Param1 and project_id=@Param2 and client_email=@Param3", new string[] { Session["firmid"].ToString(), $"C{Session["projectid"]}", txtS2CEMail.Value });
            if (!dr.Read())
            {
                dr.Close();
                Fn_enc.ExecuteNonQuery("insert into info_projects_client_invites (firm_id, project_id, client_email, invite_sent, invited_by) select @Param1, @Param2, @Param3, GetDate(), @Param4", new string[] { Session["firmid"].ToString(), $"C{Session["projectid"]}", txtS2CEMail.Value, Session["userid"].ToString() });
            }
            else
            {
                dr.Close();
            }
            Fn_enc.ExecuteNonQuery("delete from info_projects_client_invites_revisions where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            for (var i = 0; i < iTotal; i++)
            {
                if (Request.Form["chkClientRev" + i] == "on")
                {
                    Fn_enc.ExecuteNonQuery("insert into info_projects_client_invites_revisions (firm_id, project_id, revision_id) select @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Request.Form["txtHdnClientRev" + i] });
                }
            }
            Fn_enc.ExecuteNonQuery("sp_app_add_revisions_to_client @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["userid"].ToString() });

            StringBuilder sBody = new StringBuilder();
            sBody.Append("Successfully created client login with credentials:</b><font color=black><br />");
            sBody.Append($"- Url: https://reservestudyplus.com/default.aspx?c=1<br />");
            sBody.Append($"- Username: {txtS2CEMail.Value} <br />");
            sBody.Append($"- Password: C{Session["projectid"]}");
            divCloneStatus.InnerHtml = sBody.ToString();
            txtHdnType.Value = "";

            ////SendToClient
            //SqlDataReader dr = Fn_enc.ExecuteReader("sp_app_send_project_to_client @Param1, @Param2, @Param3, @Param4", new string[] { Session["firmid"].ToString(), "C" + txtHdnProject.Value, txtS2CEMail.Value, Session["userid"].ToString() });
            //if (dr.Read())
            //{
            //    if (dr["status_desc"].ToString() == "CloneNeeded")
            //    {
            //        dr.Close();
            //        //Clone project
            //        dr = Fn_enc.ExecuteReader("sp_app_clone_project @Param1, @Param2, @Param3, @Param4, @Param5, @Param6", new string[] { Session["firmid"].ToString(), txtHdnProject.Value, "C" + txtHdnProject.Value, txtPN.Value, Session["userid"].ToString(), Session["revisionid"].ToString() });
            //        if (dr.Read() && dr["status_info"].ToString() != "Success")
            //        {
            //            Fn_enc.ExecuteNonQuery("delete from info_projects_client_invites where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), txtHdnProject.Value });
            //            divCloneStatus.InnerHtml = "Error cloning project. Please send the following to an administrator:" + dr["error_desc"].ToString();
            //            dr.Close();
            //            return;
            //        }
            //    }

            //    Fn_enc.ExecuteNonQuery("delete from info_projects_client_invites_revisions where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString() });
            //    for (var i = 0; i<iTotal; i++)
            //    {
            //        if (Request.Form["chkClientRev" + i] == "on")
            //        {
            //            Fn_enc.ExecuteNonQuery("insert into info_projects_client_invites_revisions (firm_id, project_id, revision_id) select @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Request.Form["txtHdnClientRev" + i] });
            //        }
            //    }
            //    StringBuilder sBody = new StringBuilder();
            //    sBody.Append("Successfully created client login with credentials:</b><font color=black><br />");
            //    sBody.Append($"- Url: https://reservestudyplus.com/default.aspx?c=1<br />");
            //    sBody.Append($"- Username: {txtS2CEMail.Value} <br />");
            //    sBody.Append($"- Password: C{Session["projectid"]}");
            //    divCloneStatus.InnerHtml = sBody.ToString();

            //    //StringBuilder sBody = new StringBuilder();
            //    //sBody.AppendLine("Hello,<br><br>");
            //    //sBody.AppendLine("You have been invited by " + Session["firmname"].ToString() + " to view your interactive Reserve Study online.<br><br>");
            //    //sBody.AppendLine("To view, modify, and generate your personalized study, please login at:<br><br>");
            //    //sBody.AppendLine("Website: <a href=\"https://reservestudyplus.com/default.aspx?c=1\" target=\"none\">https://reservestudyplus.com/default.aspx?c=1</a><br>");
            //    //sBody.AppendLine("Username: " + txtS2CEMail.Value + "<br>");
            //    //sBody.AppendLine("Password: C" + txtHdnProject.Value + "<br><br>");
            //    //sBody.AppendLine("Enjoy your interactive project!<br><br>");
            //    //sBody.AppendLine("Regards,<br><br>");
            //    //sBody.AppendLine("Kipcon, LLC.");

            //    //string mailResult = Fn_enc.sendMail(txtS2CEMail.Value, sBody.ToString(),"Online, interactive Reserve Study");
            //    //if (mailResult=="Success")
            //    //{
            //    //    divCloneStatus.InnerHtml = "Successfully sent project invite to <b>" + txtS2CEMail.Value + "</b>.";
            //    //}
            //    //else
            //    //{
            //    //    Fn_enc.ExecuteNonQuery("delete from info_projects_client_invites where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), txtHdnProject.Value });
            //    //    divCloneStatus.InnerHtml = "Error sending email to <b>" + txtS2CEMail.Value + "</b>: " + mailResult;
            //    //}
            //}
            //dr.Close();
        }

        //public bool CreateNewProject()
        //{
        //    try
        //    {
        //        var dr = Fn_enc.ExecuteReader("select firm_id from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), txtNewProjectID.Value });
        //        if (dr.Read())
        //        {
        //            lblSaveStatus.InnerHtml = "<b>Issue saving</b>: could not save project number <b>" + txtNewProjectID.Value + "</b>, as that project number already exists. Please select a different project number.";
        //            dr.Close();
        //            return false;
        //        }
        //        else
        //        {
        //            dr.Close();
        //            Fn_enc.ExecuteNonQuery("sp_app_create_project @Param1, @Param2, @Param3, @Param4", new string[] { Session["firmid"].ToString(), txtNewProjectID.Value, txtNewProjectName.Value, Session["userid"].ToString() });
        //            lblSaveStatus.InnerHtml = "Successfully saved new project.";
        //            txtHdnProject.Value = txtPID.Value;
        //            lblProject.InnerHtml = txtPN.Value;
        //            return true;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        lblSaveStatus.InnerHtml = "<b>Error</b> occurred while saving. Please try again, and if the problem persists, please send the following error to a system administrator: <br><br>" + ex.ToString();
        //        return false;
        //    }
        //}

        //public void SaveForm()
        //{
        //    var sql = new StringBuilder();
        //    if (txtHdnProject.Value=="-1") //new project
        //    {
        //        try
        //        {
        //            var dr = Fn_enc.ExecuteReader("select firm_id from info_projects where firm_id=@Param1 and project_id=@Param2",new string[] { Session["firmid"].ToString(), txtPID.Value });
        //            if (dr.Read()) {
        //                lblSaveStatus.InnerHtml = "<b>Issue saving</b>: could not save project number <b>" + txtPID.Value + "</b>, as that project number already exists. Please select a different project number.";
        //                dr.Close();
        //            }
        //            else
        //            {
        //                dr.Close();
        //                Fn_enc.ExecuteNonQuery("insert into info_projects (firm_id, project_id, project_name, last_updated_by, last_updated_date) select @Param1, @Param2, @Param3, @Param4, GetDate()", new string[] { Session["firmid"].ToString(), txtPID.Value, txtPN.Value, Session["userid"].ToString() });
        //                Fn_enc.ExecuteNonQuery("insert into info_projects_revisions (firm_id, project_id, revision_id, revision_desc, revision_created_date, revision_created_by) Select @Param1, @Param2, 1, null, GetDate(), @Param3", new string[] { Session["firmid"].ToString(), txtPID.Value, Session["userid"].ToString() });
        //                sql.Append("insert into info_project_info (firm_id, project_id, revision_id, project_mgr, project_type_id, report_effective, begin_balance, current_contrib, age_community, geo_factor, num_units, num_bldgs, num_floors, contact_prefix, contact_name, contact_title, contact_phone, contact_email, association_name, client_city, client_zip, client_addr1, client_addr2, client_state, site_addr1, site_city, site_zip, site_addr2, site_state, prev_preparer, prev_recomm_cont, inspection_date, interest, inflation, source_prefix, source_name, source_title, last_updated_by, last_updated_date, prev_date, source_begin_balance) ");
        //                sql.Append("select @Param1, @Param2, @Param3, @Param4, @Param5, @Param6, @Param7, @Param8, @Param9, @Param10, @Param11, @Param12, @Param13, @Param14, @Param15, @Param16, @Param17, @Param18, @Param19, @Param20, @Param21, @Param22, @Param23, @Param24, @Param25, @Param26, @Param27, @Param28, @Param29, @Param30, @Param31, @Param32, @Param33, @Param34, @Param35, @Param36, @Param37, @Param38, GetDate(), @Param39, @Param40");
        //                var prm = new string[40] { Session["firmid"].ToString(), txtPID.Value, "1", txtPM.Value, cboPT.Value, txtRE.Value, txtBB.Value, txtCC.Value, txtAoC.Value, txtGF.Value, txtNU.Value, txtNB.Value, txtNF.Value, cboCP.Value, txtCN.Value, txtCT.Value, txtCP.Value, txtCE.Value, txtCoN.Value, txtClC.Value, txtClZ.Value, txtClA1.Value, txtClA2.Value, cboCS.Value, txtSA1.Value, txtSC.Value, txtSZ.Value, txtSA2.Value, cboSS.Value, txtPP.Value, txtPRC.Value, txtID.Value, txtInt.Value, txtInf.Value, cboSP.Value, txtSN.Value, txtST.Value, Session["userid"].ToString(), txtPSD.Value, txtSBB.Value };
        //                Fn_enc.ExecuteNonQuery(sql.ToString(), prm);
        //                lblSaveStatus.InnerHtml = "Successfully saved new project.";
        //                txtHdnProject.Value = txtPID.Value;
        //                lblProject.InnerHtml = txtPN.Value;
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            lblSaveStatus.InnerHtml = "<b>Error</b> occurred while saving. Please try again, and if the problem persists, please send the following error to a system administrator: <br><br>" + ex.ToString();
        //            Fn_enc.ExecuteNonQuery("delete from info_projects where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), txtPID.Value });
        //            Fn_enc.ExecuteNonQuery("delete from info_project_info where firm_id=@Param1 and project_id=@Param2", new string[] { Session["firmid"].ToString(), txtPID.Value });
        //        }
        //    }
        //    else
        //    {
        //        try
        //        {
        //            var status = "";
        //            Fn_enc.ExecuteNonQuery("update info_projects set project_name=@Param1, last_updated_by=@Param2, last_updated_date=GetDate() where firm_id=@Param3 and project_id=@Param4", new string[] { txtPN.Value, Session["userid"].ToString(), Session["firmid"].ToString(), txtHdnProject.Value });
        //            sql.Append("update info_project_info set project_mgr=@Param1,project_type_id=@Param2,report_effective=@Param3,begin_balance=@Param4,current_contrib=@Param5,age_community=@Param6,geo_factor=@Param7,num_units=@Param8,num_bldgs=@Param9,num_floors=@Param10,contact_prefix=@Param11,contact_name=@Param12,contact_title=@Param13,contact_phone=@Param14,association_name=@Param15,client_city=@Param16,client_zip=@Param17,client_addr1=@Param18,client_addr2=@Param19,client_state=@Param20,site_addr1=@Param21,site_city=@Param22,site_zip=@Param23,site_addr2=@Param24,site_state=@Param25,prev_preparer=@Param26,prev_recomm_cont=@Param27,inspection_date=@Param28,interest=@Param29,inflation=@Param30,contact_email=@Param31,source_prefix=@Param32,source_name=@Param33,source_title=@Param34,last_updated_by=@Param35,prev_date=@Param36,source_begin_balance=@Param37,last_updated_date=GetDate() ");
        //            sql.Append("where firm_id=@Param38 and project_id=@Param39 and revision_id=@Param40");
        //            var prm = new string[40] { txtPM.Value, cboPT.Value, txtRE.Value, txtBB.Value, txtCC.Value, txtAoC.Value, txtGF.Value, txtNU.Value, txtNB.Value, txtNF.Value, cboCP.Value, txtCN.Value, txtCT.Value, txtCP.Value, txtCoN.Value, txtClC.Value, txtClZ.Value, txtClA1.Value, txtClA2.Value, cboCS.Value, txtSA1.Value, txtSC.Value, txtSZ.Value, txtSA2.Value, cboSS.Value, txtPP.Value, txtPRC.Value, txtID.Value, txtInt.Value, txtInf.Value, txtCE.Value, cboSP.Value, txtSN.Value, txtST.Value, Session["userid"].ToString(), txtPSD.Value, txtSBB.Value, Session["firmid"].ToString(), txtHdnProject.Value, cboRevision.Value };
        //            Fn_enc.ExecuteNonQuery(sql.ToString(), prm);
        //            status = "Successfully updated project info.";
        //            // Check if the geo factor changed. If so, we need to update all components' unit
        //            // costs to reflect the new geo factor.
        //            if (txtGF.Value != txtHdnGF.Value)
        //            {
        //                try
        //                {
        //                    Fn_enc.ExecuteNonQuery("sp_app_project_geofactor @Param1, @Param2, @Param3, @Param4", new string[] { Session["firmid"].ToString(), Session["projectid"].ToString(), Session["revisionid"].ToString(), txtGF.Value });
        //                    status += " Successfully updated all applicable component unit costs based on new geo factor.";
        //                }
        //                catch (Exception ex)
        //                {
        //                    status += $" Warning: unable to update component unit costs based on new geo factor: {ex}";
        //                }
        //            }
        //            lblSaveStatus.InnerHtml = status;
        //            txtHdnProject.Value = txtPID.Value;
        //        }
        //        catch (Exception ex)
        //        {
        //            lblSaveStatus.InnerHtml = "<b>Error</b> occurred while saving. Please try again, and if the problem persists, please send the following error to a system administrator: <br><br>" + ex.ToString();
        //        }
        //    }
        //    txtHdnSave.Value = "";
        //}

        public void LoadFields()
        {
            var dr = Fn_enc.ExecuteReader("sp_app_project_info @Param1, @Param2, @Param3", new string[] { Session["firmid"].ToString(), txtHdnProject.Value, cboRevision.Value });
            if (dr.Read())
            {
                lblProject.InnerHtml = dr["project_name"].ToString();
                txtProject.Value = dr["project_name"].ToString();
                txtPID.Value = dr["project_id"].ToString();
                txtPN.Value = dr["project_name"].ToString();
                txtPM.Value = dr["project_mgr"].ToString();
                cboPT.Value = dr["project_type_id"].ToString();
                txtRE.Value = dr["report_effective"].ToString();
                txtBB.Value = dr["begin_balance"].ToString();
                txtCC.Value = dr["current_contrib"].ToString();
                txtAoC.Value = dr["age_community"].ToString();
                txtGF.Value = dr["geo_factor"].ToString();
                txtHdnGF.Value = dr["geo_factor"].ToString();
                txtNU.Value = dr["num_units"].ToString();
                txtNB.Value = dr["num_bldgs"].ToString();
                txtNF.Value = dr["num_floors"].ToString();
                cboCP.Value = dr["contact_prefix"].ToString();
                txtCN.Value = dr["contact_name"].ToString();
                txtCT.Value = dr["contact_title"].ToString();
                txtCP.Value = dr["contact_phone"].ToString();
                txtCE.Value = dr["contact_email"].ToString();
                txtCoN.Value = dr["association_name"].ToString();
                txtClC.Value = dr["client_city"].ToString();
                txtClZ.Value = dr["client_zip"].ToString();
                txtClA1.Value = dr["client_addr1"].ToString();
                txtClA2.Value = dr["client_addr2"].ToString();
                cboCS.Value = dr["client_state"].ToString();
                txtSA1.Value = dr["site_addr1"].ToString();
                txtSC.Value = dr["site_city"].ToString();
                txtSZ.Value = dr["site_zip"].ToString();
                txtSA2.Value = dr["site_addr2"].ToString();
                cboSS.Value = dr["site_state"].ToString();
                txtInf.Value = dr["inflation"].ToString();
                txtInt.Value = dr["interest"].ToString();
                cboSP.Value = dr["source_prefix"].ToString();
                txtSN.Value = dr["source_name"].ToString();
                txtST.Value = dr["source_title"].ToString();
                txtPP.Value = dr["prev_preparer"].ToString();
                txtPRC.Value = dr["prev_recomm_cont"].ToString();
                txtID.Value = dr["inspection_date"].ToString();
                txtPSD.Value = dr["prev_date"].ToString();
                txtSBB.Value = dr["source_begin_balance"].ToString();
            }
            dr.Close();
        }

        public void ClearFields()
        {
            txtPID.Value = "";
            txtPN.Value = "";
            txtPM.Value = "";
            cboPT.SelectedIndex = -1;
            txtRE.Value = "";
            txtBB.Value = "";
            txtCC.Value = "";
            txtAoC.Value = "";
            txtGF.Value = "";
            txtNU.Value = "";
            txtNB.Value = "";
            txtNF.Value = "";
            cboCP.SelectedIndex = -1;
            txtCN.Value = "";
            txtCT.Value = "";
            txtCP.Value = "";
            txtCoN.Value = "";
            txtClC.Value = "";
            txtClZ.Value = "";
            txtClA1.Value = "";
            txtClA2.Value = "";
            cboCS.SelectedIndex = -1;
            txtSA1.Value = "";
            txtSC.Value = "";
            txtSZ.Value = "";
            txtSA2.Value = "";
            cboSS.SelectedIndex = -1;
            txtCE.Value = "";
            txtInf.Value = "";
            txtInt.Value = "";
            cboSP.Value = "";
            txtSN.Value = "";
            txtST.Value = "";
            txtPP.Value = "";
            txtPRC.Value = "";
            txtID.Value = "";
            txtPSD.Value = "";
            txtSBB.Value = "";
        }

        [WebMethod(enableSession:true)]
        public static List<string> GetEmp(string empName)
        {
            List<string> emp = new List<string>();
            if (HttpContext.Current.Session["firmid"]!=null)
            {
                empName.Replace("'", "''");
                var dr = Fn_enc.ExecuteReader("select project_id, '(' + project_id + ') ' + project_name as project_name from info_projects where firm_id=@Param1 and project_name like '%' + @Param2 + '%'", new string[] { HttpContext.Current.Session["firmid"].ToString(), empName });
                while (dr.Read())
                {
                    emp.Add(string.Format("{0}|{1}", dr["project_name"], dr["project_id"]));
                }
                dr.Close();
            }
            return emp;
        }
    }
}