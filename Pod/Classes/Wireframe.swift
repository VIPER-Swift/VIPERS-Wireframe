//
//  Wireframe.swift
//  Pods
//
//  Created by Jan Bartel on 12.04.16.
//
//

import Foundation
import VIPERS_Wireframe_Protocol
import JLRoutes


public enum WireframeError : ErrorType{
    case NORoutingOptionFound(wireframe: WireframeProtocol,routeString: String, parameters: [String : AnyObject])
    case NOControllerFound(wireframe: WireframeProtocol,routeString: String, parameters: [String : AnyObject])
    case NORoutingPresenterFound(controller: UIViewController,wireframe: WireframeProtocol,routeString: String, parameters: [String : AnyObject])
}


/**
 * The wireframe is the powerful thing that wires the view controllers in
 * your app together.
 * It takes an NSURL and some parameters, talks to the components that create your
 * view controllers (the ControllerProvider) which create the view controller
 * connected to this URL, and gives it to those components which are responsible for
 * presenting your controller (the ControllerRoutingPresenter).
 **/
public class Wireframe : WireframeProtocol{
    
    public init(){
    
    }
    
    private var controllerProviderArray    = [ControllerProviderProtocol]()
    private var routingOptionProviderArray = [RoutingOptionProviderProtocol]()
    private var routingPresenterArray      = [ControllerRoutingPresenterProtocol]()
    private var routingObserverArray       = [RoutingObserverProtocol]()
    
    private var routes = JLRoutes()
    
    /**
     * ROUTE-STRING:
     * A route string is a string representation of the NSURL connected
     * to one view controller
     * It might be something like '/path/to/my/starting/controller'.
     **/
    
    
    /**
     * Adds a route string connected to a view controller
     * (it is the string representation of the controllers URL)
     * to your wireframe.
     * If you call with wireframe.routeURL(url:NSURL('/path/to/my/starting/controller'), ...)
     * the corresponding view controller will be presented.
     **/
    public func addRouteString(routeString:String){
        self.routes.addRoute(routeString) { (routeParams: [NSObject : AnyObject]) -> Bool in
            let params = routeParams as! [String : AnyObject]
            
            var routingOption : RoutingOptionProtocol? = params["routingOption"] as! RoutingOptionProtocol?
            
            routingOption = self.findRoutingOption(routingOption, routingString: routeString, parameters: params)
            
            if routingOption == nil{
                self.notifyRoutingObserversForError(WireframeError.NORoutingOptionFound(wireframe: self, routeString: routeString, parameters: params), routingString: routeString, parameters: params, routingOption: nil)
                return true
            }
            
            let controller = self.findController(routeString, parameters: params, routingOption: routingOption!)
            
            if controller == nil{
                self.notifyRoutingObserversForError(WireframeError.NOControllerFound(wireframe: self, routeString: routeString, parameters: params), routingString: routeString, parameters: params, routingOption: nil)
                return true
            }

            do{
                try self.presentController(controller!,routingString: routeString, parameters: params, routingOption: routingOption!){
                    self.notifyRoutingObserversForSuccessfulyRoutedRoute(controller!,routingString: routeString, parameters: params, routingOption: routingOption!)
                }
            }catch let error {
                self.notifyRoutingObserversForError(error, routingString: routeString, parameters: params, routingOption: nil)
            }
           
            
            return true
        }
    }
    
    
    func findRoutingOption(routingOption: RoutingOptionProtocol?,routingString: String, parameters: [String : AnyObject]) -> RoutingOptionProtocol?{
        
        var resultOption = routingOption
        
        for provider in self.routingOptionProviderArray{
            resultOption = provider.option(routingString, parameters: parameters, currentOption: resultOption)
        }
        
        return resultOption
    }
    
    func findController(routingString: String, parameters: [String : AnyObject],routingOption: RoutingOptionProtocol) -> UIViewController?{
        var controller : UIViewController?
        
        for provider in self.controllerProviderArray{
            controller = provider.controller(routingString, option: routingOption, parameters: parameters)
            if(controller != nil){
                break
            }
        }
        
        return controller
    }
    
    func presentController(controller: UIViewController,routingString: String, parameters: [String : AnyObject],routingOption: RoutingOptionProtocol,completion: (()->Void)) throws{
        
        for presenter in self.routingPresenterArray{
            
            if(presenter.isResponsible(routingOption)){
                
                
                presenter.present(routingString,
                                     controller: controller,
                                         option: routingOption,
                                     parameters: parameters,
                                      wireframe: self,
                                     completion: completion)
                return
            }
        }
        
        throw WireframeError.NORoutingPresenterFound(controller: controller, wireframe: self, routeString: routingString, parameters: parameters)
    }
    
    func notifyRoutingObserversForSuccessfulyRoutedRoute(controller: UIViewController,routingString: String, parameters: [String : AnyObject],routingOption: RoutingOptionProtocol){
        for observer in self.routingObserverArray{
            if(observer.observes(routingString, option: routingOption, parameters: parameters)){
                observer.didRouteTo(controller, routeString: routingString, option: routingOption, parameters: parameters, wireframe: self)
            }
        }
    }
    
    func notifyRoutingObserversForError(error: ErrorType,routingString: String, parameters: [String : AnyObject],routingOption: RoutingOptionProtocol?){
        for observer in self.routingObserverArray{
            if(observer.observes(routingString, option: routingOption, parameters: parameters)){
                observer.error(self, error: error)
            }
        }
    }
    
    
    
    /**
     * Adds a route string connected to a handler block
     * It might be something like '/path/to/invoke/for/my/handler/block'.
     * Your handler block will be invoked if you call your wireframe with
     * wireframe.routeURL(url:NSURL('/path/to/invoke/for/my/handler/block'), ...)
     * in that case
     **/
    public func addRouteString(routeString: String, handler:((parameters:[String:AnyObject])->Void)){
        self.routes.addRoute(routeString) { (parameters:[NSObject : AnyObject]) -> Bool in
            handler(parameters: parameters as! [String : AnyObject])
            return true
        }
    }
    
    
    /**
     * Routes a URL, which results is calling handler blocks or presenting a view controller
     * connected to the called URL
     **/
    public func routeURL(URL:NSURL){
        self.routeURL(URL, parameters : nil)
    }
    
    public func routeURL(URL:NSURL,parameters:[String:AnyObject]?){
        self.routeURL(URL,parameters: parameters,option: nil)
    }
    
    public func routeURL(URL:NSURL,parameters:[String:AnyObject]?,option:RoutingOptionProtocol?){
        self.routes.routeURL(URL,withParameters:parameters)
    }
    
    
    /**
     * Returns the controller connected to a given URL
     */
    public func controllerFor(URL:NSURL,parameters:[String:AnyObject]?) -> UIViewController{
        return UIViewController()
    }
    
    
    /**
     * Returns whether a route exists for a URL
     **/
    public func canRoute(URL:NSURL) -> Bool{
        return self.canRoute(URL,parameters:nil)
    }
    
    public func canRoute(URL:NSURL,parameters:[String:AnyObject]?) -> Bool{
        return self.routes.canRouteURL(URL,withParameters:parameters)
    }
    
    
    /**
     * ControllerProvider: a provider reponsible for creating a view controller
     * for a specific URL
     **/
    
    
    /**
     * Add a controller provider, responsible for creating a view controller
     * for a specific NSURL
     **/
    public func addControllerProvider(provider: ControllerProviderProtocol){
        self.controllerProviderArray.append(provider)
    }
    
    
    /**
     * Returns all registered controller providers
     **/
    public func controllerProviders() -> [ControllerProviderProtocol]{
        return self.controllerProviderArray
    }
    
    
    /**
     * RoutingOptionProvider: a routing option provider is responsible for creating
     * a RoutingOption for a specific URL. By creating a specific RoutingOption
     * for an URL a RoutingOptionProvider can decide in which way a controller
     * should be presented
     **/
    
    
    /**
     * Add a RoutingOptionProvider, responsible for creating a RoutingOption for
     * a specific URL
     **/
    public func addRoutingOptionProvider(provider:RoutingOptionProviderProtocol){
        self.routingOptionProviderArray.append(provider)
    }
    
    
    /**
     * Returns  all registered routing option providers
     **/
    public func routingOptionProviders() -> [RoutingOptionProviderProtocol]{
        return  [RoutingOptionProviderProtocol]()
    }
    
    
    /**
     * ControllerRoutingPresenter: a presenter responsible for presenting
     * a controller with a specific RoutingOption
     **/
    
    
    /**
     * Add a ControllerRoutingPresenter, responsible for presenting controllers with
     * a specific RoutingOption
     **/
    public func addControllerRoutingPresenter<T : RoutingPresenterWithRootViewControllerProtocol>(presenter: T){
        self.routingPresenterArray.append(presenter)
    }
    
    /**
     * set root view controller to all routing presenters using a rootController of this type
     */
    public func setControllerRoutingPresenterRootController<T : UIViewController>(controller : T){
        for presenter in self.routingPresenterArray{
            if(presenter.rootViewControllerInjectable(controller)){
                
            }
        }
    }

    
    /**
     * Returns all registered ControllerRoutingPresenters
     **/
    public func controllerRoutingPresenters()->[ControllerRoutingPresenterProtocol]{
        return self.routingPresenterArray
    }
    
    /**
     * RoutingObserver: an observer object for observing the routing process
     **/
    
    
    /**
     * Add a RoutingObserver an observer object for observing the routing process
     **/
    public func addRoutingObserver(observer:RoutingObserverProtocol){
        self.routingObserverArray.append(observer)
    }
    
    
    /**
     * Returns all routing observers
     **/
    public func routingObserver()->[RoutingObserverProtocol]{
        return self.routingObserverArray
    }
    
}