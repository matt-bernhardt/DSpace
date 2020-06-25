(function ($) {
    window.atmire = window.atmire || {};
    window.atmire.CUA = window.atmire.CUA || {};
    window.atmire.CUA.statlet = window.atmire.CUA.statlet || {};
    var afterLoadAdditionsCallbacks = atmire.CUA.statlet.afterLoadAdditionsCallbacks = atmire.CUA.statlet.afterLoadAdditionsCallbacks || [];
    afterLoadAdditionsCallbacks.push(noMasonry);

    function noMasonry() {
        $('#aspect_statistics_statlet_StatletTransformer_div_statswrapper')
            .find('.widgets').removeClass('widgets');
        $('body').append($('<div class="widgets hidden">'));
    }

})(jQuery);
