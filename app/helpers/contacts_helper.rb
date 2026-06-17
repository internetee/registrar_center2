module ContactsHelper
  def verification_status_badge(contact)
    state = verification_status_state(contact)
    css_class = {
      verified: 'label-success',
      pending_review: 'label-warning',
      requested: 'label-info',
      unverified: 'label-default'
    }.fetch(state, 'label-default')

    content_tag(:span, t("contacts.show.status_labels.#{state}"), class: "label #{css_class}")
  end

  def verification_status_state(contact)
    record = contact.to_h.with_indifferent_access
    return :verified if record[:verified_at].present?
    return :pending_review if record[:verification_pending_at].present?
    return :requested if record[:ident_request_sent_at].present?

    :unverified
  end
end
