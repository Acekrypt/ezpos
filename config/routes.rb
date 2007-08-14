ActionController::Routing::Routes.draw do |map|
    # Add your own custom routes here.
    # The priority is based upon order of creation: first created -> highest priority.

    # Here's a sample route:
    # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
    # Keep in mind you can assign values other than :controller and :action

    # You can have the root of your site routed by hooking up ''
    # -- just remember to delete public/index.html.
    # map.connect '', :controller => "welcome"

#    map.connect 'webmail', :controller=>'webmail', :action=>'index'
#    map.connect 'intra/webmail/:action', :controller=>'webmail'
#    map.connect 'intra/sales/:action/:id', :controller=>'sales'
#    map.connect 'intra/prefs/:action', :controller=>'employee_prefs'
#    map.connect 'intra/contacts/:action/:id', :controller=>'contact'
#    map.connect 'intra/calendar', :controller=>'calendar', :action=>'index'
#    map.connect 'intra/calendar/:year/:month', :controller=>'calendar', :action=>'index'
    # Allow downloading Web Service WSDL as a file with an extension
    # instead of a file named 'wsdl'
#    map.connect ':controller/service.wsdl', :action => 'wsdl'

    # Install the default route as the lowest priority.
    map.connect ':controller/:action/:id'

end
