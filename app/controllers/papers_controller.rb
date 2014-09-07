class PapersController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    @papers = Paper.paginate(:per_page => 20, :page => params[:page])
    respond_with(@papers)
  end

  def show
    @paper = Paper.find(params[:id])
    respond_with(@paper)
  end

  def new
    @paper = Paper.new
    respond_with(@paper)
  end

  # GET /papers/1/edit
  def edit
    @paper = Paper.find(params[:id])
  end

  def create
    @paper = Paper.new(params[:paper])
    respond_with(@paper)
  end

  def update
    @paper = Paper.find(params[:id])
    respond_with(@paper)
  end

  def destroy
    @paper = Paper.find(params[:id])
    @paper.destroy
    respond_with(@paper)
  end
end
