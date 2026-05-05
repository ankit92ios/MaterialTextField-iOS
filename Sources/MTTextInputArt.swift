//
//  MTTextInputArt.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//

import UIKit

func OEPathForClearButtonImageFrame(_ frame: CGRect) -> UIBezierPath {
    // GENERATED CODE
    
    let innerBounds = CGRect(
        x: frame.minX + 2,
        y: frame.minY + 2,
        width: floor((frame.width - 2) * 0.90909 + 0.5),
        height: floor((frame.height - 2) * 0.90909 + 0.5)
    )
    
    let ic_clear_path = UIBezierPath()
    ic_clear_path.move(to: CGPoint(
        x: innerBounds.minX + 0.50000 * innerBounds.width,
        y: innerBounds.minY + 0 * innerBounds.height
    ))
    ic_clear_path.addCurve(
        to: CGPoint(
            x: innerBounds.minX + 1 * innerBounds.width,
            y: innerBounds.minY + 0.50000 * innerBounds.height
        ),
        controlPoint1: CGPoint(
            x: innerBounds.minX + 0.77600 * innerBounds.width,
            y: innerBounds.minY + 0 * innerBounds.height
        ),
        controlPoint2: CGPoint(
            x: innerBounds.minX + 1 * innerBounds.width,
            y: innerBounds.minY + 0.22400 * innerBounds.height
        )
    )
    ic_clear_path.addCurve(
        to: CGPoint(
            x: innerBounds.minX + 0.50000 * innerBounds.width,
            y: innerBounds.minY + 1 * innerBounds.height
        ),
        controlPoint1: CGPoint(
            x: innerBounds.minX + 1 * innerBounds.width,
            y: innerBounds.minY + 0.77600 * innerBounds.height
        ),
        controlPoint2: CGPoint(
            x: innerBounds.minX + 0.77600 * innerBounds.width,
            y: innerBounds.minY + 1 * innerBounds.height
        )
    )
    ic_clear_path.addCurve(
        to: CGPoint(
            x: innerBounds.minX + 0 * innerBounds.width,
            y: innerBounds.minY + 0.50000 * innerBounds.height
        ),
        controlPoint1: CGPoint(
            x: innerBounds.minX + 0.22400 * innerBounds.width,
            y: innerBounds.minY + 1 * innerBounds.height
        ),
        controlPoint2: CGPoint(
            x: innerBounds.minX + 0 * innerBounds.width,
            y: innerBounds.minY + 0.77600 * innerBounds.height
        )
    )
    ic_clear_path.addCurve(
        to: CGPoint(
            x: innerBounds.minX + 0.50000 * innerBounds.width,
            y: innerBounds.minY + 0 * innerBounds.height
        ),
        controlPoint1: CGPoint(
            x: innerBounds.minX + 0 * innerBounds.width,
            y: innerBounds.minY + 0.22400 * innerBounds.height
        ),
        controlPoint2: CGPoint(
            x: innerBounds.minX + 0.22400 * innerBounds.width,
            y: innerBounds.minY + 0 * innerBounds.height
        )
    )
    ic_clear_path.close()
    
    ic_clear_path.move(to: CGPoint(
        x: innerBounds.minX + 0.73417 * innerBounds.width,
        y: innerBounds.minY + 0.31467 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.68700 * innerBounds.width,
        y: innerBounds.minY + 0.26750 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.50083 * innerBounds.width,
        y: innerBounds.minY + 0.45367 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.31467 * innerBounds.width,
        y: innerBounds.minY + 0.26750 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.26750 * innerBounds.width,
        y: innerBounds.minY + 0.31467 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.45367 * innerBounds.width,
        y: innerBounds.minY + 0.50083 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.26750 * innerBounds.width,
        y: innerBounds.minY + 0.68700 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.31467 * innerBounds.width,
        y: innerBounds.minY + 0.73417 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.50083 * innerBounds.width,
        y: innerBounds.minY + 0.54800 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.68700 * innerBounds.width,
        y: innerBounds.minY + 0.73417 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.73417 * innerBounds.width,
        y: innerBounds.minY + 0.68700 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.54800 * innerBounds.width,
        y: innerBounds.minY + 0.50083 * innerBounds.height
    ))
    ic_clear_path.addLine(to: CGPoint(
        x: innerBounds.minX + 0.73417 * innerBounds.width,
        y: innerBounds.minY + 0.31467 * innerBounds.height
    ))
    ic_clear_path.close()
    
    return ic_clear_path
}

