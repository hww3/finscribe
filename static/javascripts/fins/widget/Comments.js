dojo.provide("fins.widget.Comments");

dojo.require("dojo.fx");
dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
/* Call <div dojoType="fins.widget.Comments" refreshUrl="/exec/json/comments?id=34" connectorId="button-34" /> */

dojo.declare("fins.widget.Comments", [dijit._Widget, dijit._Templated], 
{

  /* Stuff for Dojo */
  templateString: dojo.cache("fins.widget", "templates/Comments.html"),
  widgetType: "Comments",
  /* end */

  refreshUrl: '',
  refreshRate: 30,
  connectorId: '',
  myRoot: null,
  myDiv: null,
  myLinkDiv: null,
  myLink: null,
  targetName: '',
  /* closure crap */
  onDisplay: 0,
  connectorOriginalHref: '',
  showLink: '',
  updating: 0,

  startup: function() {
 //   dojo.debug("Hello from comments");
//alert("have target " + this.targetName);
    this.myLink.href="#" + this.targetName;
    if(this.showLink != '')
    {
 	  dojo.fx.wipeIn({ node: this.myLinkDiv, duration:10 }).play();
    }
    var connector = dojo.byId(this.connectorId);
    if (connector) {
      // Do this so that if the widget doesn't work then the original
      // fallback in the href works.
      this.connectorOriginalHref = connector.href;
      connector.href = '#' + (this.targetName);
      this.connect(connector, "onclick", this.click);
    }
   this.myDiv.style.visibility = 'hidden';
//    this.update();
  },

  click: function() {
	//alert("click!");
    if (!this.onDisplay) {
		this.update();
    }
  },

  update: function() {
//alert("update!");
    if (!this.updating) {
      var bindArgs = { 
	url : this.refreshUrl,
	sync : "false",
	error : function(type, errObj) {},
	load : this._update,
	widget: this
      };
      this.updating = dojo.xhrGet(bindArgs);
    }
  },

  _update: function(data, evt) {
	var widget = this.widget;
    widget.myDiv.innerHTML = data;
	if(!widget.onDisplay)
	{
 	  dojo.fx.wipeOut({ node: widget.myLink, duration:100 }).play();
	  dojo.fx.wipeIn({ node: widget.myDiv, duration:1000 }).play();
	  widget.onDisplay = 1;
	}
	widget.updating = 0;
	
    if (widget.refreshRate > 0) 
      setTimeout(widget.update, widget.refreshRate * 1000);
  }
});

