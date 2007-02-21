dojo.provide("fins.widget.Folder");

dojo.require("dojo.widget.*");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.html.style");
dojo.require("dojo.lfx.*");
dojo.require("dojo.animation");

/* Call <div dojoType="Comments" refreshUrl="/exec/json/comments?id=34" connectorId="button-34" /> */

fins.widget.Folder = function() {

  this.templatePath = dojo.uri.dojoUri("fins/widget/templates/Folder.html");
  this.templateCssPath = dojo.uri.dojoUri("fins/widget/templates/Folder.css");
  this.widgetType = "Folder";

  this.plussrc =  dojo.uri.dojoUri("fins/widget/templates/Icon-UnFold.png");
  this.minussrc =  dojo.uri.dojoUri("fins/widget/templates/Icon-Fold.png");

  this.myImg = null;
  this.myDiv = null;
  this.myLink = null;
  this.origDiv = null;

  this.onDisplay = 0;

  dojo.widget.HtmlWidget.call(this);

  this.fillInTemplate = function(args, frag)
  {
    var te = this.getFragNodeRef(frag);
    this.origDiv = te;
    this.myImg.src=this.plussrc;
    this.myLink.innerHTML="Click to Show Contents";
    this.myDiv.innerHTML = te.innerHTML;
    dojo.html.hide(this.myDiv);
  };

  this.click = function() {
    if (!this.onDisplay) {
      dojo.lfx.html.wipeIn(this.myDiv, 10).play();
      this.onDisplay = 1;
      this.myImg.src=this.minussrc;
      this.myLink.innerHTML="Click to Hide Contents";
    }
    else
    {
      dojo.lfx.html.wipeOut(this.myDiv, 10).play();
      this.onDisplay = 0;
      this.myImg.src=this.plussrc;
      this.myLink.innerHTML="Click to Show Contents";
    }
  };

};

dojo.inherits(fins.widget.Folder, dojo.widget.HtmlWidget);
