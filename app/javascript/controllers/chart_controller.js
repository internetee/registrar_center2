import { Controller } from "@hotwired/stimulus"
import Highcharts, { setOptions } from 'highcharts';
import Exporting from 'highcharts/modules/exporting';
import Accessibility from 'highcharts/modules/accessibility';
import NoDataToDisplay from 'highcharts/modules/no-data-to-display';
Exporting(Highcharts);
Accessibility(Highcharts);
NoDataToDisplay(Highcharts);

// Connects to data-controller="chart"
export default class extends Controller {
    static values = { url: String, title: String, translations: Object }
    connect() {
        this.setLangOptions();
        this.load();
    }
    load() {
        fetch(this.urlValue)
            .then(response => response.json())
            .then((data) => {
              this.load_chart(data);
            });
    }
    load_chart(data){
        let chart = Highcharts.chart(this.element, {
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
    setLangOptions(){
        Highcharts.setOptions({
            lang: this.translationsValue
        });
    }
}
