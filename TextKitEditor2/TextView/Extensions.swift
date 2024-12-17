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

extension TextView : NSTextStorageDelegate{
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        guard editedMask.contains(.editedCharacters) else { return }

        
        let paragraphRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
        textStorage.enumerateAttributes(in: paragraphRange, options: []) { attributes, range, _ in
            if let customValue = attributes[.customCase] {
                textStorage.addAttribute(.customCase, value: customValue, range: paragraphRange)
                return
            }
        }

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
