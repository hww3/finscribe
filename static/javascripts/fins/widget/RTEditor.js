dojo.provide("fins.widget.RTEditor");
dojo.require("dojo.widget.*");
dojo.require("dojo.widget.Editor2");
dojo.require("dojo.widget.TabContainer");
dojo.require("dojo.widget.ContentPane");
//dojo.require("dojo.widget.LayoutContainer");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.style");

fins.widget.RTEditor = function() {

  /* Stuff for Dojo */
  dojo.widget.HtmlWidget.call(this);
  this.templatePath = dojo.uri.dojoUri("fins/widget/templates/RTEditor.html");
  this.templateCssPath = dojo.uri.dojoUri("fins/widget/templates/RTEditor.css");
  this.widgetType = "RTEditor";
  /* end */

  this.masterNode = null;
  this.myDiv = null;
  this.tabContainer = null;

  this.textarea = null;

  this.htmlDiv = null;
  this.sourceDiv = null;

  this.sourceTab = null;
  this.htmlTab = null;
  this.editorDiv = null;

  this.editor = null;

  this.editorBuilt = false;

  this.fillInTemplate = function(args, frag)
  {
    this.tabContainer = dojo.widget.createWidget("TabContainer", {id: "tabContainer"}, this.myDiv);

    this.tabContainer.useVisibility = false;

    this.htmlTab = dojo.widget.createWidget("ContentPane", {id: "htmlTab", label:"HTML"});
    this.htmlTab.setContent("<div id=\"editorPane\" style=\"height:200px; border:2px;\"></div>");
    this.tabContainer.addChild(this.htmlTab);

    this.sourceTab = dojo.widget.createWidget("ContentPane", {id: "sourceTab", label:"Source"});
    this.tabContainer.addChild(this.sourceTab);
    this.tabContainer.selectTab(this.htmlTab);

    var self = this;

    dojo.event.connect(this.htmlTab, "show", this, "updateHtml");
    dojo.event.connect(this.sourceTab, "show", this, "updateSource");

    var te = this.getFragNodeRef(frag);

    if(te.nodeName.toLowerCase() == "textarea")
    {
      dojo.debug("hooking textarea.");
      te.style.height="100%";
      te.style.width="100%";
      this.textarea = te;

      if(this.textarea.form){
        dojo.event.connect(this.textarea.form, "onsubmit",
        dojo.lang.hitch(this, function(){
          this.textarea.value = this.getMostUpdatedContent();
          })
                                        );
                                }



    }    
  }

  this.getMostUpdatedContent = function()
  {
    // if the editor page is showing, then that's the most up to date.
    if(this.HtmlTab.selected)
      return this.editor.getEditorContent();
    else
      return this.textarea.value;
  }

  this.updateSource = function(self)
  {
     this.sourceTab.setContent(this.textarea);
     this.textarea.value = this.editor.getEditorContent();
  }

  this.updateHtml = function()
  {
     this.editor.replaceEditorContent(this.textarea.value);
  }


  this.initEditor = function(e)
  {
    dojo.debug("this.initEditor()");
    if(this.editorBuilt)
      return true;
    var eargs = {items: ["textGroup", "listGroup", "linkGroup"]};
    if(this.textarea)
      dojo.byId("editorPane").innerHTML = (this.textarea.value);

    var editor = dojo.widget.createWidget("Editor2", eargs, dojo.byId("editorPane"));
    this.editor = editor;
    this.editorBuilt = true;
  }


  this.initialize = function() {
    dojo.debug("Hello from RTEditor");
//    dojo.event.connect(this.htmlTab, "onshow", function(e){this.initEditor(e);}); 
  }

  this.postInitialize = function(args, fragment, parentComp)
  {
    fins.widget.RTEditor.superclass.postInitialize.call(this, args, fragment, parentComp);
    this.initEditor();
  }

};

dojo.inherits(fins.widget.RTEditor, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:rteditor");
