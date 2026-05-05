//
//  MTTextInputController.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

/// Controllers that manipulate styling and animation of text inputs.
@MainActor
protocol MTTextInputController: MTTextInputPositioningDelegate {
    var activeColor: UIColor { get set }
    var disabledColor: UIColor { get set }
    var errorColor: UIColor { get set }
    var errorText: String? { get }
    var normalColor: UIColor { get set }
    var placeholderText: String { get set }
    var textInput: MaterialTextField! { get set }
    init(textInput: MaterialTextField)
    func setErrorText(_ errorText: String?, errorAccessibilityValue: String?)
}

