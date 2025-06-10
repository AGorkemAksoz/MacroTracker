//
//  Font+Extension.swift
//  MacroTracker
//
//  Created by Gorkem on 3.06.2025.
//

import SwiftUI

extension Font {
    
    static func customFont(_ name: String, size: CGFloat) -> Font {
        return Font.custom(name, size: size)
    }
    
    static var headerTitle: Font {
        return customFont("Manrope-Bold", size: 18)
    }
    
    static var confirmButtonTitle: Font {
        return customFont("Manrope-Bold", size: 16)
    }
    
    static var confirmViewEditButtonTitle: Font {
        return customFont("Manrope-Bold", size: 14)
    }
    
    static var primaryTitle: Font {
        return customFont("Manrope-Medium", size: 16)
    }
    
    static var primaryNumberTitle: Font {
        return customFont("Manrope-Bold", size: 24)
    }
    
    static var secondaryNumberTitle: Font {
        return customFont("Manrope", size: 14)
    }
    
    static var foodDateLabel: Font {
        return customFont("Manrope-Regular", size: 16)
    }
    
    static var dayDetailTitle: Font {
        return customFont("Manrope-Bold", size: 22)
    }
}
