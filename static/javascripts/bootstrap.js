var fs_global = this;

function setupAjaxLinks()
{
  if(!(typeof fs_global["dojo"] == "undefined"))
  {
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
   convertToAjax("Admin", openAdmin);
   convertToAjax("PostBlog", openPostBlog);
   convertToAjax("Actions", openActions);

   if(!(typeof fs_global["doThemeSetup"] == "undefined"))
     doThemeSetup();
} 

function convertToAjax(id, func)
{
  var a = document.getElementById(id);

  if(!a) return;
  var z = a.href;
  a.onclick = function(event){ if(!event) event = window.event; func(a, event, z); return false; };
  a.href="#";
}

function convertToPopup(id)
{
  var a = document.getElementById(id);

  if(!a) return;

  var z = a.href + "?ajax=1";

  a.onclick = function(event){ openPopup(z, a.innerHTML, null, null, null, null, id + "OnLoad");};
  a.href="#";
}
