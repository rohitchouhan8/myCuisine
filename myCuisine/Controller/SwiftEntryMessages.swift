//
//  SwiftEntryMessages.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 6/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation
import SwiftEntryKit

struct SwiftEntryMessages {
    
    static func displayUnsuccessfulLogin(errorMessage: String) {
        print("Displaying unsuccessful login")
        /*
         Do some customization on customView
         */
        
        // Attributes struct that describes the display, style, user interaction and animations of customView.
        var attributes = EKAttributes()
        // Preset I
        attributes = .topFloat
        attributes.hapticFeedbackType = .success
        let amber = UIColor(red:1.00, green:0.76, blue:0.03, alpha:1.0)
        let pinky = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0)
        attributes.entryBackground = .gradient(gradient: .init(colors: [amber, pinky], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.size.width), height: .intrinsic)
        
        let title = "Login Error"
        let desc = errorMessage
        
        
        showNotificationMessage(attributes: attributes, title: title, desc: desc, textColor: .white)
    }
    
    static func showNotificationMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.systemFont(ofSize: 16), color: textColor))
        let description = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.systemFont(ofSize: 14), color: textColor))
        var image: EKProperty.ImageContent?
        if let imageName = imageName {
            image = .init(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
        }
        
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
}
