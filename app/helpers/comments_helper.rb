module CommentsHelper

  def comment_types_for(parent)
    @comment_types_for ||= parent.comment_types.select{ |type, id| policy(Comment).public_send("show_#{type}?") }
  end

  def comments_for(parent, comment_type)
    @comments_for ||= {}
    @comments_for[comment_type] ||= parent.comments.public_send(comment_type).includes(:user).to_a
  end

end
