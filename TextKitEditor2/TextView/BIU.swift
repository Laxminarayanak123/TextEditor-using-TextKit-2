//
//  BIU.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 07/01/25.
//

import UIKit

extension TextView{
    @objc func setBold() {
        isBoldEnabled.toggle()
        var currentTypingAttributes = typingAttributes
        let currentFont = currentTypingAttributes[.font] as! UIFont
        let currentTraits = currentFont.fontDescriptor.symbolicTraits
        
        if selectedRange.length > 0 {
            addBoldandItalicTraits(in: selectedRange, traits: .traitBold)
        } else {
            if isBoldEnabled {
                let new = UIFont(descriptor: currentFont.fontDescriptor.withSymbolicTraits([.traitBold, currentTraits])!, size: 24)
                currentTypingAttributes[.font] = new
            } else {
                let newTraits = currentTraits.subtracting(.traitBold)
                currentTypingAttributes[.font] = UIFont(descriptor: currentFont.fontDescriptor.withSymbolicTraits(newTraits)!, size: 24)
            }
            
            typingAttributes = currentTypingAttributes
        }
    }
    
    @objc func setItalic() {
        isItalicEnabled.toggle()
        var currentTypingAttributes = typingAttributes
        let currentFont = currentTypingAttributes[.font] as! UIFont
        let currentTraits = currentFont.fontDescriptor.symbolicTraits
        
        
        if selectedRange.length > 0 {
            addBoldandItalicTraits(in: selectedRange, traits: .traitItalic)
        } else {
            if isItalicEnabled {
                let new = UIFont(descriptor: currentFont.fontDescriptor.withSymbolicTraits([.traitItalic, currentTraits])!, size: 24)
                
                currentTypingAttributes[.font] = new
            } else {
                let newTraits = currentTraits.subtracting(.traitItalic)
                currentTypingAttributes[.font] = UIFont(descriptor: currentFont.fontDescriptor.withSymbolicTraits(newTraits)!, size: 24)
            }
            
            typingAttributes = currentTypingAttributes
        }
    }
    
    @objc func setUnderline() {
        isUnderlineEnabled.toggle()
        
        if selectedRange.length > 0 {
            modifyFontForUnderline(in: selectedRange)
        } else {
            if isUnderlineEnabled {
                typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            } else {
                typingAttributes.removeValue(forKey: .underlineStyle)
            }
        }
    }
    
    @objc func setStrikeThrough() {
        isStrikeThroughEnabled.toggle()
        
        if selectedRange.length > 0 {
            modifyStrikeThrough(in: selectedRange)
        } else {
            if isStrikeThroughEnabled {
                typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            } else {
                typingAttributes.removeValue(forKey: .strikethroughStyle)
            }
        }
    }
    
    //for bold and italic
    func addBoldandItalicTraits(in range: NSRange, traits: UIFontDescriptor.SymbolicTraits) {
        undoManager?.beginUndoGrouping()
        let text = textStorage.attributedSubstring(from: range)
        
        var shouldAddTrait : Bool = true
        textStorage.enumerateAttribute(.font, in: range) { value, subRange, _ in
            guard let currentFont = value as? UIFont else { return }
            
            // Get the current traits of the font
            let currentTraits = currentFont.fontDescriptor.symbolicTraits
            
            if currentTraits.contains(traits){
                shouldAddTrait = false
                return
            }
        }
        
        //        let startingFont = textStorage.attribute(.font, at: range.location, effectiveRange: nil) as! UIFont
        //        let startingTraits = startingFont.fontDescriptor.symbolicTraits
        //        let shouldAddTrait = !startingTraits.contains(traits)
        
        // Enumerate through the text storage and update font traits
        textStorage.enumerateAttribute(.font, in: range) { (value, subrange, _) in
            guard let currentFont = value as? UIFont else { return }
            
            // Get the current traits of the font
            let currentTraits = currentFont.fontDescriptor.symbolicTraits
            
            // Determine new traits based on the starting point
            let newTraits = shouldAddTrait
            ? currentTraits.union(traits)
            : currentTraits.subtracting(traits)
            
            // Create a new font with updated traits
            if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(newTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
                textStorage.removeAttribute(.font, range: subrange)
                textStorage.addAttribute(.font, value: newFont, range: subrange)
            }
        }
        
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.restoreBoldandItalic(range: range, text: text, traits: traits )
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func restoreBoldandItalic(range: NSRange, text: NSAttributedString, traits: UIFontDescriptor.SymbolicTraits) {
        undoManager?.beginUndoGrouping()
        
        textStorage.replaceCharacters(in: range, with: text)
        
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.addBoldandItalicTraits(in: range, traits: traits)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    //for underline
    func modifyFontForUnderline(in range: NSRange) {
        undoManager?.beginUndoGrouping()
        // Check if the starting point of the selection has an underline
        let text = textStorage.attributedSubstring(from: range)
        //        let startingUnderline = (textStorage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int) ?? 0
        var shouldAddUnderline = true // Add underline if not present
        
        textStorage.enumerateAttribute(.underlineStyle, in: range) { val, range, _ in
            guard let _ = val else { return }
            
            shouldAddUnderline = false
        }
        
        // Enumerate through the text storage and update underline style
        
        if shouldAddUnderline {
            // Add underline
            textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        } else {
            // Remove underline
            textStorage.removeAttribute(.underlineStyle, range: range)
        }
        
        
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.restoreUnderline(range: range, text: text)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func restoreUnderline(range: NSRange, text: NSAttributedString) {
        undoManager?.beginUndoGrouping()
        
        textStorage.replaceCharacters(in: range, with: text)
        
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.modifyFontForUnderline(in: range)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    //for strikethrough
    func modifyStrikeThrough(in range: NSRange) {
        undoManager?.beginUndoGrouping()
        let text = textStorage.attributedSubstring(from: range)
        
        // Check if the starting point of the selection has a strike-through
        //        let startingStrikeThrough = (textStorage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int) ?? 0
        var shouldAddStrikeThrough = true
        
        textStorage.enumerateAttribute(.strikethroughStyle, in: range) { val, range, _ in
            guard let _ = val else { return }
            
            shouldAddStrikeThrough = false
        }
        
        // Enumerate through the text storage and update strike-through style
        if shouldAddStrikeThrough {
            textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        } else {
            textStorage.removeAttribute(.strikethroughStyle, range: range)
        }
        
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.restoreStrikeThrough(range: range, text: text)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func restoreStrikeThrough(range: NSRange, text: NSAttributedString) {
        undoManager?.beginUndoGrouping()
        
        textStorage.replaceCharacters(in: range, with: text)
        
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.modifyStrikeThrough(in: range)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func updateHighlighting(){
        isBoldEnabled = false
        isItalicEnabled = false
        isUnderlineEnabled = false
        isStrikeThroughEnabled = false
        isCheckListEnabled = false
        isNumberedListEnabled = false
        leftIndentEnabled = false
        rightIndentEnabled = false
        
        if selectedRange.length > 0 {
            
            isCheckListEnabled = containsListType(range: selectedRange, paragraphType: .checkList, paragraphRanges: nil)
            isNumberedListEnabled = containsListType(range: selectedRange, paragraphType: .NumberedList, paragraphRanges: nil)
            leftIndentEnabled = canIndent(range: selectedRange, left: true, right: false)
            rightIndentEnabled = canIndent(range: selectedRange, left: false, right: true)
            
            textStorage.enumerateAttributes(in: selectedRange, options: []) { attributes, range, _ in
                if let font = attributes[.font] as? UIFont {
                    let traits = font.fontDescriptor.symbolicTraits
                    if traits.contains(.traitBold) {
                        isBoldEnabled = true
                    }
                    if traits.contains(.traitItalic) {
                        isItalicEnabled = true
                    }
                }
                
                if let underlineStyle = attributes[.underlineStyle] as? Int, underlineStyle != 0 {
                    isUnderlineEnabled = true
                }
                
                if let strikeStyle = attributes[.strikethroughStyle] as? Int, strikeStyle != 0 {
                    isStrikeThroughEnabled = true
                }
                
                // Exit early if all styles are enabled
                if isBoldEnabled && isItalicEnabled && isUnderlineEnabled && isStrikeThroughEnabled {
                    return
                }
            }
        } else {
            guard let font = typingAttributes[.font] as? UIFont else {
                isBoldEnabled = false
                isItalicEnabled = false
                isUnderlineEnabled = false
                isStrikeThroughEnabled = false
                return
            }
            leftIndentEnabled = false
            rightIndentEnabled = true
            
            isBoldEnabled = font.fontDescriptor.symbolicTraits.contains(.traitBold)
            isItalicEnabled = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            
            if let underlineStyle = typingAttributes[.underlineStyle] as? Int {
                isUnderlineEnabled = underlineStyle != 0
            } else {
                isUnderlineEnabled = false
            }
            
            if let strike = typingAttributes[.strikethroughStyle] as? Int {
                isStrikeThroughEnabled = strike != 0
            } else {
                isStrikeThroughEnabled = false
            }
            
            if selectedRange.location < textStorage.length {
                var minLevel = 0
                if let listType = textStorage.attribute(.listType, at: selectedRange.location, effectiveRange: nil){
                    minLevel = 1
                    if let _ = listType as? Int{
                        isNumberedListEnabled = true
                        isCheckListEnabled = false
                    }
                    else{
                        isCheckListEnabled = true
                        isNumberedListEnabled = false
                    }
                }
                else{
                    isCheckListEnabled = false
                    isNumberedListEnabled = false
                }
                
                if let indent = textStorage.attribute(.indentLevel, at: selectedRange.location, effectiveRange: nil) as? Int {
                    if indent > minLevel {
                        leftIndentEnabled = true
                    } else {
                        leftIndentEnabled = false
                    }
                    
                    if indent < 4 {
                        rightIndentEnabled = true
                    } else {
                        rightIndentEnabled = false
                    }
                }
            }
        }
    }
    
    
}
