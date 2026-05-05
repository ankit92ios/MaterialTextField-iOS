//
//  MTTextInputClearButton.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

final class OETextInputClearButton: UIButton {
    private var minimumTouchTargetInsets: UIEdgeInsets = .zero
    private let targetSize: CGFloat = 48

    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        let height = bounds.height
        let verticalInset = min(0, -(targetSize - height) / 2)
        let horizontalInset = min(0, -(targetSize - width) / 2)
        minimumTouchTargetInsets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if minimumTouchTargetInsets != .zero {
            let expandedBounds = bounds
                .standardized
                .inset(by: minimumTouchTargetInsets)
            return expandedBounds.contains(point)
        }
        return super.point(inside: point, with: event)
    }
}


