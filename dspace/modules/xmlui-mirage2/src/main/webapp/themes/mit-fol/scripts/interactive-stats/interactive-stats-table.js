/**
 * Created by Bavo Van Geit
 * Date: 14/12/12
 * Time: 14:33
 */
window.atmire = window.atmire || {};
window.atmire.CUA = window.atmire.CUA || {};
window.atmire.CUA.mp = window.atmire.CUA.mp || {};
window.atmire.CUA.mp.mainCategories =
    ['visits', 'item-by-author', 'bycountry', 'author', 'department', 'item-by-department'];

window.atmire.CUA.mp.getCountryCategory = function (category) {
    if (category === 'item-by-author') {
        return 'country-by-author';
    }
    if (category === 'item-by-department') {
        return 'country-by-department';
    }
    return null;
};

window.atmire.CUA.mp.isCountryCategory = function (category) {
    return category === 'country-by-author'
           || category === 'country-by-department'
           || category === 'bycountry';
};

var map;
var spinner;
(function ($) {
    var TIMEOUT_ID;
    var sandbox;
    var activeTable = 'visits';
    var validCategories = window.atmire.CUA.mp.mainCategories;
    var myType;
    var initiated = false;

    Core.loadModule('interactive-stats-table', function (sandboxx) {
        sandbox = sandboxx;
        return {
            init: function () {
                if ($('#aspect_statistics_mostpopular_MostPopular_table_statable').length > 0) {
                    sandbox.subscribe('interactive-stats-table--switch-category-start',
                        function (data) {
                            if (!initiated) {
                                init();
                                initiated = true;
                            }

                            activeTable = data.new;
                            if (isValidCategory(data.new)) {
                                loadTable();
                            }
                        });
                }
            }
        }
    });

    $(document).ready(function () {
        if ($('#aspect_statistics_mostpopular_MostPopular_table_statable').length > 0) {
            var type = $('input#aspect_statistics_mostpopular_MostPopular_field_bytype').val();
            if (isValidCategory(type)) {
                if (typeof type === 'undefined') {
                    type = 'visits';
                }
                myType = type;
                sandbox.publish('interactive-stats-table--register-category', {name: type});
                sandbox.publish('interactive-stats-table--switch-category-start',
                    {prev: null, new: type});

                var countryCategory = window.atmire.CUA.mp.getCountryCategory(type);
                if (countryCategory != null) {
                    sandbox.publish('interactive-stats-table--register-category',
                        {name: countryCategory});
                }
            }
            if (type === "item-by-department" || type === "country-by-department") {
                $('select[name=geo]')
                    .parent()
                    .removeClass('col-sm-3')
                    .addClass('col-sm-2');
                $('select[name=collection]')
                    .parent()
                    .removeClass('col-sm-3')
                    .addClass('col-sm-2');
                $('select[name=department]').change(function () {
                    var queryString = insertParam('department', $(this).val());
                    pushUrl(queryString);
                    var selectedCountry = $('select[name=department] option:selected').text();
                    var header = $('h2.ds-div-head');
                    var index = header.text().indexOf('"');
                    header.text(header.text().substring(0, index) + '"' + selectedCountry + '"');
                    triggerUpdate();
                });
            }
        }
    });

    function triggerUpdate() {
        sandbox.publish('interactive-stats-table--switch-category-start',
            {prev: null, new: myType});
    }

    function isValidCategory(category) {
        return validCategories.indexOf(category) >= 0 || (typeof category === 'undefined');
    }

    function init() {

        var table = $('#aspect_statistics_mostpopular_MostPopular_table_statable');
        findAndImportJSFilesWithin($(
            '#aspect_statistics_mostpopular_MostPopular_div_timefilter'),
            function () {
                //IE sucks
                $('th.sortable').each(function () {
                    var $this;
                    $this = $(this);
                    $this.html('<span class="sortable_label">' + $this.text() + '</span><span class="sorticon fa fa-sort-desc">&nbsp;</span></td></tr></tbody></table>')
                });

                atmire.CUA = atmire.CUA || {};
                triggerUpdate = atmire.CUA.triggerUpdate || triggerUpdate;

                $('th.sortable', table).click(function () {
                    var $this = $(this);
                    if ($this.hasClass('sort_by')) return;
                    triggerUpdate();
                    $('.sort_by', table).removeClass('sort_by');
                    $this.addClass('sort_by');
                });

                //table
                $('#aspect_statistics_mostpopular_MostPopular_field_nbitems')
                    .change(triggerUpdate);
                $('#aspect_statistics_mostpopular_MostPopular_field_collection')
                    .change(triggerUpdate);
                $('#aspect_statistics_mostpopular_MostPopular_field_geo').change(triggerUpdate);
                $('select[name=simplefilter]').change(triggerUpdate);
                $('#startCalDiv').datepicker('option', 'onSelect', triggerUpdate);
                $('#endCalDiv').datepicker('option', 'onSelect', triggerUpdate);


                $('#aspect_statistics_mostpopular_MostPopular_field_newCountryCode')
                    .change(function () {
                        var header = $('h1.ds-div-head');
                        var selectedCountry =
                                $('#aspect_statistics_mostpopular_MostPopular_field_newCountryCode option:selected');
                        header.text(selectedCountry.text() + ':' + header.text().split(':').pop());
                        triggerUpdate();
                    });
                triggerUpdate();
            });
    }

    function loadTable() {
        var fallback = false;
        if (isValidCategory(activeTable)) {
            if (TIMEOUT_ID) {
                window.clearTimeout(TIMEOUT_ID);
            }
            //This function is called (among other places) as a callback from the jQueryUI timefilter.
            //jQueryUI sometimes calls it twice as a reaction to the same value change.
            //This timeout ensures that that doesn't trigger two requests.
            TIMEOUT_ID = window.setTimeout(function () {
                sandbox.publish('interactive-stats-table--spinner-start');
                var _data = getMostPopularData();
                $.ajax(atmire.contextPath + '/JSON/cua/geo-stat-ajax', {
                        type: 'POST',
                        dataType: 'json',
                        data: _data,
                        success: function (data) {
                            sandbox.publish('interactive-stats-table--switch-category-end',
                                _data.bytype);
                            sandbox.publish('interactive-stats-table--newdata', data);
                        }
                    }
                );
            }, 30);
        }

        function processData(data) {
            var table = $('#aspect_statistics_mostpopular_MostPopular_table_statable');
            var proto = $('.count-data-proto');
            var noresults = $('#aspect_statistics_mostpopular_MostPopular_div_error');
            var warn = $('#aspect_statistics_mostpopular_MostPopular_div_warning');
            var model = $('#aspect_statistics_mostpopular_MostPopular_table_statable')
                .data("model");
            // var startTimeStamp = model.startTimeStamp;

            $('.count-data').remove();
            table.fadeOut(300).addClass('hidden');
            noresults.fadeOut(300).addClass("hidden");

            if (!fallback) {
                $('p', warn).hide();
            }
            if (data == null || data.results.length == 0) {


                $('.coms', noresults);
                noresults.hide().removeClass("hidden").fadeIn(300);
                var current = $('.sort_by', table);
                if (!fallback) {
                    var fallBackUseless = false;
                    if (data != null && data.total != null && data.total[2] == 0) {
                        fallBackUseless = true;
                    }
                    if (!fallBackUseless) {
                        if (current.closest('th.sortable').hasClass('downloads')) {
                            $('.items', table).click();
                            $('.downloads', warn)
                                .slideDown()
                                .delay(10000)
                                .slideUp();
                        } else if (current.closest('th.sortable')
                                          .hasClass('items')) {
                            $('.downloads', table).click();
                            $('.items', warn).slideDown().delay(10000).slideUp();
                        }
                    }

                    fallback = true;

                } else {
                    $('p', warn).hide();
                    fallback = false;
                }


            } else {

                fallback = false;

                $.each(data.results, function (i, item) {
                    if (i < model.tableSize) {
                        var row = proto.clone();
                        var a = $('.itemname a', row)
                        if (item.html || item.url.length == 0) {
                            a.replaceWith(item.label);
                        } else {
                            a.text(item.label);
                            var url = replace_nbitems(item.url, model.orig_nbitems);
                            a.attr("href", url);
                        }

                        $.each(item.count, function (j, res) {
                            $('.count-' + j, row).text(res);
                        });

                        if (item.additionalCounts != undefined) {
                            $.each(item.additionalCounts, function (j, res) {
                                $('.additional-' + j, row).text(res);
                            });
                        }

                        row.removeClass("count-data-proto");
                        row.addClass("count-data");
                        row.removeClass("hidden");
                        $('#aspect_statistics_mostpopular_MostPopular_table_statable')
                            .append(row);

                    }
                });

                $.each(data.total, function (i, res) {
                    var succ = $('#aspect_statistics_mostpopular_MostPopular_div_total-row-' + i);
                    $(".value", succ).html(res);
                    succ.removeClass('hidden').fadeIn(300);
                });
                table.hide().removeClass('hidden').fadeIn(300);
            }
            sandbox.publish('interactive-stats-table--spinner-stop');
//                    matchHeights();
            updateTitle();
        }

        sandbox.subscribe('interactive-stats-table--newdata', processData);

        function updateTitle() {
            var countryName = $(
                '#aspect_statistics_mostpopular_MostPopular_field_newCountryCode')
                .find(':selected')
                .first()
                .text();
            if (typeof countryName === "string" && countryName !== '') {
                var header = $('#aspect_statistics_mostpopular_MostPopular_div_wrap')
                    .find('.first-page-header')
                    .first();
                var title = header.text();
                if (!title.startsWith(countryName) && title.indexOf(':') > 0) {
                    var newTitle = countryName + title.substring(title.indexOf(':'));
                    header.text(newTitle);
                }
            }
        }
    }

})(jQuery);

var findAndImportJSFilesWithinDone = false;

function findAndImportJSFilesWithin(jqObj, callback) {
    if (findAndImportJSFilesWithinDone) {
        callback();
        return;
    }
    findAndImportJSFilesWithinDone = true;

    var jslink = jqObj.find('[name="functjavascript"]');
    if ($.isFunction(callback)) {
        var callbackID = 'callback' + generateID();
        registerCallbackCounter(callbackID, callback, jslink.length);
        for (var i = 0; i < jslink.length; i++) {
            var val = $(jslink.get(i)).val();
            var semicolonIndex = val.indexOf(";");
            if (semicolonIndex == -1) {
                $.getScript(val, function () {
                    removeCallbackConstraint(callbackID);
                });
            } else {
                var url = val.substring(0, semicolonIndex);
                var method = val.substring(semicolonIndex + 1);
                evalExternalMetod(method, url, function () {
                    removeCallbackConstraint(callbackID);
                });
            }
        }
    } else {
        for (var i = 0; i < jslink.length; i++) {
            var val = $(jslink.get(i)).val();
            var semicolonIndex = val.indexOf(";");
            if (semicolonIndex == -1) {
                $.getScript(val);
            } else {
                var url = val.substring(0, semicolonIndex);
                var method = val.substring(semicolonIndex + 1);
                evalExternalMetod(method, url);
            }
        }
    }
}

function registerCallbackCounter(callbackID, callbackFunction, initialNb) {
    var form = $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-table');
    if (!initialNb) {
        initialNb = 0;
    }
    form.data(callbackID + 'counter', initialNb);
    form.data(callbackID, callbackFunction);
}

function addCallbackConstraint(callbackID) {
    var counterID = callbackID + 'counter';
    var form = $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-table');
    var counter = form.data(counterID) * 1;
    counter++;
    form.data(counterID, counter);
}

function removeCallbackConstraint(callbackID) {
    var counterID = callbackID + 'counter';
    var form = $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-table');
    var counter = form.data(counterID) * 1;
    counter--;
    if (counter == 0) {
        var callbackFunction = form.data(callbackID);
        if ($.isFunction(callbackFunction)) {
            callbackFunction.call(this);
        }
        form.removeData(callbackID);
        form.removeData(counterID);
    } else {
        form.data(counterID, counter);
    }
}

function evalExternalMetod(method, jsUrl, callback) {
    try {
        eval(method + ";");
    } catch (e) {
        //if the method is not defined, the js file containing it is not yet loaded, so load it first.
        jQuery.ajax({
            url: jsUrl, dataType: 'script', async: true, success: function () {
                eval(method + ";");
                if ($.isFunction(callback)) {
                    callback.call(this);
                }
            }, error: function () {
//            console.log(arguments);
            }
        });
    }
}

function uniqueifyIDs(jqObj) {
    var arr = jqObj.find('[id *="generateid"]');
    var html = jqObj.html();
    if (arr.length > 0) {
        jQuery.each(arr, function () {
            var id = $(this).attr('id');
            var toReplace = id.substring(id.indexOf('generateid'));
            var newId = generateID();
            html = html.replace(eval('/' + id + '/g'), newId);
            html = html.replace(eval('/' + toReplace + '/g'), newId);
//            eval('html = html.replace( + /' + toReplace + '/g, \'' + newId + '\');');
        });
        jqObj.html(html);
    }
}

function generateID() {
    var newDate = new Date;
    return newDate.getTime();
}

function toggleSubscribe() {
    // Empty function, this is a mock function to ensure no errors are thrown.
}

function replace_nbitems(url, orig_nbitems) {
    var index = url.indexOf("nbitems=501"); //magic number
    if (index > 0) {
        url = url.substring(0,
            index) + "nbitems=" + orig_nbitems + url.substring(index + "nbitems=501".length);
    }
    return url;
}

function replace_collection(url) {
    // collection=2::22279  -> type=2&id=22279
    var newUrl = url;
    var index = url.indexOf("collection=");
    if (index > 0) {
        var endIndex = url.indexOf("&", index);
        if (endIndex < 0) {
            endIndex = url.length;
        }
        var data = url.substring(index, endIndex).split('=')[1].split('::');
        var type = data[0];
        var id = data[1];
        newUrl = url.substring(0, index) + "type=" + type + "&id=" + id;
        if (endIndex < url.length) {
            newUrl += "&" + url.substring(endIndex);
        }
    }
    return newUrl;
}

function i18nParametrize() {
    var key = arguments[0];

    var message = key;
    if (typeof $(document).data('i18n') != 'undefined' && key in $(document).data('i18n')) {
        message = $(document).data('i18n')[key];
    }

    var i = 1;
    while (arguments[i]) {
        message = message.replace('[' + i + ']', arguments[i]);
        i++;
    }
    return message;
}

function getMostPopularData() {
// var startTimeStamp = (new Date()).getTime();
    var table = $('#aspect_statistics_mostpopular_MostPopular_table_statable');
    var bytype = $('input#aspect_statistics_mostpopular_MostPopular_field_bytype').val();
    if (bytype === undefined) {
        bytype = "";
    }
    var country = $('#aspect_statistics_mostpopular_MostPopular_field_newCountryCode').val();
    if (country === undefined) {
        country = "";
    }
    var department = getParam('department') || $('select[name=simplefilter]').val();
    var _data = {
        nbitems: $('#aspect_statistics_mostpopular_MostPopular_field_nbitems').val(),
        collection: $('#aspect_statistics_mostpopular_MostPopular_field_collection').val(),
        geo: $('#aspect_statistics_mostpopular_MostPopular_field_geo').val(),
        timefilter: $('#aspect_statistics_mostpopular_MostPopular_field_timeFilter').val(),
        simplefilter: $('select[name=simplefilter]').val(),
        time_filter_start_date: $('[id$=_start_date]').val(),
        time_filter_end_date: $('[id$=_end_date]').val(),
        bytype: bytype,
        country: country,
        sort_by: $('.sort_by', table).closest('th.sortable').index() - 1,
        department: department,
        solutionfilter: $('#aspect_statistics_mostpopular_MostPopular_field_solutionfilter').val()
    };

    $('[id^="aspect_statistics_mostpopular_MostPopular_field_filterCode_"]')
        .each(function () {
            var index = $(this)
                .attr('id')
                .replace('aspect_statistics_mostpopular_MostPopular_field_filterCode_', '');
            _data["filterCode_" + index] = $(this).val();
        });
    $('input[id^="aspect_statistics_mostpopular_MostPopular_field_filterType_"]')
        .each(function () {
            var index = $(this)
                .attr('id')
                .replace('aspect_statistics_mostpopular_MostPopular_field_filterType_', '');
            _data["filterType_" + index] = $(this).val();
        });

    if (window.atmire && window.atmire.cua && typeof atmire.setGearMenuSortByOption === 'function') {
        window.atmire.setGearMenuSortByOption();
    }

    var statableModel = table.data("model");
    if (statableModel === undefined) {
        statableModel = {};
    }
    statableModel['data'] = _data;
    // statableModel['startTimeStamp'] = startTimeStamp;

    statableModel['tableSize'] = _data.nbitems;
    statableModel['orig_nbitems'] = _data.nbitems;
    table.data("model", statableModel);

    if ($('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-chart').length > 0
    // || $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-chart-cities').length > 0
    ) {
        _data.nbitems = 501;
    }
    return _data;
}

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

function insertParam(key, value) {
    key = encodeURI(key);
    value = encodeURI(value);

    var kvp = [];
    var queryString = document.location.search;
    if (queryString.length) {
        kvp = queryString.substr(1).split('&');
    }

    var i = kvp.length;
    var x;
    while (i--) {
        x = kvp[i].split('=');

        if (x[0] == key) {
            x[1] = value;
            kvp[i] = x.join('=');
            break;
        }
    }

    if (i < 0) {
        kvp[kvp.length] = [key, value].join('=');
    }

    return kvp.join('&');
}

function pushUrl(queryString, pushCallback) {
    // var usePushState = false;
    var usePushState = true;
    if (usePushState && window.history.pushState) {
        window.history.pushState({}, document.title, location.pathname + '?' + queryString);
        if (typeof pushCallback === "function") {
            pushCallback();
        }
    } else {
        document.location.search = queryString;
    }
}

function mpTranslate(key) {
    if (typeof $(document).data('i18n') != 'undefined' && key in $(document)
        .data('i18n')) {
        return $(document).data('i18n')[key];
    } else {
        return key;
    }
}

function mpTranslateIs(key) {
    var message = key;
    if (typeof $(document).data('i18n') != 'undefined' && key in $(document).data('i18n')) {
        message = $(document).data('i18n')[key];
    }
    message = message.replace('\\n', '<br />');
    return message;
}

function mpFormatNumber(value) {
    if (typeof value === 'undefined') {
        value = '0';
    } else if (typeof value !== 'number') {
        return value;
    }
    var numberFormat = '0,0';
    return numeral(Math.round(value)).format(numberFormat);
}

function mpRegisterHelpers() {
    Handlebars.registerHelper('I18n', mpTranslate);
    Handlebars.registerHelper('I18nIs', mpTranslateIs);
    Handlebars.registerHelper('format_mp_number', mpFormatNumber);
}

mpRegisterHelpers();
(function ($) {
    $(document).ready(function () {
        mpRegisterHelpers();
    });
})(jQuery);

function getHandlebars($, callback) {
    if (!$.isFunction(Handlebars.compile)) {
        Handlebars = undefined;
        $.ajax({
            url: atmire.CUA.getContextPath() + '/aspects/ReportingSuite/handlebars.min.js',
            async: false,
            dataType: "script",
            success: function () {
                mpRegisterHelpers($);
                callback();
            }
        });
    } else {
        mpRegisterHelpers($);
        callback();
    }
}