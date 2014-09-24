class BacktestsController < ApplicationController
  load_and_authorize_resource
  include ActionView::Helpers::NumberHelper

  def backtest
    @datainicial = Date.new(2000,1,1)
    @datafinal = Date.current

    session[:qtd_candles] = nil

    @ponto_acima_abaixo_sobre = [['acima','acima'],['abaixo','abaixo'],['sobre','sobre']]
    @ponto_de_entrada_4 = define_lista_ponto_de_entrada_4()
    @ponto_de_stop_3 = define_lista_ponto_de_stop_3()
    @tipo_de_media = [['Exponencial',1],['Simples',2]]
    @direcao_da_media = [['de baixo para cima',1],['de cima para baixo',2]]

    @lista_de_padroes = Setup.where("user_id = 0").collect{|e| [e.setup, e.id]}

    if @lista_de_padroes.present?
      @setup_id = @lista_de_padroes[0][1]
      @setup = Setup.find(@setup_id)
      @lista_de_candles = Setup.carrega_lista_de_candles_do_setup(@setup_id)
    end
  end

  def backtest_resultado

    ultima_data = Date.new(2000, 1, 1)

    date_ini = Date.new(params[:datainicial][:year].to_i, params[:datainicial][:month].to_i, params[:datainicial][:day].to_i)
    date_end = Date.new(params[:datafinal][:year].to_i, params[:datafinal][:month].to_i, params[:datafinal][:day].to_i)

    if params[:prazo].downcase == 'diario'
      Import.import_day(params[:paper][:id])
      @ticks = DailyQuotation.where("paper = ? and date_quotation between ? and ?", Paper.busca_papel(params[:paper][:id]).symbol, date_ini, date_end).order("date_quotation ASC")

    elsif params[:prazo].downcase == 'semanal'
      Import.import_week(params[:paper][:id])
      @ticks = WeeklyQuotation.find_all_by_paper(Paper.busca_papel(params[:paper][:id]).symbol, :conditions => ["date_quotation between ? and ?", date_ini, date_end], :order => "date_quotation ASC")
    end

    if not @ticks.nil?
      @ret = Backtest.backtest(     @ticks,
                                    false,
                                    params )

      if not @ret.nil?
        @totais = @ret[:totais]
      end

      @trade_results = @ret[:trade]

      if params[:mm_enabled]
        if params[:mm_tipo].downcase == 'simples'
          @mm_descricao = 'MMA' + params[:mm_periodo].to_s
        else
          @mm_descricao = 'MME' + params[:mm_periodo].to_s
        end
      end
    end

    respond_to do |format|
      format.html
      format.xml
    end
  end


    def carrega_cotacoes_normais
      session[:file_tag] = nil
      carrega_todos_dropdown
      render :action => "search"
    end

    def carrega_lista
      session[:qtd_candles] = Setup.identifica_quantidade_candles_do_padrao(1)
      @ponto_de_entrada_1 = define_lista_ponto_de_entrada_1()
      @ponto_de_entrada_3 = define_lista_ponto_de_entrada_3()
      @ponto_de_entrada_4 = define_lista_ponto_de_entrada_4()
      @lista_de_candles = define_lista_ponto_de_entrada_5()
      render :layout => false
    end

    def carrega_chart
      @setup_id = params[:setup]
    	render :layout => false
    end

    def carrega_div_ponto_stop
      @ponto_de_stop_3 = define_lista_ponto_de_stop_3()
      carrega_lista
    end

    def politica_privacidade
    end

    def importar
      @quotes = Quote.importar
    end

    def carrega_arquivo
    end

    def resumo_pwtinvest
      @count = User.count - 2
      @usuarios_logados = User.logged_in.size
      @cad_hoje = User.find(:all, :conditions => ["created_at >= ? and created_at <= ?", Time.now.utc.at_beginning_of_day, Time.now.utc.end_of_day]).size
      @cad_ontem = User.find(:all, :conditions => ["created_at >= ? and created_at <= ?", Time.now.utc.yesterday.at_beginning_of_day, Time.now.utc.yesterday.end_of_day]).size
      @cad_semana = User.find(:all, :conditions => ["created_at >= ? and created_at <= ?", Time.now.utc.at_beginning_of_week, Time.now.utc.end_of_week]).size
      @cad_mes = User.find(:all, :conditions => ["created_at >= ? and created_at <= ?", Time.now.utc.at_beginning_of_month, Time.now.utc.end_of_month]).size
    end

    def atualiza_dados_ponto_de_entrada
      @lista_de_candles = Setup.carrega_lista_de_candles_do_setup(params[:cod])
      render :partial => 'carrega_div_ponto_de_entrada', :layout => false
    end

    def atualiza_dados_ponto_de_stop
      @lista_de_candles = Setup.carrega_lista_de_candles_do_setup(params[:cod])
      render :partial => 'carrega_div_ponto_de_stop', :layout => false
    end

    def atualiza_chart
      @setup_id = params[:cod]
      @setup = Setup.find(params[:cod])

    	render :partial => 'carrega_chart', :layout => false
    end

    def atualiza_specs
      @setup = Setup.find(params[:id])
    	render :partial => 'carrega_specs', :layout => false
    end

  private

    def define_lista_ponto_de_entrada_4
      return
    end

    def define_lista_ponto_de_stop_3
      return [['da minima'],['da maxima'], ['da abertura'],['do fechamento']]
    end

end
