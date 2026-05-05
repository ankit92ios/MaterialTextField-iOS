//
//  MTTextInputControllerFloatingPlaceholder.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

@MainActor
protocol MTTextInputControllerFloatingPlaceholder: MTTextInputController {
    var floatingPlaceholderActiveColor: UIColor? { get set }
    var floatingPlaceholderNormalColor: UIColor? { get set }
    var floatingPlaceholderErrorActiveColor: UIColor? { get set }
    var floatingPlaceholderOffset: UIOffset { get }
    var floatingPlaceholderScale: NSNumber { get set }
}

