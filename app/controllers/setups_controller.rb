class SetupsController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    @setup = Setup.where('user_id = 0')

    if current_user
      @setup = Setup.where('user_id = ?', current_user.id)
    end
    respond_with(@setup)
  end

  def show
    @setup = Setup.find(params[:id])
    session[:setup_id] = @setup.id
    respond_with(@setup)
  end

  def new
    @setup = Setup.new
    respond_with(@setup)
  end

  def edit
    @setup = Setup.find(params[:id])
    respond_with(@setup)
  end

  def create
    @setup = Setup.new(params[:setup])

    if current_user
      @setup.user_id = current_user.id
    else
      @setup.user_id = 0
    end
    respond_with(@setup)
  end

  def update
    @setup = Setup.find(params[:id])

    if params[:setup][:first_candle] == "N"
      flash[:error] = 'Voce deve definir o Primeiro candle.'
    elsif params[:setup][:second_candle] == "N" && params[:setup][:third_candle] != "N"
      flash[:error] = 'Voce deve definir o SEGUNDO candle, quando o TERCEIRO candle esta definido.'
    elsif @setup.update_attributes(params[:setup])
      flash[:notice] = 'Padrao atualizado com sucesso.'
    end
    respond_with(@setup)
  end

  def destroy
    @setup = Setup.find(params[:id])
    @setup.destroy
    respond_with(@setup)
  end

  private
    def setup_params
      params.require(:setup).permit(:id, :setup, :quantity_candle, :description, :first_candle, :second_candle, :third_candle, :first_candle_type, :second_candle_type, :third_candle_type)
    end

end
