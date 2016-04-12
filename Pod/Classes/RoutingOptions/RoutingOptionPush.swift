//
//  RoutingOptionPush.swift
//  Pods
//
//  Created by Jan Bartel on 12.04.16.
//
//

import Foundation
import VIPERS_Wireframe_Protocol

public struct RoutingOptionPush : RoutingOptionPushProtocol{

    public let animated : Bool
    
    public init(animated : Bool){
        self.animated = animated
    }

}