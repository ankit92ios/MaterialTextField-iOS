//
//  MTTextInputControllerBase.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

extension UIColor {
    static let customRedFF1744 = UIColor(
        red: 1.0,
        green: 23.0 / 255.0,
        blue: 68.0 / 255.0,
        alpha: 1.0
    )
    static let defaultTextColor = UIColor(white: 0, alpha: 0.54)
}

@MainActor
public class MTTextInputControllerBase: NSObject, MTTextInputControllerFloatingPlaceholder {
    private var placeholderAnimationConstraints: [NSLayoutConstraint] = []
    private var placeholderAnimationConstraintLeading: NSLayoutConstraint?
    private var placeholderAnimationConstraintTop: NSLayoutConstraint?
    private var placeholderAnimationConstraintTrailing: NSLayoutConstraint?
    private var previousLeadingText: String?

    private let defaultPadding: CGFloat = 8

    private let downAnimationDuration: TimeInterval = 0.27
    private let upAnimationDuration: TimeInterval = 0.3
    private let textColorDefault = UIColor.defaultTextColor
    private let underlineColorDefault = UIColor.lightGray
    private let errorColorDefault = UIColor.customRedFF1744
    
    public var activeColor: UIColor = .white {
        didSet {
            updateLayout()
        }
    }
    
    public var borderFillColor: UIColor = .clear {
        didSet {
            updateBorder()
        }
    }
    
    var disabledColor: UIColor = .white {
        didSet {
            updateLayout()
        }
    }
    
    var errorColor: UIColor = .red
    
    private(set) var errorText: String?
    
    public var normalColor: UIColor = .white {
        didSet {
            updateLayout()
        }
    }
    
    public var placeholderText: String {
        get {
            return textInput.placeholder ?? ""
        }
        set {
            if textInput.placeholder != newValue {
                textInput.placeholder = newValue
                let count = textInput.text?.count ?? 0
                if count > 0 {
                    updatePlaceholderAnimationConstraints(isToUp: true)
                }
            }
        }
    }
    
    var textInput: MaterialTextField! {
        didSet {
            unsubscribeFromNotifications()
            setupInput()
        }
    }
    
    // MARK: - Floating Placeholder Properties
    
    public var floatingPlaceholderActiveColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    public var floatingPlaceholderNormalColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    public var floatingPlaceholderErrorActiveColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    public var floatingPlaceholderOffset: UIOffset {
        var vertical = defaultPadding
        vertical -= (textInput.placeholderLabel.font.lineHeight) * (1 - CGFloat(floatingPlaceholderScale.floatValue)) * 0.5
        
        let insets = textInput.textInsets
        
        let placeholderMaxWidth = ((textInput.bounds.width) / CGFloat(floatingPlaceholderScale.floatValue)) - insets.left - insets.right
        
        var placeholderWidth = textInput.placeholderLabel.systemLayoutSizeFitting(.init(width: 0, height: 0)).width
        if placeholderWidth > placeholderMaxWidth {
            placeholderWidth = placeholderMaxWidth
        }
        
        let horizontal = placeholderWidth * (1 - CGFloat(floatingPlaceholderScale.floatValue)) * 0.5
        
        return UIOffset(horizontal: horizontal, vertical: vertical)
    }
    
    var floatingPlaceholderScale: NSNumber = NSNumber(value: 0.75) {
        didSet {
            updatePlaceholder()
            textInput.setNeedsUpdateConstraints()
        }
    }
    
    // MARK: - Border Properties
   
    var borderStrokeColor: UIColor = UIColor.white
    
    var borderRadius: CGFloat = 4 {
        didSet {
            updateLayout()
        }
    }
    
    var isDisplayingErrorText: Bool {
        return errorText != nil
    }
    
    // MARK: - Initialization
    required init(coder aDecoder: NSCoder) {
        super.init()
        commonInit()
        setupInput()
    }
    
    public required init(textInput: MaterialTextField) {
        super.init()
        self.textInput = textInput
        setupInput()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    private func commonInit() {
        disabledColor = underlineColorDefault
        borderRadius = 4
        disabledColor = underlineColorDefault
        normalColor = underlineColorDefault
        floatingPlaceholderNormalColor = textColorDefault
        errorColor = errorColorDefault
        
        forceUpdatePlaceholderY()
    }
    
    private func setupInput() {
        textInput.underline.disabledColor = disabledColor
        textInput.positioningDelegate = self
        
        subscribeForNotifications()
        textInput.underline.color = underlineColorDefault
        textInput.clearButton.tintColor = floatingPlaceholderActiveColor
        forceUpdatePlaceholderY()
    }
    
    private func subscribeForNotifications() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(textInputDidToggleEnabled(_:)), name: .mtTextInputDidToggleEnabledNotification, object: self.textInput)
        defaultCenter.addObserver(self, selector: #selector(textInputDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: self.textInput)
        defaultCenter.addObserver(self, selector: #selector(textInputDidChange(_:)), name: UITextField.textDidChangeNotification, object: self.textInput)
        defaultCenter.addObserver(self, selector: #selector(textInputDidEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: self.textInput)
        
        defaultCenter.addObserver(self, selector: #selector(textInputDidChange(_:)), name: .mtTextFieldTextDidSetTextNotification, object: self.textInput)
    }
    
    nonisolated private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateBorder() {
        textInput.borderView?.borderFillColor = borderFillColor
        textInput.borderView?.borderStrokeColor = borderStrokeColor
        textInput.borderPath = defaultBorderPath()
    }
    
    private func defaultBorderPath() -> UIBezierPath {
        var borderBound = textInput.bounds
        borderBound.size.height = textInput.underline.frame.maxY
        return UIBezierPath(roundedRect: borderBound, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: borderRadius, height: borderRadius))
    }
    
    private func updateLeadingUnderlineLabel() {
        textInput.leadingUnderlineLabel.font = self.captionFont()
        textInput.leadingUnderlineLabel.textColor = isDisplayingErrorText ? errorColor : self.normalColor
    }

    func updatePlaceholder() {
        let placeHolderFont = bodyFont()
        
        if textInput.placeholderLabel.font == nil || !textInput.placeholderLabel.font!.isSimplyEqual(to: placeHolderFont) {
            textInput.placeholderLabel.font = placeHolderFont
        }
        
        var placeholderColor: UIColor?
        if isPlaceholderUp() {
            let errorColor = textInput.isEditing == true ? (floatingPlaceholderErrorActiveColor ?? errorColor) : errorColor
            let nonErrorColor = textInput.isEditing == true ? floatingPlaceholderActiveColor : floatingPlaceholderNormalColor
            placeholderColor = isDisplayingErrorText ? errorColor : nonErrorColor
        } else {
            placeholderColor = normalColor
        }
        if textInput.isEnabled == false {
            placeholderColor = disabledColor
        }
        textInput.placeholderLabel.textColor = placeholderColor
    }
    
    private func movePlaceholderToUp(_ isToUp: Bool) {
        if isPlaceholderUp() == isToUp {
            return
        }
        
        let scaleFactor = CGFloat(floatingPlaceholderScale.floatValue)
        let floatingPlaceholderScaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
        let scaleTransform = isToUp ? floatingPlaceholderScaleTransform : .identity
        
        textInput.layoutIfNeeded()
        updatePlaceholderAnimationConstraints(isToUp: isToUp)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.textInput.placeholderLabel.transform = scaleTransform
            self.updatePlaceholder()
            self.updateBorder()
            self.textInput.layoutIfNeeded()
        } completion: { finished in
            if !isToUp {
                self.cleanupPlaceholderAnimationConstraints()
            }
        }
    }
    
    func isPlaceholderUp() -> Bool {
        return placeholderAnimationConstraints.count > 0 &&
               textInput.placeholderLabel.transform != .identity
    }
    
    private func updatePlaceholderAnimationConstraints(isToUp: Bool) {
        if isToUp {
            let offset = floatingPlaceholderOffset
            let insets = textInput.textInsets
            
            let leadingConstant = floatingPlaceholderAnimationConstraintLeadingConstant(textInsets: insets, offset: offset)
            if placeholderAnimationConstraintLeading == nil {
                placeholderAnimationConstraintLeading = NSLayoutConstraint(item: textInput.placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: textInput, attribute: .leading, multiplier: 1, constant: leadingConstant)
            }
            placeholderAnimationConstraintLeading!.constant = leadingConstant
            
            if placeholderAnimationConstraintTop == nil {
                placeholderAnimationConstraintTop = NSLayoutConstraint(item: textInput.placeholderLabel, attribute: .top, relatedBy: .equal, toItem: textInput, attribute: .top, multiplier: 1, constant: offset.vertical)
            }
            placeholderAnimationConstraintTop!.constant = offset.vertical
            
            let trailingConstant = floatingPlaceholderAnimationConstraintTrailingConstant(textInsets: insets, offset: offset)
            if placeholderAnimationConstraintTrailing == nil {
                placeholderAnimationConstraintTrailing = NSLayoutConstraint(item: textInput.placeholderLabel, attribute: .trailing, relatedBy: .equal, toItem: textInput, attribute: .trailing, multiplier: 1, constant: trailingConstant)
                placeholderAnimationConstraintTrailing!.priority = .defaultHigh - 1
            }
            placeholderAnimationConstraintTrailing!.constant = trailingConstant
            
            placeholderAnimationConstraints = [
                placeholderAnimationConstraintLeading!,
                placeholderAnimationConstraintTop!,
                placeholderAnimationConstraintTrailing!
            ]
            NSLayoutConstraint.activate(placeholderAnimationConstraints)
        } else {
            NSLayoutConstraint.deactivate(placeholderAnimationConstraints)
        }
    }
    
    private func needsUpdatePlaceholderAnimationConstraintsToUp() -> Bool {
        if !isPlaceholderUp() {
            return false
        }
        
        let insets = textInput.textInsets
        let offset = floatingPlaceholderOffset
        
        let leadingConstant = floatingPlaceholderAnimationConstraintLeadingConstant(textInsets: insets, offset: offset)
        let trailingConstant = floatingPlaceholderAnimationConstraintTrailingConstant(textInsets: insets, offset: offset)
        
        return placeholderAnimationConstraintLeading?.constant != leadingConstant &&
               placeholderAnimationConstraintTrailing?.constant != trailingConstant
    }
    
    private func cleanupPlaceholderAnimationConstraints() {
        if placeholderAnimationConstraintLeading?.isActive == true &&
           placeholderAnimationConstraintTop?.isActive == true &&
           placeholderAnimationConstraintTrailing?.isActive == true {
            return
        }
        placeholderAnimationConstraints = []
        placeholderAnimationConstraintLeading = nil
        placeholderAnimationConstraintTop = nil
        placeholderAnimationConstraintTrailing = nil
    }
    
    private func forceUpdatePlaceholderY() {
        var isDirectionToUp = false
        isDirectionToUp = textInput.text!.count > 0 || (textInput.isEditing)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        movePlaceholderToUp(isDirectionToUp)
        updateLayout()
        CATransaction.commit()
        textInput.layoutIfNeeded()
    }
    
    private func floatingPlaceholderAnimationConstraintLeadingConstant(textInsets: UIEdgeInsets, offset: UIOffset) -> CGFloat {
        return textInsets.left - offset.horizontal
    }
    
    private func floatingPlaceholderAnimationConstraintTrailingConstant(textInsets: UIEdgeInsets, offset: UIOffset) -> CGFloat {
        return offset.horizontal - textInsets.right
    }
    
    private func updateTrailingUnderlineLabel() {
        textInput.trailingUnderlineLabel.text = nil

        var textColor = textColorDefault
        if isDisplayingErrorText {
            textColor = errorColor
        }

        textInput.trailingUnderlineLabel.textColor = textColor
    }
    
    private func updateUnderline() {
        let underlineColor = textInput.isEditing == true ? activeColor : normalColor
        
        textInput.underline.color = isDisplayingErrorText ? errorColor : underlineColor
        textInput.underline.lineHeight = 0
        textInput.underline.disabledColor = disabledColor
    }
    
    func updateLayout() {
        updatePlaceholder()
        updateLeadingUnderlineLabel()
        updateTrailingUnderlineLabel()
        updateUnderline()
        updateBorder()
    }
    
    func textInsets(_ defaultInsets: UIEdgeInsets, withSizeThatFitsWidthHint widthHint: CGFloat) -> UIEdgeInsets {
        var textInsets = defaultInsets
        textInsets.top = defaultPadding +
        ceil((textInput.placeholderLabel.font.lineHeight) * CGFloat(floatingPlaceholderScale.floatValue)) +
                       defaultPadding
        
        let scale = UIScreen.main.scale
        let leadingOffset = ceil((textInput.leadingUnderlineLabel.font.lineHeight) * scale) / scale
        let calculatedNumberOfLinesForLeadingLabel: CGFloat = 1
        let adjustedLeadingOffset = max(leadingOffset, calculatedNumberOfLinesForLeadingLabel * leadingOffset)
        let trailingOffset = ceil((textInput.trailingUnderlineLabel.font.lineHeight) * scale) / scale
        
        var underlineOffset: CGFloat = 0
        underlineOffset += max(adjustedLeadingOffset, trailingOffset) + defaultPadding
        
        textInsets.bottom = underlineOffset + defaultPadding
        return textInsets
    }
    
    func textInsets(_ defaultInsets: UIEdgeInsets) -> UIEdgeInsets {
        return textInsets(defaultInsets, withSizeThatFitsWidthHint: 0)
    }
    
    func textInputDidLayoutSubviews() {
        updateBorder()
        
        if needsUpdatePlaceholderAnimationConstraintsToUp() {
            updatePlaceholderAnimationConstraints(isToUp: true)
        }
    }
    
    func textInputDidUpdateConstraints() {
        let count = self.textInput.text?.count ?? 0
        if count > 0 {
            updatePlaceholderAnimationConstraints(isToUp: true)
        }
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
    
    func trailingViewRect(forBounds bounds: CGRect, defaultRect: CGRect) -> CGRect {
        return defaultRect
    }
    
    func trailingViewTrailingPaddingConstant() -> CGFloat {
        return 0
    }
    
    @objc private func textInputDidBeginEditing(_ note: Notification) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(upAnimationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1))
        
        updateLayout()
        let count = self.textInput.text?.count ?? 0
        if !(count > 0) {
            movePlaceholderToUp(true)
        }
        CATransaction.commit()
    }
    
    @objc private func textInputDidToggleEnabled(_ notification: Notification) {
        if notification.object as? UIView !== textInput {
            return
        }
        updateLayout()
    }
    
    @objc private func textInputDidChange(_ note: Notification) {
        if note.name == .mtTextFieldTextDidSetTextNotification {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            updateLayout()
            forceUpdatePlaceholderY()
            CATransaction.commit()
        } else {
            updateLayout()
        }
    }
    
    @objc private func textInputDidEndEditing(_ note: Notification) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(downAnimationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1))
        
        updateLayout()
        if !(textInput.text!.count > 0) {
            movePlaceholderToUp(false)
        }
        CATransaction.commit()
    }
    
    public func setErrorText(_ errorText: String?, errorAccessibilityValue: String?) {
        if let errorText = errorText, !isDisplayingErrorText {
            previousLeadingText = textInput.leadingUnderlineLabel.text ?? ""
            textInput.leadingUnderlineLabel.text = errorText
            updatePlaceholder()
        }
        
        if let errorText = errorText, isDisplayingErrorText {
            textInput.leadingUnderlineLabel.text = errorText
        }
        
        if errorText == nil {
            if let previousLeadingText = previousLeadingText {
                textInput.leadingUnderlineLabel.text = previousLeadingText
            }
            previousLeadingText = nil
        }
        
        self.errorText = errorText
        updateLayout()
    }
    
    private func bodyFont() -> UIFont {
        let fontDescriptor = UIFontDescriptor.standardFontDescriptorForMaterialTextStyle()
        return UIFont(descriptor: fontDescriptor, size: 0.0)
    }
    
    private func captionFont() -> UIFont {
        let fontDescriptor = UIFontDescriptor.standardFontDescriptorForMaterialTextStyle()
        return UIFont(descriptor: fontDescriptor, size: 0.0)
    }
}

