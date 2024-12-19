//
//  Extensions.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 13/12/24.
//

import UIKit

extension NSAttributedString.Key{
    static let customCase = NSAttributedString.Key("CustomCase")
    static let indentLevel = NSAttributedString.Key("IndentLevel")
}


extension UITextView{
    var paragraphRange: NSRange {
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let paragraphRange = mutableAttributedText.mutableString.paragraphRange(for: selectedRange)
        return paragraphRange
    }
    
    var paragraphString: NSAttributedString {
        textStorage.attributedSubstring(from: paragraphRange)
    }
}



extension NSAttributedString {
    var containsListAttachment: Bool {
        
        if let _ = self.attribute(.customCase, at: 0, effectiveRange: nil) as? String{
            return true
        }
        
        return false
    }
}
