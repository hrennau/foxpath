/**
 * This file will be loaded by the oXygen XML Author WebApp in order to
 * provide some custom behaviour for DITA files.
 */
if (sync.ext.Registry.extensionURL.indexOf("ditamap") != -1) {
  goog.provide('sync.dita.DitamapExtension');
  
  
  
  /**
   * Constructor for the Ditamap Extension.
   *
   * @constructor
   */
  sync.dita.DitamapExtension = function(){
    sync.ext.Extension.call(this);
  };
  goog.inherits(sync.dita.DitamapExtension, sync.ext.Extension);


  /**
   * Editor created callback.
   *
   * @param {sync.Editor} editor The currently created editor.
   */
  sync.dita.DitamapExtension.prototype.editorCreated = function(editor) {
    // Override the open link action to provide the current ditamap as a param.
    goog.events.listen(editor, sync.api.Editor.EventTypes.LINK_OPENED, function(e) {
      if (!e.external) {
        var urlParams = sync.util.getApiParams();
        if (!urlParams.ditamap) {
          e.params['ditamap'] = editor.options.url;
        } else {
          // If the ditamap is already specified, it means that the current map is a
          // sub-map and the links must be opened in the context of the parent map.
        }
      }
    }, true);
    goog.events.listen(editor, sync.api.Editor.EventTypes.ACTIONS_LOADED, function(e) {
      var actionsManager = editor.getActionsManager();
      var originalInsertTableAction = actionsManager.getActionById('insert.table');
      if (originalInsertTableAction) {
        var insertTableAction = new sync.actions.InsertTable(
          originalInsertTableAction,
          "ro.sync.ecss.extensions.dita.map.table.InsertTableOperation",
          editor, [], []);
        actionsManager.registerAction('insert.table', insertTableAction);
      }
      var originalInsertTopicRef = actionsManager.getActionById('insert.topicref');
      if (originalInsertTopicRef) {
        var insertTopicRef = new sync.actions.InsertTopicRef(originalInsertTopicRef, editor);
        if (insertTopicRef.isEnabled()) {
          actionsManager.registerAction('insert.topicref', insertTopicRef);
        }
      }
    });
  };

  // Publish the extension.
  sync.ext.Registry.extension = new sync.dita.DitamapExtension();
} else {
  goog.provide('sync.dita.DitaExtension');

  /**
   * Constructor for the DITA Extension.
   *
   * @constructor
   */
  sync.dita.DitaExtension = function(){
    sync.ext.Extension.call(this);
  };
  goog.inherits(sync.dita.DitaExtension, sync.ext.Extension);

  /**
   * Editor created callback.
   *
   * @param {sync.Editor} editor The currently created editor.
   */
  sync.dita.DitaExtension.prototype.editorCreated = function(editor) {
    goog.events.listen(editor, sync.api.Editor.EventTypes.ACTIONS_LOADED, function(e) {
      var actionsManager = editor.getActionsManager();

      var originalReuseContentAction = actionsManager.getActionById('reuse.content');
      if (originalReuseContentAction) {
        var reuseContentAction = new sync.actions.dita.ReuseContentAction(
          originalReuseContentAction,
          editor);
        actionsManager.registerAction('reuse.content', reuseContentAction);
      }

      var originalInsertImageAction = actionsManager.getActionById('insert.image');
      if (originalInsertImageAction) {
        var insertImageAction = new sync.actions.InsertImage(
          originalInsertImageAction,
          "ro.sync.ecss.extensions.dita.topic.InsertImageOperation",
          editor);
        actionsManager.registerAction('insert.image', insertImageAction);
      }

      // Wrap the Insert Web Link action.
      var insertWebLinkId = 'insert.url.reference';
      var originalInsertWebLinkAction = actionsManager.getActionById(insertWebLinkId);
      if(originalInsertWebLinkAction) {
        var insertWebLinkAction = new sync.actions.InsertWebLink(
          originalInsertWebLinkAction,
          'ro.sync.ecss.extensions.dita.link.InsertXrefOperation',
          editor,
          'reference_value',
          {
            format: 'html',
            scope: 'external',
            'href type': 'web page'
          });
        actionsManager.registerAction(insertWebLinkId, insertWebLinkAction);
        var changeToWebLinkAction = new sync.actions.InsertWebLink(
          originalInsertWebLinkAction,
          'ro.sync.ecss.extensions.dita.link.InsertXrefOperation',
          editor,
          'reference_value',
          {
            format: 'html',
            scope: 'external',
            'href type': 'web page',
            replace_reference: 'true'
          });
        actionsManager.registerAction('change.url.reference', changeToWebLinkAction);
      }

      var insertFileReferenceId = 'insert.file.reference';
      var originalInsertFileReferenceAction = actionsManager.getActionById(insertFileReferenceId);
      if(originalInsertFileReferenceAction) {
        var insertFileReferenceAction = new sync.actions.InsertFileReference(
          originalInsertFileReferenceAction,
          'ro.sync.ecss.extensions.dita.link.InsertXrefOperation',
          editor);
        actionsManager.registerAction(insertFileReferenceId, insertFileReferenceAction);
        var changeFileReferenceAction = new sync.actions.InsertFileReference(
          originalInsertFileReferenceAction,
          'ro.sync.ecss.extensions.dita.link.InsertXrefOperation',
          editor,
          {replace_reference: 'true'}
        );
        actionsManager.registerAction('change.file.reference', changeFileReferenceAction);

      }

      var originalEditImageMap = actionsManager.getActionById('edit.image.map');
      if (originalEditImageMap) {
        actionsManager.registerAction('edit.image.map', 
          new sync.actions.InsertImageMap(
                  originalEditImageMap,
                  editor.getActionsManager(),
                  editor.getReadOnlyStatus(),
                  'ro.sync.ecss.extensions.dita.DITAUpdateImageMapOperation'));
      }

      var originalInsertTableAction = actionsManager.getActionById('insert.table');
      if (originalInsertTableAction) {
        var insertTableAction = new sync.actions.InsertTable(
          originalInsertTableAction,
          "ro.sync.ecss.extensions.dita.topic.table.InsertTableOperation",
          editor,
          [sync.actions.InsertTable.TableTypes.CALS, sync.actions.InsertTable.TableTypes.DITA_SIMPLE],
          [sync.actions.InsertTable.ColumnWidthTypes.PROPORTIONAL,
            sync.actions.InsertTable.ColumnWidthTypes.DYNAMIC,
            sync.actions.InsertTable.ColumnWidthTypes.FIXED]);
        actionsManager.registerAction('insert.table', insertTableAction);
      }
      
      var originalInsertTableWizardAction = actionsManager.getActionById('insert.table.wizard');
      if (originalInsertTableWizardAction) {
        var insertTableAction = new sync.actions.InsertTable(
          originalInsertTableWizardAction,
          "ro.sync.ecss.extensions.dita.topic.table.InsertTableOperation",
          editor,
          [sync.actions.InsertTable.TableTypes.CALS, sync.actions.InsertTable.TableTypes.DITA_SIMPLE],
          [sync.actions.InsertTable.ColumnWidthTypes.PROPORTIONAL,
            sync.actions.InsertTable.ColumnWidthTypes.DYNAMIC,
            sync.actions.InsertTable.ColumnWidthTypes.FIXED]);
        actionsManager.registerAction('insert.table.wizard', insertTableAction);
      }

      var originalInsertXref = actionsManager.getActionById('insert.cross.reference');
      if (originalInsertXref) {
        var insertXref = new sync.actions.InsertXref(originalInsertXref, editor);
        actionsManager.registerAction('insert.cross.reference', insertXref);
        var changeXref = new sync.actions.InsertXref(originalInsertXref, editor, {replace_reference: 'true'});
        actionsManager.registerAction('change.cross.reference', changeXref);
      }

      if (editor.ditamapsManagerEnabled) {
        var ACTION_ID = 'DITA/SetDitaMap';
        var editingSupport = editor.getEditingSupport();
        var askForDitamapAction =
          new sync.actions.AskForDitamap(editor, editor.widgets, editingSupport.scheduler,
            editingSupport.getController(), editingSupport.problemReporter);
        actionsManager.registerAction(ACTION_ID, askForDitamapAction);

        var config = e.actionsConfiguration;
        // Add a "set ditamap" button to the DITA toolbar
        for (var i = 0; i < config.toolbars.length; i++) {
          var toolbar = config.toolbars[i];
          if (toolbar.name === 'DITA') {
            toolbar.children.unshift({
              id: ACTION_ID,
              type: 'action'
            }, {
              type: 'sep'
            });
            break;
          }
        }
      }

      addOldStyleTableActions(e.actionsConfiguration, "DITA", actionsManager);
    }, true); // Listening on capture so we can add actions to the toolbar before
              // plugins have a chance to remove actions.
  };

  /**
   * Adds old-style (selection-based) actions to the current configuration.
   *
   * @param {object} actionsConfiguration The actions configuration.
   * @param {string} toolbarName name of the toolbar defined in the framework.
   * @param {sync.actions.ActionsManager} actionsManager The actions manager.
   */
  function addOldStyleTableActions(actionsConfiguration, toolbarName, actionsManager) {
    if (shouldInstallTableActions(actionsConfiguration, toolbarName)) {
      var split_join_actions = [
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
   * @return {boolean} true if the table-related actions should be installed.
   */
  function shouldInstallTableActions(actionsConfiguration, toolbarName) {
    var toolbars = actionsConfiguration.toolbars;
    if (toolbars && toolbars.length > 0 && toolbars[0].name == toolbarName) {
      var items = toolbars[0].children;
      return indexOfId(items, 'table.join') != -1;
    }
    return false;
  }

  // Publish the extension.
  sync.ext.Registry.extension = new sync.dita.DitaExtension();
}
