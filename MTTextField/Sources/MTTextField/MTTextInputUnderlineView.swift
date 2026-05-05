//
//  MTTextInputUnderlineView.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

class MTTextInputUnderlineView: UIView {
    
    private var disabledUnderline: CAShapeLayer?
    private var underline: CAShapeLayer?
    
    var disabledColor: UIColor = .lightGray
   
    var color: UIColor = .lightGray {
        didSet {
            updateColor()
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            if oldValue != isEnabled {
                updateUnderline()
                updateColor()
            }
        }
    }
    
    var lineHeight: CGFloat = 1 {
        didSet {
            if oldValue != lineHeight {
                updateUnderline()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: lineHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderlinePath()
        updateColor()
    }
    
    private func commonInit() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        clipsToBounds = false
        updateUnderline()
    }
    
    private func updateUnderlinePath() {
        let bounds = self.bounds
        let path = CGMutablePath()
        let offset = 1 / UIScreen.main.scale
        path.move(to: CGPoint(x: bounds.minX, y: bounds.midY + offset))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY + offset))
        
        if let underline = underline {
            underline.frame = bounds
            underline.path = path
        }
        
        if let disabledUnderline = disabledUnderline {
            disabledUnderline.frame = bounds
            disabledUnderline.path = path
        }
    }
    
    private func updateUnderline() {
        if isEnabled {
            if underline == nil {
                let newUnderline = CAShapeLayer()
                newUnderline.contentsScale = UIScreen.main.scale
                newUnderline.frame = .zero
                newUnderline.lineWidth = lineHeight
                newUnderline.strokeColor = color.cgColor
                layer.addSublayer(newUnderline)
                underline = newUnderline
            }
            
            disabledUnderline?.opacity = 0
        } else {
            if disabledUnderline == nil {
                let newDisabledUnderline = CAShapeLayer()
                newDisabledUnderline.contentsScale = UIScreen.main.scale
                newDisabledUnderline.frame = .zero
                newDisabledUnderline.lineJoin = .miter
                newDisabledUnderline.lineDashPattern = [1.5, 1.5]
                newDisabledUnderline.lineWidth = 1.0
                newDisabledUnderline.isOpaque = false
                newDisabledUnderline.strokeColor = disabledColor.cgColor
                layer.addSublayer(newDisabledUnderline)
                disabledUnderline = newDisabledUnderline
            }
            
            disabledUnderline?.opacity = 1
        }
        
        underline?.lineWidth = lineHeight
        
        updateUnderlinePath()
        updateColor()
    }
    
    private func updateColor() {
        let showUnderline = isEnabled
        let strokeColor: UIColor = showUnderline ? color : .clear
        
        disabledUnderline?.strokeColor = disabledColor.cgColor
        underline?.strokeColor = strokeColor.cgColor
        isOpaque = showUnderline
    }
}

