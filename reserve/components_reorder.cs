using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;

namespace reserve
{
    public class components_reorder : ApiController
    {
        [HttpPost]
        public string reorder (string json)
        {
            return "hi";
        }
    }
}