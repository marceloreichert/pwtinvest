Pwtinvest::Application.routes.draw do
  resources :home
  resources :setups
  resources :setup_rels

  devise_for :users

  post 'processar_backtest' => 'backtests#backtest_resultado'
  get '/backtests' => 'backtests#backtest', :as => 'backtest'

  get '/atualiza_dados_ponto_de_entrada/:cod' => 'backtests#atualiza_dados_ponto_de_entrada'
  get 'atualiza_dados_ponto_de_stop/:cod' =>'backtests#atualiza_dados_ponto_de_stop'
  get 'atualiza_chart/:cod' => 'backtests#atualiza_chart'

  root :to => "backtests#backtest"

end
