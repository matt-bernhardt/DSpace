$(function() {
    $('select[name="collectionSelection"]').change(function() {
        var selectedValue = $(this).find('option:selected').val();
        var submitContinueButton = $('input[name="submit_continue"]');
        if(selectedValue !== undefined && selectedValue!== ''){
            submitContinueButton.removeAttr('disabled');
        }else{
            submitContinueButton.attr('disabled',true);
        }
    });
});