class CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy]
  before_action :load_commentable

  def create
    @comment = Comment.new(comment_params.merge(commentable: @commentable, user: current_user))
    authorize @comment
    if @comment.save
      redirect_to @commentable, notice: "Opmerking is toegevoegd."
    else
      # @team = @commentable
      # @comments = @team.comments
      # render :template => "teams/show"
      render :new
    end
  end

  # def edit
  # end

  def update
  end

  def destroy
    @comment.destroy
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
      authorize @comment
    end

    def load_commentable
      resource, id = request.path.split('/')[1, 2]
      @commentable = resource.singularize.classify.constantize.find(id)
    end

    def comment_params
      params.require(:comment).permit(:body, :comment_type, :private)
    end
end
