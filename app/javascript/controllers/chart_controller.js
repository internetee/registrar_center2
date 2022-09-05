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
    // rubocop:disable Metrics/MethodLength
    load_market_share_growth_rate_chart(data){
        var curData = data['current'];
        var prevData = data['previous'];

        const getData = data => data.map((registrar, i) => ({
            name: registrar[0],
            y: registrar[1],
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
                headerFormat: '<span style="font-size: 15px">{point.point.name}</span><br/>',
                pointFormat: '<span style="color:{point.color}">\u25CF</span> ' + this.translationsValue['yAxisTitle'] + ' - {series.name}: <b>{point.y}</b><br/>'
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
    // rubocop:enable Metrics/MethodLength
    setLangOptions(){
        Highcharts.setOptions({
            lang: this.translationsValue
        });
    }
    randomRGB() {
        var o = Math.round, r = Math.random, s = 255;
        return 'rgb(' + o(r()*s) + ',' + o(r()*s) + ',' + o(r()*s) + ')';
    }
}
