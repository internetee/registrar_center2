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
                      subtitle: String}
    connect() {
        this._data = {};
        this.colors = [];
        this.chart;
        this.setLangOptions();
        this.load();
    }
    load() {
      if (this.urlValue) {
          fetch(this.urlValue)
              .then(response => response.json())
              .then((data) => {
                  this._data = data;
                  this['load_' + this.typeValue](data);
              });
      } 
    }
    load_market_share_distribution_chart(data){
        this.chart = Highcharts.chart(this.element, {
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
        this.chart = Highcharts.chart(this.element.querySelector('.bar_chart'), {
            chart: {
                type: 'bar',
                events: {
                    load: function() {
                        let categoryHeight = 35;
                        this.update({
                            chart: {
                              height: categoryHeight * this.pointCount + (this.chartHeight - this.plotHeight)
                            }
                        });
                    }
                }
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
                enabled: true
            },
            tooltip: this.setTooltip('market_share'),
            xAxis: {
                type: 'category',
                labels: {
                    style: {
                        textAlign: 'center'
                    },
                    formatter: function() {
                        if (this.value === data['current_registrar']) {
                            return '<span style="font-weight: bold; text-decoration: underline; font-size: 15px;">' + this.value.toString() + '</span>';
                        }
                        return this.value;
                    }
                },
                title: {
                    text: this.translationsValue['xAxisTitle']
              },
            },
            yAxis: this.setYAxis('market_share'),
            series: this.setSeries(data, 'market_share'),
            exporting: {
                allowHTML: true
            }
        });
    }
    setYAxis(data_type){
        return [{
            title: {
                text: this.translationsValue['yAxisTitle'][data_type]
            },
            showFirstLabel: false,
            floor: 0,
            ceiling: ((data_type == 'market_share') ? 100 : null)
        }]
    }
    setTooltip(data_type) {
        return {
            shared: true,
            // headerFormat: '<span style="font-size: 15px">{point.point.name}</span><br/>',
            // pointFormat: '<span style="color:{point.color}">\u25CF</span> ' + this.translationsValue['yAxisTitle'] + ' - {series.name}: <b>{point.y} ({point.diff}%)</b><br/>',
            formatter: function () { 
                var points = this.points;
                var result = '<span style="font-size: 15px">' + points[0].key + '</span><br/>';
                var apndx = ((data_type == 'market_share') ? '%' : '');
                points.forEach(point => {
                    let diff = point.point.diff;
                    result += '<span style="color:' + point.color + '">\u25CF</span> ' + point.series.yAxis.axisTitle.textStr + 
                        ' - ' + point.series.name + ': <b>' + point.y + apndx + '</b>';
                    if (typeof diff !== 'undefined' && diff != 100  && diff != 0) {
                        let color, sign;
                        if (diff > 0) {
                            color = 'rgb(9,138,13)';
                            sign = '+';
                        } else if (diff < 0) {
                            color = 'rgb(233,23,44)';
                            sign = '';
                        } else {
                            color = 'rgb(0,0,0)';
                            sign = '';
                        }
                        result += ' <span style="color: ' + color + '"><b>(' + sign + point.point.diff + apndx + ')</b></span><br/>';
                    } else {
                        result += '<br/>';
                    }
                });
                return result
            }
        }
    }
    setSeries(data, data_type){
      var curData = data['current'];
      var prevData = data['previous'];
      var apndx = ((data_type == 'market_share') ? '%' : '');
      this.setColors(curData[data_type]);
      const getData = data => data.map((registrar, i) => ({
          name: registrar[0],
          y: registrar[1],
          diff: this.getDiffPercent(data_type, registrar[1], prevData[data_type][i][1]),
          color: this.colors[i]
      }));
      return [{ color: 'rgba(158, 159, 163, 0.5)',
                pointPlacement: -0.15,
                linkedTo: 'main',
                data: prevData[data_type].slice(),
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
                    },
                    format: '{y}' + apndx
                }],
                data: getData(curData[data_type]).slice()
              }];
    }
    setColors(data){
        if (!this.colors.length) {
            this.colors = data.map(r => this.randomRGB());
        }
    }
    setLangOptions(){
      if (this.translationsValue) {
          Highcharts.setOptions({
              lang: this.translationsValue
          });
      }
    }
    randomRGB() {
        var o = Math.round, r = Math.random, s = 255;
        return 'rgb(' + o(r()*s) + ',' + o(r()*s) + ',' + o(r()*s) + ')';
    }
    getDiffPercent(data_type, original, new_number) {
        return (original - new_number).toFixed(+ (data_type === 'market_share'));
    }
    toggleChartDataType(e){
        e.preventDefault();
        let data_type = e.target.value;
        this.chart.update({
          tooltip: this.setTooltip(data_type),
          yAxis: this.setYAxis(data_type),
          series: this.setSeries(this._data, data_type),
        });
    }
}
