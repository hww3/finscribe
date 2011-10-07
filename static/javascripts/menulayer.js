
function openActions(item, event)
{
  // onclick="menuLayers.show('actions', '/exec/actions/<%$obj%>', event, this)"
  var obj;
  var d;

  d = document.getElementById("object");
  if(!d) return;
  else obj = d.innerHTML;

  d = new dijit.TooltipDialog({id: "actions", href: '/exec/actions/' + obj});

  dijit.popup.open({ popup: d, around: dojo.byId(item) });
  dojo.connect(d, "onMouseLeave", function(){ dijit.popup.close(d); d.destroyRecursive(true);  });
}

function openPostBlog(item)
{
  var obj;
  var d;

  d = document.getElementById("object");
  if(!d) return;
  else obj = d.innerHTML;

  openPopup("/exec/post/" + obj + "?ajax=1", 'Post Blog Entry', null, null, null, /*function(){if(window.postOnLoad) window.postOnLoad();}*/ null);
}

function uploadAttachemnts(obj, formid)
{
	  var bindArgs = { 
	    url:        "/exec/addattachments/" + obj, 
	 	form: dojo.byId(formid),
	    content: {ajax: "1"},
	    error:      function(type, errObj){
	    },
	    load:      function(data, evt){
	        // handle successful response here
	//        var d = document.getElementById("popup_contents");
	  var dialog = dijit.byId('dialog');

	        if(!dialog)
	          return;
	        else
	        {
	          if(data.toString() != "OK")
			  {
	            dialog.set('content', data);
	   		  }
	          else
	          {
				  dialog.set('content', 'OK');
			      window.setTimeout('closePopup();', 2000);
				  var d = dijit.byId(obj + "_comments");
				  if(d) d.click();
		          //displayComments('wiper', obj);
	          }
	        }
	    }    
	  };

	// dispatch the request
	    var requestObj = dojo.xhrPost(bindArgs);
	
}


function deleteAttachment(obj, filetodelete)
{
	
	  var dialog = dijit.byId('dialog');

	        if(!dialog)
	          return;
	
  var bindArgs = {
    url:        "/exec/editattachments/" + obj,
    content: {ajax: "1", when: (new Date().getTime()), action: "Delete", 'save-as-filename': filetodelete},
    error:      function(type, errObj){
    },
    load:      function(data){
        // handle successful response here
        if(!dialog)
          return;
        else
		{
   			dialog.set('content', data.toString());
		}
    }
  };

    var requestObj = dojo.xhrPost(bindArgs);

}


function postBlog(obj, formid)
{
var bindArgs = { 
    url:        "/exec/post/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    method: "POST",
    error:      function(type, errObj){
    },
    load:      function(data, evt){
        // handle successful response here

 var dialog = dijit.byId('dialog');
 if(!dialog)
 {
	alert("uh-oh!");
          return;
 }

   dialog.set('content', data.toString());
   var d = dojo.byId("result");
   if(d && d.innerHTML == "Success")
      window.setTimeout('saveBlog();', 2000);
    }

  };

  if(formid)
  {
    var form = dojo.byId(formid);
    if(form)
      bindArgs.form = form;
  }
    
// dispatch the request
    var requestObj = dojo.xhrPost(bindArgs);
    
}

function saveBlog(id, obj)
{	
	closePopup();
	window.setTimeout('refreshBlog();', 500);
}

function refreshBlog()
{
	window.location = window.location + "?refresh=" + (Date.now()); 
}

function saveComment(obj, formid, noanim, widgetId)
{
//	alert("saveComment");
  var bindArgs = { 
    url:        "/exec/comments/" + obj, 
 	form: dojo.byId(formid),
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(data, evt){
        // handle successful response here
//        var d = document.getElementById("popup_contents");
  var dialog = dijit.byId('dialog');

        if(!dialog)
          return;
        else
        {
          if(data.toString() != "OK")
		  {
            dialog.set('content', data);
   		  }
          else
          {
			  dialog.set('content', 'OK');
		      window.setTimeout('closePopup();', 2000);
			  var d = dijit.byId(obj + "_comments");
			  if(d) d.click();
	          //displayComments('wiper', obj);
          }
        }
    }    
  };
    
// dispatch the request
    var requestObj = dojo.xhrPost(bindArgs);
}

function openAttachments(obj, sid)
{
  setCurrentSessionId(sid);
  openPopup('/exec/editattachments/' + obj, '500px', null, null, null,
       function(){ setCurrentObject(obj); /*showSWFUpload('/exec/addattachments/' + obj  + '?PSESSIONID=' + sid);*/})
}

function openLogin()
{
//  openPopup("/exec/login?ajax=1&return_to="  + window.location, 'Login', null, null, null, null, setinsert);
// onclick="menuLayers.show('actions', '/exec/actions/<%$obj%>', event, this)"
var obj;
var d;

d = document.getElementById("object");
if(!d) return;
else obj = d.innerHTML;

d = new dijit.TooltipDialog({id: "LoginPopup", href: '/exec/login?ajax=1&return_to=' + window.location});
var lh =  dojo.connect(d, "onLoad", function() {dojo.disconnect(lh); if(setinsert) setinsert();});

dijit.popup.open({ popup: d, around: dojo.byId('Login') });
dojo.connect(d, "onMouseLeave", function(){ dijit.popup.close(d); d.destroyRecursive(true);  });


}

function setinsert()
{
 window.setTimeout('var elem = dojo.byId("username");if(elem){ elem.focus(); }', 300);
}

var currentPopup;
var currentObj;
var currentSessionId;

function setCurrentObject(co)
{
  currentObj = co;
}

function setCurrentSessionId(sid)
{
  currentSessionId = sid;
}

var loadhandler;

function openPopup(url, title, width, height, formid, action, loadfunc) {
//  closePopup();
  currentPopup = url;  
  //dojo.debug("closed popup.");
  var s = "";

  if(width!=null) s += "width: " + width + "; ";
  if(height!=null) s += "height: " + height + "; ";

  var dialog;
  dialog = dijit.byId('dialog');
  if(dialog) dialog.destroyRecursive(true);

 	dialog = new dijit.Dialog({
      title: title,
      style: s,
      id: 'dialog'
  });
 
  if(loadhandler) dojo.disconnect(loadhandler);

  loadhandler =  
  dojo.connect(dialog, "onLoad", function() {dojo.disconnect(loadhandler); loadhandler = 0; if(loadfunc && dojo.isFunction(loadfunc)) loadfunc(); 
		else if(dojo.global[loadfunc]){ dojo.global[loadfunc]();}});

  dialog.set("href", url);
  dialog.show();
}

function installScript( script )
{
    if (!script)
        return;

    if (script.src)
    {
        var head = document.getElementsByTagName("head")[0];
        var scriptObj = document.createElement("script");

        scriptObj.setAttribute("type", "text/javascript");
        scriptObj.setAttribute("src", script.src);  

        head.appendChild(scriptObj);

    }
    else if (script.innerHTML)
    {
        //  Internet Explorer has a funky execScript method that makes this easy
        if (window.execScript)
            window.execScript( script.innerHTML );
        else
            window.setTimeout( script.innerHTML, 0 );
    }
}

function editCategory(obj, formid, a) {
  var forme = dojo.byId(formid);

  var bindArgs = { 
    url:        "/exec/editcategory/" + obj,  
    content: {ajax: "1"},
	form: forme,
    error:      function(type, errObj){
    },
    load:      function(data, evt){

	 var dialog = dijit.byId('dialog');
	 if(!dialog)
	 {
		alert("uh-oh!");
	          return;
	 }
	 dialog.set('content', data.toString());
    }
  };

  if(a && forme)
  {
    dojo.byId("action").value=a;
  }

// dispatch the request
    var requestObj = dojo.xhrPost(bindArgs);
}

function closePopup()
{
	var dialog2;
	
	dialog2 = dijit.byId('dialog');
	if(dialog2)
	{
		//alert("closing");
		dialog2.hide();
	}
  //return false;	
}

function updateFilename(elem)
{

  var str = elem.value;

  var ch = 0;

  ch = str.lastIndexOf('/');
 
  if(ch == -1)
    ch = str.lastIndexOf('\\');

  var e = document.getElementById('filename');

  if(e)
    e.value = str.substring(ch + 1);

  var d = document.getElementById('filename-div');
  if(d)
    d.innerHTML = str.substring(ch + 1);

}

function toggleCreated()
{  
  var field = dijit.byId("createdDate");
  if(field) field.set('disabled', !field.disabled);
}
