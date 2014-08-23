class QuoteWeekliesController < ApplicationController
  # GET /quote_weeklies
  # GET /quote_weeklies.xml
  def index
    @quote_weeklies = QuoteWeekly.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quote_weeklies }
    end
  end

  # GET /quote_weeklies/1
  # GET /quote_weeklies/1.xml
  def show
    @quote_weekly = QuoteWeekly.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @quote_weekly }
    end
  end

  # GET /quote_weeklies/new
  # GET /quote_weeklies/new.xml
  def new
    @quote_weekly = QuoteWeekly.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @quote_weekly }
    end
  end

  # GET /quote_weeklies/1/edit
  def edit
    @quote_weekly = QuoteWeekly.find(params[:id])
  end

  # POST /quote_weeklies
  # POST /quote_weeklies.xml
  def create
    @quote_weekly = QuoteWeekly.new(params[:quote_weekly])

    respond_to do |format|
      if @quote_weekly.save
        flash[:notice] = 'QuoteWeekly was successfully created.'
        format.html { redirect_to(@quote_weekly) }
        format.xml  { render :xml => @quote_weekly, :status => :created, :location => @quote_weekly }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @quote_weekly.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /quote_weeklies/1
  # PUT /quote_weeklies/1.xml
  def update
    @quote_weekly = QuoteWeekly.find(params[:id])

    respond_to do |format|
      if @quote_weekly.update_attributes(params[:quote_weekly])
        flash[:notice] = 'QuoteWeekly was successfully updated.'
        format.html { redirect_to(@quote_weekly) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quote_weekly.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /quote_weeklies/1
  # DELETE /quote_weeklies/1.xml
  def destroy
    @quote_weekly = QuoteWeekly.find(params[:id])
    @quote_weekly.destroy

    respond_to do |format|
      format.html { redirect_to(quote_weeklies_url) }
      format.xml  { head :ok }
    end
  end
end
