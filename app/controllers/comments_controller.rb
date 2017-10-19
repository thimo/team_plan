class CommentsController < ApplicationController
  before_action :load_commentable, only: [:toggle_include_member, :create]
  before_action :create_comment, only: [:create]
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :add_breadcrumbs, except: [:toggle_include_member]

  def toggle_include_member
    authorize @commentable, :show_comments?
    current_user.toggle_include_member_comments
    render 'tabs'
  end

  def create
    if @comment.save
      redirect_to [@commentable, comment: @comment.comment_type], notice: "Opmerking is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @comment.update_attributes(comment_params)
      redirect_to [@comment.commentable, comment: @comment.comment_type], notice: "Opmerking is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to [@comment.commentable, comment: @comment.comment_type], notice: "Opmerking is verwijderd."
    @comment.destroy
  end

  private

    def create_comment
      @comment = Comment.new(comment_params.merge(commentable: @commentable, user: current_user))
      authorize @comment
    end

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

    def add_breadcrumbs
      add_breadcrumb @comment.commentable.name, @comment.commentable
      if @comment.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb "Opmerking"
      end
    end
end
