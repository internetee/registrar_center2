module ApiUsersHelper
  def creator(creator_str)
    return unless creator_str
    return 'admin' if creator_str.include?('admin') || creator_str.include?('Admin')

    creator_str
  end
end
