//
//  MTTextInputControllerOutlined.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

public class MTTextInputControllerOutlined: MTTextInputControllerBase {
    private var placeholderCenterY: NSLayoutConstraint?
    private var placeholderLeading: NSLayoutConstraint?
    
    private let placeholderPadding: CGFloat = 8
    private let fullPadding: CGFloat = 16
    private let normalPlaceholderPadding: CGFloat = 20
    private let threeQuartersPadding: CGFloat = 12
    
    public required init(textInput: MaterialTextField) {
        super.init(textInput: textInput)
    }
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var floatingPlaceholderOffset: UIOffset {
        var offset = super.floatingPlaceholderOffset
        let textVerticalOffset: CGFloat = 0
        offset.vertical = textVerticalOffset
        return offset
    }
    
    override func leadingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect {
        var leadingViewRect = defaultRect
        let xOffset = fullPadding
        
        leadingViewRect = leadingViewRect.offsetBy(dx: xOffset, dy: 0)
        
        let borderRect = borderRect()
        leadingViewRect.origin.y = borderRect.minY + borderRect.height / 2 - leadingViewRect.height / 2
        
        return leadingViewRect
    }
    
    override func leadingViewTrailingPaddingConstant() -> CGFloat {
        return fullPadding
    }
    
    override func trailingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect {
        var trailingViewRect = defaultRect
        let xOffset = -1 * threeQuartersPadding
        
        trailingViewRect = trailingViewRect.offsetBy(dx: xOffset, dy: 0)
        
        let borderRect = borderRect()
        trailingViewRect.origin.y = borderRect.minY + borderRect.height / 2 - trailingViewRect.height / 2
        
        return trailingViewRect
    }
    
    override func trailingViewTrailingPaddingConstant() -> CGFloat {
        return threeQuartersPadding
    }
    
    override func textInsets(_ defaultInsets: UIEdgeInsets, withSizeThatFitsWidthHint widthHint: CGFloat) -> UIEdgeInsets {
        var textInsets = defaultInsets
        textInsets.left = fullPadding
        textInsets.right = fullPadding
        textInsets = super.textInsets(textInsets, withSizeThatFitsWidthHint: widthHint)
        
        let textVerticalOffset = textInput.placeholderLabel.font.lineHeight * 0.5
        
        let scale = UIScreen.main.scale
        let placeholderEstimatedHeight = ceil((textInput?.placeholderLabel.font.lineHeight ?? 0) * scale) / scale
        textInsets.top = borderHeight() - fullPadding - placeholderEstimatedHeight + textVerticalOffset
        
        return textInsets
    }
    
    override func updateLayout() {
        super.updateLayout()
        textInput?.clipsToBounds = false
    }
    
    func updateUnderline() {
        textInput?.underline.isHidden = true
    }
    
    override func updateBorder() {
        super.updateBorder()
        
        var path: UIBezierPath
        if isPlaceholderUp() {
            var placeholderWidth: CGFloat = 0
            if let placeholderString = textInput?.placeholderLabel.text?.trimmingCharacters(in: .whitespaces), !placeholderString.isEmpty {
                placeholderWidth = (textInput?.placeholderLabel.systemLayoutSizeFitting(.init(width: 0, height: 0)).width ?? 0) * CGFloat(floatingPlaceholderScale.floatValue)
                placeholderWidth += placeholderPadding
            }
            
            path = roundedPath(fromRect: borderRect(), withTextSpace: placeholderWidth, leadingOffset: fullPadding - placeholderPadding / 2)
        } else {
            let cornerRadius = CGSize(width: borderRadius, height: borderRadius)
            path = UIBezierPath(roundedRect: borderRect(), byRoundingCorners: UIRectCorner.allCorners, cornerRadii: cornerRadius)
        }
        textInput?.borderPath = path
        
        var borderColor = textInput?.isEditing == true ? activeColor : borderStrokeColor
        if textInput?.isEnabled == false {
            borderColor = disabledColor
        }
        textInput?.borderView?.borderStrokeColor = isDisplayingErrorText ? errorColor : borderColor
        textInput?.borderView?.borderPath.lineWidth = textInput?.isEditing == true ? 2 : 1
        
        textInput?.borderView?.setNeedsLayout()
        
        updatePlaceholder()
    }
    
    private func borderRect() -> CGRect {
        guard let textInput = textInput else { return .zero }
        var pathRect = textInput.bounds
        pathRect.origin.y = pathRect.origin.y + (textInput.placeholderLabel.font.lineHeight * 0.5)
        pathRect.size.height = borderHeight()
        return pathRect
    }
    
    private func roundedPath(fromRect f: CGRect, withTextSpace textSpace: CGFloat, leadingOffset offset: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let radius = borderRadius
        let yOffset = f.origin.y
        let xOffset = f.origin.x
        
        // Draw the path
        path.move(to: CGPoint(x: radius + xOffset, y: yOffset))
        path.addLine(to: CGPoint(x: offset + xOffset, y: yOffset))
        path.move(to: CGPoint(x: textSpace + offset + xOffset, y: yOffset))
        path.addLine(to: CGPoint(x: f.size.width - radius + xOffset, y: yOffset))
        
        path.addArc(withCenter: CGPoint(x: f.size.width - radius + xOffset, y: radius + yOffset), radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: f.size.width + xOffset, y: f.size.height - radius + yOffset))
        path.addArc(withCenter: CGPoint(x: f.size.width - radius + xOffset, y: f.size.height - radius + yOffset), radius: radius, startAngle: 0, endAngle: -CGFloat.pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: radius + xOffset, y: f.size.height + yOffset))
        path.addArc(withCenter: CGPoint(x: radius + xOffset, y: f.size.height - radius + yOffset), radius: radius, startAngle: -CGFloat.pi * 3 / 2, endAngle: -CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: xOffset, y: radius + yOffset))
        path.addArc(withCenter: CGPoint(x: radius + xOffset, y: radius + yOffset), radius: radius, startAngle: -CGFloat.pi, endAngle: -CGFloat.pi / 2, clockwise: true)
        
        return path
    }
    
    override func updatePlaceholder() {
        super.updatePlaceholder()
        
        let scale = UIScreen.main.scale
        let placeholderEstimatedHeight = ceil((textInput?.placeholderLabel.font.lineHeight ?? 0) * scale) / scale
        let placeholderConstant = (borderHeight() / 2) - (placeholderEstimatedHeight / 2) + (textInput?.placeholderLabel.font.lineHeight ?? 0) * 0.5
        
        if placeholderCenterY == nil {
            placeholderCenterY = NSLayoutConstraint(item: textInput!.placeholderLabel, attribute: .top, relatedBy: .equal, toItem: textInput, attribute: .top, multiplier: 1, constant: placeholderConstant)
            placeholderCenterY?.priority = .defaultHigh
            placeholderCenterY?.isActive = true
            
            textInput?.placeholderLabel.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        }
        placeholderCenterY?.constant = placeholderConstant
        
        var placeholderLeadingConstant = fullPadding
        
        if let leadingViewInput = textInput, leadingViewInput.leftView?.superview != nil {
            placeholderLeadingConstant += leadingViewInput.leftView!.frame.width + leadingViewTrailingPaddingConstant()
        }
        
        if placeholderLeading == nil {
            placeholderLeading = NSLayoutConstraint(item: textInput!.placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: textInput, attribute: .leading, multiplier: 1, constant: placeholderLeadingConstant)
            placeholderLeading?.priority = .defaultHigh
            placeholderLeading?.isActive = true
        }
        placeholderLeading?.constant = placeholderLeadingConstant
    }
    
    private func borderHeight() -> CGFloat {
        let scale = UIScreen.main.scale
        let placeholderEstimatedHeight = ceil((textInput?.placeholderLabel.font.lineHeight ?? 0) * scale) / scale
        return normalPlaceholderPadding + placeholderEstimatedHeight + normalPlaceholderPadding
    }
}

