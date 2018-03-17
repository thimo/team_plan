class TodosController < ApplicationController
  before_action :set_todo, only: [:edit, :update, :destroy, :toggle]
  before_action :load_todoable, only: [:new, :create]
  before_action :create_todo, only: [:new, :create]
  before_action :add_breadcrumbs

  def new
    @todo.body = params[:title] if params[:title].present?
  end

  def create
    if @todo.save
      flash_message(:success, "Todo is toegevoegd.")
      redirect_to @todo.todoable.present? ? @todo.todoable : root_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @todo.update_attributes(todo_params)
      flash[:success] =  "Todo is aangepast."
      url = if params[:return].present?
        params[:return]
      elsif @todo.todoable.present?
        @todo.todoable
      else
        root_path
      end
      redirect_to url
    else
      render 'edit'
    end
  end

  def destroy
    flash[:success] =  "Todo is verwijderd."
    redirect_to @todo.todoable.present? ? @todo.todoable : root_path
    @todo.destroy
  end

  def toggle
    @todo.finished = !@todo.finished
    @todo.save
  end

  private

    def create_todo
      @todo = if action_name == 'new'
                current_user.todos.new
              else
                current_user.todos.new(todo_params)
              end
      @todo.todoable = @todoable

      authorize @todo
    end

    def set_todo
      @todo = Todo.find(params[:id])
      authorize @todo
    end

    def load_todoable
      if (path_split = request.path.split('/')).size > 3
        resource, id = path_split[1, 2]
        @todoable = resource.singularize.classify.constantize.find(id)
      end
    end

    def todo_params
      params.require(:todo).permit(:body, :waiting, :finished, :started_on, :ended_on)
    end

    def add_breadcrumbs
      add_breadcrumb @todo.todoable.name, @todo.todoable if @todo.todoable
      add_breadcrumb "Todo's"
      if @todo.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb 'Todo'
      end
    end

end
