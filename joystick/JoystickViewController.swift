//
//  JoystickViewController.swift
//  Maytronics
//
//  Created by nadavb on 4/30/17.
//

import UIKit
import AudioToolbox

class JoystickViewController : UIViewController, JoystickProtocol {
    
    @IBOutlet weak var joystickView : JoystickView!
    
    // MARK:- UIOutlets
    @IBOutlet weak var upArrowButton: UIButton!
    @IBOutlet weak var downArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var stopCleaningButton: UIButton!
    
    
    // MARK:- Properties
    
    // The divider to the amount of movement from the percentage
    // Set the max range movement
    let maxRangeForDivider = 50
    
    private var isTiltMode : Bool = false
    
    private var lastDirection : JoystickDirection = JoystickDirection.none
    
    // MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        joystickView.initWith(nil, thumbImage: nil)
        
        self.initButtons()
    }
    
    private func initButtons() {
        self.upArrowButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(JoystickViewController.upTap(_:))))
        
        self.upArrowButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                             action: #selector(JoystickViewController.upLongPress(_:))))
        
        self.downArrowButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(JoystickViewController.downTap(_:))))
        
        self.downArrowButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                               action: #selector(JoystickViewController.downLongPress(_:))))
        
        self.rightArrowButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action: #selector(JoystickViewController.rightTap(_:))))
        
        self.rightArrowButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                                action: #selector(JoystickViewController.rightLongPress(_:))))
        
        self.leftArrowButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(JoystickViewController.leftTap(_:))))
        
        self.leftArrowButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                               action: #selector(JoystickViewController.leftLongPress(_:))))
    }
    
    func upTap(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .up)
    }
    func upLongPress(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .up)
    }
    
    func downTap(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .down)
    }
    func downLongPress(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .down)
    }
    
    func rightTap(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .right)
    }
    func rightLongPress(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .right)
    }
    
    func leftTap(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .left)
    }
    func leftLongPress(_ sender: UIGestureRecognizer) {
        self.joystickView.moveIn(direction: .left)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        joystickView.joystickDelegate = nil
        joystickView.reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.joystickView.initJoystickCoordinate()
        self.updateBackgourndImageAccordingToCurrentDirection()
        joystickView.joystickDelegate = self
        joystickView.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func joystickDidEndMoving(_ joystickView: JoystickView) -> Void {
        self.resetJoystick()
    }
    
    private func resetJoystick() {
        self.updateBackgourndImageAccordingToCurrentDirection()
    }
    
    func didMoveIn(direction: JoystickDirection, percentageOfMovement: CGFloat) -> Void {
        
        let range = Int(floor(percentageOfMovement * CGFloat.init(integerLiteral: self.maxRangeForDivider)))
        print("Current range : \(range)")
        
        if abs(range) >= self.maxRangeForDivider - 2  {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        self.updateBackgourndImageAccordingToCurrentDirection()
    }
    
    private func isThumbReachedHalfwayDistanceFromCenter(currentPosition : Int) -> Bool {
        return abs(currentPosition) >= Int(abs(self.maxRangeForDivider) / 2) &&
            abs(currentPosition) < Int(Double(self.maxRangeForDivider) * 0.85)
    }
    
    private func isThumbReachedFullDistanceFromCenter(currentPosition : Int) -> Bool {
        return abs(currentPosition) >= Int(Double(self.maxRangeForDivider) * 0.85)
    }
    
    /// Use it in case you want to update the background image with another
    /// For example : reaching to the end of the circle
    func updateBackgourndImageAccordingToCurrentDirection() {
        //        let currentCenter = self.joystickView.thumbImageView.center
        //        let centerView = self.joystickView.backgroundCenter
        //        var direction : JoystickDirection = .none
        //        var image : UIImage = #imageLiteral(resourceName: "joystick_base_view")
        //
        //        if currentCenter.y < centerView.y && centerView.y > currentCenter.y + 15.0 {
        //            direction = .up
        //        }
        //        if currentCenter.y > centerView.y && centerView.y < currentCenter.y - 15.0 {
        //            direction = .down
        //        }
        //        if currentCenter.x < centerView.x && centerView.x > currentCenter.x + 15.0 {
        //            direction = .left
        //        }
        //        if currentCenter.x > centerView.x && centerView.x < currentCenter.x - 15.0 {
        //            direction = .right
        //        }
        //
        //        if self.isThumbReachedHalfwayDistanceFromCenter(currentPosition: self.left) {
        //            switch direction {
        //            case .up:
        //                image = #imageLiteral(resourceName: "joystick_up_halfway")
        //                break
        //            case .right:
        //                image = #imageLiteral(resourceName: "joystick_right_halfway")
        //                break
        //            case .down:
        //                image = #imageLiteral(resourceName: "joystick_down_halfway")
        //                break
        //            case .left:
        //                image = #imageLiteral(resourceName: "joystick_left_halfway")
        //                break
        //            default:
        //                image = #imageLiteral(resourceName: "joystick_base_view")
        //            }
        //        }
        //        if self.isThumbReachedFullDistanceFromCenter(currentPosition: self.left){
        //            switch direction {
        //            case .up:
        //                image = #imageLiteral(resourceName: "joystick_up_full")
        //                break
        //            case .right:
        //                image = #imageLiteral(resourceName: "joystick_right_full")
        //                break
        //            case .down:
        //                image = #imageLiteral(resourceName: "joystick_down_full")
        //                break
        //            case .left:
        //                image = #imageLiteral(resourceName: "joystick_left_full")
        //                break
        //            default:
        //                image = #imageLiteral(resourceName: "joystick_base_view")
        //            }
        //        }
        //        DispatchQueue.main.async {
        //            UIView.transition(with: (self.joystickView.backgroundImageView)!,
        //                              duration: 0.3,
        //                              options: .transitionCrossDissolve,
        //                              animations: {
        //                                self.joystickView.backgroundImageView.image = image
        //            }, completion: nil)
        //        }
    }
    
    @IBAction func tiltButtonAction(_ sender: Any) {
        
        self.isTiltMode = !isTiltMode
        self.joystickView.tiltMode = self.isTiltMode
        self.joystickView.isUserInteractionEnabled = !self.isTiltMode
        
        self.upArrowButton.isEnabled = !self.isTiltMode
        self.downArrowButton.isEnabled = !self.isTiltMode
        self.leftArrowButton.isEnabled = !self.isTiltMode
        self.rightArrowButton.isEnabled = !self.isTiltMode
        self.updateBackgourndImageAccordingToCurrentDirection()
    }
    
    @IBAction func stopCleaningAction() {
        self.joystickView.initJoystickCoordinate()
        // self.updateBackgourndImageAccordingToCurrentDirection()
    }
}
