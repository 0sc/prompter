module Views
  module HtmlHelpers
    def page
      @page ||= Capybara::Node::Simple.new(rendered)
    end
  end
end
