dojo.require("dojo.html");
dojo.require("dojo.fx.*");

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
    url:        "/exec/actions/" + o,
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
alert("no div!\n");
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
//      this.timer = setTimeout("document.getElementById('"+menuLayers.activeMenuID+"').style.visibility = 'hidden'", 200);
//      this.timer = setTimeout("Effect.Fade('"+menuLayers.activeMenuID+"')", 200);
//      this.timer = setTimeout("dojo.graphics.htmlEffects.fadeOut(document.getElementById('"+menuLayers.activeMenuID+"'), 200)", 200);
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
//    this.timer = setTimeout("document.getElementById('" + menuLayers.activeMenuID + "').style.visibility = 'visible'", 200);
//    this.timer = setTimeout("Effect.Appear('" + menuLayers.activeMenuID + "')", 200);
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
