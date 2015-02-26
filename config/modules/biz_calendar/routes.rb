CmsCMS::Application.routes.draw do
  mod = "biz_calendar"
  
  ## admin
  scope "#{CmsCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources(:places,
      :controller  => "admin/places",
      :path        => ":content/places") do
      resources :hours,
        :controller => 'admin/hours'
      resources :holidays,
        :controller => 'admin/holidays'
      resources :exception_holidays,
        :controller => 'admin/exception_holidays'
    end
    resources :types,
      :controller  => "admin/types",
      :path        => ":content/types"
    
    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller  => "admin/content/settings",
      :path        => ":content/content_settings"
    
    ## node
    resources :node_places,
      :controller  => "admin/node/places",
      :path        => ":parent/node_places"
    
    ## piece
    resources :piece_daily_links,
      :controller  => "admin/piece/daily_links"
    resources :piece_holidays,
      :controller  => "admin/piece/holidays"
    resources :piece_bussiness_times,
      :controller  => "admin/piece/bussiness_times"
  end
  
  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_places/index"              => "public/node/places#index",
      :as => nil, :via => [:get, :post]
    match "node_places/:piece/bussiness_times/:name" => "public/node/places#bussiness_times", :via => [:get, :post]
    match "node_places/:piece/bussiness_times"       => "public/node/places#bussiness_times", :via => [:get, :post]
    match "node_places/:name/index"        => "public/node/places#show",
      :as => nil, :via => [:get, :post]
  end
end