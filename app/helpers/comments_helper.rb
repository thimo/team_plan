module CommentsHelper

  def comment_types_for(parent)
    @comment_types_for ||= parent.comment_types.select{ |type, id| policy(Comment).public_send("show_#{type}?") }
  end

  def comments_for(parent, comment_type)
    @comments_for ||= {}

    if @comments_for[comment_type].nil?
      comments = Comment.where(commentable: parent)
      if include_member_comments?(parent)
        comments = comments.or(Comment.where(commentable: parent.members))
      end

      @comments_for[comment_type] = comments.public_send(comment_type).desc.includes(:user, :commentable).to_a
    end

    @comments_for[comment_type]
  end

  private

    def include_member_comments?(parent)
      parent.is_a?(Team) && current_user.settings.include_member_comments
    end
end
