class SetupRelsController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    if not params[:id].nil?
      session[:setup_id] = params[:id]
    end

    @setup_rel = SetupRel.find_all_by_user_setup_id(session[:setup_id])
    @setup = Setup.find(session[:setup_id])
    respond_with(@setup_rel)
  end

  def show
    @setup_rel = SetupRel.find(params[:id])
    respond_with(@setup_rel)  end

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
    respond_with(@setup_rel)  end

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

  def create
    @setup_rel = SetupRel.new(params[:setup_rel])
    @setup_rel.setup_id = session[:setup_id]
    respond_with(@setup_rel)
  end

  def update
    @setup_rel = SetupRel.find(params[:id])

    respond_with(@setup_rel)
  end

  def destroy
    @setup_rel = SetupRel.find(params[:id])
    @setup_rel.destroy
    respond_with(@setup_rel)
  end
end
