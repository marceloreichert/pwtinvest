module Backtest
  class Import

    def self.day(paper)

      quote = DailyQuotation.where("paper = ?", Paper.busca_papel(paper).symbol).order("date_quotation ASC").last

      if quote.nil?
        ultima_data = Date.new(2000, 1, 1)
      else
        ultima_data = quote.date_quotation
      end

      @papel = ""

      YahooFinance::get_HistoricalQuotes( Paper.busca_papel(paper).symbol, ultima_data, Date.today() ) do |hq|

        if @papel.empty?
            @papel = Paper.where("symbol = ?", hq.symbol)

            if @papel.empty?
              @papel = Paper.new
              @papel.symbol = hq.symbol
              @papel.save
            end
        end

        @quote = DailyQuotation.where("date_quotation = ? AND paper = ?", hq.date, hq.symbol)

        if @quote.empty?

            if hq.open > hq.close
              tipo_candle = "B"
            elsif hq.close > hq.open
              tipo_candle = "A"
            else
              tipo_candle = "N"
            end

            @quote = DailyQuotation.new
            @quote.paper = hq.symbol
            @quote.date_quotation = hq.date
            @quote.open = hq.open
            @quote.close = hq.close
            @quote.low = hq.low
            @quote.high = hq.high
            @quote.volume = hq.volume
            @quote.type_candle = tipo_candle
            @quote.save
        end
      end
    end


    def self.week(paper)

      quote = WeeklyQuotation.where("paper = ?", Paper.busca_papel(paper).symbol).order("date_quotation ASC").last

      if quote.nil?
        ultima_data = '2000-01-01'
      else
        ultima_data = quote.date_quotation
      end

      papel = Paper.busca_papel(paper).symbol
      quote = DailyQuotation.find_by_sql(["select yearweek(date_quotation) as yearweek, min(low) as low, max(high) as high, min(date_quotation) as data_abertura, max(date_quotation) as data_fechamento, sum(volume) as volume from daily_quotations where paper = ? and date_quotation between ? and ? group by yearweek(date_quotation) order by date_quotation", papel, ultima_data, Date.today ])

      quote.each  do |q|

        candle_abertura = DailyQuotation.where("paper = ? AND date_quotation = ?", paper, q[:data_abertura])
        unless candle_abertura.empty?
          valor_abertura = candle_abertura[0].open
        end

        candle_fechamento = DailyQuotation.where("paper = ? AND date_quotation = ?", paper, q[:data_fechamento])
        unless candle_fechamento.empty?
          valor_fechamento = candle_fechamento[0].close
        end

        if valor_abertura > valor_fechamento
          type = "B"
        elsif valor_fechamento > valor_abertura
          type = "A"
        else
          type = "N"
        end

        quote_week = WeeklyQuotation.find_all_by_paper_and_date_quotation(papel,q[:data_abertura])

        if quote_week.empty?
          @quote = WeeklyQuotation.new
          @quote.paper = papel
          @quote.date_quotation = q[:data_abertura]
          @quote.open = valor_abertura
          @quote.close = valor_fechamento
          @quote.low = q[:low]
          @quote.high = q[:high]
          @quote.volume = q[:volume]
          @quote.type_candle = type
          @quote.save
        else
            quote_week[0].update_attributes(:close => valor_fechamento,
                                          :low => q[:low],
                                          :high => q[:high],
                                          :type_candle => type )
        end
      end
    end
  end
end
