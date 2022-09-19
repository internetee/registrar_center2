import { Controller } from "@hotwired/stimulus"
import Highcharts, { setOptions } from 'highcharts';
import Exporting from 'highcharts/modules/exporting';
// import ExportData from 'highcharts/modules/export-data';
import Accessibility from 'highcharts/modules/accessibility';
import NoDataToDisplay from 'highcharts/modules/no-data-to-display';
Exporting(Highcharts);
Accessibility(Highcharts);
NoDataToDisplay(Highcharts);
// ExportData(Highcharts);

// Connects to data-controller="chart"
export default class extends Controller {
    static values = { url: String, title: String, type: String, translations: Object,
                      subtitle: String}
    connect() {
        this._data = {};
        this.legends = [];
        this.hiddenRegistrars = [];
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
    load_market_share_distribution_chart(data) {
        this.chart = Highcharts.chart(this.element.querySelector('.pie_chart'), {
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                height: 800,
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
            exporting: {
                chartOptions: {
                    legend: {
                        enabled: false
                    }
                }
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        format: '{point.name}: {point.percentage:.1f} %'
                    },
                    showInLegend: true
                }
            },
            legend: {
                align: 'right',
                verticalAlign: 'top',
                layout: 'vertical',
                itemMarginTop: 1,
                itemMarginBottom: 1,
                x: 0,
                y: 100
          },
            series: data
        });
    }
    load_market_share_growth_rate_chart(data) {
        var that = this;
        this.chart = Highcharts.chart(this.element.querySelector('.bar_chart'), {
            chart: {
                object: this,
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
                    borderWidth: 0,
                    animation: false,
                    events: {
                        legendItemClick: function() {
                            that.handleLegendItemClick(this, 'market_share');
                        }
                    }
                }
            },
            tooltip: this.setTooltip('market_share'),
            xAxis: {
                accessibility: {
                    description: 'Registrars'
                },
                type: 'category',
                labels: {
                    style: {
                        textAlign: 'center'
                    },
                    formatter: function() {
                        return that.xAxisFormatter(this.value, data);
                    }
                },
                title: {
                    text: this.translationsValue['xAxisTitle']
              },
            },
            yAxis: this.setYAxis('market_share'),
            series: this.setSeries(data, 'market_share'),
            legend: {
                align: 'right',
                verticalAlign: 'top',
                layout: 'vertical',
                itemMarginTop: 1,
                itemMarginBottom: 1,
                x: 0,
                y: 100
            },
            exporting: {
                allowHTML: true,
                chartOptions: {
                    legend: {
                        enabled: false
                    }
              }
            }
        });
    }
    setYAxis(data_type) {
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
    setSeries(data, data_type) {
        var curData = data['current'], prevData = data['previous'];
        this.setLegends(curData[data_type]);
        var apndx = ((data_type == 'market_share') ? '%' : '');
        // console.log(curData[data_type]);
        // console.log(this.getData(curData[data_type], prevData[data_type], data_type).slice());
        const newPrevData = this.filterData(prevData[data_type]),
        newCurData = this.filterData(curData[data_type]);
        // console.log(newPrevData);
        // console.log(this.getData(newCurData, newPrevData, data_type).slice());
        return [{ color: 'rgba(158, 159, 163, 0.5)',
                  pointPlacement: -0.15,
                  linkedTo: 'main',
                  data: newPrevData.slice(),
                  name: this.translationsValue[prevData['name']]
                }, {
                  name: this.translationsValue[curData['name']],
                  id: 'main',
                  showInLegend: false,
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
                  data: this.getData(newCurData, newPrevData, data_type).slice()
                },
                ...this.legends];
    }
    filterData(data) {
        return data.filter(point => !(this.hiddenRegistrars.indexOf(point[0]) > -1));
    }
    setLegends(data) {
        if (!this.legends.length) {
            this.legends = data.map(r => ({ 
                name: r[0],
                color: this.randomRGB()
            }));
        }
    }
    setLangOptions() {
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
    toggleChartDataType(e) {
        e.preventDefault();
        let data_type = e.target.value;
        var that = this;
        this.updateChart(data_type);
    }
    xAxisFormatter(value, data) {
        if (value === data['current_registrar']) {
            return '<span style="font-weight: bold; text-decoration: underline; font-size: 15px;">' + value.toString() + '</span>';
        }
        return value;
    }
    handleLegendItemClick(item, data_type) {
        const name = item.name,
        visible = item.visible;
        if (visible) {
            this.hiddenRegistrars.push(name);
        } else {
            this.hiddenRegistrars = this.hiddenRegistrars.filter(function(e) { return e !== name });
        }
        // console.log(this.hiddenRegistrars);
        this.updateChart(data_type);
    }
    getData(curData, prevData, data_type) {
        return curData.map((registrar, i) => ({
                  name: registrar[0],
                  y: registrar[1],
                  diff: this.getDiffPercent(data_type, registrar[1], prevData[i][1]),
                  color: this.legends.find(r => r.name === registrar[0]).color
              }));
    }
    updateChart(data_type) {
        let that = this;
        this.chart.update({
          tooltip: this.setTooltip(data_type),
          yAxis: this.setYAxis(data_type),
          plotOptions: {
              series: {
                  events: {
                      legendItemClick: function(e) {
                          that.handleLegendItemClick(this, data_type);
                      }
                  }
              }
          },
          series: this.setSeries(this._data, data_type)
        }, true, false, {duration: 200});
    }
}
