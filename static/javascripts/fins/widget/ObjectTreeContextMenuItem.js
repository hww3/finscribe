dojo.provide("fins.widget.ObjectTreeContextMenuItem");

dojo.require("dojo.widget.*");
dojo.require("dojo.widget.TreeContextMenuV3");
//dojo.require("dojo.widget.TreeMenuItemV3");
dojo.require("dojo.event.*");
dojo.require("dojo.html");
dojo.require("dojo.html.style");
dojo.require("dojo.lfx");



dojo.widget.defineWidget(
        "fins.widget.ObjectTreeContextMenuItem",
        [dojo.widget.MenuItem2, dojo.widget.TreeCommon],
        function() {
                this.treeActions = [];
        },
{
        // treeActions menu item performs following actions (to be checked for permissions)

        getTreeNode: function() {
                var menu = this;

                // FIXME: change to dojo.widget[this.widgetType]
                while (! (menu instanceof dojo.widget.TreeContextMenuV3) ) {
                                menu = menu.parent;
                }

                var treeNode = menu.getTreeNode()

                return treeNode;
        },


        menuOpen: function(treeNode) {

                treeNode.viewEmphasize()
        },

        menuClose: function(treeNode) {

                treeNode.viewUnemphasize()
        },

        toString: function() {
                return "["+this.widgetType+" node "+this.getTreeNode()+"]";
        }
});




