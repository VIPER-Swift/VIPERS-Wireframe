  //
//  AppDelegate.swift
//  VIPERS-Wireframe
//
//  Created by Jan Bartel on 04/12/2016.
//  Copyright (c) 2016 Jan Bartel. All rights reserved.
//

import UIKit
import VIPERS_Wireframe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        let navigationController = UINavigationController()
        
        let pushRoutingPresenter = RoutingPresenterPush()
        pushRoutingPresenter.setRootViewController(navigationController)
        
        let aNavigationController : UINavigationController = pushRoutingPresenter.rootViewController()!
        
        print("controller:\(aNavigationController)")
        
        
        let wireframe = Wireframe()
        
        
        
        // Override point for customization after application launch.
        return true
    }

}

