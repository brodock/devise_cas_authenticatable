if ActionController::Routing.name =~ /ActionDispatch/
  # Rails 3
  
  ActionDispatch::Routing::Mapper.class_eval do
    protected
  
    def devise_cas_authenticatable(mapping, controllers)
      # service endpoint for CAS server
      get "/cas_service", :to => "#{controllers[:cas_sessions]}#service"
      
      resource :session, :only => [], :controller => controllers[:cas_sessions], :path => "" do
        get :new, :path => mapping.path_names[:sign_in], :to => "#{controllers[:cas_sessions]}#create", :as => "new"
        post :create, :path => mapping.path_names[:sign_in]
        match :destroy, :path => mapping.path_names[:sign_out], :as => "destroy"
      end      
    end
  end
else
  # Rails 2
  
  ActionController::Routing::RouteSet::Mapper.class_eval do
    protected
    
    def cas_authenticatable(routes, mapping)
      routes.with_options(:controller => 'devise/cas_sessions', :name_prefix => nil) do |session|
        session.send(:"#{mapping.name}", '/', :action => 'service', :conditions => {:method => :get})
        session.send(:"new_#{mapping.name}_session", mapping.path_names[:sign_in], :action => 'create', :conditions => {:method => :get})
        session.send(:"#{mapping.name}_session", mapping.path_names[:sign_in], :action => 'create', :conditions => {:method => :post})
        session.send(:"destroy_#{mapping.name}_session", mapping.path_names[:sign_out], :action => 'destroy', :conditions => { :method => :get })
      end
    end
  end
end
