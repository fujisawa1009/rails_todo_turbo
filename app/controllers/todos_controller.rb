class TodosController < ApplicationController
  before_action :set_todo, only: [:edit, :update, :destroy]

  def index
    @todos = Todo.all
  end

  def new
    @todo = Todo.new
    respond_to do |format|
      format.html # Non-Turboリクエストのフォールバック
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('new_todo_form', partial: 'todos/form', locals: { todo: @todo })
      end
    end
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      respond_to do |format|
        format.html { redirect_to todos_path, notice: 'To-Do was successfully created.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append('todos', partial: 'todos/todo', locals: { todo: @todo }), # 新しいtodoをリストに追加
            turbo_stream.replace('new_todo_form', partial: 'todos/form', locals: { todo: Todo.new }) # フォームを初期化
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('new_todo_form', partial: 'todos/form', locals: { todo: @todo }) # エラーを対処
        end
      end
    end
  end

  def edit; end

  def update
    if @todo.update(todo_params)
      respond_to do |format|
        format.turbo_stream { render partial: "todos/todo", locals: { todo: @todo } }
      end
    else
      render :edit
    end
  end

  def destroy
    @todo.destroy
    respond_to do |format|
      format.html { redirect_to todos_path, notice: 'To-Do was successfully deleted.' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("todo_#{@todo.id}")
      end
    end
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end
end