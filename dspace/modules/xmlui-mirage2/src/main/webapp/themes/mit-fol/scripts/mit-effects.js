$(function () {

    if ($("#research_news").length > 0) {

        // Load news items from Libraries' news API
        $.getJSON("//libraries.mit.edu/news/wp-json/wp/v2/posts?tags=162")
                .success(function (data) {
                    /** Only the first 2 articles **/
                    data = data.slice(0, 2);


                    var container = $("#research_news");
                    var items = [];

                    $.each(data, function (key, val) {
                        var itemDate = new Date(val.date);
                        var dateFormat = {
                            year: "numeric",
                            month: "long",
                            day: "numeric"
                        };
                        items.push("<div class='ds-static-div newsitem'>" +
                                "<p class='ds-paragraph title'><a href='" + val.link + "'>" + val.title.rendered + "</a></h2>" +
                                "<p class='ds-paragraph dateline'>" + itemDate.toLocaleDateString("en-us", dateFormat) + "</p>" +
                                "<p class='ds-paragraph'>" + val.excerpt.rendered + "</p>" +
                                "</div>"
                        );
                    });

                    $("<div>", {
                        "class": "post-list",
                        html: items.join("")
                    }).appendTo(container);

                })
                .fail(function () {
                    console.log('Failure parsing news item feed');
                });

    }
})