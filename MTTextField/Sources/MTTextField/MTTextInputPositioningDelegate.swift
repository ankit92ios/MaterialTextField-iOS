//
//  MTTextInputPositioningDelegate.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

@MainActor
protocol MTTextInputPositioningDelegate {
    func textInsets(_ defaultInsets: UIEdgeInsets) -> UIEdgeInsets
    func textInsets(_ defaultInsets: UIEdgeInsets, withSizeThatFitsWidthHint widthHint: CGFloat) -> UIEdgeInsets
    func editingRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect
    func leadingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect
    func leadingViewTrailingPaddingConstant() -> CGFloat
    func textInputDidLayoutSubviews()
    func textInputDidUpdateConstraints()
    func trailingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect
    func trailingViewTrailingPaddingConstant() -> CGFloat
}

extension MTTextInputPositioningDelegate {
    func textInsets(_ defaultInsets: UIEdgeInsets) -> UIEdgeInsets {
        return textInsets(defaultInsets, withSizeThatFitsWidthHint: 0)
    }
    
    func editingRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect {
        return defaultRect
    }
    
    func leadingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect {
        return defaultRect
    }
    
    func leadingViewTrailingPaddingConstant() -> CGFloat {
        return 0
    }
    
    func textInputDidLayoutSubviews() {
        // Default implementation does nothing
    }
    
    func textInputDidUpdateConstraints() {
        // Default implementation does nothing
    }
    
    func trailingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect {
        return defaultRect
    }
    
    func trailingViewTrailingPaddingConstant() -> CGFloat {
        return 0
    }
}

