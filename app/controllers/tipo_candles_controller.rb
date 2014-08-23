class TipoCandlesController < ApplicationController
  # GET /tipo_candles
  # GET /tipo_candles.xml
  load_and_authorize_resource

  def index
    @tipo_candles = TipoCandle.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tipo_candles }
    end
  end

  # GET /tipo_candles/1
  # GET /tipo_candles/1.xml
  def show
    @tipo_candle = TipoCandle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tipo_candle }
    end
  end

  # GET /tipo_candles/new
  # GET /tipo_candles/new.xml
  def new
    @tipo_candle = TipoCandle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tipo_candle }
    end
  end

  # GET /tipo_candles/1/edit
  def edit
    @tipo_candle = TipoCandle.find(params[:id])
  end

  # POST /tipo_candles
  # POST /tipo_candles.xml
  def create
    @tipo_candle = TipoCandle.new(params[:tipo_candle])

    respond_to do |format|
      if @tipo_candle.save
        flash[:notice] = 'TipoCandle was successfully created.'
        format.html { redirect_to(@tipo_candle) }
        format.xml  { render :xml => @tipo_candle, :status => :created, :location => @tipo_candle }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tipo_candle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tipo_candles/1
  # PUT /tipo_candles/1.xml
  def update
    @tipo_candle = TipoCandle.find(params[:id])

    respond_to do |format|
      if @tipo_candle.update_attributes(params[:tipo_candle])
        flash[:notice] = 'TipoCandle was successfully updated.'
        format.html { redirect_to(@tipo_candle) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tipo_candle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tipo_candles/1
  # DELETE /tipo_candles/1.xml
  def destroy
    @tipo_candle = TipoCandle.find(params[:id])
    @tipo_candle.destroy

    respond_to do |format|
      format.html { redirect_to(tipo_candles_url) }
      format.xml  { head :ok }
    end
  end
end
