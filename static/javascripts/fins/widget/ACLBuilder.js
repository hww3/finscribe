
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

    this.formNode = null;
    this.builderNode = null;
    this.builderFromContainerNode = null;
    this.builderControlContainerNode = null;
    this.builderToContainerNode = null;

    this.ruleChangedFlag = false;
    this.newRuleFlag = false;
    this.currentRuleId = null;
    this.currentRule = null;
    this.currentRuleIndex = null;

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

    this.xmitChanged = function(evt)
    {
//      var xmit = evt.target.name;    
//      dojo.debug(xmit);
      this.ruleChanged();
    }

    this.newRule = function()
    {
      this.fromRulesList.disabled = 1;
      this.newRuleFlag = true;
      this.enableRule();
    }

    this.editRule = function()
    {

      var sel = this.fromRulesList.selectedIndex;

      if(sel == -1)
      {
        alert("error: no item selected!");
        return;
      }
      
      var rule = this.originalRules.item(sel);
      this.currentRuleIndex = sel;

      if(!rule)
      {
        alert("invalid rule!");
        return;
      }

      this.fromRulesList.disabled = 1;
      this.enableRule();
      this.populateRule(rule);

    }

    this.populateRule = function(rule)
    {
      this.updateRuleApplies(rule);
      this.updateRulePermissions(rule);

      this.currentRuleId = rule.id;     
      this.currentRule = rule;

      this.saveButton.disabled = 1;
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
          this.ruleAppliesChangedInternal();
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

      var r = this.originalRules.item(s);

      // if we're a new rule, we won't be on the server yet, so we can just forget the rule.
      if(!r.isNew)
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
     
      this.saveRuleChanges();
      this.resetRule();
    }

    this.saveRuleChanges = function()
    {
      var r = this.currentRule;

      if(this.newRuleFlag)
        r = {};

      r.class = this.ruleAppliesList.options[this.ruleAppliesList.selectedIndex].value;

      r["browse"] = this.rule_xmit_browse.checked;
      r["read"] = this.rule_xmit_read.checked;
      r["version"] = this.rule_xmit_version.checked;
      r["write"] = this.rule_xmit_write.checked;
      r["delete"] = this.rule_xmit_delete.checked;
      r["post"] = this.rule_xmit_post.checked;
      r["comment"] = this.rule_xmit_comment.checked;
      r["lock"] = this.rule_xmit_lock.checked;

      if(r.class == "user")
      {
        r.user = this.toUserList.options[this.toUserList.selectedIndex].value;
        if(r.group) r.group = null;
      }

      else if(r.class == "group")
      {
        r.group = this.toGroupList.options[this.toGroupList.selectedIndex].value;
        if(r.user) r.user = null;
      }

      if(this.newRuleFlag)
      {
        r.isNew = 1;
        this.fromRulesList.options[this.fromRulesList.length] = new Option(this.describeRule(r), "0");
        this.originalRules.add(r);
        this.fullRule.innerHTML = "New ACL Rule Saved.";
      }
      else
      {
        // we can be editing a new, uncommitted rule. if so, it's still just a new rule.
        if(!r.isNew)
          r.isChanged = 1;
        r.id = this.currentRuleId;
        this.fromRulesList.options[this.currentRuleIndex].text = this.describeRule(r);
        this.fullRule.innerHTML = "ACL Rule Saved.";
      }

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

    this.describeRule = function(rule)
    {
      var res = "";
      var s = new String(rule.class);
      s = s.replace("_", " ");
      res += dojo.string.capitalize(s);

      if(rule.class == "user")
      {
        var u;
        for(u = 0; u < this.toUserList.options.length; u++)
        {
          if(this.toUserList.options[u].value == rule.user)
          {
             res = res + " " +  this.toUserList.options[u].text;
             break;
          }
        }
      }
      else if(rule.class == "group")
      {
        var g;
        for(g = 0; g < this.toGroupList.options.length; g++)
        {
          if((this.toGroupList.options[g].value) == rule.group)
          {
             res = res + " " + this.toGroupList.options[g].text;
             break;
          }
        }
      }

      res += ": ";

      var a = new dojo.collections.ArrayList();;

      if(rule["browse"])
         a.add("BROWSE");
      if(rule["read"])
         a.add("READ");
      if(rule["version"])
         a.add("VERSION");
      if(rule["write"])
         a.add("WRITE");
      if(rule["delete"])
         a.add("DELETE");
      if(rule["comment"])
         a.add("COMMENT");
      if(rule["post"])
         a.add("POST");
      if(rule["lock"])
         a.add("LOCK");

      return res + a.toArray().join(", ");
    }

    this.resetRule = function()
    {
      this.ruleEnableOwner();

      this.ruleAppliesList.selectedIndex = -1;

      this.currentRuleId = null;
      this.currentRuleIndex = null;
      this.currentRule = null;

      this.ruleAppliesList.disabled = 1;
      this.newRuleFlag = false;
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

      this.ruleChangedFlag = false;
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


    this.initialize = function(args, fragment)
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
          this.fromRulesList.options[this.fromRulesList.length] = new Option(this.describeRule(res[i].value), res[i].value.id);
          this.originalRules.add(res[i].value);
        }

      }

      var f = this.getFragNodeRef(fragment);
      if(f.form)
      {
              dojo.debug("hooking into the form.");
       	this.formNode = f;
                                dojo.event.connect(f.form, "onsubmit",
                                        dojo.lang.hitch(this, function(){
                                dojo.dom.insertAfter(this.formNode, this.domNode, 1); 
					  this.formNode.value=dojo.json.serialize({rules: this.originalRules.toArray(), deleted: this.deletedRules.toArray() });
                                        })
                                );

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

        this.ruleChanged = function()
        {
          this.ruleChangedFlag = true;
          this.saveButton.disabled = 0;
        }
	
        this.ruleAppliesChanged = function()
        {
          this.ruleAppliesChangedInternal();
          this.ruleChanged();
        }

        this.ruleAppliesChangedInternal = function()
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

