
function displayComments(div, path, force)
{
//  if(comments_displayed !=0)
//    dojo.lfx.html.wipeOut(document.getElementById(div), 100);

    var bindArgs = {
    url:         "/exec/getcomments/" + path,
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
      document.getElementById(div).innerHTML = data.toString();
      dojo.lfx.html.wipeIn(document.getElementById(div), 100).play();
    }
  };

    requestObj = dojo.xhrGet(bindArgs);

  return false;
}


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
    var form = document.getElementById(formid);
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

function saveComment(obj, formid, noanim)
{
var bindArgs = { 
    url:        "/exec/comments/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById("popup_contents");
        
        if(!d)
          return;
        else
        {
          if(data.toString() != "OK")
            d.innerHTML = data.toString();
          else
          {
            closePopup();
            displayComments('wiper', obj);
          }
        }
    }
    
  };

  if(formid)
  {
    var form = document.getElementById(formid);
    if(form)
      bindArgs.formNode = form;
  }
    
// dispatch the request
    var requestObj = dojo.xhrPost(bindArgs);
}

function postComment(obj, formid, noanim)
{
  var bindArgs = { 
    url:        "/exec/comments/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById("popup_contents");
        if(!d)
          return;
        else
          d.innerHTML = data.toString();
    }
  };

  if(formid)
  {
    var form = document.getElementById(formid);
    if(form)
    {
      bindArgs.formNode = form;
    }
  }
    
// dispatch the request
    var requestObj = dojo.xhrPost(bindArgs);
}

//
// getPageScroll()
// Returns array with x,y page scroll values.
// Core code from - quirksmode.org
//
function getPageScroll(){

	var yScroll;

	if (self.pageYOffset) {
		yScroll = self.pageYOffset;
	} else if (document.documentElement && document.documentElement.scrollTop){	 // Explorer 6 Strict
		yScroll = document.documentElement.scrollTop;
	} else if (document.body) {// all other Explorers
		yScroll = document.body.scrollTop;
	}

	arrayPageScroll = new Array('',yScroll) 
	return arrayPageScroll;
}



//
// getPageSize()
// Returns array with page width, height and window width, height
// Core code from - quirksmode.org
// Edit for Firefox by pHaez
//
function getPageSize(){
	
	var xScroll, yScroll;
	
	if (window.innerHeight && window.scrollMaxY) {	
		xScroll = document.body.scrollWidth;
		yScroll = window.innerHeight + window.scrollMaxY;
	} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
		xScroll = document.body.scrollWidth;
		yScroll = document.body.scrollHeight;
	} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
		xScroll = document.body.offsetWidth;
		yScroll = document.body.offsetHeight;
	}
	
	var windowWidth, windowHeight;
	if (self.innerHeight) {	// all except Explorer
		windowWidth = self.innerWidth;
		windowHeight = self.innerHeight;
	} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
		windowWidth = document.documentElement.clientWidth;
		windowHeight = document.documentElement.clientHeight;
	} else if (document.body) { // other Explorers
		windowWidth = document.body.clientWidth;
		windowHeight = document.body.clientHeight;
	}	
	
	// for small pages with total height less then height of the viewport
	if(yScroll < windowHeight){
		pageHeight = windowHeight;
	} else { 
		pageHeight = yScroll;
	}

	// for small pages with total width less then width of the viewport
	if(xScroll < windowWidth){	
		pageWidth = windowWidth;
	} else {
		pageWidth = xScroll;
	}


	arrayPageSize = new 
Array(pageWidth,pageHeight,windowWidth,windowHeight) 
	return arrayPageSize;
}

function openAttachments(obj, sid)
{
  setCurrentSessionId(sid);
  openPopup('/exec/editattachments/' + obj, '500px', null, null, null,
       function(){ setCurrentObject(obj); /*showSWFUpload('/exec/addattachments/' + obj  + '?PSESSIONID=' + sid);*/})
}

function openLogin()
{
  openPopup("/exec/login?ajax=1&return_to="  + window.location, 'Login', null, null, null, null, setinsert);
}

function setinsert()
{
 window.setTimeout('var elem = document.getElementById("UserName");if(elem){ elem.focus(); }', 300);
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
 

  var lh =  
  dojo.connect(dialog, "onLoad", function() {dojo.disconnect(lh); if(loadfunc) loadfunc();});

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

var block2 = document.getElementById("popup_contents");

var bindArgs = { 
    url:        "/exec/editcategory/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
     block2.innerHTML = data.toString();
    }

  };
  if(formid)
  {
    var form = document.getElementById(formid);
    if(form)
      bindArgs.formNode = form;

    if(a && form)
    {
      document.getElementById("action").value=a;
    }
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
//		alert("closing");
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

function cumulativeOffset(element) 
{
  var valueT = 0, valueL = 0;
  do 
  {
    valueT += element.offsetTop || 0;
    valueL += element.offsetLeft || 0;
    element = element.offsetParent;
  } 
  while (element);
  return [valueL, valueT];
}

function toggleCreated()
{  
  var field = dijit.byId("createdDate");
  if(field) field.set('disabled', !field.disabled);
}
