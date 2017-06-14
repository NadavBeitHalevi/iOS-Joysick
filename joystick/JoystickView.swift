//
//  JoystickView.swift
//  joystick
//
//  Created by nadavb on 4/26/17.
//  Copyright © 2017 Nadav Beit-Halevi. All rights reserved.
//

import UIKit
import CoreMotion

@IBDesignable
public class JoystickView : UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var view:UIView?
    
    // MARK:- Properties
    var thumbRadius: CGFloat!
    let margin: CGFloat = 7.0
    var nibName: String = "JoystickView"
    var joystickDelegate : JoystickProtocol!
    var motionManager: CMMotionManager!
    var lastPoint : CGPoint = CGPoint.init(x: 0.0, y: 0.0)
    var lastDirection : JoystickDirection = .none
    var backgroundCenter : CGPoint = CGPoint.init(x: 0.0, y: 0.0)
    
    private var _tiltMode: Bool = false
    var tiltMode : Bool {
        set (newValue) {
            // Switch on super init as false
            if newValue {
                self.setTiltModeOn()
            }
            else {
                self.setTiltModeOff()
            }
            
        }
        get { return _tiltMode }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // MARK:- Setup view - Load from nib
    func setup() {
        view = loadViewFromNib()
        
        view?.frame = bounds
        view?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        addSubview(view!)
        if view != nil {
            self.backgroundCenter = (self.view?.center)!
        }
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK:- Set images to view
    public func initWith(_ backgroundImage: UIImage?, thumbImage: UIImage?)
    {
        self.thumbRadius = self.thumbImageView.frame.width / 2
        
        // Background image
        if backgroundImage == nil {
            self.backgroundImageView.backgroundColor = UIColor.gray
        }
        else {
            self.backgroundImageView.image = backgroundImage
        }
        
        self.backgroundImageView.layer.cornerRadius = self.frame.width / 2
        self.backgroundImageView.center = self.center
        
        // Thumb image
        self.thumbImageView.layer.cornerRadius = self.thumbRadius
        
        self.thumbImageView.center = self.center
        
        if thumbImage == nil {
            self.thumbImageView.backgroundColor = UIColor.yellow
        }
        else {
            self.thumbImageView.image = thumbImage
        }
    }
    
    // MARK:- UITouch events handlers
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleFingerTouch(touches)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleFingerTouch(touches)
        
    }
    
    private func getPersentageBy(location: CGPoint,
                                 andDirection: JoystickDirection) -> CGFloat {
        
        let distance = CGPointDistance(from: location, to: self.view!.center)
        
        return (distance + self.thumbRadius) / ((self.view?.frame.width)! / 2)
    }
    
    private func updateThumbImageViewCenter(center : CGPoint, inDirection: JoystickDirection) {
        switch inDirection {
        case .up, .down:
            DispatchQueue.main.async {
                self.thumbImageView.center = CGPoint(x: self.view!.center.x,
                                                     y: (center.y))
            }
            break
        case .right, .left:
            DispatchQueue.main.async {
                self.thumbImageView.center = CGPoint(x: (center.x),
                                                     y: (self.view?.center.y)!)
            }
            break
        default:
            break
        }
    }
    
    private func valided(location: CGPoint, accordingTo direction: JoystickDirection) -> Bool {
        var tempPoint = CGPoint.init(x: 0, y: 0)
        
        switch direction {
        case .up:
            tempPoint = CGPoint(x: self.view!.center.x, y: (location.y) - self.thumbRadius)// - self.margin)
            break
        case .down:
            tempPoint = CGPoint(x: self.view!.center.x, y: (location.y) + self.thumbRadius)// + self.margin)
            
            break
        case .left:
            tempPoint = CGPoint(x: location.x - (self.thumbRadius),// - self.margin,
                y: self.view!.center.y)
            break
        case .right:
            tempPoint = CGPoint(x: location.x + (self.thumbRadius), // + self.margin,
                y: self.view!.center.y)
            break
        default:
            break
        }
        
        return self.backgroundImageView.point(inside: tempPoint, with: nil)
    }
    
    private func getCurrentDirection(location: CGPoint) -> JoystickDirection {
        var direction : JoystickDirection = .none
        
        // Up or Down
        if (location.x) <= (self.view!.center.x) + 25 &&
            (location.x) >= (self.view!.center.x) - 25 &&
            location.y != self.view!.center.y {
            direction = location.y >= self.view!.center.y ? .down : .up
        }
        // Left of Right
        else if (location.y) <= self.view!.center.y + 25 &&
            (location.y) >= self.view!.center.y - 25 &&
            location.x != self.center.x {
            direction = location.x > self.view!.center.x ? JoystickDirection.right : JoystickDirection.left
        }
        return direction
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.initJoystickCoordinate()
        if self.joystickDelegate != nil {
            self.joystickDelegate.joystickDidEndMoving(self)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleFingerTouch(touches)
        initJoystickCoordinate()
    }
    
    func initJoystickCoordinate() {
        self.thumbImageView.center = self.view!.center
        if self.joystickDelegate != nil {
            self.joystickDelegate.joystickDidEndMoving(self)
        }
    }
    
    private func handleFingerTouch(_ touches: Set<UITouch>) {
        
        let touch = touches.first
        let location = touch?.location(in: self.view)
        
        guard location != nil else {
            return
        }
        let direction = self.getCurrentDirection(location: location!)
        let isValid = self.valided(location: location!, accordingTo: direction)
        
        print(direction)
        print(isValid)
        guard isValid else {
            // "OUT OF FRAME"
            print("out of frame")
            return
        }
        self.updateThumbImageViewCenter(center: location!, inDirection: direction)
        let persent = self.getPersentageBy(location: location!, andDirection: direction)
        
        if self.joystickDelegate != nil {
            self.joystickDelegate.didMoveIn(direction: direction, percentageOfMovement: persent)
        }
    }
    
    // MARK:- Tilt mode
    private func setTiltModeOn() {
        DispatchQueue.main.async {
            self.initJoystickCoordinate()
            self.thumbImageView.alpha = 0.6
        }
        self.startAcceleration()
    }
    
    private func startAcceleration(){
        self.motionManager = CMMotionManager()
        
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 0.025
            self.motionManager.startAccelerometerUpdates(to: .main) {
                [weak self] (data: CMAccelerometerData?, error: Error?) in
                if let acceleration = data?.acceleration {
                    
                    let distance = CGPointDistance(from: CGPoint.init(x: 0.0, y: 0.0),
                                                   to: CGPoint.init(x: acceleration.x, y: acceleration.y))
                    
                    let currentDirection = self!.getDirection(acceleration: acceleration)
                    
                    if currentDirection == JoystickDirection.none {
                        return
                    }
                    
                    let point = self?.convert(direction: currentDirection,
                                              distance: distance)
                    
                    guard let _ = point else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.updateJoystick(centerPoint: point!,
                                             direction: currentDirection)
                    }
                }
            }
        }
        else {
            // should raise error handler
        }
    }
    
    private func updateJoystick(centerPoint: CGPoint, direction: JoystickDirection) {
        var shouldUpadte = false
        if (self.valided(location: centerPoint, accordingTo: direction)) {
            // should check whether the current point is of the right path
            switch direction {
            case .down, .up:
                let width = self.backgroundCenter.x
                if (centerPoint.x) < width + 15 && centerPoint.x > width - 15 {
                    shouldUpadte = true
                }
                break
            case .left, .right:
                let height = self.backgroundCenter.y
                if (centerPoint.y) > height - 15 && (centerPoint.y) < height + 15 {
                    shouldUpadte = true
                }
                break
            default:
                return
            }
        }
        if shouldUpadte {
            DispatchQueue.main.async {
                self.thumbImageView.center = centerPoint
            }
        }
        if self.joystickDelegate != nil {
            let persent = self.getPersentageBy(location: centerPoint, andDirection: direction)
            self.joystickDelegate.didMoveIn(direction: direction, percentageOfMovement: persent)
        }
    }
    
    private func setTiltModeOff() {
        DispatchQueue.main.async {
            self.initJoystickCoordinate()
            self.thumbImageView.alpha = 1.0
        }
        self.stopAcceleration()
    }
    
    private func stopAcceleration() {
        self.motionManager = nil
    }
    
    private func convert(direction: JoystickDirection, distance: CGFloat) -> CGPoint? {
        let outterRadius = self.backgroundImageView.frame.width / 2
        var yAxis: CGFloat = 0.0
        var xAxis: CGFloat = 0.0
        
        guard distance < 1.0 else {
            return nil
        }
        
        switch direction {
        case .up:
            yAxis = self.thumbImageView.center.y - (outterRadius * distance / self.thumbRadius)
            xAxis = self.thumbImageView.center.x
            break
        case .down:
            yAxis = self.thumbImageView.center.y + (outterRadius * distance / self.thumbRadius)
            xAxis = self.thumbImageView.center.x
            break
        case .left:
            yAxis = self.thumbImageView.center.y
            xAxis = self.thumbImageView.center.x - (outterRadius * distance / self.thumbRadius)
            break
        case .right:
            yAxis = self.thumbImageView.center.y
            xAxis = self.thumbImageView.center.x + (outterRadius * distance / self.thumbRadius)
            break
        default:
            break
        }
        
        let newCenter = CGPoint.init(x: xAxis, y: yAxis)
        return newCenter
        
    }
    
    private func getDirection(acceleration: CMAcceleration) -> JoystickDirection
    {
        var direction = JoystickDirection.none
        print("Xaxis : \(acceleration.x) YAxis : \(acceleration.z)")
        if fabs(acceleration.x) < 0.003 && fabs(acceleration.y) < 0.003 {
            return direction
        }
        else if (fabs(acceleration.x) > fabs(acceleration.y)) {
            direction = CGFloat(acceleration.x) < 0.0  ? .left : .right
            
        }
        else {
            direction = CGFloat(acceleration.y) < 0.0  ? .down : .up
        }
        print(direction)
        return direction
    }
    
    // MARK:- Move in direction from outter view (such as buttons)
    func moveIn(direction: JoystickDirection)
    {
        let currentThumbCenter = self.thumbImageView.center
        var nextCenter = CGPoint.init(x: 0.0, y: 0.0)
        switch direction {
        case .up:
            nextCenter.x = currentThumbCenter.x
            nextCenter.y = currentThumbCenter.y - 1
            break
        case .down:
            nextCenter.x = currentThumbCenter.x
            nextCenter.y = currentThumbCenter.y + 1
            break
        case .right:
            nextCenter.x = currentThumbCenter.x + 1
            nextCenter.y = currentThumbCenter.y
            break
        case .left:
            nextCenter.x = currentThumbCenter.x - 1
            nextCenter.y = currentThumbCenter.y
            break
        case .none:
            nextCenter.x = self.backgroundCenter.x
            nextCenter.y = self.backgroundCenter.y
            break
        }
        
        let isValid = self.valided(location: nextCenter,
                                   accordingTo: direction)
        
        guard isValid else { // "OUT OF FRAME"
            return
        }
        
        self.updateThumbImageViewCenter(center: nextCenter, inDirection: direction)
        
        let persent = self.getPersentageBy(location: nextCenter, andDirection: direction)
        
        if self.joystickDelegate != nil {
            self.joystickDelegate.didMoveIn(direction: direction, percentageOfMovement: persent)
        }
    }
    
    func reset() {
        if self.motionManager != nil {
            self.stopAcceleration()
            self.motionManager = nil
        }
    }
    
    
    
}
