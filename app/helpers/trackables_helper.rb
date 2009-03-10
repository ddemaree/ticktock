module TrackablesHelper

  def trackable_nickname(trackable)
    return "" if trackable.name == trackable.nickname
    content_tag(:span, "(#{trackable.nickname})", :class => "nickname")
  end

end
