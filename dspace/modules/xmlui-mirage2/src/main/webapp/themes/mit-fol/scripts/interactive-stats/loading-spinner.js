(function ($) {[]

    function spinner_start() {

        var controls = $('#aspect_statistics_mostpopular_MostPopular_p_controls');
        $('#aspect_statistics_mostpopular_MostPopular_div_warning .downloads,#aspect_statistics_mostpopular_MostPopular_div_warning .items')
            .slideUp();

        var ld = $('<div id="loading" class="alert"/>')
            .insertAfter(controls)
            .append("Now loading: ");
        var sp = $('<div id="loadingopacity" class=""/>').hide().insertAfter(controls);
        $('option:selected', controls).each(function () {

            ld.append($(this).text());
            if ($('select', controls).last()[0] !== $(this).parent()[0]) {
                ld.append(", ")
            }
        });
        ld.fadeIn(300);
        sp.fadeIn(300);
    }

    function spinner_stop() {
        var ld = $('#loading.alert');
        var sp = $('#loadingopacity');
        ld.fadeOut(300, function () {
            $(this).remove();
        });
        sp.fadeOut(300, function () {
            $(this).remove();
        });
    }

    Core.loadModule('interactive-stats-loading-spinner', function (sandbox) {
        return {
            init: function () {
                sandbox.subscribe('interactive-stats-table--spinner-start', spinner_start);
                sandbox.subscribe('interactive-stats-table--spinner-stop', spinner_stop);
            }
        };
    });

})(jQuery);
