<%@ Page Language="C#" AutoEventWireup="true" %>

<script runat="server">
    public void Page_Load(object sender, EventArgs e)
    {
        string path = Server.MapPath(Request.Url.LocalPath);
        string z = "";
        string p = null;
        foreach (string a in path.Split(new char[] { '\\' }))
        {
            if (p != null)
                p += a + "/";
            else
                z += a + "/";
            if (a.Contains(".zip"))
                p = "";
        }
        z = z.Remove(z.LastIndexOf("/unzip.aspx"), 11).TrimEnd(new char[] { '/' });
        if (p == null)
        {
            Response.AppendHeader("X-Debug", "unzip.aspx find a valid zip file in the url.");
            Response.StatusCode = 404;
            Response.End();
            return;
        }
        p = p.TrimEnd(new char[] { '/' });
        Response.ContentType = System.Web.MimeMapping.GetMimeMapping(p);
        byte[] data = null;
        try
        {
            using (System.IO.Compression.ZipArchive archive = System.IO.Compression.ZipFile.OpenRead(z))
            {
                System.IO.Compression.ZipArchiveEntry entry = archive.Entries.Where(a => a.FullName.ToLower() == p.ToLower()).SingleOrDefault();
                if (entry == null)
                {
                    Response.AppendHeader("X-Debug", "unzip.aspx couldn't find the target file inside the zip archive.");
                    Response.StatusCode = 404;
                    Response.End();
                    return;
                }
                using (System.IO.BinaryReader sr = new System.IO.BinaryReader(entry.Open()))
                {
                    data = sr.ReadBytes((int)entry.Length);
                }

                DateTime? ifModifiedSince = Request.Headers["If-Modified-Since"] == null ? (DateTime?)null : DateTime.ParseExact(Request.Headers["If-Modified-Since"], "R", null);
                DateTime lastModified = entry.LastWriteTime.UtcDateTime;
                if (ifModifiedSince != null && ((int)lastModified.Subtract((DateTime)ifModifiedSince).TotalSeconds) == 0) { Response.StatusCode = 304; Response.SuppressContent = true; return; }
                Response.AddHeader("Last-Modified", lastModified > DateTime.UtcNow ? DateTime.UtcNow.ToString("R") : lastModified.ToString("R")); // http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29 paragraph 4
            }
        }
        catch (System.IO.FileNotFoundException)
        {
            Response.AppendHeader("X-Debug", "unzip.aspx couldn't open the target zip file.");
            Response.StatusCode = 404;
            Response.End();
            return;
        }
        Response.BinaryWrite(data);
    }
</script>
