(function ($) {
    var store = {};
    function countryTab(category) {
        store[category] = {};

        function getSandbox() {
            return store[category].sandbox;
        }

        function setSandbox(sandbox) {
            return store[category].sandbox = sandbox;
        }

        function getActive() {
            return store[category].active;
        }

        function setActive(active) {
            return store[category].active = active;
        }

        function getModel() {
            return store[category].model;
        }

        function setModel(model) {
            return store[category].model = model;
        }


        var model = {
            category: category,
            headers: [
                {
                    name: 'mit.most-popular.country',
                    sortable: false
                }, {
                    name: 'mit.most-popular.file-downloads',
                    sortable: true,
                    sorted: false,
                    sort_value: 0,
                    data_cell_class: ''
                }, {
                    name: 'mit.most-popular.views',
                    sortable: true,
                    sorted: false,
                    sort_value: 1,
                    data_cell_class: ''
                }, {
                    name: 'mit.most-popular.total',
                    sortable: true,
                    sorted: false,
                    sort_value: 2,
                    data_cell_class: ''
                }
            ],
            rows: [
                // {
                //     cells: [
                //         {content: 'Test'}, {content: '1'}, {content: '2'}
                //     ]
                // },
            ]
        };
        setModel(model);

        Core.loadModule('interactive-stats-' + category, function (sandbox) {
            setSandbox(sandbox);
            return {
                init: function () {
                    sandbox.subscribe('interactive-stats-table--switch-category-start',
                        function (data) {
                            switchCategory(sandbox, data);
                        }
                    );
                }
            }
        });

        $(document).ready(function () {
            var type = $('input#aspect_statistics_mostpopular_MostPopular_field_bytype').val();
            var model = getModel();
            if (type === model.category) {
                var sandbox = getSandbox();
                sandbox.publish('interactive-stats-table--register-category',
                    {name: category.replace('country','item')}); // {name: 'item-by-author'}
                sandbox.publish('interactive-stats-table--register-category',
                    {name: model.category});
                sandbox.publish('interactive-stats-table--switch-category-start',
                    {prev: null, new: model.category});
            }
        });

        function switchCategory(sandbox, categoryData) {
            if (categoryData.new === getModel().category) {
                setActive(true);
                update();
            } else {
                setActive(false);
            }
        }

        function getSortValue() {
            var value = 2;
            iterateHeaders(function (header) {
                if (header.sorted) {
                    value = header.sort_value;
                }
            });
            return value;
        }

        function update() {
            if (getActive()) {
                var url = DSpace.context_path + '/JSON/cua/geo-stat-ajax';
                var parameters = getMostPopularData();
                parameters.sort_by = getSortValue();

                var sandbox = getSandbox();
                sandbox.publish('interactive-stats-table--spinner-start');
                $.ajax({
                    dataType: "json",
                    url: url,
                    data: parameters,
                    success: function (data) {
                        updateModel(data);
                        getHandlebars($, updateView);

                        sandbox.publish('interactive-stats-table--spinner-stop');
                        sandbox.publish('interactive-stats-table--switch-category-end',
                            getModel().category);
                        sandbox.publish('interactive-stats-table--newdata', data);
                    },
                    error: function (a, b, c) {
                        sandbox.publish('interactive-stats-table--spinner-stop');
                        console.log(c);
                    }
                });
            }
        }


        function updateModel(data) {
            var rows = [];
            var maxRows = $('#aspect_statistics_mostpopular_MostPopular_field_nbitems').val();
            var dataLength = Math.min(maxRows, data.results.length);
            for (var i = 0; i < dataLength; i++) {
                var result = data.results[i];
                var cells = [];

                var label = {
                    content: result.label,
                    url: result.url
                };
                cells.push(label);
                var counts = result.count;

                for (var j = 0, countsLength = counts.length; j < countsLength; j++) {
                    cells.push({
                        content: counts[j]
                    });
                }
                rows.push({
                    cells: cells
                });
            }
            var model = getModel();
            model.rows = rows;
            if (data.total) {
                model.total_downloads = data.total[0];
                model.total_views = data.total[1];
            }
            setModel(model);
        }

        function getTable() {
            // return $('#interactive-stats-country-by-author_div_tableContainer');
            return $('#interactive-stats-' + category + '_div_tableContainer');
        }

        function updateView() {
            var template = DSpace.getTemplate('interactive-stats-table');
            var html = template(getModel());

            var table = getTable();
            if (table.length) {
                table.remove();
            }

            var newTable = $(html);
            var parentDiv = $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-table');
            parentDiv.append(newTable);

            createActions();
        }


        function createActions() {
            var table = getTable();
            $(table).find('.sortable').click(clickHeader);
        }

        function clickHeader() {
            var name = $(this).data('name');
            var doUpdate = true;
            iterateHeaders(function (header) {
                if (header.sortable) {
                    var wasSorted = header.sorted;
                    header.sorted = header.name === name;
                    if (header.sorted && wasSorted) {
                        doUpdate = false;
                    }
                }
            });
            if (doUpdate) {
                update();
            }
        }

        function iterateHeaders(fn) {
            var headers = getModel().headers;
            for (var h = 0, headersLength = headers.length; h < headersLength; h++) {
                var header = headers[h];
                fn(header);
            }
        }
    }

    for (var i = 0, categoriesLength = window.atmire.CUA.mp.mainCategories.length; i < categoriesLength; i++) {
        var category = window.atmire.CUA.mp.mainCategories[i];
        var countryCategory = window.atmire.CUA.mp.getCountryCategory(category);
        if (countryCategory != null) {
            countryTab(countryCategory);
        }
    }
})(jQuery);