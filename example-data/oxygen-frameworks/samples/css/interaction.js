/** 
 * This function is called by Oxygen after the Javascript to Java bridge is installed. This bridge 
 * consists in the following global variables:
 * 
 * authorAccess - this object is an instance of ro.sync.ecss.extensions.api.AuthorAccess.
 * contextElement - an instance of ro.sync.ecss.extensions.api.node.AuthorNode. The form control is added over this node.
 * pluginWorkspace- an instance of ro.sync.exml.workspace.api.standalone.StandalonePluginWorkspace
 * fcArguments - a java.util.Map implementation with the property name -> property value pairs passed on the form control function.
 * apiHelper - A helper object for creating Java objects. These objects can afterwards be passed as arguments when calling Oxygen's Java API:
 * 
 * var newAttrValue = apiHelper.newInstance(
 *           "ro.sync.ecss.extensions.api.node.AttrValue",
 *           ["normalizedValue", "rawValue", true]);
 * authorAccess.getDocumentController().setAttribute(
 *        "counter", newAttrValue, contextElement);
 */
function bridgeReady () {
     init();
       
      var handler = {
        attributeChanged : function(event) {
            var node = event.getOwnerAuthorNode();
            var attrName = event.getAttributeName();
            
            if (node.equals(contextElement) && attrName === "counter") {
              init();
            }
        },
        contentDeleted : function(event) {
        },
        contentInserted : function(event) {
        }
    };
     
     authorDocumentListener = apiHelper.createProxyListener(
     	"ro.sync.ecss.extensions.api.AuthorListener", handler);
     
      var ctrl = authorAccess.getDocumentController();
      ctrl.addAuthorListener(authorDocumentListener);
}

/**
 * Initializes the form control with the values from the document.
 */
function init () {
    // All the global variables are installed. You can synchronize the browser with the document
     var cVal = contextElement.getAttribute("counter").getValue();
     // Update the label of the button.
     document.getElementsByClassName("increment.btn")[0].innerHTML="Increment counter to " + (parseInt(cVal) + 1);
     
}

/**
 * The form control will not be used anymore. Clean up.
 */
function dispose() {
    // Dispose all added listeners.
     var ctrl = authorAccess.getDocumentController();
     ctrl.removeAuthorListener(authorDocumentListener);
}

/** 
 * Increments the attribute @counter attribute from the context element.
 */
function increment() {
    if (typeof apiHelper !== 'undefined') {
        // "contextElement" is a reference to the element associated with the form control.
        var attrValue = contextElement.getAttribute("counter").getValue();
        
        var newValue = parseInt(attrValue) + 1;
        // Oxygen's API needs an ro.sync.ecss.extensions.api.node.AttrValue for an attribute value. 
        var newAttrValue = apiHelper.newInstance("ro.sync.ecss.extensions.api.node.AttrValue",[ "" + newValue]);
        
        var ctrl = authorAccess.getDocumentController();
        try {
        	// On Mac, methods that change the document must be executed asynchronously.
        	ctrl.async();
        	
        	ctrl.setAttribute("counter", newAttrValue, contextElement);        	
        } finally {
        	ctrl.sync();
        }
        
        // Update the label of the button.
        document.getElementsByClassName("increment.btn")[0].innerHTML="Increment counter to " + (parseInt(newValue) + 1);
    }
    
}

/**
 * Opens the HTML in an Oxygen editor.
 */
function openHTMLInOxygen() {
    // Oxygen's API needs an java.net.URL Java Object so we build it using the "apiHelper".
    var toOpen = apiHelper.newInstance("java.net.URL",[ "" + window.location.href]);
    // The open method is overloaded. You can pick a specific overloaded method by listing the parameter 
    // types in an extended method name.
    try {
    	// On Mac, methods that change the document must be executed asynchronously.
    	pluginWorkspace.async();
    	pluginWorkspace["open(java.net.URL,java.lang.String)"](toOpen, "Text");    	
    } finally {
    	pluginWorkspace.sync();
    }
}

/**
 * Opens the Javascript file inside an Oxygen editor.
 */
function openJSInOxygen() {
    var scripts = document.getElementsByTagName('script');
    // Oxygen's API needs an java.net.URL Java Object so we build it using the "apiHelper".
    var toOpen = apiHelper.newInstance("java.net.URL",[ "" + scripts[0].src]);
    // The open method is overloaded. You can pick a specific overloaded method by listing the parameter 
    // types in an extended method name.    
    try {
    	// On Mac, it's safer to call the API asynchronously because of threading issues.
    	pluginWorkspace.async();
    	pluginWorkspace["open(java.net.URL,java.lang.String)"](toOpen, "Text");    	
    } finally {
    	pluginWorkspace.sync();
    }
}

/**
 * Adds a new paragraph inside the document by using Oxygen's API.
 */
function addPara() {
    // Create the fragment.
    var fragment = "<p xmlns=\"http://www.oxygenxml.com/ns/samples/form-controls\">A new paragraph inserted from Javascript.</p>";
    // We insert the fragment before the context element.
    var offset = contextElement.getStartOffset();
    
    var ctrl = authorAccess.getDocumentController();
    // The "insertXMLFragment" method is overloaded. You can pick a specific overloaded method by listing the parameter 
    // types in an extended method name.    
    try {
    	// On Mac, methods that change the document must be executed asynchronously.
    	ctrl.async();
    	ctrl[ "insertXMLFragment(java.lang.String,int)"](fragment, offset);
    } finally {
    	ctrl.sync();
    }
}

