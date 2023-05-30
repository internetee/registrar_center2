module ApiUsersHelper
  def creator(creator_str)
    return 'admin' if creator_str.include? 'admin'

    creator_str
  end
end
