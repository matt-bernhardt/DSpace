/**
 * Created by roeland on 04/12/14.
 */

(function ($) {

    
    Core.loadModule('interactive-stats-chart', function (sandbox) {

        return {
            init: function () {
                sandbox.subscribe('interactive-stats-table--newdata', loadChart);
            }
        };
    });

    var alreadyLoaded = false;
    var geoStatChartCleanhtml = "";

    function isValidType(type){
        return window.atmire.CUA.mp.isCountryCategory(type);
    }

    function loadChart(dt) {
        var type = $('input#aspect_statistics_mostpopular_MostPopular_field_bytype').val();
        var mapWrapper = $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-chart_wrapper');

        if (mapWrapper.length === 0) {
            if (!$.isFunction(Handlebars.compile)) {
                getHandlebars($, function () {
                    loadChart(dt);
                });
                return;
            }
            var template = DSpace.getTemplate('geo-stats-chart');
            var html = template({});
            mapWrapper = $(html);
            mapWrapper.insertBefore(
                $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-table'));
        }

        var geoStatChart = $('#aspect_statistics_mostpopular_MostPopular_div_geo-stat-chart');
        var disclaimer = $('.geochartDisclaimer');
        if (dt.results && dt.results.length && isValidType(type)) {
            mapWrapper.show();
            geoStatChart.show();
            var statable = $('#aspect_statistics_mostpopular_MostPopular_table_statable');
            var statableModel = statable.data("model");
            var sort_by = statableModel.data.sort_by;
            var label = "";
            var labelkey = "";
            if (sort_by === 0) {
                label = $(document).data('i18n')['wb.geochart.downloads'];
                labelkey = "downloads";
            }
            if (sort_by === 1) {
                label = $(document).data('i18n')['wb.geochart.views'];
                labelkey = "views";
            }
            if (sort_by === 2) {
                label = $(document).data('i18n')['wb.geochart.visits'];
                labelkey = "visits";
            }
            //we need to do this in javascript because Rafael JS doesn't pass on the class atribute;
            var colours = ["#FFFFFF", "#CFEDFB", "#9CD2ED", "#70BDFF", "#4D739E"];
            var series = [];
            var areas = {};
            $.each(dt.results, function (index, item) {
                var value = item.count[sort_by].replace(/,/g, '') * 1;
                series.push(value);
                areas[item.attributes.code] = {
                    value: value,
                    tooltip: {content: '<span style=\"font-weight:bold;\">' + item.label + ": " + value.toLocaleString() + " " + label + '</span>'}
                };
                if (item.url) {
                    var href = replace_nbitems(item.url, statableModel.orig_nbitems);
                    href = replace_collection(href);
                    // var hrefIndex = href.indexOf("country?");
                    // if (hrefIndex >= 0) {
                    //     href = "city?" + href.substring("country?".length);
                    // }
                    areas[item.attributes.code].href = href;
                }
            });
            for (var i in $.fn.mapael.maps.countries.elems) {
                if (areas[i] === undefined) {
                    areas[i] = {
                        value: 0,
                        href: '#',
                        tooltip: {content: '<span style=\"font-weight:bold;\">' + getCountryName(i) + ": 0" + " " + label + '</span>'}
                    };
                }
            }
            var gs = new geostats(series);
            var classes = gs.getClassGeometricProgression(6).slice(2);
            var slices = [];
            $.each(classes, function (index, item) {
                var o = {};
                if (index !== 0) o.min = (Math.ceil(classes[index - 1]));
                if (index !== (classes.length - 1)) o.max = Math.ceil(item);
                o.attrs = {
                    fill: colours[index]
                };
                if (o.min === undefined) {
                    o.label = i18nParametrize('wb.geochart.fewer_than_' + labelkey,
                        o.max.toLocaleString());
                } else if (o.max === undefined) {
                    o.label = i18nParametrize('wb.geochart.more_than_' + labelkey,
                        o.min.toLocaleString());
                } else {
                    o.label = i18nParametrize('wb.geochart.between_' + labelkey,
                        o.min.toLocaleString(),
                        o.max.toLocaleString());
                }
                slices.push(
                    o
                );
            });
            var options = {
                map: {
                    name: "countries",
                    zoom: {
                        enabled: true,
                        maxLevel: 10,
                        init: {
                            level: 0,
                            latitude: 476.430938,
                            longitude: 114.186982
                        }
                    },
                    defaultArea: {
                        attrs: {
                            stroke: "#444",
                            "stroke-width": .5,
                            class: "defaultArea",
                            fill: "white"
                        }
                    }
                },
                legend: {
                    area: {
                        title: " ",
                        slices: slices//,
                        //mode:window.atmire.viewport_is_lg()?"horizontal":"vertical"
                    }
                },
                areas: areas
            };
            if (!alreadyLoaded) {
                geoStatChartCleanhtml = geoStatChart.html();
                geoStatChart.mapael(options);
                geoStatChart.find('.areaLegend').append(disclaimer);
                alreadyLoaded = true;
            } else {
                geoStatChart.html(geoStatChartCleanhtml);
                geoStatChart.mapael(options);
                geoStatChart.find('.areaLegend').append(disclaimer);
                // geoStatChart.trigger('update', [options]); // does not update the legend
            }
            geoStatChart.find('svg path').attr('vector-effect', 'non-scaling-stroke');
            var hideTooltip = function () {
                $('.mapTooltip').hide();
            };
            $('body').on('mouseover', hideTooltip);
        } else {
            mapWrapper.hide();
            geoStatChart.hide();
        }
    }

})(jQuery);


var isoCountries = {
    '99': 'Arunachal Pradesh',
    'AF': 'Afghanistan',
    'AX': 'Aland Islands',
    'AL': 'Albania',
    'DZ': 'Algeria',
    'AS': 'American Samoa',
    'AD': 'Andorra',
    'AO': 'Angola',
    'AI': 'Anguilla',
    'AQ': 'Antarctica',
    'AG': 'Antigua And Barbuda',
    'AR': 'Argentina',
    'AM': 'Armenia',
    'AW': 'Aruba',
    'AU': 'Australia',
    'AT': 'Austria',
    'AZ': 'Azerbaijan',
    'BS': 'Bahamas',
    'BH': 'Bahrain',
    'BD': 'Bangladesh',
    'BB': 'Barbados',
    'BY': 'Belarus',
    'BE': 'Belgium',
    'BZ': 'Belize',
    'BJ': 'Benin',
    'BM': 'Bermuda',
    'BT': 'Bhutan',
    'BO': 'Bolivia',
    'BA': 'Bosnia And Herzegovina',
    'BW': 'Botswana',
    'BV': 'Bouvet Island',
    'BR': 'Brazil',
    'IO': 'British Indian Ocean Territory',
    'BN': 'Brunei Darussalam',
    'BG': 'Bulgaria',
    'BF': 'Burkina Faso',
    'BI': 'Burundi',
    'KH': 'Cambodia',
    'CM': 'Cameroon',
    'CA': 'Canada',
    'CV': 'Cape Verde',
    'KY': 'Cayman Islands',
    'CF': 'Central African Republic',
    'TD': 'Chad',
    'CL': 'Chile',
    'CN': 'China',
    'CX': 'Christmas Island',
    'CC': 'Cocos (Keeling) Islands',
    'CO': 'Colombia',
    'KM': 'Comoros',
    'CG': 'Congo',
    'CD': 'Congo, Democratic Republic',
    'CK': 'Cook Islands',
    'CR': 'Costa Rica',
    'CI': 'Cote D\'Ivoire',
    'HR': 'Croatia',
    'CU': 'Cuba',
    'CY': 'Cyprus',
    'CZ': 'Czech Republic',
    'DK': 'Denmark',
    'DJ': 'Djibouti',
    'DM': 'Dominica',
    'DO': 'Dominican Republic',
    'EC': 'Ecuador',
    'EG': 'Egypt',
    'SV': 'El Salvador',
    'GQ': 'Equatorial Guinea',
    'ER': 'Eritrea',
    'EE': 'Estonia',
    'ET': 'Ethiopia',
    'FK': 'Falkland Islands (Malvinas)',
    'FO': 'Faroe Islands',
    'FJ': 'Fiji',
    'FI': 'Finland',
    'FR': 'France',
    'GF': 'French Guiana',
    'PF': 'French Polynesia',
    'TF': 'French Southern Territories',
    'GA': 'Gabon',
    'GM': 'Gambia',
    'GE': 'Georgia',
    'DE': 'Germany',
    'GH': 'Ghana',
    'GI': 'Gibraltar',
    'GR': 'Greece',
    'GL': 'Greenland',
    'GD': 'Grenada',
    'GP': 'Guadeloupe',
    'GU': 'Guam',
    'GT': 'Guatemala',
    'GG': 'Guernsey',
    'GN': 'Guinea',
    'GW': 'Guinea-Bissau',
    'GY': 'Guyana',
    'HT': 'Haiti',
    'HM': 'Heard Island & Mcdonald Islands',
    'VA': 'Holy See (Vatican City State)',
    'HN': 'Honduras',
    'HK': 'Hong Kong',
    'HU': 'Hungary',
    'IS': 'Iceland',
    'IN': 'India',
    'ID': 'Indonesia',
    'IR': 'Iran, Islamic Republic Of',
    'IQ': 'Iraq',
    'IE': 'Ireland',
    'IM': 'Isle Of Man',
    'IL': 'Israel',
    'IT': 'Italy',
    'JM': 'Jamaica',
    'JP': 'Japan',
    'JE': 'Jersey',
    'JO': 'Jordan',
    'KZ': 'Kazakhstan',
    'KE': 'Kenya',
    'KI': 'Kiribati',
    'KR': 'Korea',
    'KW': 'Kuwait',
    'KG': 'Kyrgyzstan',
    'LA': 'Lao People\'s Democratic Republic',
    'LV': 'Latvia',
    'LB': 'Lebanon',
    'LS': 'Lesotho',
    'LR': 'Liberia',
    'LY': 'Libyan Arab Jamahiriya',
    'LI': 'Liechtenstein',
    'LT': 'Lithuania',
    'LU': 'Luxembourg',
    'MO': 'Macao',
    'MK': 'Macedonia',
    'MG': 'Madagascar',
    'MW': 'Malawi',
    'MY': 'Malaysia',
    'MV': 'Maldives',
    'ML': 'Mali',
    'MT': 'Malta',
    'MH': 'Marshall Islands',
    'MQ': 'Martinique',
    'MR': 'Mauritania',
    'MU': 'Mauritius',
    'YT': 'Mayotte',
    'MX': 'Mexico',
    'FM': 'Micronesia, Federated States Of',
    'MD': 'Moldova',
    'MC': 'Monaco',
    'MN': 'Mongolia',
    'ME': 'Montenegro',
    'MS': 'Montserrat',
    'MA': 'Morocco',
    'MZ': 'Mozambique',
    'MM': 'Myanmar',
    'NA': 'Namibia',
    'NR': 'Nauru',
    'NP': 'Nepal',
    'NL': 'Netherlands',
    'AN': 'Netherlands Antilles',
    'NC': 'New Caledonia',
    'NZ': 'New Zealand',
    'NI': 'Nicaragua',
    'NE': 'Niger',
    'NG': 'Nigeria',
    'NU': 'Niue',
    'NF': 'Norfolk Island',
    'MP': 'Northern Mariana Islands',
    'NO': 'Norway',
    'OM': 'Oman',
    'PK': 'Pakistan',
    'PW': 'Palau',
    'PS': 'Palestinian Territory, Occupied',
    'PA': 'Panama',
    'PG': 'Papua New Guinea',
    'PY': 'Paraguay',
    'PE': 'Peru',
    'PH': 'Philippines',
    'PN': 'Pitcairn',
    'PL': 'Poland',
    'PT': 'Portugal',
    'PR': 'Puerto Rico',
    'QA': 'Qatar',
    'RE': 'Reunion',
    'RO': 'Romania',
    'RU': 'Russian Federation',
    'RW': 'Rwanda',
    'BL': 'Saint Barthelemy',
    'SH': 'Saint Helena',
    'KN': 'Saint Kitts And Nevis',
    'LC': 'Saint Lucia',
    'MF': 'Saint Martin',
    'PM': 'Saint Pierre And Miquelon',
    'VC': 'Saint Vincent And Grenadines',
    'WS': 'Samoa',
    'SM': 'San Marino',
    'ST': 'Sao Tome And Principe',
    'SA': 'Saudi Arabia',
    'SN': 'Senegal',
    'RS': 'Serbia',
    'SC': 'Seychelles',
    'SL': 'Sierra Leone',
    'SG': 'Singapore',
    'SK': 'Slovakia',
    'SI': 'Slovenia',
    'SB': 'Solomon Islands',
    'SO': 'Somalia',
    'ZA': 'South Africa',
    'GS': 'South Georgia And Sandwich Isl.',
    'ES': 'Spain',
    'LK': 'Sri Lanka',
    'SD': 'Sudan',
    'SR': 'Suriname',
    'SJ': 'Svalbard And Jan Mayen',
    'SZ': 'Swaziland',
    'SE': 'Sweden',
    'CH': 'Switzerland',
    'SY': 'Syrian Arab Republic',
    'TW': 'Taiwan',
    'TJ': 'Tajikistan',
    'TZ': 'Tanzania',
    'TH': 'Thailand',
    'TL': 'Timor-Leste',
    'TG': 'Togo',
    'TK': 'Tokelau',
    'TO': 'Tonga',
    'TT': 'Trinidad And Tobago',
    'TN': 'Tunisia',
    'TR': 'Turkey',
    'TM': 'Turkmenistan',
    'TC': 'Turks And Caicos Islands',
    'TV': 'Tuvalu',
    'UG': 'Uganda',
    'UA': 'Ukraine',
    'AE': 'United Arab Emirates',
    'GB': 'United Kingdom',
    'US': 'United States',
    'UM': 'United States Outlying Islands',
    'UY': 'Uruguay',
    'UZ': 'Uzbekistan',
    'VU': 'Vanuatu',
    'VE': 'Venezuela',
    'VN': 'Viet Nam',
    'VG': 'Virgin Islands, British',
    'VI': 'Virgin Islands, U.S.',
    'WF': 'Wallis And Futuna',
    'EH': 'Western Sahara',
    'YE': 'Yemen',
    'ZM': 'Zambia',
    'ZW': 'Zimbabwe'
};

function getCountryName(countryCode) {
    if (isoCountries.hasOwnProperty(countryCode)) {
        return isoCountries[countryCode];
    } else {
        return countryCode;
    }
}
