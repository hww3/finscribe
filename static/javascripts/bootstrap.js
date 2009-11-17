var fs_global = this;

function setupAjaxLinks()
{
  //alert("setupAjaxLinks() " + fs_global["dojo"] + " " + (typeof fs_global["dojo"]));
  if(!(typeof fs_global["dojo"] == "undefined"))
  {
//    console.debug("dojo is here.");
    doSetupAjaxLinks();
  }
}

function doSetupAjaxLinks()
{
  //alert("doSetupAjaxLinks()");
   convertToPopup("BackLinks"); 
   convertToPopup("PostComment"); 
   convertToPopup("TrackBacks"); 
   convertToPopup("PingBacks"); 

   convertToAjax("Login", openLogin);
//   convertToAjax("PostBlog", openPostBlog);
   convertToAjax("Actions", openActions);

   if(!(typeof fs_global["doThemeSetup"] == "undefined"))
     doThemeSetup();
} 

function convertToAjax(id, func)
{
  var a = document.getElementById(id);

  if(!a) return;
//alert("have the element: " + id);

//    console.debug("ajaxifying " + id);

  a.onclick = function(event){ if(!event) event = window.event; func(a, event); return false; };

  a.href="#";
}

function convertToPopup(id)
{
  var a = document.getElementById(id);

  if(!a) return;
//alert("have the element: " + id);

  var z = a.href;
  a.onclick = function(event){ openPopup(z + "?ajax=1", "80%"); return false; };

  a.href="#";
}
