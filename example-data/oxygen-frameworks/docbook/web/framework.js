goog.provide('sync.docbook.DocbookExtension');


/**
 * Constructor for the docbook Extension.
 *
 * @constructor
 */
sync.docbook.DocbookExtension = function(){
  sync.ext.Extension.call(this);
};
goog.inherits(sync.docbook.DocbookExtension, sync.ext.Extension);

/**
 * The docbook version.
 */
sync.docbook.DocbookExtension.prototype.version =
  (decodeURIComponent(decodeURIComponent(sync.ext.Registry.extensionURL))).indexOf("5") != -1? 5 : 4;

/**
 * Editor created callback.
 *
 * @param {sync.Editor} editor The currently created editor.
 */
sync.docbook.DocbookExtension.prototype.editorCreated = function(editor) {
  goog.events.listen(editor, sync.api.Editor.EventTypes.ACTIONS_LOADED, function(e) {
    var actionsManager = editor.getActionsManager();
    var originalInsertImageAction = actionsManager.getActionById('insert.graphic');
    if (originalInsertImageAction) {
      var insertImageAction = new sync.actions.InsertImage(
        originalInsertImageAction, 
        sync.docbook.DocbookExtension.prototype.version == 5 ? 
            "ro.sync.ecss.extensions.docbook.InsertImageDataOperation" : 
            "ro.sync.ecss.extensions.docbook.InsertGraphicOperation", 
        editor);
      actionsManager.registerAction('insert.graphic', insertImageAction);
    }

    // Wrap the Insert Web Link action.
    var insertWebLinkActionId =
      sync.docbook.DocbookExtension.prototype.version == 5 ? "insert.web.link" : "insert.web.ulink";
    var originalInsertWebLinkAction = actionsManager.getActionById(insertWebLinkActionId);
    if(originalInsertWebLinkAction) {
      var webLinkOperationClass = sync.docbook.DocbookExtension.prototype.version == 5 ?
        "ro.sync.ecss.extensions.docbook.link.InsertExternalLinkOperation" :
        "ro.sync.ecss.extensions.docbook.link.InsertULink";
      var insertWebLinkAction = new sync.actions.InsertWebLink(
        originalInsertWebLinkAction,
        webLinkOperationClass,
        editor,
        'url_value');
      actionsManager.registerAction(insertWebLinkActionId, insertWebLinkAction);
    }

    var originalInsertTableAction = actionsManager.getActionById('insert.table');
    if (originalInsertTableAction) {
      var insertTableAction = new sync.actions.InsertTable(
        originalInsertTableAction, 
        "ro.sync.ecss.extensions.docbook.table.InsertTableOperation", 
        editor, 
        [sync.actions.InsertTable.TableTypes.CALS, sync.actions.InsertTable.TableTypes.HTML],
        [sync.actions.InsertTable.ColumnWidthTypes.PROPORTIONAL, 
         sync.actions.InsertTable.ColumnWidthTypes.DYNAMIC, 
         sync.actions.InsertTable.ColumnWidthTypes.FIXED],
        "Title",
        "http://docbook.org/ns/docbook");
        actionsManager.registerAction('insert.table', insertTableAction);
    }

    addOldStyleTableActions(e.actionsConfiguration, "DocBook", actionsManager);
  }, true);
};

/**
 * Adds old-style (selection-based actions to the current configuration.
 *
 * @param {object} actionsConfiguration The actions configuration.
 * @param {string} toolbarName name of the toolbar defined in the framework.
 * @param {sync.actions.ActionsManager} actionsManager The actions manager.
 */
function addOldStyleTableActions(actionsConfiguration, toolbarName, actionsManager) {
  if (isFrameworkActions(actionsConfiguration, toolbarName)) {
    var split_join_actions = [
      {"type": "sep"},
      {"id": "table.join.row.cells", "type": "action"},
      {"id": "table.join.cell.above", "type": "action"},
      {"id": "table.join.cell.below", "type": "action"},
      {"type": "sep"},
      {"id": "table.split.left", "type": "action"},
      {"id": "table.split.right", "type": "action"},
      {"id": "table.split.above", "type": "action"},
      {"id": "table.split.below", "type": "action"},
      {"type": "sep"}
    ];
    var row_actions = [
      {"id": "insert.table.row.above", "type": "action"},
      {"id": "insert.table.row.below", "type": "action"},
      {"id": "delete.table.row", "type": "action"}
    ];
    var column_actions = [
      {"id": "insert.table.column.before", "type": "action"},
      {"id": "insert.table.column.after", "type": "action"},
      {"id": "delete.table.column", "type": "action"}
    ];

    // Make table-related actions context-aware.
    [].concat(split_join_actions, row_actions, column_actions).forEach(function(action) {
      sync.actions.TableAction.wrapTableAction(actionsManager, action.id);
    });

    actionsConfiguration.toolbars[0].children.push({
      "type": "list",
      "name": "Join or split table cells.",
      "displayName": tr(msgs.TABLE_JOIN_SPLIT_),
      "icon16": "/images/TableJoinSplit16.png",
      "icon20": "/images/TableJoinSplit24.png",
      "children": split_join_actions
    });

    var contextualItems = actionsConfiguration.contextualItems;
    for (var i = 0; i < contextualItems.length; i++) {
      if (contextualItems[i].name === "Table") {
        var items = contextualItems[i].children;
        Array.prototype.push.apply(items, split_join_actions);
        var row_actions_index = indexOfId(items, row_actions[2].id);
        goog.bind(items.splice, items, row_actions_index, 1).apply(items, row_actions);

        var column_actions_index = indexOfId(items, column_actions[2].id);
        goog.bind(items.splice, items, column_actions_index, 1).apply(items, column_actions);
        break;
      }
    }
  }
}

/**
 * @param {Array<{id:string}>} items The array of items.
 * @param {string} id The ID that we search for.
 * @return {number} The index of the element with the given ID.
 */
function indexOfId(items, id) {
  for (var i = 0; i < items.length; i++) {
    if (items[i].id === id) {
      return i;
    }
  }
  return -1;
}

/**
 * @param {object} actionsConfiguration The actions configuration.
 * @param {string} toolbarName name of the toolbar defined in the framework.
 *
 * @return {boolean} true if the actions loaded come from the framework.
 */
function isFrameworkActions(actionsConfiguration, toolbarName) {
  var toolbars = actionsConfiguration.toolbars;
  return toolbars && toolbars.length > 0 && toolbars[0].name == toolbarName;
}

// Publish the extension.
sync.ext.Registry.extension = new sync.docbook.DocbookExtension();