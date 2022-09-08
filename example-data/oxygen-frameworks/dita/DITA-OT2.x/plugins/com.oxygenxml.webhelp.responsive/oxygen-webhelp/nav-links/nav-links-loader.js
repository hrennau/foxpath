define(function (require) {

    var ATTRS = {
        /* The state attribute name */
        state : "data-state",
        id : "data-id",
        tocID : "data-tocid"
    };

    var STATE = {
        /* The possible states */
        pending : "pending",
        notReady : "not-ready",
        collapsed : "collapsed",
        expanded : "expanded",
        leaf : "leaf"
    };

    var jsonBaseDir = "json";

    /**
     * The path of the output directory, relative to the current HTML file.
     * @type {String}
     */
    var path2root = null;

    $(document).ready ( function() {
        // Register the click handler for the TOC
        var topicRefExpandBtn = $(".wh_side_toc .wh-expand-btn");
        topicRefExpandBtn.click(toggleTocExpand);

        // Register the hover handler for the Menu
        var menuTopicRefSpan = $(".wh_top_menu li");
        menuTopicRefSpan.hover(menuItemHovered);
    });

    /**
     * Retrieves the path of the output directory, relative to the current HTML file.
     *
     * @returns {*} the path of the output directory, relative to the current HTML file.
     */
    function getPathToRoot() {
        if (path2root == null) {
            path2root = $('meta[name="wh-path2root"]').attr("content");
            if (path2root == null || path2root == undefined) {
                path2root = "";
            }
        }
        return path2root;
    };

    function toggleTocExpand() {

        var topicRef = $(this).closest(".topicref");
        var state = topicRef.attr(ATTRS.state);

        if (state == null) {
            // Do nothing
        } else if (state == STATE.pending) {
            // Do nothing
        } else if (state == STATE.notReady) {
            topicRef.attr(ATTRS.state, STATE.pending);
            retrieveChildNodes(topicRef, true);
        } else if (state == STATE.expanded) {
            topicRef.attr(ATTRS.state, STATE.collapsed);
        } else if (state == STATE.collapsed) {
            topicRef.attr(ATTRS.state, STATE.expanded);
        }
    };

    /**
     * Loads the JS file containing the list of child nodes for the current topic node.
     * Builds the list of child topics element nodes based on the retrieved data.
     *
     * @param topicRefSpan The topicref 'span' element of the current node from TOC / Menu.
     * @param forToc <p><code>true</code> if the child nodes should be retrieved for the TOC.</p>
     *               <p><code>false</code> if the child nodes should be retireved for the Menu.</p>
     */
    function retrieveChildNodes(topicRefSpan, forToc) {
        var tocId = $(topicRefSpan).attr(ATTRS.tocID);
        if (tocId != null) {
            var jsonHref = jsonBaseDir + "/" + tocId;
            require(
                [jsonHref],
                function(data) {
                    if (data != null) {
                        var topics = data.topics;
                        var topicLi = topicRefSpan.closest('li');
                        var topicsUl = createTopicsList(topics, forToc);

                        if (!forToc) {
                            var loadingDotsUl = topicLi.children("ul.loading");
                            // Remove the loading dots from the menu.
                            loadingDotsUl.find('li').remove();
                            loadingDotsUl.removeClass('loading');

                            topicsUl.forEach(function(topic){
                                loadingDotsUl.append(topic);
                            });
                        } else {
                            var topicsUlParent = $('<ul/>');
                            topicsUl.forEach(function(topic){
                                topicsUlParent.append(topic);
                            });
                            topicLi.append(topicsUlParent);
                        }

                        topicRefSpan.attr(ATTRS.state, STATE.expanded);
                    } else {
                        topicRefSpan.attr(ATTRS.state, STATE.leaf);
                    }
                }
            );
        }
    }

    /**
     * Creates the <code>ul</code> element containing the child topic nodes of the current topic.
     *
     * @param topics The array of containing info about the child topics.
     * @param forToc <p><code>true</code> if the element belongs to the TOC.</p>
     *               <p><code>false</code> if the element belongs to the Menu.</p>
     *
     * @returns {*|jQuery|HTMLElement} the <code>li</code> elements representing the child topic nodes of the current topic.
     */
    function createTopicsList(topics, forToc) {
        var topicsArray = [];
        topics.forEach(function(topic) {
            if (forToc || !topic.menu.isHidden) {
                var topicLi = createTopicLi(topic, forToc);
                topicsArray.push(topicLi);
            }
        });
        return topicsArray;
    };

    /**
     * Creates the <code>li</code> element containing a topic node.
     *
     * @param topic The info about the topic node.
     * @param forToc <p><code>true</code> if the element belongs to the TOC.</p>
     *               <p><code>false</code> if the element belongs to the Menu.</p>
     *
     * @returns {*|jQuery|HTMLElement} the <code>li</code> element containing a topic node.
     */
    function createTopicLi(topic, forToc) {
        var li = $("<li>");
        if (!forToc) {
            if (topic.menu.hasChildren) {
                li.addClass("has-children");
            }
            var topicImage = topic.menu.image;
            if (topicImage != null && topicImage.href != null) {
                var menuImageSpan = createMenuImageSpan(topic);
                li.append(menuImageSpan);
            }
            li.hover(menuItemHovered);
        }

        // .topicref span
        var topicRefSpan = createTopicRefSpan(topic, forToc);
        // append the topicref node in parent
        li.append(topicRefSpan);

        return li;
    };

    /**
     * Creates the <span> element containing the image icon for the current node in the menu.
     * @param topic The JSON object containing the info about the associated node.
     *
     * @returns {*|jQuery|HTMLElement} the image 'span' element.
     */
    function createMenuImageSpan(topic) {
        var topicImage = topic.menu.image;
        // Image span
        var imgSpan = $("<span>", {class : "topicImg"});

        var isExternalReference = topicImage.scope == 'external';
        var imageHref = '';
        if (!isExternalReference) {
            imageHref += getPathToRoot();
        }
        imageHref += topicImage.href;

        var img = $("<img>", {
            src : imageHref,
            alt : topic.title
        });

        if (topicImage.height != null) {
            img.attr("height", topicImage.height);
        }
        if (topicImage.width != null) {
            img.attr("width", topicImage.width);
        }
        imgSpan.append(img);

        return imgSpan;
    }

    /**
     * Creates the <span> element containing the title and the link to the topic associated to a node in the menu or the TOC.
     *
     * @param topic The JSON object containing the info about the associated node.
     *
     * @returns {*|jQuery|HTMLElement} the topic title 'span' element.
     */
    function createTopicRefSpan(topic, forToc) {
        var isExternalReference = topic.scope == 'external';

        // .topicref span
        var topicRefSpan = $("<span>");
        topicRefSpan.addClass("topicref");
        if (topic.outputclass != null) {
            topicRefSpan.addClass(topic.outputclass);
        }

        topicRefSpan.attr(ATTRS.id, topic.id);
        topicRefSpan.attr(ATTRS.tocID, topic.tocID);

        // If the "topics" property is not specified then it means that children should be loaded from the
        // module referenced in the "next" property
        var children = topic.topics;

        var hasChildren;
        if (children != null && children.length == 0) {
            hasChildren = false;
        } else if (!forToc && topic.menu != null) {
            hasChildren = topic.menu.hasChildren;
        } else {
            hasChildren = true;
        }

        // Current node state
        if (hasChildren) {
            // This state means that the child topics should be retrieved later.
            topicRefSpan.attr(ATTRS.state, STATE.notReady);
        } else {
            topicRefSpan.attr(ATTRS.state, STATE.leaf);
        }

        if (forToc) {
            var expandBtn = $("<span>", {
                class: "wh-expand-btn"
            });
            expandBtn.click(toggleTocExpand);
            topicRefSpan.append(expandBtn);
        }

        // Topic ref link
        var linkHref = '';
        if (topic.href != null && topic.href != 'javascript:void(0)') {
            if (!isExternalReference) {
                linkHref += getPathToRoot();
            }
            linkHref += topic.href;
        }
        var link = $("<a>", {
            href: linkHref,
            html: topic.title
        });
        if (isExternalReference) {
            link.attr("target", "_blank");
        }
        var titleSpan = $("<span>", {
           class: "title"
        });

        titleSpan.append(link);

        // Topic ref short description
        if (forToc && topic.shortdesc != null) {

            var tooltipSpan = $("<span>", {
                class: "wh-tooltip",
                html: topic.shortdesc
            });
			
			/* WH-1518: Check if the tooltip has content. */
            if (tooltipSpan.find('.shortdesc:empty').length == 0) {

                // Update the relative links
                var pathToRoot = getPathToRoot();
                var links = tooltipSpan.find("a[href]");
                links.each(function () {
                    var href = $(this).attr("href");
                    if (!(href.startsWith("http:") || href.startsWith("https:"))) {
                        $(this).attr("href", pathToRoot + href);
                    }
                });

                titleSpan.append(tooltipSpan);
            }

        }

        topicRefSpan.append(titleSpan);

        return topicRefSpan;
    }


    function menuItemHovered() {
        var topicRefSpan = $(this).children('.topicref');
        var state = topicRefSpan.attr(ATTRS.state);
        if (state == null) {
            // Do nothing
        } else if (state == STATE.pending) {
            // Do nothing
        } else if (state == STATE.notReady) {
            topicRefSpan.attr(ATTRS.state, STATE.pending);

            var dot = $("<span>", {
                class: "dot"
            });
            var loadingMarker =
                $("<ul>", {
                    class: "loading",
                    html: $("<li>", {
                        html: [dot, dot.clone(), dot.clone()]
                    })
                });

            $(this).append(loadingMarker);

            handleMenuPosition($(this));
            retrieveChildNodes(topicRefSpan, false);

        } else if (state == STATE.expanded) {
            handleMenuPosition($(this));
        }
    };

    var dirAttr = $('html').attr('dir');
    var rtlEnabled = false;
    if (dirAttr=='rtl') {
        rtlEnabled = true;
    }

    /**
     * Display top menu so that it will not exit the viewport.
     *
     * @param $menuItem The top menu menu 'li' element of the current node from TOC / Menu.
     */
    function handleMenuPosition($menuItem) {
        // Handle menu position
        var parentDir = rtlEnabled ? 'left' : 'right';
        var index = $('.wh_top_menu ul').index($menuItem.parent('ul'));

        var currentElementOffsetLeft = parseInt($menuItem.offset().left);
        var currentElementWidth = parseInt($menuItem.width());
        var currentElementOffsetRight = currentElementOffsetLeft + currentElementWidth;
        var nextElementWidth = parseInt($menuItem.children('ul').width());
        var offsetLeft,
            offsetRight = currentElementOffsetRight + nextElementWidth;

        if (index == 0) {
            if (parentDir=='left') {
                $menuItem.attr('data-menuDirection', 'left');
                offsetLeft = currentElementOffsetRight - nextElementWidth;
                if (offsetLeft <= 0) {
                    $menuItem.css('position', 'relative');
                    $menuItem.children('ul').css('position','absolute');
                    $menuItem.children('ul').css('right', 'auto');
                    $menuItem.children('ul').css('left', '0');
                }
            } else {
                $menuItem.attr('data-menuDirection', 'right');
                offsetRight = currentElementOffsetLeft + nextElementWidth;
                if (offsetRight >= $(window).width()) {
                    $menuItem.css('position', 'relative');
                    $menuItem.children('ul').css('position','absolute');
                    $menuItem.children('ul').css('right', '0');
                    $menuItem.children('ul').css('left', 'auto');
            }
            }
        } else {
            offsetLeft = currentElementOffsetLeft - nextElementWidth;

            if (parentDir == 'left') {
                if (offsetLeft >= 0) {
                    $menuItem.attr('data-menuDirection', 'left');
                    $menuItem.children('ul').css('right', '100%');
                    $menuItem.children('ul').css('left', 'auto');
                } else {
                    $menuItem.attr('data-menuDirection', 'right');
                    $menuItem.children('ul').css('right', 'auto');
                    $menuItem.children('ul').css('left', '100%');
                }
            } else {
                if (offsetRight <= $(window).width()) {
                    $menuItem.attr('data-menuDirection', 'right');
                    $menuItem.children('ul').css('right', 'auto');
                    $menuItem.children('ul').css('left', '100%');
                } else {
                    $menuItem.attr('data-menuDirection', 'left');
                    $menuItem.children('ul').css('right', '100%');
                    $menuItem.children('ul').css('left', 'auto');
                }
            }
        }
    }
});
