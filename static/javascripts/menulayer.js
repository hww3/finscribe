//dojo.require("dojo.html");
//dojo.require("dojo.lfx.*");
dojo.require("dojo.widget.*");
//dojo.require("dojo.widget.DatePicker");
//dojo.require("dojo.widget.ResizableTextarea");
//dojo.require("dojo.io.IframeIO");

var menuLayers = {
  timer: null,
  activeMenuID: null,
  item: null,
  onLoad: null,
  offX: 4,   // horizontal offset 
  offY: 6,   // vertical offset 
  clientX: null,
  clientY: null,
  pageX: null,
  pageY: null,
  show: function(id, o, e, item) {
    this.clientX = e.clientX;
    this.clientY = e.clientY;
    this.pageX = e.pageX;
    this.pageY = e.pageY;
    this.activeMenuID = id;
    this.item = item;

var bindArgs = {
    url:         o + "?ajax=1&return_to=" + window.location,
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById(id + "_contents");
        if(!d)
          return;
        d.innerHTML = data.toString();
	menuLayers.low_show();
    }
};

// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
  },

  low_show: function() {
    var mnu = document.getElementById? document.getElementById(menuLayers.activeMenuID): null;
    if (!mnu){
      return;
    }
    if ( mnu.onmouseout == null ) mnu.onmouseout = menuLayers.mouseoutCheck;
    if ( mnu.onmouseover == null ) mnu.onmouseover = menuLayers.clearTimer;
    menuLayers.position(mnu);
  },
  
  hide: function() {
    this.clearTimer();
    if (menuLayers.activeMenuID && document.getElementById) 
      this.timer = setTimeout("dojo.lfx.html.implode(document.getElementById('"+menuLayers.activeMenuID+"'), menuLayers.item, 200).play()", 200);
      return false;
  },
  
  position: function(mnu) {
    var x = menuLayers.pageX? menuLayers.pageX: menuLayers.clientX + dojo.html.getScroll().left;
    var y = menuLayers.pageY? menuLayers.pageY: menuLayers.clientY + dojo.html.getScroll().top;
    if ( x + mnu.offsetWidth + this.offX > dojo.html.getViewport().width + dojo.html.getScroll().left)
      x = x - mnu.offsetWidth - this.offX;
    else x = x + this.offX;
  
    if ( y + mnu.offsetHeight + this.offY > dojo.html.getViewport().height + dojo.html.getScroll().top )
      y = ( y - mnu.offsetHeight - this.offY > dojo.html.getScroll().top )? y - mnu.offsetHeight - 
this.offY : dojo.html.getViewport().height + dojo.html.getScroll().top - mnu.offsetHeight;
    else y = y + this.offY;
    mnu.style.left = x + "px"; mnu.style.top = y + "px";
      this.timer = setTimeout("dojo.lfx.html.explode(menuLayers.item, document.getElementById('"+menuLayers.activeMenuID+"'), 200).play()", 
200);
  },
  
  mouseoutCheck: function(e) {
    e = e? e: window.event;
	    // is element moused into contained by menu? or is it menu (ul or li or a to menu div)?
    var mnu = document.getElementById(menuLayers.activeMenuID);
    var toEl = e.relatedTarget? e.relatedTarget: e.toElement;
    if ( mnu != toEl && !menuLayers.contained(toEl, mnu) ) menuLayers.hide();
  },
  
  // returns true of oNode is contained by oCont (container)
  contained: function(oNode, oCont) {
    if (!oNode) return; // in case alt-tab away while hovering (prevent error)
    while ( oNode = oNode.parentNode ) 
      if ( oNode == oCont ) return true;
    return false;
  },

  clearTimer: function() {
    if (menuLayers.timer) clearTimeout(menuLayers.timer);
  }
  
}

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

    requestObj = dojo.io.bind(bindArgs);

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

  menuLayers.show('actions', '/exec/actions/' + obj, event, item)

}

function openPostBlog(item)
{
  var obj;
  var d;

  d = document.getElementById("object");
  if(!d) return;
  else obj = d.innerHTML;

  openPopup("/exec/post/" + obj, '80%', null, null, null, setinsert);
}

function postBlog(id, obj, formid)
{
var bindArgs = { 
    url:        "/exec/post/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    method: "POST",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById(id);
        if(!d)
          return;
        d.innerHTML = data.toString();
        d = document.getElementById("result");
        if(d && d.innerHTML == "Success")
          window.setTimeout('saveBlog();', 2000);
    }

  };

  if(formid)
  {
    var form = document.getElementById(formid);
    if(form)
      bindArgs.formNode = form;
  }
    
// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
    
}

function saveBlog(id, obj)
{
	closePopup();
	window.location = window.location + "?refresh=1";    
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
    var requestObj = dojo.io.bind(bindArgs);
   
  
}


function saveAttachment(obj, formid, noanim)
{
var bindArgs = { 
    url:        "/exec/editattachments/" + obj,  
    content: {ajax: "1"},
    method: "POST",
    mimetype:   "text/html",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById("popup_contents");
        if(!d)
          return;
        else
            d.innerHTML = data.toString();
        showSWFUpload("/exec/addattachments/" + obj + "?PSESSIONID=" + currentSessionId);

    }
    
  };

  if(formid)
  {
    var form = document.getElementById(formid);
    if(form)
      bindArgs.formNode = form;
  }
    
// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
   
  
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
    var requestObj = dojo.io.bind(bindArgs);
}

/*
dojo.provide("dojo.widget.YellowFade")
dojo.provide("dojo.widget.HtmlYellowFade")
dojo.require("dojo.widget.*");
dojo.require("dojo.graphics.*");
dojo.widget.HtmlYellowFade = function() {
    dojo.widget.HtmlWidget.call(this);
    this.widgetType = "YellowFade";
    this.delay    = 0;
    this.duration = 4000;
    this.initColor = "#FFE066";
    this.buildRendering = function(args, frag) {
        var o = frag["dojo:yellowfade"]["nodeRef"];
        dojo.lfx.html.colorFadeIn(o, 
dojo.graphics.color.extractRGB(this.initColor), this.duration, this.delay).play();
    }
}
dj_inherits(dojo.widget.HtmlYellowFade, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:yellowfade");

*/
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
  openPopup('/exec/editattachments/' + obj, '60%', null, null, null,
       function(){ setCurrentObject(obj); showSWFUpload('/exec/addattachments/' + obj  + '?PSESSIONID=' + sid);})
}

function openLogin()
{
  openPopup("/exec/login?return_to="  + window.location, '300px', null, null, null, setinsert);
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

function openPopup(url, width, height, formid, action, loadfunc) {
  closePopup();
  currentPopup = url;  
dojo.debug("closed popup.");
  var objOverlay = document.getElementById("dialogoverlay");

  if(!objOverlay)
  {

	var objBody = document.getElementsByTagName("body").item(0);

	objOverlay = document.createElement("div");
	objOverlay.setAttribute('id','dialogoverlay');
	objOverlay.onclick = function () {closePopup(); return false;}
	objOverlay.style.display = 'none';
	objOverlay.style.position = 'absolute';
	objOverlay.style.top = '0';
	objOverlay.style.left = '0';
	objOverlay.style.zIndex = '90';
 	objOverlay.style.width = ((dojo.html.getViewport().width + dojo.html.getScroll().left + 10) || 2000) + 
"px";
	objBody.insertBefore(objOverlay, null);
  }

	var arrayPageSize = getPageSize();
	var arrayPageScroll = getPageScroll();

	// set height of Overlay to take up whole page and show
	objOverlay.style.height = (arrayPageSize[1] + 'px');
        dojo.debug("page height: " + arrayPageSize[1]);
        dojo.debug("page width: " + objOverlay.style.width);
	objOverlay.style.display = 'block';

var block = document.getElementById("popup");
if (!block) {
var body = dojo.body();
block = document.createElement("div");
block.setAttribute("id", "popup");
block.className = "rounded rc-parentcolor-404040";
block.style.display = "none";
block.style.position = "absolute";
block.style.width = width;
if(height)
  block.style.height= height;
//block.style.padding;
block.style.zIndex = "400";
block.style.background = "Window";
block.style.backgroundColor = "#FFEB99";

body.appendChild(block);

}

var block1 = document.getElementById("popup_close");
if(!block1)
{
  block1 = document.createElement("div");
  block1.style.padding="0px";
  block1.style.textAlign = "right";
  block1.style.width="100%";
  block1.setAttribute("id", "popup_close");
  block1.innerHTML="<a href=\"#\" onclick=\"closePopup(); return false;\"><img border=\"0\" src=\"/static/images/close.gif\"></a> &nbsp;";
  block.appendChild(block1);
}

var block2 = document.getElementById("popup_contents");

if(!block2)
{
  block2 = document.createElement("div");
  block2.style.padding="0px 20px 20px 20px";
  block2.setAttribute("id", "popup_contents");
  block.appendChild(block2);
}

dojo.debug("got everything set up.");

var bindArgs = { 
    url:        url,  
    content: {ajax: "1"},
    method: "POST",
    mimetype:   "text/plain",
    error:      function(type, errObj){
      alert("error: " + type + "," + errObj.message + ", " + errObj.type + ", " + errObj.number );
    },
    load:      function(type, data, evt){
        // handle successful response here
     block2.innerHTML = data.toString();

//     objOverlay.style.width = dojo.html.getViewport().width + dojo.html.getScroll().left + 10;
     var h = block.offsetHeight || block.style.pixelHeight || 
               (block.currentStyle && block.currentStyle.height) || block.height;

     if(h && dojo.lang.isNumber(h)) h = ((dojo.html.getViewport().height) - h) / 2
       else h = 20;
     var blockTop = dojo.html.getScroll().top + h;
   
     h = block.offsetWidth || block.style.pixelWidth ||
               (block.currentStyle && block.currentStyle.width) || block.width;

     if(h && dojo.lang.isNumber(h)) h = ((dojo.html.getViewport().width) - h) / 2
       else h = 20;

     var blockLeft = dojo.html.getScroll().left + h;

		block.style.top = (blockTop < 0) ? "0px" : blockTop + "px";
		block.style.left = (blockLeft < 0) ? "0px" : blockLeft + "px";
dojo.debug("making corners.");
     make_corners();
dojo.debug("made corners.");
     dojo.lfx.html.fadeShow(block, 200, 0, function(){		

		arrayPageSize = getPageSize();
		objOverlay.style.width = (arrayPageSize[2] + 'px');
		objOverlay.style.height = (arrayPageSize[1] + 'px');
		dojo.debug("showing item.");
dojo.widget.createWidget(block);
     		if(loadfunc) loadfunc();
}
).play();
dojo.debug("done.");

	// After image is loaded, update the overlay height as the new image might have
	// increased the overall page height.


    }

  };
  if(formid)
  {
    var form = document.getElementById(formid);
    if(form)
      bindArgs.formNode = form;

    if(action && form)
    {
      document.getElementById("action").value=action;
    }
  }

// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
   
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
    var requestObj = dojo.io.bind(bindArgs);
   
}

function closePopup()
{
  var d = document.getElementById("popup");
  if(d)
  {
    dojo.lfx.html.fadeHide(d, 200).play();
    var objOverlay = document.getElementById("dialogoverlay");
    objOverlay.style.display = 'none';
    d.parentNode.removeChild(d);
  }
  return false;	
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

function showDatePicker() {
var block = document.getElementById("datePicker");
var picker;
if (!block) {
var body = dojo.body();
block = document.createElement("div");
block.setAttribute("id", "datePicker");
block.style.display = "none";
block.style.position = "absolute";
block.style.zIndex = "400";
block.style.background = "Window";
block.style.backgroundColor = "white";
block.style.border = "1px solid #efefef";
var inputField = document.getElementById("createdDate");
var offsets = cumulativeOffset(inputField);
block.style.top = offsets[1] + 15 + 'px';
block.style.left = offsets[0] + 'px';
body.appendChild(block);

picker = dojo.widget.createWidget("DatePicker",
{widgetId: "datePickerPicker"}, block, "last");
dojo.event.kwConnect({srcObj: picker,srcFunc:"onValueChanged",targetObj: this, targetFunc:"setDateField",
once:true});
}
dojo.lfx.html.fadeShow(block, 200).play();
}

function cumulativeOffset(element) {
var valueT = 0, valueL = 0;
do {
valueT += element.offsetTop || 0;
valueL += element.offsetLeft || 0;
element = element.offsetParent;
} while (element);
return [valueL, valueT];
}

  function setDateField(evt) {

        document.getElementById("datePicker").style.display="none";

        var field = document.getElementById("createdDate");

        var date = dojo.widget.manager.getWidgetById("datePickerPicker").getDate();

        field.value = dojo.date.format(date, "#yyyy-#MM-#dd");

    }

        function toggleCreated()
        {  

                var field = dojo.widget.byId("createdDate");
                if(field.disabled) field.enable();
		else field.disable();
       }

var swfu;
function showSWFUpload(upload_url) {
        
        swfu = new SWFUpload({
                upload_script : upload_url,
                target : "SWFUploadTarget",
                flash_path : "/static/javascripts/SWFUpload.swf",
                allowed_filesize : 30720,       // 30 MB
                allowed_filetypes : "*.*",
                allowed_filetypes_description : "All files...",
                browse_link_innerhtml : "Browse",
                upload_link_innerhtml : "Upload Files",
                browse_link_class : "swfuploadbtn browsebtn",
                upload_link_class : "swfuploadbtn uploadbtn",
                flash_loaded_callback : 'swfu.flashLoaded',
                upload_file_queued_callback : "fileQueued",
                upload_file_start_callback : 'uploadFileStart',
                upload_progress_callback : 'uploadProgress',
                upload_file_complete_callback : 'uploadFileComplete',
                upload_file_cancel_callback : 'uploadFileCancelled',
                upload_queue_complete_callback : 'uploadQueueComplete',
                upload_error_callback : 'uploadError',
                upload_cancel_callback : 'uploadCancel',
                auto_upload : false
        });

};

function fileQueued(file, queuelength) {
        var listingfiles = document.getElementById("SWFUploadFileListingFiles");

        if(!listingfiles.getElementsByTagName("ul")[0]) {
                        
                var info = document.createElement("h4");
                info.appendChild(document.createTextNode("Upload Queue"));

                listingfiles.appendChild(info);
                 
                var ul = document.createElement("ul")
                listingfiles.appendChild(ul);  
        }
                        
        listingfiles = listingfiles.getElementsByTagName("ul")[0];
                 
        var li = document.createElement("li");
        li.id = file.id;
        li.className = "SWFUploadFileItem";
        li.innerHTML = "<a id='" + file.id + "deletebtn' class='cancelbtn' href='javascript:swfu.cancelFile(\"" + file.id +"\");'><!-- IE --></a>"
		+ file.name + " <span class='progressBar' id='" + file.id + "progress'></span>";
                        
        listingfiles.appendChild(li);
                        
        var queueinfo = document.getElementById("queueinfo");
        queueinfo.innerHTML = queuelength + " file" + ((queuelength > 1)?"s":"") + " queued";
        document.getElementById(swfu.movieName + "UploadBtn").style.display = "block";
        document.getElementById("cancelqueuebtn").style.display = "block";
}

function uploadFileCancelled(file, queuelength) {
        var li = document.getElementById(file.id);
        li.innerHTML = file.name + " - cancelled";
        li.className = "SWFUploadFileItem uploadCancelled";
        var queueinfo = document.getElementById("queueinfo");
        queueinfo.innerHTML = queuelength + " files queued";
}
                
function uploadFileStart(file, position, queuelength) {
        var div = document.getElementById("queueinfo");
        div.innerHTML = "Uploading file " + position + " of " + queuelength;
        
        var li = document.getElementById(file.id);
        li.className += " fileUploading";
}
        
function uploadProgress(file, bytesLoaded) {
        
        var progress = document.getElementById(file.id + "progress");
        var percent = Math.ceil((bytesLoaded / file.size) * 200)
        progress.style.background = "#f0f0f0 url(/static/images/progressbar.png) no-repeat -" + (200 - percent) + "px 0";
}
        
function uploadError(errno) {
        // SWFUpload.debug(errno);
} 

function uploadFileComplete(file) {
        var li = document.getElementById(file.id);
        li.className = "SWFUploadFileItem uploadCompleted";
}
        
function cancelQueue() {
        swfu.cancelQueue();
        document.getElementById(swfu.movieName + "UploadBtn").style.display = "none";
        document.getElementById("cancelqueuebtn").style.display = "none";
}

function uploadQueueComplete(file) {
        var div = document.getElementById("queueinfo");
        div.innerHTML = "All files uploaded..."
        document.getElementById("cancelqueuebtn").style.display = "none";
        
  var bindArgs = { 
    url:        currentPopup,  
    content: {ajax: "1"},
    method: "POST",
    mimetype:   "text/html",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById("popup_contents");
        if(!d)
          return;
        else
            d.innerHTML = data.toString();
        showSWFUpload("/exec/addattachments/" + currentObj + "?PSESSIONID=" + currentSessionId);
    }
    
  };

// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
   
}

function SWFUpload(settings){try
{document.execCommand('BackgroundImageCache',false,true);}catch(e){}
this.movieName="SWFUpload_"+SWFUpload.movieCount++;this.init(settings);this.loadFlash();if(this.debug)
this.debugSettings();}
SWFUpload.movieCount=0;SWFUpload.handleErrors=function(errcode,file,msg){switch(errcode){case-10:alert("Error Code: HTTP Error, File name: "+file.name+", Message: "+msg);break;case-20:alert("Error Code: No upload script, File name: "+file.name+", Message: "+msg);break;case-30:alert("Error Code: IO Error, File name: "+file.name+", Message: "+msg);break;case-40:alert("Error Code: Security Error, File name: "+file.name+", Message: "+msg);break;case-50:alert("Error Code: Filesize exceeds limit, File name: "+file.name+", File size: "+file.size+", Message: "+msg);break;}};SWFUpload.prototype.init=function(settings){this.settings=[];this.addSetting("debug",settings["debug"],false);this.addSetting("target",settings["target"],"");this.addSetting("create_ui",settings["create_ui"],false);this.addSetting("browse_link_class",settings["browse_link_class"],"SWFBrowseLink");this.addSetting("upload_link_class",settings["upload_link_class"],"SWFUploadLink");this.addSetting("browse_link_innerhtml",settings["browse_link_innerhtml"],"<span>Browse...</span>");this.addSetting("upload_link_innerhtml",settings["upload_link_innerhtml"],"<span>Upload</span>");this.addSetting("flash_loaded_callback",settings["flash_loaded_callback"],"SWFUpload.flashLoaded");this.addSetting("upload_file_queued_callback",settings["upload_file_queued_callback"],"");this.addSetting("upload_file_start_callback",settings["upload_file_start_callback"],"");this.addSetting("upload_file_complete_callback",settings["upload_file_complete_callback"],"");this.addSetting("upload_queue_complete_callback",settings["upload_queue_complete_callback"],"");this.addSetting("upload_progress_callback",settings["upload_progress_callback"],"");this.addSetting("upload_dialog_cancel_callback",settings["upload_dialog_cancel_callback"],"");this.addSetting("upload_file_error_callback",settings["upload_file_error_callback"],"SWFUpload.handleErrors");this.addSetting("upload_file_cancel_callback",settings["upload_file_cancel_callback"],"");this.addSetting("upload_queue_cancel_callback",settings["upload_queue_cancel_callback"],"");this.addSetting("upload_script",escape(settings["upload_script"],""));this.addSetting("auto_upload",settings["auto_upload"],false);this.addSetting("allowed_filetypes",settings["allowed_filetypes"],"*.*");this.addSetting("allowed_filetypes_description",settings["allowed_filetypes_description"],"All files");this.addSetting("allowed_filesize",settings["allowed_filesize"],1024);this.addSetting("flash_path",settings["flash_path"],"/static/javascripts/SWFUpload.swf");this.addSetting("flash_target",settings["flash_target"],"");this.addSetting("flash_width",settings["flash_width"],"1px");this.addSetting("flash_height",settings["flash_height"],"1px");this.addSetting("flash_color",settings["flash_color"],"#000000");this.debug=this.getSetting("debug");};SWFUpload.prototype.loadFlash=function(){var html="";var sb=new stringBuilder();if(navigator.plugins&&navigator.mimeTypes&&navigator.mimeTypes.length){sb.append('<embed type="application/x-shockwave-flash" src="'+this.getSetting("flash_path")+'" width="'+this.getSetting("flash_width")+'" height="'+this.getSetting("flash_height")+'"');sb.append(' id="'+this.movieName+'" name="'+this.movieName+'" ');sb.append('bgcolor="'+this.getSetting["flash_color"]+'" quality="high" wmode="transparent" menu="false" flashvars="');sb.append(this._getFlashVars());sb.append('" />');}else{sb.append('<object id="'+this.movieName+'" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="'+this.getSetting("flash_width")+'" height="'+this.getSetting("flash_height")+'">');sb.append('<param name="movie" value="'+this.getSetting("flash_path")+'" />');sb.append('<param name="bgcolor" value="#000000" />');sb.append('<param name="quality" value="high" />');sb.append('<param name="wmode" value="transparent" />');sb.append('<param name="menu" value="false" />');sb.append('<param name="flashvars" value="'+this._getFlashVars()+'" />');sb.append('</object>');}
var container=document.createElement("div");container.style.width="0px";container.style.height="0px";container.style.position="absolute";container.style.top="0px";container.style.left="0px";var target_element=document.getElementsByTagName("body")[0];if(typeof(target_element)=="undefined"||target_element==null)
return false;var html=sb.toString();target_element.appendChild(container);container.innerHTML=html;this.movieElement=document.getElementById(this.movieName);};SWFUpload.prototype._getFlashVars=function(){var sb=new stringBuilder();sb.append("uploadScript="+this.getSetting("upload_script"));sb.append("&allowedFiletypesDescription="+this.getSetting("allowed_filetypes_description"))
sb.append("&flashLoadedCallback="+this.getSetting("flash_loaded_callback"));sb.append("&uploadFileQueuedCallback="+this.getSetting("upload_file_queued_callback"));sb.append("&uploadFileStartCallback="+this.getSetting("upload_file_start_callback"));sb.append("&uploadProgressCallback="+this.getSetting("upload_progress_callback"));sb.append("&uploadFileCompleteCallback="+this.getSetting("upload_file_complete_callback"));sb.append("&uploadQueueCompleteCallback="+this.getSetting("upload_queue_complete_callback"));sb.append("&uploadDialogCancelCallback="+this.getSetting("upload_dialog_cancel_callback"));sb.append("&uploadFileErrorCallback="+this.getSetting("upload_file_error_callback"));sb.append("&uploadFileCancelCallback="+this.getSetting("upload_file_cancel_callback"));sb.append("&uploadQueueCompleteCallback="+this.getSetting("upload_queue_complete_callback"));sb.append("&autoUpload="+this.getSetting("auto_upload"));sb.append("&allowedFiletypes="+this.getSetting("allowed_filetypes"));sb.append("&maximumFilesize="+this.getSetting("allowed_filesize"));return sb.toString();}
SWFUpload.prototype.flashLoaded=function(bool){this.loadUI();if(this.debug)
SWFUpload.debug("Flash called home and is ready.");};SWFUpload.prototype.loadUI=function(){if(this.getSetting("target")!=""&&this.getSetting("target")!="fileinputs"){var instance=this;var target=document.getElementById(this.getSetting("target"));var browselink=document.createElement("a");browselink.className=this.getSetting("browse_link_class");browselink.id=this.movieName+"BrowseBtn";browselink.href="javascript:void(0);";browselink.onclick=function(){instance.browse();return false;}
browselink.innerHTML=this.getSetting("browse_link_innerhtml");target.innerHTML="";target.appendChild(browselink);if(this.getSetting("auto_upload")==false){var uploadlink=document.createElement("a");uploadlink.className=this.getSetting("upload_link_class");uploadlink.id=this.movieName+"UploadBtn";uploadlink.href="#";uploadlink.onclick=function(){instance.upload();return false;}
uploadlink.innerHTML=this.getSetting("upload_link_innerhtml");target.appendChild(uploadlink);}}};SWFUpload.debug=function(value){if(window.console)
console.log(value);else
alert(value);}
SWFUpload.prototype.addSetting=function(name,value,default_value){return this.settings[name]=(typeof(value)=="undefined"||value==null)?default_value:value;};SWFUpload.prototype.getSetting=function(name){return(typeof(this.settings[name])=="undefined")?null:this.settings[name];};SWFUpload.prototype.browse=function(){this.movieElement.browse();};SWFUpload.prototype.upload=function(){this.movieElement.upload();}
SWFUpload.prototype.cancelFile=function(file_id){this.movieElement.cancelFile(file_id);};SWFUpload.prototype.cancelQueue=function(){this.movieElement.cancelQueue();};SWFUpload.prototype.debugSettings=function(){var sb=new stringBuilder();sb.append("----- DEBUG SETTINGS START ----\n");sb.append("ID: "+this.movieElement.id+"\n");for(var key in this.settings)
sb.append(key+": "+this.settings[key]+"\n");sb.append("----- DEBUG SETTINGS END ----\n");sb.append("\n");var res=sb.toString();SWFUpload.debug(res);};function stringBuilder(join){this._strings=new Array;this._join=(typeof join=="undefined")?"":join;stringBuilder.prototype.append=function(str){this._strings.push(str);};stringBuilder.prototype.toString=function(){return this._strings.join(this._join);};};
