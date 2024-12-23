//
//  TextView_Delegates.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 17/12/24.
//

import UIKit

extension TextView : NSTextLayoutManagerDelegate{
    
    
    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: any NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
        
        
        if(textStorage.length == 0){
            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        }
        
        if let textElement = textElement as? NSTextParagraph{
            let attrString = textElement.attributedString
            
            if let value = attrString.attribute(.listType, at: 0, effectiveRange: nil){
                
                if let number = value as? Int{
                    let fragment = NumberedListTextLayoutFragment(textElement: textElement, range: textElement.elementRange!, number: number)
                    return fragment
                }
                let fragment = CheckboxTextLayoutFragment(textElement: textElement, range: textElement.elementRange!)
                return fragment
                
            }

        }
    
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
    
    
}


extension TextView : NSTextContentStorageDelegate{
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        
            let attrString = textContentStorage.textStorage?.attributedSubstring(from: range)
            let mutableString = NSMutableAttributedString(attributedString: attrString!)
        

            let paragraphStyle = NSMutableParagraphStyle()
            if let ogParagraphStyle = mutableString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle{
                paragraphStyle.setParagraphStyle(ogParagraphStyle)

            }
        

        if let indentLevel = mutableString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
            paragraphStyle.headIndent = CGFloat(indentLevel) * 48
            paragraphStyle.firstLineHeadIndent = CGFloat(indentLevel) * 48
        }
        
                
        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableString.length))
        

            
        return NSTextParagraph(attributedString: mutableString)
        
    }
    
}

extension TextView : NSTextStorageDelegate{
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        guard editedMask.contains(.editedCharacters) else { return }

        
        let editedRange = (textStorage.string as NSString).paragraphRange(for: editedRange)
        
        textStorage.enumerateAttributes(in: editedRange, options: []) { attributes, range, _ in
            
            let paragraphRange = (textStorage.string as NSString).paragraphRange(for: range)
            
            if let customValue = attributes[.listType] {
                textStorage.addAttribute(.listType, value: customValue, range: paragraphRange)
            }
            
            if let indentValue = attributes[.indentLevel]{
                textStorage.addAttribute(.indentLevel, value: indentValue, range: paragraphRange)
            }
        }

    }
}
