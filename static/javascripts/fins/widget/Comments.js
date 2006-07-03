dojo.provide("fins.widget.Comments");

dojo.require("dojo.widget.*");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.style");
dojo.require("dojo.lfx");
dojo.require("dojo.animation");

/* Call <div dojoType="Comments" refreshUrl="/exec/json/comments?id=34" connectorId="button-34" /> */

fins.widget.Comments = function() {

  /* Stuff for Dojo */
  dojo.widget.HtmlWidget.call(this);
  this.templatePath = dojo.uri.dojoUri("fins/widget/templates/Comments.html");
  this.templateCssPath = dojo.uri.dojoUri("fins/widget/templates/Comments.css");
  this.widgetType = "Comments";
  /* end */

  this.refreshUrl = '';
  this.refreshRate = 30;
  this.connectorId = '';
  this.myDiv = null;
  /* closure crap */
  var _this = this;
  this.onDisplay = 0;
  this.connectorOriginalHref = '';
  this.updating;

  this.initialize = function() {
    dojo.debug("Hello from comments");
    var connector = document.getElementById(this.connectorId);
    if (connector) {
      // Do this so that if the widget doesn't work then the original
      // fallback in the href works.
      this.connectorOriginalHref = connector.href;
      connector.href = '#';
      dojo.event.connect(connector, "onlick", this.click);
    }
    this.myDiv.style.visibility = 'hidden';
    this.update();
  }

  this.click = function() {
    if (!this.onDisplay) {
      dojo.lfx.wipeIn(this.myDiv, 1000);
    }
  }

  this.update = function() {
    if (!this.updating) {
      var bindArgs = { 
	url : _this.refreshUrl,
	mimetype: "text/plain",
	sync : "false",
	error : function(type, errObj) {},
	load : _this._update
      };
      _this.updating = dojo.io.bind(bindArgs);
    }
  }

  this._update = function(type, data, evt) {
    this.myDiv.innerHTML = data.toString();
    if (this.refreshRate > 0) 
      setTimeout(this.update, this.refreshRate * 1000);
  }

};

dojo.inherits(dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:Comments");
