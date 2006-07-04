var fs_global = this;

function setupAjaxLinks()
{
  if(!(typeof fs_global["dojo"] == "undefined"))
  {
    dojo.debug("dojo is here.");
    doSetupAjaxLinks();
  }
}

function doSetupAjaxLinks()
{
   convertToPopup("BackLinks"); 
   convertToPopup("PostComment"); 
   convertToPopup("TrackBacks"); 
   convertToPopup("PingBacks"); 

   convertToAjax("Login", openLogin);
   convertToAjax("PostBlog", openPostBlog);
   convertToAjax("Actions", openActions);

   if(!dj_undef("doThemeSetup"))
     doThemeSetup();
} 

function convertToAjax(id, func)
{
  var a = document.getElementById(id);

  if(!a) return;
 
  dojo.debug("ajaxifying " + id);

  a.onclick = function(event){ if(!event) event = window.event; func(a, event); return false; };

  a.href="#";
}

function convertToPopup(id)
{
  var a = document.getElementById(id);

  if(!a) return;

  var z = a.href;
  a.onclick = function(event){ openPopup(z + "?ajax=1", "80%"); return false; };

  a.href="#";
}
