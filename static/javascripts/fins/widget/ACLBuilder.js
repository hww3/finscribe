
dojo.provide("fins.widget.ACLBuilder");

dojo.require("dojo.widget.*");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.style");

fins.widget.ACLBuilder = function(){

    dojo.widget.HtmlWidget.call(this);

    this.added = new Array();
    this.removed = new Array();

    this.originalRules = new dojo.collections.ArrayList();
    this.deletedRules = new dojo.collections.ArrayList();
    this.newRules = new dojo.collections.ArrayList();

    this.builderNode = null;
    this.builderFromContainerNode = null;
    this.builderControlContainerNode = null;
    this.builderToContainerNode = null;

    this.ruleAppliesList = null;
    this.fullRule = null;

    this.newButton = null;
    this.editButton = null;
    this.deleteButton = null;
    this.saveButton = null;
    this.cancelButton = null;

    this.fromRulesList = null;
    this.toGroupList = null;
    this.toUserList = null;

    this.rule_groups_div = null;
    this.rule_users_div = null;

    this.rule_radio_user = null;
    this.rule_radio_group = null;
    this.rule_radio_allusers = null;
    this.rule_radio_owner = null;
    this.rule_radio_anonymous = null;

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

    this.editRule = function()
    {

      var sel = this.fromRulesList.selectedIndex;

      if(sel == -1)
      {
        alert("error: no item selected!");
        return;
      }
      
      var rulejson = this.originalRules.item(sel);
      if(!rulejson || rulejson == "")
      {
        alert("invalid rule json!");
        return;
      }

      var rule = dojo.json.evalJSON(rulejson);


      this.fromRulesList.disabled = 1;
      this.enableRule();
      this.populateRule(rule);

    }

    this.populateRule = function(rule)
    {
      this.updateRuleApplies(rule);
      this.updateRulePermissions(rule);
     
      this.saveButton.disabled = 0;
      this.editButton.disabled = 1;
      this.deleteButton.disabled = 1;
      this.newButton.disabled = 1;

    }

    this.updateRulePermissions = function(rule)
    {
      if(rule["browse"])
        this.rule_xmit_browse.checked = 1;
      if(rule["read"])
        this.rule_xmit_read.checked = 1;
      if(rule["version"])
        this.rule_xmit_version.checked = 1;
      if(rule["write"])
        this.rule_xmit_write.checked = 1;
      if(rule["delete"])
        this.rule_xmit_delete.checked = 1;
      if(rule["comment"])
        this.rule_xmit_comment.checked = 1;
      if(rule["post"])
        this.rule_xmit_post.checked = 1;
      if(rule["lock"])
        this.rule_xmit_lock.checked = 1;
    }

    this.updateRuleApplies = function(rule)
    {
      var i;
      var c = rule.class;
      for(i=0; i<this.ruleAppliesList.length; i++)
      {
        if(this.ruleAppliesList.options[i].value == c)
        {
          this.ruleAppliesList.selectedIndex = i;
          this.ruleAppliesChanged();
          break;
        }
      }

      if(c == "group")
      {
        var g;
        for(g = 0; g < this.toGroupList.options.length; g++)
        {
          if(this.toGroupList.options[g].value == rule.group)
          {
             this.toGroupList.selectedIndex = g;
             break;
          }
        }
      }
      else if(c == "user")
      {
        var u;
        for(u = 0; u < this.toUserList.options.length; u++)
        {
          if(this.toUserList.options[u].value == rule.user)
          {
             this.toUserList.selectedIndex = u;
             break;
          }
        }
      }
    }

    this.deleteRule = function()
    {
      var s = this.fromRulesList.selectedIndex;


      this.deletedRules.add(this.originalRules.item(s));      
      this.originalRules.removeAt(s);
      this.fromRulesList.options[s] = null;
      this.fromRulesList.selectedIndex = -1;
      this.editButton.disabled = 1;   
      this.deleteButton.disabled = 1;   
      this.fullRule.innerHTML = "ACL Rule Deleted.";
    }

    this.saveRule = function()
    {
      this.saveButton.disabled = 1;
      this.editButton.disabled = 0;
      this.deleteButton.disabled = 0;
      this.newButton.disabled = 0;
      this.fromRulesList.disabled = 0;
    }

    this.cancelRule = function()
    {
      this.saveButton.disabled = 1;
      this.editButton.disabled = 0;
      this.deleteButton.disabled = 0;
      this.newButton.disabled = 0;
      this.fromRulesList.disabled = 0;
      this.resetRule();
    }

    this.resetRule = function()
    {
      this.ruleEnableOwner();

      this.ruleAppliesList.disabled = 1;

      this.rule_xmit_browse.checked = 0;
      this.rule_xmit_read.checked = 0;
      this.rule_xmit_version.checked = 0;
      this.rule_xmit_write.checked = 0;
      this.rule_xmit_delete.checked = 0;
      this.rule_xmit_comment.checked = 0;
      this.rule_xmit_post.checked = 0;
      this.rule_xmit_lock.checked = 0;

      this.rule_xmit_browse.disabled = 1;
      this.rule_xmit_read.disabled = 1;
      this.rule_xmit_version.disabled = 1;
      this.rule_xmit_write.disabled = 1;
      this.rule_xmit_delete.disabled = 1;
      this.rule_xmit_comment.disabled = 1;
      this.rule_xmit_post.disabled = 1;
      this.rule_xmit_lock.disabled = 1;
    }

    this.enableRule = function()
    {
      this.ruleEnableOwner();

      this.ruleAppliesList.disabled = 0;

      this.rule_xmit_browse.checked = 0;
      this.rule_xmit_read.checked = 0;
      this.rule_xmit_version.checked = 0;
      this.rule_xmit_write.checked = 0;
      this.rule_xmit_delete.checked = 0;
      this.rule_xmit_comment.checked = 0;
      this.rule_xmit_post.checked = 0;
      this.rule_xmit_lock.checked = 0;

      this.rule_xmit_browse.disabled = 0;
      this.rule_xmit_read.disabled = 0;
      this.rule_xmit_version.disabled = 0;
      this.rule_xmit_write.disabled = 0;
      this.rule_xmit_delete.disabled = 0;
      this.rule_xmit_comment.disabled = 0;
      this.rule_xmit_post.disabled = 0;
      this.rule_xmit_lock.disabled = 0;
    }

    this.ruleEnableUser = function()
    {
      this.rule_groups_div.style.display = 'none';
      this.rule_users_div.style.display = '';
      this.toGroupList.selectedIndex = -1;
      this.toUserList.disabled = 0;
      this.toGroupList.disabled = 1;
    }

    this.ruleEnableOwner = function()
    {
      this.ruleEnableOther();
    }

    this.ruleEnableAllUsers = function()
    {
      this.ruleEnableOther();
    }

    this.ruleEnableAnonymous = function()
    {
      this.ruleEnableOther();
    }

    this.ruleEnableGroup = function()
    {
      this.rule_users_div.style.display = 'none';
      this.rule_groups_div.style.display = '';
      this.toUserList.selectedIndex = -1;
      this.toGroupList.disabled = 0;
      this.toUserList.disabled = 1;
    }

    this.ruleEnableOther = function()
    {
      this.rule_users_div.style.display = 'none';
      this.rule_groups_div.style.display = 'none';
      this.toUserList.selectedIndex = -1;
      this.toGroupList.selectedIndex = -1;
      this.toGroupList.disabled = 1;
      this.toUserList.disabled = 1;
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

       this.editButton.disabled = 1;
       this.deleteButton.disabled = 1;
       this.saveButton.disabled = 1;

    }


    this.initialize = function()
    {
       this.resetRule();

      if(this.loadAvailableUsersFunction &&  dojo.lang.isFunction(this.loadAvailableUsersFunction))
      {
        var res = this.loadAvailableUsersFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.toUserList.options[this.toUserList.length] = new Option(res[i].name, res[i].value);
//          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableGroupsFunction &&  dojo.lang.isFunction(this.loadAvailableGroupsFunction))
      {
        var res = this.loadAvailableGroupsFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.toGroupList.options[this.toGroupList.length] = new Option(res[i].name, res[i].value);
//          this.original[this.original.length] = res[i].value;
        }
      }

      if(this.loadAvailableRulesFunction &&  dojo.lang.isFunction(this.loadAvailableRulesFunction))
      {
        var res = this.loadAvailableRulesFunction();
        for(var i = 0; i < res.length; i++)
        {
          this.fromRulesList.options[this.fromRulesList.length] = new Option(res[i].name, dojo.json.serialize(res[i].value));
          this.originalRules.add(dojo.json.serialize(res[i].value));
        }
      }

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

       for (var i = 0; i < this.fromRulesList.length; i++) {
	      if(this.fromRulesList.options[i].selected)
	      {
		    var n = 0;
                    var v = this.fromRulesList.options[i].value;

                for(var y = 0; y < this.toUserList.options.length; y++)
                {
                   if(this.toUserList.options[y].value == v)
                      n = 1; // already on the list
                }
     
                if(n==0)
  	          this.toUserList.options[this.toUserList.length] = new Option(this.fromRulesList.options[i].text, v);

                n = 1;

                    for(var q = 0; q < this.originalRules.count; q++)
                    {
               	       if(this.originalRules.item(q) == v) // already had it in our list
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
		  this.fromRulesList.options[toRemove[j]] = null;
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

                for(var y = 0; y < this.fromRulesList.options.length; y++)
                {
                   if(this.fromRulesList.options[y].value == v)
                      n = 1; // already on the list
                }
     
                if(n==0)
  	          this.fromRulesList.options[this.fromRulesList.length] = new Option(this.toUserList.options[i].text, v);

                n = 0;

                for(var q = 0; q < this.originalRules.count; q++)
                {
                   if(this.originalRules.item(q) == v) // already had it in our list
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
	
       sortSelect(this.fromRulesList);

		for(var j = toRemove.length-1; j >= 0; j--)
		  this.toUserList.options[toRemove[j]] = null;


	};
	
        this.ruleAppliesChanged = function()
        {
          var t = this.ruleAppliesList.options[this.ruleAppliesList.selectedIndex];

          var v = t.value;

          if(v=="group") this.ruleEnableGroup();
          else if(v=="user") this.ruleEnableUser();
          else if(v=="anonymous") this.ruleEnableAnonymous();
          else if(v=="all_users") this.ruleEnableAllUsers();
          else if(v=="owner") this.ruleEnableOwner();

        }

	this.fromChanged = function() {	
          var selectedItems = new Array();


          for (var i = 0; i < this.fromRulesList.length; i++) {
            if (this.fromRulesList.options[i].selected)
              selectedItems[selectedItems.length] = this.fromRulesList.options[i].value;
          }
          if(selectedItems.length == 0)
          {
            this.fullRule.innerHTML = "";
	    this.deleteButton.disabled = 1;
	    this.editButton.disabled = 1;
          }
          else
  	  {
            this.fullRule.innerHTML = this.fromRulesList.options[this.fromRulesList.selectedIndex].text;
            
dojo.debug(this.fromRulesList.options[this.fromRulesList.selectedIndex].text);
	    this.deleteButton.disabled = 0;
	    this.editButton.disabled = 0;
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

