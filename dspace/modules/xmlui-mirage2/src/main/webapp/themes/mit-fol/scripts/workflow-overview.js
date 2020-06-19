$(function() {
    var handleCheckBoxSelections = function () {
        var allSelectedBefore = $('input[name="all-selected"]').val();
        $('input[type="checkbox"][name="item-identifier"]').each(function () {
            if (allSelectedBefore === 'false') {
                $(this).prop('checked', true);
            } else {
                $(this).prop('checked', false);
            }
        });
        if (allSelectedBefore === 'false') {
            $('input[name="all-selected"]').val("true");
        } else {
            $('input[name="all-selected"]').val("false");
        }
    };
    $('input[name="workflow-select-all-page"], input[name="workflow-deselect-all-page"]').click(function(){
        $(this).addClass('hidden');
        if($(this).attr('name')=='workflow-select-all-page'){
            $('input[name="workflow-deselect-all-page"]').removeClass('hidden');
        }else{
            $('input[name="workflow-select-all-page"]').removeClass('hidden');

        }
        handleCheckBoxSelections();
    });
    $('input[name="workflow-select-all-global"], input[name="workflow-deselect-all-global"]').click(function(){
        $(this).addClass('hidden');
        // var href = $('a#aspect_eperson_Navigation_item_batch-workflow-xref').attr('href');
        var formElement = $('form[action^="batch-workflow-task"]');
        var href =formElement.attr('action')
        if($(this).attr('name')=='workflow-select-all-global'){
            $('input[name="workflow-deselect-all-global"]').removeClass('hidden');
                if(href.indexOf('?')>0){
                    href+="&all-selected=true";
                }else{
                    href+="?all-selected=true";
                }
            $('input.page-wide').each(function(){
                $(this).prop('disabled', true);
            })
            $('input[type="checkbox"][name="item-identifier"]').each(function () {
                $(this).prop('disabled', true);
            });
        }else {
            $('input[name="workflow-select-all-global"]').removeClass('hidden');
            var formElement = $('form[action^="batch-workflow-task"]');
            var href =formElement.attr('action')
            // var href = $('a#aspect_eperson_Navigation_item_batch-workflow-xref').attr('href');
                if(href.indexOf('&all-selected=true')>0){
                    href = href.replace("&all-selected=true",'');
                }else{
                    href = href.replace("?all-selected=true",'');
                }
            $('input.page-wide').each(function(){
                $(this).prop('disabled', false);
            })
            $('input[type="checkbox"][name="item-identifier"]').each(function () {
                $(this).prop('disabled', false);
            });
        }
        formElement.attr('action',href);
        handleCheckBoxSelections();


    })
    $('input[type="checkbox"][name="item-identifier"]').click(function(){
        $('input[name="all-selected"]').val("false");
        $('input[name="workflow-select-all-page"]').removeClass('hidden');
        $('input[name="workflow-deselect-all-page"]').addClass('hidden');
        var href = $('a#aspect_eperson_Navigation_item_batch-workflow-xref').attr('href');
        if(href.indexOf('&all-selected=true')>0){
            href = href.replace("&all-selected=true",'');
        }else{
            href = href.replace("?all-selected=true",'');
        }
        $('a#aspect_eperson_Navigation_item_batch-workflow-xref').attr('href',href);
    });

    $('a#aspect_eperson_Navigation_item_batch-workflow-xref').click(function (e) {
        e.preventDefault();
        var formElement = $('form[action^="batch-workflow-task"]');
        if (formElement.attr('action').indexOf('all-selected=true') > 0) {
            formElement.submit();
        } else {
            formElement.empty();
            $('input[name="item-identifier"]:checked').each(function (index) {
                var jQuery = $(this).clone(true,true);
                jQuery.attr('name','item-identifier_'+index);
                formElement.append(jQuery);
            })
            formElement.submit();
        }
    });

    $('input[name="go_back"]').click(function (e){
        e.preventDefault();
        window.history.back();
    });

    $('input[name="batch_rejection_reason"]').on('input',function () {
        var submitContinueButton = $('input[name="submit_continue"]');
        if ($(this).val().length > 0) {
            submitContinueButton.removeAttr('disabled');
        } else {
            submitContinueButton.attr('disabled', true);
        }
    })
});