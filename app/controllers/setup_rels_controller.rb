class SetupRelsController < ApplicationController
  load_and_authorize_resource


  # GET /user_setup_rels
  # GET /user_setup_rels.xml
  def index
    if not params[:id].nil?
      session[:setup_id] = params[:id]
    end
    
    @setup_rel = SetupRel.find_all_by_user_setup_id(session[:setup_id])
    @setup = Setup.find(session[:setup_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @setup_rel }
    end
  end

  # GET /user_setup_rels/1
  # GET /user_setup_rels/1.xml
  def show
    @setup_rel = SetupRel.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @setup_rel }
    end
  end

  # GET /user_setup_rels/new
  # GET /user_setup_rels/new.xml
  def new
    @setup_rel = SetupRel.new
    if not params[:id].nil?
      session[:setup_id] = params[:id]
    end
    
    @lista_candle_value = [['abertura'],['fechamento'],['minima'],['maxima']]
    @lista_candle_position = []
    
    if not params[:obj1] == 'N'
      @lista_candle_position << ['primeiro']
    end
    
    if not params[:obj2] == 'N'
      @lista_candle_position << ['segundo']
    end
    
    if not params[:obj3] == 'N'
      @lista_candle_position << ['terceiro']
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @setup_rel }
    end
  end

  # GET /user_setup_rels/1/edit
  def edit
    @setup_rel = SetupRel.find(params[:id])
    @lista_candle_value = [['abertura'],['fechamento'],['minima'],['maxima']]
    @lista_candle_position = []
    
    if not params[:obj1] == 'N'
      @lista_candle_position << ['primeiro']
    end
    
    if not params[:obj2] == 'N'
      @lista_candle_position << ['segundo']
    end
    
    if not params[:obj3] == 'N'
      @lista_candle_position << ['terceiro']
    end    
  end

  # POST /user_setup_rels
  # POST /user_setup_rels.xml
  def create
    @setup_rel = SetupRel.new(params[:setup_rel])
    @setup_rel.setup_id = session[:setup_id]
    
    respond_to do |format|
      if @setup_rel.save
        flash[:notice] = 'Relacionamento entre candles incluido com sucesso.'
        format.html { redirect_to(@setup_rel) }
        format.xml  { render :xml => @setup_rel, :status => :created, :location => @setup_rel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @setup_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_setup_rels/1
  # PUT /user_setup_rels/1.xml
  def update
    @setup_rel = SetupRel.find(params[:id])

    respond_to do |format|
      if @setup_rel.update_attributes(params[:setup_rel])
        flash[:notice] = 'Relacionamento entre candles atualizado com sucesso.'
        format.html { redirect_to(@setup_rel) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @setup_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_setup_rels/1
  # DELETE /user_setup_rels/1.xml
  def destroy
    @setup_rel = SetupRel.find(params[:id])
    @setup_rel.destroy
    
    respond_to do |format|
      format.html { redirect_to(:controller => 'setups', :action => 'index') }
      format.xml  { head :ok }
    end
  end
end
