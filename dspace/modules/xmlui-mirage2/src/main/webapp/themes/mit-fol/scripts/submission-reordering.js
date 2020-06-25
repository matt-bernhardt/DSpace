$(function () {
    $('span.reorderingarrow').click(function () {
        var position = $(this).attr('position');
        var metadataField = $(this).attr('field');
        var moveDown = $(this).hasClass('glyphicon-arrow-down');
        var updatePositionValues = function (currentPosition, toUpdatePosition) {
            swapField('_last_', currentPosition, toUpdatePosition);
            swapField('_first_', currentPosition, toUpdatePosition);
            swapField('_authority_', currentPosition, toUpdatePosition);
            swapField('_confidence_', currentPosition, toUpdatePosition);

        };
        var swapField = function (field, currentPosition, toUpdatePosition) {
            var currentField = $('input[name="' + metadataField + field + currentPosition + '"]');
            var toUpdateField = $('input[name="' + metadataField + field + toUpdatePosition + '"]');
            currentField.attr('name', metadataField + field + toUpdatePosition);
            toUpdateField.attr('name', metadataField + field + currentPosition);
        };
        var checkAndUpdateValues = function (clickedElement, arrowDirection, currentPosition, toUpdatePosition) {
            var toUpdateValue = $('span.reorderingarrow.glyphicon-arrow-' + arrowDirection + '[position="' + toUpdatePosition + '"]');
            if (toUpdateValue.length > 0) {
                // Only try if there actually IS a value to update
                var toUpdateCheckbox = toUpdateValue.parent();
                var toUpdateLabel = toUpdateCheckbox.find('label');
                var currentCheckBox = clickedElement.parent();
                var currentLabel = currentCheckBox.find('label');

                // Update the positions on the checkboxes in the label element
                toUpdateLabel.find('input[value="'+metadataField+'_'+toUpdatePosition+'"]').attr('value',metadataField+'_'+currentPosition);
                currentLabel.find('input[value="'+metadataField+'_'+currentPosition+'"]').attr('value',metadataField+'_'+toUpdatePosition);
                // Remove the wrapping labels from the checkbox element
                currentLabel.remove();
                toUpdateLabel.remove();
                // Add the labels to the destination wrapper
                currentCheckBox.prepend(toUpdateLabel);
                toUpdateCheckbox.prepend(currentLabel);
                if ($('input[name="' + metadataField + '_authority' + position + '"]') !== undefined) {
                    updatePositionValues(position, toUpdatePosition);
                } else {
                    swapField('_', position, toUpdatePosition);
                }
            }
        };
        if (moveDown) {
            var toUpdatePosition = +position + 1;
            checkAndUpdateValues($(this), 'down', position, toUpdatePosition);

        } else {
            var toUpdatePosition = +position - 1;
            checkAndUpdateValues($(this), 'up', position, toUpdatePosition);
        }
    })
});