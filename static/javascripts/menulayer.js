dojo.require("dojo.html");
dojo.require("dojo.fx.*");
dojo.require("dojo.widget.*");
dojo.require("dojo.widget.html.DatePicker");
dojo.require("dojo.widget.ResizableTextarea");
dojo.require("dojo.io.IframeIO");

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
  show: function(id, o, e, item, onLoad) {
    this.clientX = e.clientX;
    this.clientY = e.clientY;
    this.pageX = e.pageX;
    this.pageY = e.pageY;
    this.activeMenuID = id;
    this.item = item;
    this.onLoad = onLoad;

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
        if(menuLayers.onLoad)
        {
           menuLayers.onLoad();
           menuLayers.onLoad = null;
        }
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
      this.timer = setTimeout("dojo.fx.html.implode(document.getElementById('"+menuLayers.activeMenuID+"'), menuLayers.item, 200)", 200);
      return false;
  },
  
  position: function(mnu) {
    var x = menuLayers.pageX? menuLayers.pageX: menuLayers.clientX + dojo.html.getScrollLeft();
    var y = menuLayers.pageY? menuLayers.pageY: menuLayers.clientY + dojo.html.getScrollTop();
    if ( x + mnu.offsetWidth + this.offX > dojo.html.getViewportWidth() + dojo.html.getScrollLeft())
      x = x - mnu.offsetWidth - this.offX;
    else x = x + this.offX;
  
    if ( y + mnu.offsetHeight + this.offY > dojo.html.getViewportHeight() + dojo.html.getScrollTop() )
      y = ( y - mnu.offsetHeight - this.offY > dojo.html.getScrollTop() )? y - mnu.offsetHeight - 
this.offY : dojo.html.getViewportHeight() + dojo.html.getScrollTop() - mnu.offsetHeight;
    else y = y + this.offY;
    mnu.style.left = x + "px"; mnu.style.top = y + "px";
      this.timer = setTimeout("dojo.fx.html.explode(menuLayers.item, document.getElementById('"+menuLayers.activeMenuID+"'), 200)", 200);
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
//    dojo.fx.html.wipeOut(document.getElementById(div), 100);

    var bindArgs = {
    url:         "/exec/getcomments/" + path,
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
      document.getElementById(div).innerHTML = data.toString();
      dojo.fx.html.wipeIn(document.getElementById(div), 100);
    }
  };

    requestObj = dojo.io.bind(bindArgs);

  return false;
}


function openPostBlog(obj)
{
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
        dojo.graphics.htmlEffects.colorFadeIn(o, 
dojo.graphics.color.extractRGB(this.initColor), this.duration, this.delay);
    }
}
dj_inherits(dojo.widget.HtmlYellowFade, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:yellowfade");


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

function openLogin()
{
  openPopup("/exec/login", '300px', null, null, null, setinsert);
}

function setinsert()
{
 window.setTimeout('var elem = document.getElementById("UserName");if(elem){ elem.focus(); }', 300);
}

function openPopup(url, width, height, formid, action, loadfunc) {
  closePopup();

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
 	objOverlay.style.width = dojo.html.getViewportWidth() + dojo.html.getScrollLeft() + 10;
	objBody.insertBefore(objOverlay, null);
  }

	var arrayPageSize = getPageSize();
	var arrayPageScroll = getPageScroll();

	// set height of Overlay to take up whole page and show
	objOverlay.style.height = (arrayPageSize[1] + 'px');
	objOverlay.style.display = 'block';

var block = document.getElementById("popup");
if (!block) {
var body = dojo.html.body();
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

var bindArgs = { 
    url:        url,  
    content: {ajax: "1"},
    method: "POST",
    mimetype:   "text/plain",
    error:      function(type, errObj){
      alert("error");
    },
    load:      function(type, data, evt){
        // handle successful response here
     block2.innerHTML = data.toString();

     objOverlay.style.width = dojo.html.getViewportWidth() + dojo.html.getScrollLeft() + 10;
     var h = block.offsetHeight || block.style.pixelHeight || 
               (block.currentStyle && block.currentStyle.height) || block.height;

     if(h && dojo.lang.isNumber(h)) h = ((dojo.html.getViewportHeight()) - h) / 2
       else h = 20;
     var blockTop = dojo.html.getScrollTop() + h;
   
     h = block.offsetWidth || block.style.pixelWidth ||
               (block.currentStyle && block.currentStyle.width) || block.width;

     if(h && dojo.lang.isNumber(h)) h = ((dojo.html.getViewportWidth()) - h) / 2
       else h = 20;

     var blockLeft = dojo.html.getScrollLeft() + h;

		block.style.top = (blockTop < 0) ? "0px" : blockTop + "px";
		block.style.left = (blockLeft < 0) ? "0px" : blockLeft + "px";

     make_corners();
     dojo.fx.html.fadeShow(block, 200, function(){		
		arrayPageSize = getPageSize();
		objOverlay.style.width = (arrayPageSize[2] + 'px');
		objOverlay.style.height = (arrayPageSize[1] + 'px');

     if(loadfunc) loadfunc();
}
);
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
    dojo.fx.html.fadeHide(d, 200);
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
var body = dojo.html.body();
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
dojo.event.kwConnect({srcObj: picker,srcFunc:"onSetDate",targetObj: this, targetFunc:"setDateField",
once:true});
}
dojo.fx.html.fadeShow(block, 200);
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

        var date = dojo.widget.manager.getWidgetById("datePickerPicker").date;

        field.value = dojo.date.toString(date, "#yyyy-#MM-#dd");

    }

        function toggleCreated()
        {  

                var field = document.getElementById("createdDate");
                field.disabled = !field.disabled;
                if(!field.disabled)
                  showDatePicker();
       }
