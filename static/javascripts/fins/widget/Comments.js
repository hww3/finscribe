dojo.provide("fins.widget.Comments");

dojo.require("dojo.fx");
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
  myDiv: null,
  /* closure crap */
  onDisplay: 0,
  connectorOriginalHref: '',
  updating: 0,

  startup: function() {
 //   dojo.debug("Hello from comments");
    var connector = dojo.byId(this.connectorId);
    if (connector) {
      // Do this so that if the widget doesn't work then the original
      // fallback in the href works.
      this.connectorOriginalHref = connector.href;
      connector.href = '#';
      this.connect(connector, "onclick", this.click);
    }
   this.myDiv.style.visibility = 'hidden';
//    this.update();
  },

  click: function() {
//	alert("click!");
    if (!this.onDisplay) {
		this.update();
    }
  },

  update: function() {
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
	  dojo.fx.wipeIn({ node: widget.myDiv, duration:1000 }).play();
	  widget.onDisplay = 1;
	}
	widget.updating = 0;
	
    if (widget.refreshRate > 0) 
      setTimeout(widget.update, widget.refreshRate * 1000);
  }
});

