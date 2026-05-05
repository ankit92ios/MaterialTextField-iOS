//
//  MTMath.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//


import CoreGraphics
import Foundation
import UIKit

func MTCGFloatEqual(_ a: CGFloat, _ b: CGFloat) -> Bool {
    let constantK: CGFloat = 3
    let epsilon = Double.ulpOfOne
    let min = Double.leastNormalMagnitude
    return (abs(a - b) < constantK * CGFloat(epsilon) * abs(a + b) || abs(a - b) < CGFloat(min))
}

