(function($) {


    //---------------------------------
    //-------- Submission page --------
    //---------------------------------

    var licenseMenu = $('select[name="license-menu"]');
    var licenseContentList = $('.license-content-list');

    licenseMenu.change(function () {

        var newLicense = 'license-' + (licenseMenu.find('option:selected').index() +1);
        getLicenseContent(newLicense);
    });

    licenseMenu.trigger("change");


    function getLicenseContent(key){
        licenseContentList.find('li:not([class*="hidden"])').addClass("hidden");
        var licenseContent = licenseContentList.find('li#'+key);
        licenseContent.toggleClass("hidden");
    }

    //---------------------------------
    //------- Item display page -------
    //---------------------------------

    $('div.bitstream-license').find('a.license-key').click(function (e) {
        e.preventDefault();
        $(this).next('.license-content')
                .toggleClass('hidden');
        $(this).parent('div.bitstream-license').siblings().find('.license-content:not(.hidden)').addClass('hidden');
    })

})(jQuery);