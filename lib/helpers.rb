module Blog
  module ApplicationHelper

    def nested_comments(comments, resource)
      comments.map do |comment, sub_comments|
        render(comment, :resource => resource) + content_tag(:div, nested_comments(sub_comments, resource), :class => 'nested_comments')
      end.join.html_safe
    end

    def reply_link(resource, comment)
      content_tag(:div, (link_to "Reply", new_post_comment_path(resource, :parent_id => comment), :remote => true), :class => 'reply')
    end

  end
end