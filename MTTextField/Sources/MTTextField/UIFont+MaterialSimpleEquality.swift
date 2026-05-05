//
//  UIFont+MaterialSimpleEquality.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//

import UIKit

extension UIFont {
    /// Checks simple characteristics: name, weight, pointsize, traits.
    /// While the actual implementation of UIFont's isEqual: is not known, it is believed that
    /// isSimplyEqual: is more 'shallow' than isEqual:.
    func isSimplyEqual(to font: UIFont) -> Bool {
        return fontName == font.fontName &&
               MTCGFloatEqual(pointSize, font.pointSize) &&
               fontDescriptor.fontAttributes[.face] as? String == font.fontDescriptor.fontAttributes[.face] as? String
    }
}

