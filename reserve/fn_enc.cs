using System;
using System.Text;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;

namespace reserve
{
    public class Fn_enc
    {
        public static string sendMail(string sTo, string sBody, string sSubject)
        {
            SmtpClient smtpClient = new SmtpClient("mail.reservestudyplus.com", 25);

            smtpClient.Credentials = new System.Net.NetworkCredential("admin@reservestudyplus.com", "AWekAtBm869NAuz");
            // smtpClient.UseDefaultCredentials = true; // uncomment if you don't want to use the network credentials
            smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            MailMessage mail = new MailMessage();

            //Setting From , To and CC
            mail.From = new MailAddress("admin@reservestudyplus.org", "Reserve Study");
            mail.To.Add(new MailAddress(sTo));
            mail.Subject = sSubject;
            mail.Body = sBody;
            mail.IsBodyHtml = true;
            try
            {
                smtpClient.Send(mail);
                return "Success";
            }
            catch (Exception ex)
            {
                return ex.ToString();
            }
        }

        public static string DocLoc()
        {
            string retDocLoc = "";
            if (HttpContext.Current.Request.IsLocal)
                retDocLoc = @"c:\data\";
            else if (HttpContext.Current.Request.Url.Host.IndexOf("test.reservestudyplus.com") >= 0)
            {
                retDocLoc = @"c:\Inetpub\vhosts\reservestudyplus.com\test.reservestudyplus.com\clienttemplates\";
            }
            else
            {
                retDocLoc = @"c:\Inetpub\vhosts\reservestudyplus.com\clienttemplates\";
            }

            return retDocLoc;
        }

        public static SqlConnection getconn()
        {
            var conn = new SqlConnection();
            if (HttpContext.Current.Request.IsLocal)
                conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr_dev"];
            else if (HttpContext.Current.Request.Url.Host.IndexOf("test.reservestudyplus.com") >= 0)
                conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr_test"];
            else
                conn.ConnectionString = System.Configuration.ConfigurationManager.AppSettings["connstr"];

            return conn;
        }

        public static SqlDataReader ExecuteReader(String commandText, string[] paramColl)
        {
            var conn = getconn();

            using (SqlCommand cmd = new SqlCommand(commandText, conn))
            {
                if (paramColl != null)
                {
                    int i = 1;
                    foreach (var p in paramColl)
                    {
                        cmd.Parameters.Add(new SqlParameter("Param" + i.ToString(), p.ToString()));
                        i++;
                    }
                }

                conn.Open();
                // When using CommandBehavior.CloseConnection, the connection will be closed when the 
                // IDataReader is closed.
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                return reader;
            }
        }

        public static void ExecuteNonQuery(string commandText, string[] paramColl)
        {
            using (var conn = getconn())
            {
                using (SqlCommand cmd = new SqlCommand(commandText, conn))
                {
                    if (paramColl != null)
                    {
                        int i = 1;
                        foreach (var p in paramColl)
                        {
                            if (p.ToString() == "")
                                cmd.Parameters.Add(new SqlParameter("Param" + i.ToString(), DBNull.Value));
                            else
                                cmd.Parameters.Add(new SqlParameter("Param" + i.ToString(), p.ToString()));
                            i++;
                        }
                    }

                    conn.Open();
                    try
                    {
                        cmd.ExecuteNonQuery();
                    }
                    finally
                    {
                        conn.Close();
                    }
                }
            }



        }
    }
}