/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
(function ($) {
    $('div.list-and-text-box').each(function () {
        var emptyValueField = $(this).find('input[value=""]');
        var fieldname = emptyValueField.attr('name');
        var hiddenField = $('input[name=' + fieldname + '_text]');
        var textFieldHTML = '<div class="list-and-text-field hidden"><label for="' + fieldname + '_temp" class="control-label">Enter value:</label>' +
                '<div class="row"><div class="col-xs-12 col-sm-6"><input class="form-control" id="' + fieldname + '_temp" name="' + fieldname + '_temp" type="text" value=""></div></div></div>';

        var checked = emptyValueField.attr('checked') == 'checked';


        if (emptyValueField != undefined) {
            emptyValueField.closest('div').append(textFieldHTML);

            var tempField = $(this).find('#' + fieldname + '_temp');
            tempField.val(hiddenField.val());

            tempField.change(function () {
                hiddenField.val(tempField.val());
            });

            if (checked) {
                tempField.closest('.list-and-text-field').removeClass("hidden");
            }


            emptyValueField.change(function () {
                checked = !checked;

                if (checked) {
                    tempField.closest('.list-and-text-field').removeClass("hidden");
                    hiddenField.val(tempField.val());

                } else {
                    tempField.closest('.list-and-text-field').addClass("hidden");
                    hiddenField.val("");
                }
            });
        }
    })


})(jQuery);