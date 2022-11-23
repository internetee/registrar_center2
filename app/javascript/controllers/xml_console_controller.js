import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "payload" ]

    loadXml(event) {
      this.payloadTarget.value = 'loading...';
      fetch('xml_console/load?' + new URLSearchParams({
          obj: event.params.obj,
          epp_action: event.params.eppAction,
          }))
          .then(response => response.text())
          .then((data) => {
              this.payloadTarget.value = data;
          });
    }
}