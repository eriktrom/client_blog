module Blog
  module ApplicationHelper

    def nested_comments(comments, resource)
      comments.map do |comment, sub_comments|
        render(comment, :resource => resource) + content_tag(:div, nested_comments(sub_comments, resource), :class => 'nested_comments')
      end.join.html_safe
    end
    
    def comment_with_empty_nest(resource, parent)
      render('comments/comment', :comment => resource, :resource => parent) + content_tag(:div, '', :class => 'nested_comments')
    end

    def reply_link(resource, comment)
      content_tag(:div, (link_to "Reply", new_post_comment_path(resource, :parent_id => comment), :remote => true), :class => 'reply')
    end
    
    def disqus_comments(parent, parent_path)
      developer = Rails.env.development? ? 1 : 0
      x = raw(%(
        var disqus_shortname = '#{Settings.disqus.shortname}';
        var disqus_identifier = '#{parent_path}'; // use parent path so that its only unique to the post itself.. This way categories can change and the comments can go with them...
        var disqus_url = '#{post_show_url(parent.blog_category, parent, :host => Settings.host)}'; // here if the url changes, the system will redirect automatically
        var disqus_title = '#{parent.page_title}';
        var disqus_developer = #{developer};
      ))
      x
    end

  end
end