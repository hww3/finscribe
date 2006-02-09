dojo.require("dojo.html");
dojo.require("dojo.fx.*");
dojo.require("dojo.widget.html.DatePicker");
/*************************************************************************

  dw_viewport.js
  version date Nov 2003
  
  This code is from Dynamic Web Coding 
  at http://www.dyn-web.com/
  Copyright 2003 by Sharon Paine 
  See Terms of Use at http://www.dyn-web.com/bus/terms.html
  Permission granted to use this code 
  as long as this entire notice is included.

*************************************************************************/  
  
var viewport = {
  getWinWidth: function () {
    this.width = 0;
    if (window.innerWidth) this.width = window.innerWidth - 18;
    else if (document.documentElement && document.documentElement.clientWidth) 
  		this.width = document.documentElement.clientWidth;
    else if (document.body && document.body.clientWidth) 
  		this.width = document.body.clientWidth;
  },
  
  getWinHeight: function () {
    this.height = 0;
    if (window.innerHeight) this.height = window.innerHeight - 18;
  	else if (document.documentElement && document.documentElement.clientHeight) 
  		this.height = document.documentElement.clientHeight;
  	else if (document.body && document.body.clientHeight) 
  		this.height = document.body.clientHeight;
  },
  
  getScrollX: function () {
    this.scrollX = 0;
  	if (typeof window.pageXOffset == "number") this.scrollX = window.pageXOffset;
  	else if (document.documentElement && document.documentElement.scrollLeft)
  		this.scrollX = document.documentElement.scrollLeft;
  	else if (document.body && document.body.scrollLeft) 
  		this.scrollX = document.body.scrollLeft; 
  	else if (window.scrollX) this.scrollX = window.scrollX;
  },
  
  getScrollY: function () {
    this.scrollY = 0;    
    if (typeof window.pageYOffset == "number") this.scrollY = window.pageYOffset;
    else if (document.documentElement && document.documentElement.scrollTop)
  		this.scrollY = document.documentElement.scrollTop;
  	else if (document.body && document.body.scrollTop) 
  		this.scrollY = document.body.scrollTop; 
  	else if (window.scrollY) this.scrollY = window.scrollY;
  },
  
  getAll: function () {
    this.getWinWidth(); this.getWinHeight();
    this.getScrollX();  this.getScrollY();
  }
  
}


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
    viewport.getAll();
    menuLayers.position(mnu);
  },
  
  hide: function() {
    this.clearTimer();
    if (menuLayers.activeMenuID && document.getElementById) 
      this.timer = setTimeout("dojo.fx.html.implode(document.getElementById('"+menuLayers.activeMenuID+"'), menuLayers.item, 200)", 200);
      return false;
  },
  
  position: function(mnu) {
    var x = menuLayers.pageX? menuLayers.pageX: menuLayers.clientX + viewport.scrollX;
    var y = menuLayers.pageY? menuLayers.pageY: menuLayers.clientY + viewport.scrollY;
    if ( x + mnu.offsetWidth + this.offX > viewport.width + viewport.scrollX )
      x = x - mnu.offsetWidth - this.offX;
    else x = x + this.offX;
  
    if ( y + mnu.offsetHeight + this.offY > viewport.height + viewport.scrollY )
      y = ( y - mnu.offsetHeight - this.offY > viewport.scrollY )? y - mnu.offsetHeight - this.offY : viewport.height + viewport.scrollY - mnu.offsetHeight;
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

function showLogin(id, o, e, item)
{
  menuLayers.show(id, o, e, item, 
     function(){
        var elem = document.getElementById("UserName");
           if(elem.id =="UserName"){ elem.focus(); }
     }
  );
}

function hideLogin(id)
{
  return menuLayers.hide();
}

function postBlog(id, obj, formid, noanim)
{
var bindArgs = { 
    url:        "/exec/post/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
        var d = document.getElementById(id);
        if(!d)
          return;
        d.innerHTML = data.toString();
     if(!noanim)
       dojo.fx.html.wipeIn(d, 500);
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
	hideBlog(id, obj);
	window.location = window.location + "?refresh=1";
    
}

function hideBlog(id, obj)
{
//         d.innerHTML = data.toString();
   var d = document.getElementById(id);
   if(d)
   {
	  dojo.fx.html.wipeOut(d, 500);
   }
   return false;
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
        var d = document.getElementById("postComment_contents");
        
        if(!d)
          return;
        else
        {
          if(data.toString() != "OK")
            d.innerHTML = data.toString();
          else
          {
            hidePostComment();
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
        var d = document.getElementById("postComment_contents");
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
    this.initColor = "#FFFFC0";
    this.buildRendering = function(args, frag) {
        var o = frag["dojo:yellowfade"]["nodeRef"];
        dojo.graphics.htmlEffects.colorFadeIn(o, 
dojo.graphics.color.extractRGB(this.initColor), this.duration, this.delay);
    }
}
dj_inherits(dojo.widget.HtmlYellowFade, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:yellowfade");



function showPostComment(obj, elem) {
viewport.getAll()
var block = document.getElementById("postComment");
if (!block) {
var body = dojo.html.body();
block = document.createElement("div");
block.setAttribute("id", "postComment");
block.className = "rounded";
block.style.display = "none";
block.style.position = "absolute";
block.style.width = "80%";
//block.style.padding;
block.style.zIndex = "400";
block.style.background = "Window";
block.style.backgroundColor = "white";
block.style.border = "1px solid #efefef";
block.style.opacity = ".9";
block.style.filter = "alpha(opacity=90)";

var inputField = elem;
//var offsets = cumulativeOffset(inputField);
block.style.top = viewport.scrollY + 15;
block.style.left = viewport.scrollX + 15;;
body.appendChild(block);

}

var block2 = document.getElementById("postComment_contents");

if(!block2)
{
  block2 = document.createElement("div");
  block2.style.padding="20px";
  block2.setAttribute("id", "postComment_contents");
  block.appendChild(block2);
}

var bindArgs = { 
    url:        "/exec/comments/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
     block2.innerHTML = data.toString();
     make_corners();
     dojo.fx.html.fadeShow(block, 200);
    }

  };

// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
   
}


function showEditCategory(obj) {
viewport.getAll();
var block = document.getElementById("editCategory");
if (!block) {
var body = dojo.html.body();
block = document.createElement("div");
block.setAttribute("id", "editCategory");
block.className = "rounded";
block.style.display = "none";
block.style.position = "absolute";
block.style.width = "60%";
//block.style.padding;
block.style.zIndex = "400";
block.style.background = "Window";
block.style.backgroundColor = "white";
block.style.border = "1px solid #efefef";
block.style.opacity = ".9";
block.style.filter = "alpha(opacity=90)";

//var offsets = cumulativeOffset(inputField);
block.style.top = viewport.scrollY + 15;
block.style.left = viewport.scrollX + 15;;
body.appendChild(block);

}

var block2 = document.getElementById("editCategory_contents");

if(!block2)
{
  block2 = document.createElement("div");
  block2.style.padding="20px";
  block2.setAttribute("id", "editCategory_contents");
  block.appendChild(block2);
}

var bindArgs = { 
    url:        "/exec/editcategory/" + obj,  
    content: {ajax: "1"},
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:      function(type, data, evt){
        // handle successful response here
     block2.innerHTML = data.toString();
     make_corners();
     dojo.fx.html.fadeShow(block, 200);
    }

  };

// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);
   
}

function editCategory(obj, formid, a) {

var block2 = document.getElementById("editCategory_contents");

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

function hidePostComment()
{
  var d = document.getElementById("postComment");
  if(d)
  {
    dojo.fx.html.fadeHide(d, 200);
    d.parentNode.removeChild(d);
  }
  return false;	
}

function hideEditCategory()
{
  var d = document.getElementById("editCategory");
  if(d)
  {
    dojo.fx.html.fadeHide(d, 200);
    d.parentNode.removeChild(d);
  }
  return false;	
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
