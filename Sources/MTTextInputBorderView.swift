//
//  MTTextInputBorderView.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

final class MTTextInputBorderView: UIView {
    
    var borderFillColor: UIColor = UIColor.clear {
        didSet {
            if borderFillColor != oldValue {
                updateBorder()
            }
        }
    }
    
    var borderPath: UIBezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0))
    var borderStrokeColor: UIColor = UIColor.clear
    
    //MARK: - PRIVATE
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private var borderLayer: CAShapeLayer {
        get {
            self.layer as! CAShapeLayer
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = false
        isOpaque = false
        
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.contentsScale = UIScreen.main.scale
        borderLayer.isOpaque = false
        borderLayer.rasterizationScale = borderLayer.contentsScale
        borderLayer.shouldRasterize = true
        borderLayer.zPosition = -1
    }
    
    private func updateBorder() {
        borderLayer.fillColor = borderFillColor.cgColor
        borderLayer.lineWidth = borderPath.lineWidth
        borderLayer.lineCap = .butt
        borderLayer.lineJoin = .miter
        borderLayer.miterLimit = borderPath.miterLimit
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = borderStrokeColor.cgColor
    }
}

