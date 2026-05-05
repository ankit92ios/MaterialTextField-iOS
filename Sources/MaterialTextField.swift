//
//  MaterialTextField1.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//

import UIKit

extension Notification.Name {
    static let mtTextFieldTextDidSetTextNotification = Notification.Name("MTTextFieldTextDidSetTextNotification")
    static let mtTextInputDidToggleEnabledNotification = Notification.Name("MTTextInputDidToggleEnabledNotification")

}

@MainActor
public final class MaterialTextField: UITextField {
    private let underlineKVOKeyColor = "color"
    private let underlineKVOKeyLineHeight = "lineHeight"
    private let clearButtonPadding: CGFloat = 2.5
    private let rightViewPaddingCorrection: CGFloat = -2
    private let rectYCorrection: CGFloat = 1
    private let borderRadius: CGFloat = 4
    private let fullPadding: CGFloat = 16
    private let halfPadding: CGFloat = 8

    private let clearButtonImageSquareWidthHeight: CGFloat = 24
    private let editingRectPadding: CGFloat = 2
    
    private let placeholderTextColor = UIColor(white: 0, alpha: 0.54)
    private let inputTextColor = UIColor(white: 0, alpha: 0.87)
    private let inputUnderlineColor = UIColor.lightGray

    private var isRegisteredForKVO: Bool = false
    
    private var clearButtonCenterY: NSLayoutConstraint!
    private var clearButtonTrailing: NSLayoutConstraint!
    private var clearButtonWidth: NSLayoutConstraint!
    private var leadingUnderlineLeading: NSLayoutConstraint!
    private var leadingUnderlineTrailing: NSLayoutConstraint!
    private var trailingUnderlineLeading: NSLayoutConstraint!
    private var trailingUnderlineTrailing: NSLayoutConstraint!
    private var placeholderLeading: NSLayoutConstraint!
    private var placeholderLeadingLeadingViewTrailing: NSLayoutConstraint!
    private var placeholderTop: NSLayoutConstraint!
    private var placeholderTrailing: NSLayoutConstraint!
    private var placeholderTrailingTrailingViewLeading: NSLayoutConstraint!
    private var underlineY: NSLayoutConstraint!
    private var sizeThatFitsWidthHint: CGFloat = 0
    
    public override var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholderAlpha()
            self.setNeedsLayout()
        }
    }
    
    var textInsets: UIEdgeInsets {
        var textInsets = UIEdgeInsets.zero
        textInsets.top = fullPadding
        
        let scale = UIScreen.main.scale
        let leadingOffset = ceil(leadingUnderlineLabel.font.lineHeight * scale) / scale
        let trailingOffset = ceil(trailingUnderlineLabel.font.lineHeight * scale) / scale
        
        var contentConditionalOffset: CGFloat = 0
        if let leadingText = leadingUnderlineLabel.text, !leadingText.isEmpty {
            contentConditionalOffset = leadingOffset
        }
        if let trailingText = trailingUnderlineLabel.text, !trailingText.isEmpty {
            contentConditionalOffset = max(contentConditionalOffset, trailingOffset)
        }
        
        var underlineOffset = halfPadding
        underlineOffset += max(leadingOffset, trailingOffset)
        
        textInsets.bottom = underlineOffset + halfPadding
        
        if let positioningDelegate = positioningDelegate {
            return positioningDelegate.textInsets(textInsets, withSizeThatFitsWidthHint: sizeThatFitsWidthHint)
        }
        return textInsets
    }

    var underline: MTTextInputUnderlineView = MTTextInputUnderlineView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let interfaceBuilderPlaceholder = super.placeholder
        commonInit()
        
        if let placeholder = interfaceBuilderPlaceholder, !placeholder.isEmpty {
            self.placeholder = placeholder
        }
        placeholderLabel.backgroundColor = backgroundColor
        
        setNeedsLayout()
    }
    
    deinit {
        unsubscribeFromNotifications()
        unsubscribeFromKVO()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func commonInit() {
        setupUnderlineLabels()
        setupPlaceholderLabel()
        setupClearButton()
        self.textColor = inputTextColor
        
        setupUnderlineView()
        
        setupBorder()
        subscribeForKVO()
        
        sizeThatFitsWidthHint = 0
        self.font = bodyFont()
        borderStyle = .none
        
        // Set the clear button color to black with 54% opacity.
        clearButton.tintColor = UIColor(white: 0, alpha: 0.54)
        tintColor = UIColor(red: 0.160784, green: 0.384314, blue: 1, alpha: 1)
        
        setupUnderlineConstraints()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: self)
        defaultCenter.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: self)
        
        setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
    }
    
    // MARK: - Underline View Implementation
    
    private func setupUnderlineConstraints() {
        let underlineLeading = NSLayoutConstraint(item: underline, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        underlineLeading.priority = .defaultLow
        underlineLeading.isActive = true
        
        let underlineTrailing = NSLayoutConstraint(item: underline, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        underlineTrailing.priority = .defaultLow
        underlineTrailing.isActive = true
        
        underlineY = NSLayoutConstraint(item: underline, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: textInsets.top + estimatedTextHeight() + halfPadding)
        underlineY.priority = .defaultLow
        underlineY.isActive = true
    }
    
    private func underlineYConstant() -> CGFloat {
        return textInsets.top + estimatedTextHeight() + halfPadding
    }
    
    private func needsUpdateUnderlinePosition() -> Bool {
        return !MTCGFloatEqual(underlineY.constant, underlineYConstant())
    }
    
    private func updateUnderlinePosition() {
        underlineY?.constant = underlineYConstant()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Border Implementation
    
    private func defaultBorderPath() -> UIBezierPath {
        var borderBound = bounds
        borderBound.size.height = underline.frame.maxY
        return UIBezierPath(roundedRect: borderBound, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: borderRadius, height: borderRadius))
    }
    
    private func updateBorder() {
        borderView?.borderPath = borderPath
    }
    
    //MARK: - Protocol Properties
    
    var borderPath: UIBezierPath! {
        didSet {
            updateBorder()
        }
    }
    
    var borderView: MTTextInputBorderView!
    lazy var clearButton: OETextInputClearButton = {
        let clearButton = OETextInputClearButton()
        clearButton.backgroundColor = .clear
        clearButton.clipsToBounds = false
        clearButton.contentEdgeInsets = .zero
        return clearButton
    }()
    
    lazy var leadingUnderlineLabel: UILabel = {
        leadingUnderlineLabel = UILabel(frame: .zero)
        leadingUnderlineLabel.textColor = placeholderTextColor
        leadingUnderlineLabel.font = self.font
        leadingUnderlineLabel.textAlignment = .natural
        leadingUnderlineLabel.translatesAutoresizingMaskIntoConstraints = false
        return leadingUnderlineLabel
    }()
    
    var placeholderLabel: UILabel = UILabel(frame: .zero)
    var positioningDelegate: MTTextInputPositioningDelegate?
    lazy var trailingUnderlineLabel: UILabel = {
        trailingUnderlineLabel = UILabel(frame: .zero)
        trailingUnderlineLabel.textColor = .gray
        trailingUnderlineLabel.font = self.font
        trailingUnderlineLabel.textAlignment = .natural
        trailingUnderlineLabel.translatesAutoresizingMaskIntoConstraints = false
        return trailingUnderlineLabel
    }()
    
    public override var backgroundColor: UIColor? {
        didSet {
            placeholderLabel.backgroundColor = backgroundColor
        }
    }
    
    public override var font: UIFont? {
        didSet {
            let previousFont = oldValue
            super.font = font
            self.didSetFont(previousFont)
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            NotificationCenter.default.post(name: .mtTextInputDidToggleEnabledNotification, object: self)
        }
    }
    
    private var leadingView: UIView? {
        get {
            return leftView
        }
    }
    
    public override var text: String? {
        didSet {
            super.text = text
            self.didSetText()
            
            if !isFirstResponder {
                NotificationCenter.default.post(name: .mtTextFieldTextDidSetTextNotification,
                                                object: self)
            }
        }
    }
    
    public override var attributedText: NSAttributedString? {
        didSet {
            super.attributedText = attributedText
            self.didSetText()
            
            if !isFirstResponder {
                NotificationCenter.default.post(name: .mtTextFieldTextDidSetTextNotification, object: self)
            }
        }
    }
    
    // MARK: - UITextField Overrides
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = bounds
        
        // Standard textRect calculation
        let textInsets = self.textInsets
        textRect.origin.x += textInsets.left
        textRect.size.width -= textInsets.left + textInsets.right
        
        // Adjustments for .leftView, .rightView
        var leadingViewPadding: CGFloat = 0
        if let positioningDelegate = positioningDelegate {
            leadingViewPadding = positioningDelegate.leadingViewTrailingPaddingConstant()
        }
        
        var trailingViewPadding: CGFloat = 0
        if let positioningDelegate = positioningDelegate {
            trailingViewPadding = positioningDelegate.trailingViewTrailingPaddingConstant()
        }
        
        var leftViewWidth = leftViewRect(forBounds: bounds).width
        leftViewWidth += leadingViewPadding
        
        var rightViewWidth = rightViewRect(forBounds: bounds).width
        rightViewWidth += trailingViewPadding
        
        if leftView?.superview != nil {
            textRect.origin.x += leftViewWidth
            textRect.size.width -= leftViewWidth
        }
        
        if rightView?.superview != nil {
            textRect.size.width -= rightViewWidth
        } else {
            let clearButtonWidth = clearButton.bounds.width + 2 * abs(clearButtonPadding)
            self.clearButtonMode = .always
            if self.text!.count > 0 && !clearButton.isHidden {
                textRect.size.width -= clearButtonWidth
            }
        }
        
        let actualY = (bounds.height / 2) - ceil(max(font?.lineHeight ?? 0, placeholderLabel.font.lineHeight) / 2)
        let correctedY = textInsets.top - actualY + rectYCorrection
        textRect.origin.y = correctedY
        
        return textRect
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = textRect(forBounds: bounds)
        
        if rightView?.superview != nil {
            editingRect.size.width += rightViewPaddingCorrection
        } else {
            if self.text!.count > 0 {
                let clearButtonWidth = clearButton.bounds.width + 2 * abs(clearButtonPadding)
                
                switch clearButtonMode {
                case .unlessEditing:
                    editingRect.size.width += clearButtonWidth
                case .whileEditing:
                    editingRect.size.width -= clearButtonWidth
                default:
                    break
                }
            }
        }
        
        if let positioningDelegate = positioningDelegate {
            editingRect = positioningDelegate.editingRect(forBounds: bounds, defaultRect: editingRect)
        }
        
        return editingRect
    }
    
    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return clearButton.frame
    }
    
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftViewRect = super.leftViewRect(forBounds: bounds)
        leftViewRect.origin.y = centerYForOverlayViews(height: leftViewRect.height)
        
        if let positioningDelegate = positioningDelegate {
            leftViewRect = positioningDelegate.leadingViewRect(forBounds: bounds, defaultRect: leftViewRect)
        }
        
        return leftViewRect
    }
    
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.y = centerYForOverlayViews(height: rightViewRect.height)
        
        if let positioningDelegate = positioningDelegate {
            rightViewRect = positioningDelegate.trailingViewRect(forBounds: bounds, defaultRect: rightViewRect)
        }
        
        return rightViewRect
    }
    
    private func centerYForOverlayViews(height heightOfView: CGFloat) -> CGFloat {
        let centerY = textInsets.top + (placeholderLabel.font.lineHeight / 2) - (heightOfView / 2)
        return centerY
    }
    
    // MARK: - UITextField Draw Overrides
    
    public override func drawPlaceholder(in rect: CGRect) {
        //NO need to crate default placeholder
    }
    
    // MARK: - Layout (Custom)
    
    private func estimatedTextHeight() -> CGFloat {
        let scale = UIScreen.main.scale
        let estimatedTextHeight = ceil((font?.lineHeight ?? 0) * scale) / scale
        return estimatedTextHeight
    }
    
    // MARK: - Layout (UIView)
    
    public override var intrinsicContentSize: CGSize {
        var boundingSize = CGSize.zero
        boundingSize.width = UIView.noIntrinsicMetric
        boundingSize.height = textInsets.top + estimatedTextHeight() + textInsets.bottom
        return boundingSize
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        sizeThatFitsWidthHint = size.width
        var sizeThatFits = intrinsicContentSize
        sizeThatFits.width = sizeThatFitsWidthHint
        sizeThatFitsWidthHint = 0
        return sizeThatFits
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutSubviewsOfInput()
        if needsUpdateUnderlinePosition() {
            setNeedsUpdateConstraints()
        }
        updateBorder()
        
        positioningDelegate?.textInputDidLayoutSubviews()
    }
    
    public override func updateConstraints() {
        self.updateConstraintsOfInput()
        
        updateUnderlinePosition()
        super.updateConstraints()
        positioningDelegate?.textInputDidUpdateConstraints()
    }
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    // MARK: - UITextField Notification Observation
    
    @objc private func textFieldDidBeginEditing(_ note: Notification) {
        didBeginEditing()
    }
    
    @objc private func textFieldDidChange(_ note: Notification) {
        didChange()
    }
    
    @objc func textFieldDidEndEditing(_ note: Notification) {
        didEndEditing()
    }
    
    private func clearText() {
        text = nil
    }
    
    // MARK: - Setup Methods
    
    private func setupClearButton() {
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        clearButton.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        clearButton.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        clearButton.isOpaque = false
        
        addSubview(clearButton)
        sendSubviewToBack(clearButton)
        
        let height = NSLayoutConstraint(item: clearButton, attribute: .height, relatedBy: .equal, toItem: clearButton, attribute: .width, multiplier: 1, constant: 0)
        height.priority = .defaultLow
        
        clearButtonWidth = NSLayoutConstraint(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: clearButtonImageSquareWidthHeight)
        clearButtonWidth?.priority = .defaultLow
        
        let insets = textInsets
        let scale = UIScreen.main.scale
        let centerYConstant = insets.top + (ceil((self.font?.lineHeight ?? 0) * scale) / scale) / 2
        clearButtonCenterY = NSLayoutConstraint(item: clearButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: centerYConstant)
        clearButtonCenterY?.priority = .defaultLow
        
        placeholderTrailing = NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: clearButton, attribute: .trailing, multiplier: 1, constant: halfPadding)
        placeholderTrailing?.priority = .defaultLow
        
        clearButtonTrailing = NSLayoutConstraint(item: clearButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -1 * (2 + insets.right))
        clearButtonTrailing?.priority = .defaultLow
        
        NSLayoutConstraint.activate([height, clearButtonWidth!, clearButtonCenterY!, placeholderLeading!, clearButtonTrailing!].compactMap { $0 })
        
        clearButton.addTarget(self, action: #selector(clearButtonDidTouch), for: .touchUpInside)
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.setContentCompressionResistancePriority(.defaultLow - 2, for: .horizontal)
        placeholderLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        placeholderLabel.textAlignment = .natural
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.isOpaque = false
        
        placeholderLabel.textColor = placeholderTextColor
        placeholderLabel.font = self.font
        
        self.addSubview(placeholderLabel)
        self.sendSubviewToBack(placeholderLabel)
        
        NSLayoutConstraint.activate(placeholderDefaultConstraints())
    }
    
    private func setupUnderlineLabels() {
        leadingUnderlineLabel.isOpaque = false
        self.addSubview(leadingUnderlineLabel)
        
        trailingUnderlineLabel.isOpaque = false
        addSubview(trailingUnderlineLabel)
        
        leadingUnderlineLeading = NSLayoutConstraint(item: leadingUnderlineLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        leadingUnderlineLeading?.priority = .defaultLow
        
        leadingUnderlineTrailing = NSLayoutConstraint(item: leadingUnderlineLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        leadingUnderlineTrailing?.priority = .defaultLow
        
        trailingUnderlineTrailing = NSLayoutConstraint(item: trailingUnderlineLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        trailingUnderlineTrailing?.priority = .defaultLow
        
        let labelSpacing = NSLayoutConstraint(item: leadingUnderlineLabel, attribute: .trailing, relatedBy: .equal, toItem: trailingUnderlineLabel, attribute: .leading, multiplier: 1, constant: 0)
        labelSpacing.priority = .defaultLow
        
        trailingUnderlineLeading = NSLayoutConstraint(item: trailingUnderlineLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        trailingUnderlineLeading?.priority = .defaultLow
        
        NSLayoutConstraint.activate([labelSpacing, leadingUnderlineLeading!, trailingUnderlineTrailing!, leadingUnderlineTrailing!, trailingUnderlineLeading!].compactMap { $0 })
        
        let leadingBottom = NSLayoutConstraint(item: leadingUnderlineLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        leadingBottom.priority = .defaultLow
        
        let trailingBottom = NSLayoutConstraint(item: trailingUnderlineLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        trailingBottom.priority = .defaultLow
        
        NSLayoutConstraint.activate([leadingBottom, trailingBottom])
        
        leadingUnderlineLabel.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        leadingUnderlineLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        
        trailingUnderlineLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        trailingUnderlineLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func setupUnderlineView() {
        underline.color = inputUnderlineColor
        underline.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(underline)
        self.sendSubviewToBack(underline)
    }
    
    private func setupBorder() {
        if borderView == nil {
            borderView = MTTextInputBorderView(frame: .zero)
            self.addSubview(borderView!)
            self.sendSubviewToBack(borderView!)
            borderView?.translatesAutoresizingMaskIntoConstraints = false
            
            var constraints: [NSLayoutConstraint] = []
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[border]|", options: [], metrics: nil, views: ["border": borderView!]))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: nil, views: ["border": borderView!]))
            for constraint in constraints {
                constraint.priority = .defaultLow
            }
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    // MARK: - Layout Methods
    
    private func layoutSubviewsOfInput() {
        updatePlaceholderAlpha()
        self.sendSubviewToBack(borderView)
        
        if needsUpdateConstraintsForPlaceholderToTextInsets() || needsUpdateConstraintsForPlaceholderToOverlayViewsPosition() {
            self.setNeedsUpdateConstraints()
        }
        
        updateClearButton()
    }
    
    private func updateConstraintsOfInput() {
        updateClearButtonConstraints()
        updatePlaceholderPosition()
        updateUnderlineLabels()
    }
    
    // MARK: - Clear Button Implementation
    
    private func updateClearButton() {
        let image = clearButton.currentImage ?? drawnClearButtonImage()
        
        if self.clearButton.image(for: .normal) == nil {
            self.clearButton.setImage(image, for: .normal)
            self.clearButton.setImage(image, for: .highlighted)
            self.clearButton.setImage(image, for: .selected)
        }
        
        let clearButtonAlpha = self.clearButtonAlpha()
        self.clearButton.alpha = clearButtonAlpha
        
        if let clearButtonWidth = clearButtonWidth,
           clearButtonWidth.constant != clearButtonImageSquareWidthHeight * clearButtonAlpha {
            self.setNeedsUpdateConstraints()
        }
        
        self.clearButton.superview?.bringSubviewToFront(self.clearButton)
    }
    
    private func updateClearButtonConstraints() {
        var shouldInvalidateSize = false
        let widthConstant = clearButtonImageSquareWidthHeight * clearButtonAlpha()
        if let clearButtonWidth = clearButtonWidth, clearButtonWidth.constant != widthConstant {
            clearButtonWidth.constant = widthConstant
            shouldInvalidateSize = true
        }
        
        let insets = textInsets
        
        let trailingConstant = 2 - insets.right
        if let clearButtonTrailing = clearButtonTrailing, clearButtonTrailing.constant != trailingConstant {
            clearButtonTrailing.constant = trailingConstant
            shouldInvalidateSize = true
        }
        
        let scale = UIScreen.main.scale
        let centerYConstant = insets.top + (ceil((self.font?.lineHeight ?? 0) * scale) / scale) / 2
        if let clearButtonCenterY = clearButtonCenterY, clearButtonCenterY.constant != centerYConstant {
            clearButtonCenterY.constant = centerYConstant
            shouldInvalidateSize = true
        }
        
        if shouldInvalidateSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private func clearButtonAlpha() -> CGFloat {
        var clearButtonAlpha: CGFloat = 0
        if self.text!.count > 0  && self.isEditing {
            clearButtonAlpha = 1
        }
        return clearButtonAlpha
    }
    
    private func drawnClearButtonImage() -> UIImage {
        let clearButtonSize = CGSize(width: clearButtonImageSquareWidthHeight, height: clearButtonImageSquareWidthHeight)
        let bounds = CGRect(origin: .zero, size: clearButtonSize)
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        UIColor.gray.setFill()
        OEPathForClearButtonImageFrame(bounds).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    }
    
    @objc private func clearButtonDidTouch() {
        let textField = self
        if let delegate = textField.delegate {
            if delegate.textFieldShouldClear?(textField) == false {
                return
            }
        }
        
        
        clearText()
        if self.isFirstResponder == true {
            let textField = self
            NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
            textField.sendActions(for: .editingChanged)
        }
        
    }
    
    // MARK: - Placeholder Implementation
    
    private func updatePlaceholderAlpha() {
        placeholderLabel.alpha = 1
    }
    
    private func updatePlaceholderPosition() {
        placeholderTop.constant = self.textInsets.top
        placeholderLeading.constant = self.textInsets.left
        placeholderTrailing.constant = -1 * (self.textInsets.right)
        
        updatePlaceholderToOverlayViewsPosition()
        self.invalidateIntrinsicContentSize()
    }
    
    private func placeholderDefaultConstraints() -> [NSLayoutConstraint] {
        let textInput = self
        let insets = textInput.textInsets
        
        placeholderTop = NSLayoutConstraint(item: placeholderLabel, attribute: .top, relatedBy: .equal, toItem: textInput, attribute: .top, multiplier: 1, constant: insets.top)
        placeholderTop?.priority = .defaultLow
        
        placeholderLeading = NSLayoutConstraint(item: placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: textInput, attribute: .leading, multiplier: 1, constant: insets.left)
        placeholderLeading?.priority = .defaultLow
        
        placeholderTrailing = NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textInput, attribute: .trailing, multiplier: 1, constant: -1 * insets.right)
        placeholderTrailing?.priority = .defaultLow
        
        return [placeholderTop, placeholderLeading, placeholderTrailing].compactMap { $0 }
    }
    
    private func needsUpdateConstraintsForPlaceholderToTextInsets() -> Bool {
        return (placeholderTop.constant) != (self.textInsets.top) ||
        (placeholderLeading.constant) != (self.textInsets.left) ||
        (placeholderTrailing.constant) != -1 * (self.textInsets.right)
    }
    
    private func needsUpdateConstraintsForPlaceholderToOverlayViewsPosition() -> Bool {
        guard let leftView = self.leftView else { return false }
        guard let rightView = self.rightView else { return false }
        
        return (leftView.superview != nil && placeholderLeadingLeadingViewTrailing == nil) ||
        (leftView.superview == nil && placeholderLeadingLeadingViewTrailing != nil) ||
        (rightView.superview != nil && placeholderTrailingTrailingViewLeading == nil) ||
        (rightView.superview == nil && placeholderTrailingTrailingViewLeading != nil)
    }
    
    private func updatePlaceholderToOverlayViewsPosition() {
        let textField = self
        
        if textField.leftView?.superview != nil {
            var leadingViewTrailingConstant = editingRectPadding
            if let positioningDelegate = positioningDelegate {
                leadingViewTrailingConstant = positioningDelegate.leadingViewTrailingPaddingConstant()
            }
            
            if placeholderLeadingLeadingViewTrailing == nil {
                placeholderLeadingLeadingViewTrailing = NSLayoutConstraint(item: textField.placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: textField.leftView, attribute: .trailing, multiplier: 1, constant: leadingViewTrailingConstant)
                placeholderLeadingLeadingViewTrailing.priority = .defaultLow + 1
                placeholderLeadingLeadingViewTrailing.isActive = true
            }
            placeholderLeadingLeadingViewTrailing.constant = leadingViewTrailingConstant
        } else if textField.leftView?.superview == nil && placeholderLeadingLeadingViewTrailing != nil {
            placeholderLeadingLeadingViewTrailing = nil
        }
        
        if textField.rightView?.superview != nil && placeholderTrailingTrailingViewLeading == nil {
            placeholderTrailingTrailingViewLeading = NSLayoutConstraint(item: textField.placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textField.rightView, attribute: .leading, multiplier: 1, constant: editingRectPadding)
            placeholderTrailingTrailingViewLeading.priority = .defaultLow + 1
            placeholderTrailingTrailingViewLeading.isActive = true
        } else if textField.rightView?.superview == nil && placeholderTrailingTrailingViewLeading != nil {
            placeholderTrailingTrailingViewLeading = nil
        }
        
        textField.invalidateIntrinsicContentSize()
    }
    
    // MARK: - Underline Labels
    
    private func updateUnderlineLabels() {
        let textInsets = self.textInsets
        
        leadingUnderlineLeading?.constant = textInsets.left
        leadingUnderlineTrailing?.constant = -1 * textInsets.right
        trailingUnderlineLeading?.constant = textInsets.left
        trailingUnderlineTrailing?.constant = -1 * textInsets.right
    }
    
    // MARK: - Text Input Events
    
    private func didBeginEditing() {
        updateClearButton()
        self.invalidateIntrinsicContentSize()
    }
    
    private func didChange() {
        updateClearButton()
        updatePlaceholderAlpha()
        updatePlaceholderPosition()
    }
    
    private func didEndEditing() {
        // Implementation if needed
    }
    
    private func didSetFont(_ previousFont: UIFont?) {
        let font = self.font
        if placeholderLabel.font == nil || placeholderLabel.font == previousFont {
            placeholderLabel.font = font
        }
        updatePlaceholderPosition()
    }
    
    private func didSetText() {
        didChange()
        self.setNeedsLayout()
    }
    
    // MARK: - KVO
    
    private func subscribeForKVO() {
        self.underline.addObserver(self, forKeyPath: underlineKVOKeyColor, options: [], context: nil)
        self.underline.addObserver(self, forKeyPath: underlineKVOKeyLineHeight, options: [], context: nil)
        isRegisteredForKVO = true
    }
    
    nonisolated private func unsubscribeFromKVO() {
        Task {
            await MainActor.run {
                guard isRegisteredForKVO else { return }
                underline.removeObserver(self, forKeyPath: underlineKVOKeyColor)
                underline.removeObserver(self, forKeyPath: underlineKVOKeyLineHeight)
                isRegisteredForKVO = false
            }
        }
    }
    
    nonisolated private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bodyFont() -> UIFont {
        let fontDescriptor = UIFontDescriptor.standardFontDescriptorForMaterialTextStyle()
        return UIFont(descriptor: fontDescriptor, size: 0.0)
    }
}

