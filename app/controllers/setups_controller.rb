class SetupsController < ApplicationController
  load_and_authorize_resource

  # GET /setups
  # GET /setups.xml
  def index
    @setup = Setup.where('user_id = 0')

    if current_user
      @setup = Setup.where('user_id = ?', current_user.id)
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /setups/1
  # GET /setups/1.xml
  def show
    @setup = Setup.find(params[:id])
    session[:setup_id] = @setup.id

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @setup }
    end
  end

  # GET /setups/new
  # GET /setups/new.xml
  def new
    @setup = Setup.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @setup }
    end
  end

  # GET /setups/1/edit
  def edit
    @setup = Setup.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @setup }
    end
  end

  # POST /setups
  # POST /setups.xml
  def create
    @setup = Setup.new(params[:setup])

    if current_user
      @setup.user_id = current_user.id
    else
      @setup.user_id = 0
    end

    respond_to do |format|
      if @setup.save
        flash[:notice] = 'Padrao criado com sucesso.'
        format.html { redirect_to(@setup) }
        format.xml  { render :xml => @setup, :status => :created, :location => @setup }
      else
        flash[:error] = 'Erro ao cadastrar padrao.'
        format.html { redirect_to(:action => 'new') }
        format.xml  { render :xml => @setup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /setups/1
  # PUT /setups/1.xml
  def update
    @setup = Setup.find(params[:id])

    respond_to do |format|

      if params[:setup][:first_candle] == "N"
        flash[:error] = 'Voce deve definir o Primeiro candle.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @setup.errors, :status => :unprocessable_entity }
      elsif params[:setup][:second_candle] == "N" && params[:setup][:third_candle] != "N"
        flash[:error] = 'Voce deve definir o SEGUNDO candle, quando o TERCEIRO candle esta definido.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @setup.errors, :status => :unprocessable_entity }
      elsif @setup.update_attributes(params[:setup])
        flash[:notice] = 'Padrao atualizado com sucesso.'
        format.html { redirect_to(@setup) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @setup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /setups/1
  # DELETE /setups/1.xml
  def destroy
    @setup = Setup.find(params[:id])
    @setup.destroy

    respond_to do |format|
      format.html { redirect_to(setups_url) }
      format.xml  { head :ok }
    end
  end
end
