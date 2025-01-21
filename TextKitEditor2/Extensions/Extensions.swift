//
//  Extensions.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 13/12/24.
//

import UIKit

extension NSAttributedString.Key{
    static let listType = NSAttributedString.Key("ListType")
    static let indentLevel = NSAttributedString.Key("IndentLevel")
    static let checkListState = NSAttributedString.Key("CheckListState")
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
    
    func getParagraphRange(range : NSRange) -> NSRange {
        return textStorage.mutableString.paragraphRange(for: range)
    }
    
    func getParagraphString(range: NSRange) -> NSAttributedString {
        return textStorage.attributedSubstring(from: range)
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
    
    var isChecklist : Bool {
        if self.string == "" { return false }
        if let value = self.attribute(.listType, at: 0, effectiveRange: nil) as? String{
            if value == "checkList" {
                return true
            }
        }
        
        return false
    }
    
    var isBulletlist : Bool {
        if self.string == "" { return false }
        if let value = self.attribute(.listType, at: 0, effectiveRange: nil) as? String{
            if value == "bulletList" {
                return true
            }
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
                return .numberedList
            }
            else{
                return .checkList
            }
        }
        return .plainParagraph
    }
}

extension NSRange {
    func isSafeRange( length: Int) -> Bool {
        return self.location >= 0 && self.location + self.length <= length
    }
}

extension NSRange {
    init(_ textrange: NSTextRange, contentManager: NSTextContentManager){
        let loc = contentManager.offset(from: contentManager.documentRange.location, to: textrange.location)
        let length = contentManager.offset(from: textrange.location, to: textrange.endLocation)
        self.init(location: loc, length: length)
    }
}


extension NSTextRange{
    convenience init?(_ range: NSRange, contentManager: NSTextContentManager){
        let location = contentManager.location(contentManager.documentRange.location, offsetBy: range.location)
        let end = contentManager.location(location!, offsetBy: range.length)
        
        self.init(location: location!, end: end)
    }
}
