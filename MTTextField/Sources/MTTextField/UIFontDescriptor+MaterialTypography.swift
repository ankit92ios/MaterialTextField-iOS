//
//  UIFontDescriptor+MaterialTypography.swift
//  MTTextField
//
//  Created by Ankit on 01/01/26.
//
import UIKit

extension UIFontDescriptor {
    static func standardFontDescriptorForMaterialTextStyle() -> UIFontDescriptor {
        let smallSystemFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let smallSystemFontFamilyName = smallSystemFont.familyName
        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: UIFont.Weight.regular]
        let fontSize = 14.0
        let fontFamily = smallSystemFontFamilyName
        let attributes: [UIFontDescriptor.AttributeName: Any] = [
            .size: fontSize,
            .traits: traits,
            .family: fontFamily
        ]
        
        return UIFontDescriptor(fontAttributes: attributes)
    }
}

