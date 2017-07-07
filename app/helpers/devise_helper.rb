module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = "Oops! Please fix the errors below and try again"

    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">x</button>
      <h5>#{sentence}</h5>
      #{messages}
    </div>
    HTML

    html.html_safe
  end
end