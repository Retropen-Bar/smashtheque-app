class PageDecorator < BaseDecorator

  def formatted_content
    content.to_s
  end

end
