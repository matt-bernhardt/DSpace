(function ($) {

    var transitionTime = 300;
    var sandbox;
    var knownCategories = [];
    var previousCategory;
    var currentCategory;
    var tabs;
    var dataLoadedOnce = false;

    function getPreviousCategory() {
        return previousCategory;
    }

    function getSelector(data) {
        var prevSelector;
        if (typeof data === "undefined" || isMainCategory(data) || isNotKnown(data)) {
            prevSelector = '#aspect_statistics_mostpopular_MostPopular_div_tableContainer';
        } else {
            prevSelector = '#interactive-stats-' + data + '_div_tableContainer';
        }
        return prevSelector;
    }

    function switchCategory(data) {
        if (data.prev) {
            var queryString = insertParam('category', data.new);
            pushUrl(queryString, function () {
                sandbox.publish('interactive-stats-table--switch-category-start', data);
            });
        }
    }

    function switchCategoryStart(data) {
        var prev = data.prev || currentCategory;
        previousCategory = prev;
        currentCategory = data.new;

        $('#aspect_statistics_mostpopular_MostPopular_field_bytype').val(currentCategory);
        updateTabs();

        if (prev) {
            var prevSelector = getSelector(data.prev);
            $(prevSelector).fadeOut(transitionTime);
        }

        var categorySelect = $('#aspect_statistics_mostpopular_MostPopular_field_category');
        categorySelect.data('prev', data.new);


        if (knownCategories.indexOf(data.new) < 0) {
            knownCategories.push(data.new)
        }
    }

    function switchCategoryEnd(category) {
        // these 'end' events could arrive together if the server responses are slow
        // so make sure only the last one will be displayed
        for (var i = 0, length = knownCategories.length; i < length; i++) {
            var knownCategory = knownCategories[i];
            $(getSelector(knownCategory)).hide();
        }

        var newSelector = getSelector(category);
        $(newSelector).fadeIn(transitionTime);
    }

    function updateDropdowns(dropdowns) {
        $('#aspect_statistics_mostpopular_MostPopular_p_controls')
            .find('select').each(function (i, select) {
            var $elect = $(select);
            var name = $elect.attr('name');
            if (dropdowns.indexOf(name) < 0) {
                $elect.hide();
            } else {
                $elect.show();
            }
        });
    }

    function makeTabLink(knownCategory) {
        var link = $('<a href="#" />');
        link.text(mpTranslate('mp-' + knownCategory));
        link.click(function (e) {
            e.preventDefault();
            sandbox.publish('interactive-stats-table--switch-category',
                {
                    prev: getPreviousCategory(),
                    new: knownCategory
                }
            );
        });
        return link;
    }

    function makeTab(knownCategory, active) {
        var listItem = $('<li role="presentation" />');
        if (active) {
            listItem.addClass('active');
            previousCategory = knownCategory;
        }
        var link = makeTabLink(knownCategory);
        listItem.append(link);
        tabs.append(listItem);
    }

    function updateTabs() {
        if (!tabs && knownCategories.length >= 2) {
            tabs = $('<ul class="nav nav-tabs"/>');
            $('.main-content').prepend(tabs);
        }
        if (tabs) {
            tabs.empty();
            for (var i = 0, length = knownCategories.length; i < length; i++) {
                var knownCategory = knownCategories[i];
                makeTab(knownCategory, knownCategory === currentCategory);
            }
        }
    }

    function isKnown(name) {
        return !isNotKnown(name);
    }

    function isMainCategory(name) {
        return window.atmire.CUA.mp.mainCategories.indexOf(name) >= 0;
    }

    function isNotKnown(name) {
        return knownCategories.indexOf(name) < 0;
    }

    function registerCategory(data) {
        if (isNotKnown(data.name)) {
            knownCategories.push(data.name)
        }
        if (knownCategories.length >= 2) {
            if (currentCategory == null) {
                currentCategory = knownCategories[0];
            }
            updateTabs();
        }
    }

    Core.loadModule('interactive-stats-categorty-switcher', function (sandboxx) {
        sandbox = sandboxx;

        atmire.CUA = atmire.CUA || {};
        atmire.CUA.triggerUpdate = function () {
            if (dataLoadedOnce) {
                sandbox.publish('interactive-stats-table--switch-category-start',
                    {prev: previousCategory, new: currentCategory});
            }
        };

        var category = getParam('category');
        if (category != null) {
            $('input#aspect_statistics_mostpopular_MostPopular_field_bytype').val(category);
        }

        return {
            init: function () {
                sandbox.subscribe('interactive-stats-table--switch-category', function (data) {
                    switchCategory(data);
                });
                sandbox.subscribe('interactive-stats-table--register-category', function (data) {
                    registerCategory(data);
                });
                sandbox.subscribe('interactive-stats-table--switch-category-start',
                    switchCategoryStart);
                sandbox.subscribe('interactive-stats-table--switch-category-end',
                    switchCategoryEnd);
                sandbox.subscribe('interactive-stats-table--switch-category-dropdowns',
                    function (dropdowns) {
                        updateDropdowns(dropdowns);
                    }
                );
                sandbox.subscribe('interactive-stats-table--newdata',
                    function () {
                        dataLoadedOnce = true;
                    });
            }
        };
    });

    $(document).ready(function () {
        var category = getParam('category');
        if (category != null && isKnown(category) && category !== currentCategory) {
            sandbox.publish('interactive-stats-table--switch-category-start',
                {prev: previousCategory, new: category});
        }

        // this runs after i18n has been loaded
        atmire.CUA.statlet = atmire.CUA.statlet || {};
        var afterInitCallbacks = atmire.CUA.statlet.afterInitCallbacks = atmire.CUA.statlet.afterInitCallbacks || [];
        afterInitCallbacks.push(updateTabs);
    });

    function getParam(key) {
        var queryString = document.location.search;
        if (queryString.length) {
            kvp = queryString.substr(1).split('&');
            var i = kvp.length;
            var x;
            while (i--) {
                x = kvp[i].split('=');

                if (x[0] == key) {
                    return x[1];
                }
            }
        }
        return null;
    }

})(jQuery);