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
    
    var previousParagraphRange: NSRange {
        let prevParagraphLocation = paragraphRange.location - 1
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        if prevParagraphLocation > 0 {
            let prevParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: prevParagraphLocation, length: 0))
            return prevParagraphRange
        } else {
            return mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: paragraphRange.location, length: 0))
        }
    }
}



extension NSAttributedString {
    var containsListAttachment: Bool {
        if self.string == "" { return false }
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
    
    var paragraphType : paragraphType{
        if let value = self.attribute(.listType, at: 0, effectiveRange: nil){
            if let _ = value as? Int{
                return .NumberedList
            }
            else{
                return .checkList
            }
        }
        return .plainParagraph
    }
}
