dojo.provide("fins.widget.RTEditor");
dojo.require("dojo.widget.*");
dojo.require("dojo.widget.Editor");
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
  this.taform = null;
  this.htmlDiv = null;
  this.sourceDiv = null;
  this.newTextarea = null;
  this.sourceTab = null;
  this.htmlTab = null;
  this.editorDiv = null;

  this.editor = null;

  this.editorBuilt = false;

  this.fillInTemplate = function(args, frag)
  {
    var te = this.getFragNodeRef(frag);
    var html = null;

    if(te.nodeName.toLowerCase() == "textarea")
    {
      dojo.debug("hooking textarea.");
      this.textarea = te;

      html = dojo.string.trim(this.textarea.value);
      if(html == ""){ html = "&nbsp;"; }

      with(this.textarea.style){
        display = "block";
        position = "absolute";
        width = "1px";
        height = "1px";
        order = margin = padding = "0px";       
        visiblity = "hidden";
        if(dojo.render.html.ie){
          overflow = "hidden";
        }
      }

      if(this.textarea.form){
        dojo.debug("hooking form.");
        dojo.debug("form: " + this.textarea.form);
        this.taform = this.textarea.form;
        dojo.event.connect(this.textarea.form, "onsubmit",
        dojo.lang.hitch(this, function(){
          this.textarea.value = this.getMostUpdatedContent();
          // NOTE: this will break down if we do a submit without actually following through.
          if(!this.textarea.form)
            this.taform.appendChild(this.textarea);
          })
        ) 
       }

    }

    this.tabContainer = dojo.widget.createWidget("TabContainer", {id: "tabContainer"}, this.myDiv);

    this.tabContainer.useVisibility = false;

    dojo.debug("whee!");

    this.htmlTab = dojo.widget.createWidget("ContentPane", {id: "htmlTab", label:"HTML"});
    this.htmlTab.setContent("<div id=\"editorPane\" style=\"height:200px; border:2px;\">" + html + "</div>");
  dojo.debug("whoo!");
    this.tabContainer.addChild(this.htmlTab);

    this.sourceTab = dojo.widget.createWidget("ContentPane", {id: "sourceTab", label:"Source"});
    this.tabContainer.addChild(this.sourceTab);
    this.tabContainer.selectTab(this.htmlTab);

    this.newTextarea = document.createElement("textarea");
    this.newTextarea.style.height="100%";
    this.newTextarea.style.width="100%";

    var self = this;

    dojo.event.connect(this.htmlTab, "show", this, "updateHtml");
    dojo.event.connect(this.sourceTab, "show", this, "updateSource");

  }

  this.getMostUpdatedContent = function()
  {
    // if the editor page is showing, then that's the most up to date.
    if(this.htmlTab.selected)
      return this.editor.getEditorContent();
    else
      return this.newTextarea.value;
  }

  this.updateSource = function(self)
  {
     this.sourceTab.setContent(this.newTextarea);
     this.newTextarea.value = this.editor.getEditorContent();
  }

  this.updateHtml = function()
  {
     this.replaceEditorContent(this.newTextarea.value);
  }

  this.replaceEditorContent = function(html)
  {
    this.editor._richText.editNode.innerHTML = html;
  }

  this.initEditor = function(e)
  {
    dojo.debug("this.initEditor()");
    if(this.editorBuilt)
      return true;
    var eargs = {items: ["textGroup", "listGroup", "linkGroup"]};
    if(this.textarea)
      dojo.byId("editorPane").innerHTML = (this.textarea.value);

    var editor = dojo.widget.createWidget("Editor", eargs, dojo.byId("editorPane"));
    this.editor = editor;
    this.editorBuilt = true;
  }


  this.initialize = function() {
    dojo.debug("Hello from RTEditor");
  }

  this.postInitialize = function(args, fragment, parentComp)
  {
    fins.widget.RTEditor.superclass.postInitialize.call(this, args, fragment, parentComp);
    this.initEditor();
  }

};

dojo.inherits(fins.widget.RTEditor, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:rteditor");
