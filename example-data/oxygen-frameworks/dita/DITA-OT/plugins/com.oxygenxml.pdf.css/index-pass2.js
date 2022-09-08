window.onload = rewriteIndex;

function rewriteIndex()
{
    var div = document.getElementsByTagName("index.groups");
    if (div.length > 0) {
        var refs = div[0].getElementsByTagName("refID");
        for (var i = 0; i < refs.length; ++i)
        {
            var refElement = refs[i];
            console.log("refID " + refElement.getAttribute("value"));
            rewriteRef(refElement);
        }
    }
}

/**
 * Makes sure the index-links having the same page are removed from the parent.
 * 
 */
function rewriteRef(refElement) {

    var linkElements = refElement.getElementsByTagName("index-link");
    var linkElementsToDelete = [];

    var lastPage;
    if(refs){
        for (var i = 0; i < linkElements.length; ++i) {
            var link = linkElements[i];
            var href = link.getAttribute("href");
    
            if (!refs[href]) {
                Log.warning("unknown index refElement: "+href);
                continue;
            }
    
            var page = refs[href];
    
            if (!lastPage) {
                lastPage = page;
            } else if (lastPage != page) {
                lastPage = page;
            } else {
                // Duplicated page.
                linkElementsToDelete.push(link);
            }
        }        
        for (var i = 0; i < linkElementsToDelete.length; ++i) {
            linkElementsToDelete[i].parentNode.removeChild(linkElementsToDelete[i]);
            console.log("Removed " + linkElementsToDelete[i] );
        }
    } else {
        Log.warning("unknown refs variable");
    }
}
