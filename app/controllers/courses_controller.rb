class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :approve, :disapprove]

  def index
    if params[:name]
      #@courses = Course.where('name LIKE ?', "%#{params[:name]}%") #case-sensitive
      @courses = Course.where('name ILIKE ?', "%#{params[:name]}%") #Case-insensitive
      #@courses = Course.where('LOWER(name) LIKE LOWER(?)', "%#{params[:name]}%") #make lowercase
    else
      @courses = Course.all
    end
  end

  def my
    @courses = Course.where(user_id: current_user.id)
    render 'index'
  end

  def published_unapproved
    @courses = Course.published.unapproved
    render 'index'
  end

  def latest
    @courses = Course.all.published.approved.order(created_at: :desc)
    render 'index'
  end

  def top_rated
    @courses = Course.all.published.approved.order(average_rating: :desc, created_at: :desc)
    render 'index'
  end

  def popular
    @courses = Course.all.published.approved.order(user_courses_count: :desc, created_at: :desc)
    render 'index'
  end

  def approve
		#@event.update_attribute(:status, 'planned')
		@course.update_attribute(:approved, true)
		redirect_to @course, notice: "Course '#{@course.name}' - approved"
  end

  def disapprove
		@course.update_attribute(:approved, false)
		redirect_to @course, alert: "Course '#{@course.name}' - disapproved"
  end

  def show
    @lessons = @course.lessons.order(chapter: :asc)
    @user_courses = @course.user_courses.order(created_at: :desc)
  end

  def new
    @course = Course.new
  end

  def edit
  end

  def create
    @course = Course.new(course_params)
    @course.user_id = current_user.id

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_course
      @course = Course.friendly.find(params[:id])
    end

    def course_params
      params.require(:course).permit(:name, :category_id, :short_description, :description, :language, :duration, :price, :published, :user_id)
    end
end
