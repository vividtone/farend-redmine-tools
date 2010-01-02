class Nanoc3::Site
  # サイト内で使用されているタグの一覧を返す。
  def tags
    if @tagging_helper_tags then
      return @tagging_helper_tags
    else
      @tagging_helper_tags = []
      self.items.each do |item|
        @tagging_helper_tags |= item[:tags] if item[:tags] 
      end
      return @tagging_helper_tags
    end
  end
end
