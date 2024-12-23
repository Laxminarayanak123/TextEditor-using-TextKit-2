//
//  Extensions.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 13/12/24.
//

import UIKit

extension NSAttributedString.Key{
    static let listType = NSAttributedString.Key("CustomCase")
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
        
        if let _ = self.attribute(.listType, at: 0, effectiveRange: nil){
            return true
        }
        
        return false
    }
    
    var indentLevel : Int{
        if let value = self.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
            return value
        }
        else{
            return 0
        }
    }
    
    var NumberedListIndex: Int? {
        
        if let value = self.attribute(.listType, at: 0, effectiveRange: nil) as? Int{
            return value
        }
        
        return nil
    }
}
