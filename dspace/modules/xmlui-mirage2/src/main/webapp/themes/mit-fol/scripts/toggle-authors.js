/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
function showAuthors() {
    $('#item-view-show-all-authors-link').addClass('hidden');
    $('#item-view-hide-authors-link').removeClass('hidden');

    $('#item-view-authors-truncated').addClass('hidden');

    $('span[class*=author-list-]').removeClass('hidden');
    $('span[class*=author-spacer-list-]').removeClass('hidden');
}

function hideAuthors() {
    $('#item-view-hide-authors-link').addClass('hidden');
    $('#item-view-show-all-authors-link').removeClass('hidden');

    $('#item-view-authors-truncated').removeClass('hidden');

    $.each($('span[class*=author-list-]'), function() {
        var index = parseInt($(this).attr('class').substring(12));

        if(index > 5) {
            $(this).addClass('hidden');
        }
    });

    $.each($('span[class*=author-spacer-list-]'), function() {
        var index = parseInt($(this).attr('class').substring(19));

        if(index > 5) {
            $(this).addClass('hidden');
        }
    });
}