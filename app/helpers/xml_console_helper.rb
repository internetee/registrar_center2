module XmlConsoleHelper
  def load_xml_link(body, obj, action)
    link_to(body, 'javascript:void(0);', class: 'js_load_xml_link',
                                         'data-xml-console-obj-param': obj,
                                         'data-xml-console-epp-action-param': action,
                                         'data-action': 'xml-console#loadXml')
  end
end
