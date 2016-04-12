//
//  RoutingPresenterPush.swift
//  Pods
//
//  Created by Jan Bartel on 12.04.16.
//
//

import Foundation
import VIPERS_Wireframe_Protocol

public class RoutingPresenterPush : RoutingPresenterWithRootViewControllerProtocol{
    
    
    public init(){
    
    }
    
    public typealias RootViewControllerType = UINavigationController
    
    var navigationController : UINavigationController?
    
    public func setRootViewController(controller: UINavigationController){
        self.navigationController = controller
    }
    
    public func rootViewController() -> UINavigationController?{
        return self.navigationController
    }
    
    public func isResponsible(option:RoutingOptionProtocol) -> Bool{
        return option is RoutingOptionPushProtocol
    }
    
    public func present(routeString : String,
                 controller : UIViewController,
                 option : RoutingOptionProtocol,
                 parameters : [String : AnyObject],
                 wireframe : WireframeProtocol,
                 completion: (()->Void)){
    
    }


}