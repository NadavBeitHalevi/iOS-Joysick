//
//  JoystickEnums.swift
//  joystick
//
//  Created by nadavb on 4/26/17.
//  Copyright © 2017 Nadav Beit-Halevi. All rights reserved.
//

import Foundation
import UIKit

public enum JoystickDirection : Int {
    case none = 0
    case up
    case down
    case left
    case right
}

public protocol JoystickProtocol {
    
    func joystickDidEndMoving(_ joystickView: JoystickView) -> Void
    
    func didMoveIn(direction: JoystickDirection, percentageOfMovement: CGFloat) -> Void
}

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
}

func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(CGPointDistanceSquared(from: from, to: to));
}
