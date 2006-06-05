
dojo.provide("fins.widget.ACLBuilder");

dojo.require("dojo.widget.*");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.style");

fins.widget.ACLBuilder = function(){

    dojo.widget.HtmlWidget.call(this);

    this.added = new Array();
    this.removed = new Array();

    this.original = [];

    this.builderNode = null;
    this.builderFromContainerNode = null;
    this.builderControlContainerNode = null;
    this.builderToContainerNode = null;

    this.newButton = null;
    this.editButton = null;
    this.deleteButton = null;
    this.saveButton = null;

    this.fromRulesList = null;
    this.toGroupList = null;
    this.toUserList = null;

    this.rule_xmit_browse = null;
    this.rule_xmit_read = null;
    this.rule_xmit_version = null;
    this.rule_xmit_write = null;
    this.rule_xmit_delete = null;
    this.rule_xmit_comment = null;
    this.rule_xmit_post = null;
    this.rule_xmit_lock = null;

    // this is a div containing the current rule as built.
    this.current_rule_storage = null;

    // functions that return an array of valid users and groupss
    this.loadAvailableUsersFunction = "";
    this.loadAvailableGroupsFunction = "";
    this.loadAvailableRulesFunction = "";

    this.addsId = "";
    this.removesId = "";

    this.addsElement = null;
    this.removesElement = null;

    this.ruleEnableUser = function()
    {
      this.toGroupList.selectedIndex = -1;
      this.toUserList.disabled = 0;
      this.toGroupList.disabled = 1;
    }

    this.ruleEnableGroup = function()
    {
      this.toUserList.selectedIndex = -1;
      this.toGroupList.disabled = 0;
      this.toUserList.disabled = 1;
    }

    this.ruleDisable = function()
    {
      this.builderToContainerNode.disabled = 1;
      
    }

    this.ruleEnable = function()
    {
      this.builderToContainerNode.disabled = 0;
      
    }

     this.fillInTemplate = function() {
                if (this.loadAvailableGroupsFunction) {
                        this.loadAvailableGroupsFunction = dj_global[this.loadAvailableGroupsFunction];
                }
                if (this.loadAvailableUsersFunction) {
                        this.loadAvailableUsersFunction = dj_global[this.loadAvailableUsersFunction];
                }
                if (this.loadAvailableRulesFunction) {
                        this.loadAvailableRulesFunction = dj_global[this.loadAvailableRulesFunction];
                }

        }


    this.initialize = function()
    {
      if(this.loadAvailableUsersFunction &&  dojo.lang.isFunction(this.loadAvailableUsersFunction))
      {
        var res = this.loadAvailableUsersFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.toUserList.options[this.toUserList.length] = new Option(res[i].name, res[i].value);
          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableGroupsFunction &&  dojo.lang.isFunction(this.loadAvailableGroupsFunction))
      {
        var res = this.loadAvailableGroupsFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.toGroupList.options[this.toGroupList.length] = new Option(res[i].name, res[i].value);
          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableRulesFunction &&  dojo.lang.isFunction(this.loadAvailableRulesFunction))
      {
        var res = this.loadAvailableRulesFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.fromRulesList.options[this.fromRulesList.length] = new Option(res[i].name, dojo.json.serialize(res[i].value));
          this.original[this.original.length] = dojo.json.serialize(res[i].value);
        }
      }

      this.ruleDisable();

/*
      if(this.loadAvailableFunction &&  dojo.lang.isFunction(this.loadAvailableFunction))
      {
        var res = this.loadAvailableFunction();
        for(var i = 0; i < res.length; i++)
        {
          var l = 0;

          for(var z = 0; z < this.toUserList.options.length; z++)
          {
            if(this.toUserList.options[z].value == res[i].value)
               l = 1;
          }

          if(!l)
            this.fromList.options[this.fromList.length] = new Option(res[i].name, res[i].value);
        }
      }

      if(this.addsId)
        this.addsElement = document.getElementById(this.addsId);
      if(this.removesId)
        this.removesElement = document.getElementById(this.removesId);

      dojo.debug("removes element: " + this.removesId);
      dojo.debug("removes element: " + this.removesElement);
                        if((this.addsElement && this.addsElement.form) || 
                                  (this.removesElement && this.removesElement.form)){
				dojo.debug("hooking into the form.");
                                dojo.event.connect(this.addsElement.form, "onsubmit",
                                        dojo.lang.hitch(this, function(){
                                                this.addsElement.value = this.getAdded();
                                                this.removesElement.value = this.getRemoved();
                                        })
                                );
                        }

*/

    }

	function hasOptions(obj) {
		if (obj!=null && obj.options!=null) { return true; }
		return false;
		}

	function sortSelect(obj) {
		var o = new Array();
		if (!hasOptions(obj)) { return; }
		for (var i=0; i<obj.options.length; i++) {
			o[o.length] = new Option( obj.options[i].text, obj.options[i].value, obj.options[i].defaultSelected, obj.options[i].selected) ;
			}
		if (o.length==0) { return; }
		o = o.sort( 
			function(a,b) { 
				if ((a.text+"") < (b.text+"")) { return -1; }
				if ((a.text+"") > (b.text+"")) { return 1; }
				return 0;
				} 
			);

		for (var i=0; i<o.length; i++) {
			obj.options[i] = new Option(o[i].text, o[i].value, o[i].defaultSelected, o[i].selected);
			}

		}


    this.addItem = function() {

       var toRemove = new Array();

       for (var i = 0; i < this.fromList.length; i++) {
	      if(this.fromList.options[i].selected)
	      {
		    var n = 0;
                    var v = this.fromList.options[i].value;

                for(var y = 0; y < this.toUserList.options.length; y++)
                {
                   if(this.toUserList.options[y].value == v)
                      n = 1; // already on the list
                }
     
                if(n==0)
  	          this.toUserList.options[this.toUserList.length] = new Option(this.fromList.options[i].text, v);

                n = 1;

                    for(var q = 0; q < this.original.length; q++)
                    {
               	       if(this.original[q] == v) // already had it in our list
                       n = 0;
                    }

                    if(n)
                      this.added[this.added.length] =  v;
  
                    // we also need to remove any entry for this element from the "removed" column.
                    for(var z = this.removed.length; z >= 0; z--)
                    {
			if(this.removed[z] == v) this.removed[z] = null;
                    }
		    toRemove[toRemove.length] = i;
          }
       }

       sortSelect(this.toUserList);

		for(var j = toRemove.length-1; j >= 0; j--)
		  this.fromList.options[toRemove[j]] = null;
    };

    this.getAdded = function(){
      var a = new Array();

      for(var i = 0; i < this.added.length; i++)
        if(this.added[i] != null)
          a[a.length] = this.added[i];          

      return a;
    };

    this.getRemoved = function(){
      var a = new Array();

      for(var i = 0; i < this.removed.length; i++)
        if(this.removed[i] != null)
          a[a.length] = this.removed[i];          

      return a;
    };

    this.Q = function() {
	  	var str = "";
	    str = str + "added: " + this.getAdded();

	    str = str + "removed: " + this.getRemoved();

         alert(str);

    };

    this.removeItem = function() { 
	   
	   var toRemove = new Array();
	
	   for (var i = 0; i < this.toUserList.length; i++) {

	      if(this.toUserList.options[i].selected)
	      {
                var n = 0;
                var v = this.toUserList.options[i].value;

                for(var y = 0; y < this.fromList.options.length; y++)
                {
                   if(this.fromList.options[y].value == v)
                      n = 1; // already on the list
                }
     
                if(n==0)
  	          this.fromList.options[this.fromList.length] = new Option(this.toUserList.options[i].text, v);

                n = 0;

                for(var q = 0; q < this.original.length; q++)
                {
                   if(this.original[q] == v) // already had it in our list
                   n = 1;
                }

            if(n)
              this.removed[this.removed.length] = v;
  
          for(var z = this.added.length; z >= 0; z--)
            {
				if(this.added[z] == v) this.added[z] = null;
            }

          	toRemove[toRemove.length] = i;
		  }
       }
	
       sortSelect(this.fromList);

		for(var j = toRemove.length-1; j >= 0; j--)
		  this.toUserList.options[toRemove[j]] = null;


	};
	
	this.fromChanged = function() {
		
		
       var selectedItems = new Array();

       for (var i = 0; i < this.fromList.length; i++) {
         if (this.fromList.options[i].selected)
            selectedItems[selectedItems.length] = this.fromList.options[i].value;
       }
       if(selectedItems.length == 0)
       {
	       this.addButton.disabled = true;
       }
       else
       {
	       this.addButton.disabled = false;
       }

     };
	
	this.toChanged = function() {
		
       var selectedItems = new Array();

       for (var i = 0; i < this.toUserList.length; i++) {
         if (this.toUserList.options[i].selected)
            selectedItems[selectedItems.length] = this.toUserList.options[i].value;
       }
       if(selectedItems.length == 0)
       {
	       this.removeButton.disabled = true;
       }
       else
       {
	       this.removeButton.disabled = false;
       }

     };


	this.widgetType = "ACLBuilder";

	this.labelPosition = "top";

	this.templatePath =  dojo.uri.dojoUri("fins/widget/templates/ACLBuilder.html");
	this.templateCssPath = dojo.uri.dojoUri("fins/widget/templates/ACLBuilder.css");

};



dojo.inherits(fins.widget.ACLBuilder, dojo.widget.HtmlWidget);

dojo.widget.tags.addParseTreeHandler("dojo:aclbuilder");

