define([
	"dojo",
	"dijit",
	"dojox",
	"dijit/Dialog",
	"dojo/_base/connect",
	"dojo/_base/declare",
	"dojo/i18n",
	"dojo/string",
	"dojox/editor/plugins/PasteFromWord",
	"dojo/i18n!dijit/nls/common",
	"dojo/i18n!dijit/_editor/nls/commands"
], function(dojo, dijit, dojox) {

dojo.declare("fins.editor.plugins.SafePaste", [dojox.editor.plugins.PasteFromWord],{
});

return fins.editor.plugins.SafePaste;

});
