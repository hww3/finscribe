dojo.provide("fins.widget.ObjectTreeContextMenu");

dojo.require("dojo.widget.*");
dojo.require("dojo.widget.TreeContextMenuV3");
dojo.require("fins.widget.ObjectTreeContextMenuItem");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.html.style");
dojo.require("dojo.lfx");

fins.widget.ObjectTreeContextMenu = function() {

  /* Stuff for Dojo */
  dojo.widget.TreeContextMenuV3.call(this);
  this.widgetType = "ObjectTreeContextMenu";
  /* end */
  this.open = function(x, y, parentMenu, explodeSrc){

    dojo.debug("x: " + x + " y: " + y + " parentMenu: " + parentMenu + " explodeSrc: " + explodeSrc);
    var myNode=this.getTreeNode();
    dojo.debug("selected tree node: " + myNode);
    var _this = this;
    this.destroyChildren();

    var bindArgs = {
    sync: true,
    url:        myNode.props_url,
    mimetype:   "text/plain",
    error:      function(type, errObj){
    },
    load:     function(type, data, evt){
        // handle successful response here

        res = dojo.json.evalJson(data.toString());
        res = res.data;

        for(var x in res)
        {
	  var y = res[x];
          var _href = y.href;
	  dojo.debug("adding menu item: " + res[x].title + " at " + res[x].href);
          var newItem=dojo.widget.createWidget("fins:ObjectTreeContextMenuItem", 
                { caption: y.title,
                  href: _href,
                  onClick: make_cb(_href)
                } );
          if(y.enabled != 1) { newItem.setDisabled(true); }
          _this.addChild(newItem); 
        }

        _href = 0;
     }

   };

   var make_cb = function(h) { return function(){ dojo.debug(h); window.location = h; }; };

// dispatch the request
    var requestObj = dojo.io.bind(bindArgs);



    var result = dojo.widget.PopupMenu2.prototype.open.apply(this, arguments);

               for(var i=0; i< this.children.length; i++) {
                        /* notify children */
                        if (this.children[i].menuOpen) {
                                this.children[i].menuOpen(this.getTreeNode());
                        }
                }

    return result;
  };



};

dojo.inherits(fins.widget.ObjectTreeContextMenu, dojo.widget.TreeContextMenuV3);
