module ApiUsersHelper
  def creator(creator_str)
    return unless creator_str
    return 'admin' if creator_str.include?('admin') || creator_str.include?('Admin')

    creator_str
  end

  def verification_status_badge(api_user)
    state = verification_status_state(api_user)
    css_class = {
      verified: 'label-success',
      pending_review: 'label-warning',
      requested: 'label-info',
      unverified: 'label-default'
    }.fetch(state, 'label-default')

    content_tag(:span, t("api_users.show.status_labels.#{state}"), class: "label #{css_class}")
  end

  def verification_status_state(api_user)
    user = api_user.to_h.with_indifferent_access
    return :verified if user[:verified_at].present?
    return :pending_review if user[:verification_pending_at].present?
    return :requested if user[:ident_request_sent_at].present?

    :unverified
  end
end
