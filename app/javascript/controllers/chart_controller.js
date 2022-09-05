import { Controller } from "@hotwired/stimulus"
import Highcharts, { setOptions } from 'highcharts';
import Exporting from 'highcharts/modules/exporting';
import ExportData from 'highcharts/modules/export-data';
import Accessibility from 'highcharts/modules/accessibility';
import NoDataToDisplay from 'highcharts/modules/no-data-to-display';
Exporting(Highcharts);
Accessibility(Highcharts);
NoDataToDisplay(Highcharts);
ExportData(Highcharts);

// Connects to data-controller="chart"
export default class extends Controller {
    static values = { url: String, title: String, type: String, translations: Object,
                      subtitle: String }
    connect() {
        this.setLangOptions();
        this.load();
    }
    load() {
        fetch(this.urlValue)
            .then(response => response.json())
            .then((data) => {
              this['load_' + this.typeValue](data);
            });
    }
    load_market_share_distribution_chart(data){
        Highcharts.chart(this.element, {
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie'
            },
            title: {
                text: this.titleValue
            },
            tooltip: {
                pointFormat: '{series.name}: {point.y} (<b>{point.percentage:.1f}%</b>)'
            },
            accessibility: {
                point: {
                    valueSuffix: '%'
                }
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                    }
                }
            },
            series: data
        });
    }
    load_market_share_growth_rate_chart(data){
        var curData = data['current'];
        var prevData = data['previous'];

        const getData = data => data.map((registrar, i) => ({
            name: registrar[0],
            y: registrar[1],
            diff: this.getDiffPercent(registrar[1], prevData['domains'][i][1]),
            color: this.randomRGB()
        }));

        Highcharts.chart(this.element, {
            chart: {
                type: 'bar'
            },
            title: {
                text: this.titleValue,
                align: 'center'
            },
            subtitle: {
                text: this.subtitleValue,
                align: 'center'
            },
            plotOptions: {
                series: {
                    grouping: false,
                    borderWidth: 0
                }
            },
            legend: {
                enabled: false
            },
            tooltip: {
                shared: true,
                // headerFormat: '<span style="font-size: 15px">{point.point.name}</span><br/>',
                // pointFormat: '<span style="color:{point.color}">\u25CF</span> ' + this.translationsValue['yAxisTitle'] + ' - {series.name}: <b>{point.y} ({point.diff}%)</b><br/>',
                formatter: function () {
                    var points = this.points;
                    var result = '<span style="font-size: 15px">' + points[0].key + '</span><br/>';
                    points.forEach(point => {
                        let diff = point.point.diff;
                        result += '<span style="color:' + point.color + '">\u25CF</span> ' + point.series.yAxis.axisTitle.textStr + 
                            ' - ' + point.series.name + ': <b>' + point.y + '</b>';
                        if (diff != undefined && diff != 100) {
                            let color, sign;
                            if (diff > 0) {
                                color = 'rgb(9,138,13)';
                                sign = '+';
                            } else if (diff < 0) {
                                color = 'rgb(233,23,44)';
                                sign = '-';
                            } else {
                                color = 'rgb(0,0,0)';
                                sign = '';
                            }
                            result += ' <span style="color: ' + color + '"><b>(' + sign + point.point.diff + '%)</b></span><br/>';
                        } else {
                            result += '<br/>';
                        }
                    });
                    return result
                }
            },
            xAxis: {
                type: 'category',
                labels: {
                    style: {
                        textAlign: 'center'
                    }
                },
                title: {
                    text: this.translationsValue['xAxisTitle']
              },
            },
            yAxis: [{
                title: {
                    text: this.translationsValue['yAxisTitle']
                },
                showFirstLabel: false
            }],
            series: [{
                color: 'rgba(158, 159, 163, 0.5)',
                pointPlacement: -0.15,
                linkedTo: 'main',
                data: prevData['domains'].slice(),
                name: this.translationsValue[prevData['name']]
            }, {
                name: this.translationsValue[curData['name']],
                id: 'main',
                dataSorting: {
                    enabled: true,
                    matchByName: true
                },
                dataLabels: [{
                    enabled: true,
                    inside: true,
                    style: {
                        fontSize: '16px'
                    }
                }],
                data: getData(curData['domains']).slice()
            }],
            exporting: {
                allowHTML: true
            }
        });
    }
    setLangOptions(){
        Highcharts.setOptions({
            lang: this.translationsValue
        });
    }
    randomRGB() {
        var o = Math.round, r = Math.random, s = 255;
        return 'rgb(' + o(r()*s) + ',' + o(r()*s) + ',' + o(r()*s) + ')';
    }
    getDiffPercent(original, new_number) {
      return ((original - new_number) / original * 100).toFixed(1);
    }
}
