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
    
    func addBoldandItalicTraits(in range: NSRange, traits: UIFontDescriptor.SymbolicTraits) {

        let text = getParagraphString(range: range)
        var shouldAddTrait : Bool = true
        
        // Enumerate to check if the text contains the traits
        textStorage.enumerateAttribute(.font, in: range) { value, subRange, _ in
            guard let currentFont = value as? UIFont else { return }
            
            // Get the current traits of the font
            let currentTraits = currentFont.fontDescriptor.symbolicTraits
            
            if currentTraits.contains(traits){
                shouldAddTrait = false
                return
            }
        }
        
        // Enumerate through the text storage and update font traits
        textStorage.enumerateAttribute(.font, in: range) { (value, subrange, _) in
            guard let currentFont = value as? UIFont else { return }
           
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
        
        updateSelectedRange(range)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.restoreBoldandItalic(range: range, text: text, traits: traits )
        })
        
    }
    
    // undo part for the Bold/Italic
    func restoreBoldandItalic(range: NSRange, text: NSAttributedString, traits: UIFontDescriptor.SymbolicTraits) {
        
        textStorage.replaceCharacters(in: range, with: text)
        
        updateSelectedRange(range)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.addBoldandItalicTraits(in: range, traits: traits)
        })
        
    }
    
    
    func modifyFontForUnderline(in range: NSRange) {

        let text = getParagraphString(range: range)
        var shouldAddUnderline = true
        
        textStorage.enumerateAttribute(.underlineStyle, in: range) { val, range, _ in
            guard let _ = val else { return }
            shouldAddUnderline = false
        }
        
        if shouldAddUnderline {
            textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        } else {
            textStorage.removeAttribute(.underlineStyle, range: range)
        }
        
        updateSelectedRange(range)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.restoreUnderline(range: range, text: text)
        })
        
    }
    
    // undo part for the Underline
    func restoreUnderline(range: NSRange, text: NSAttributedString) {
        
        textStorage.replaceCharacters(in: range, with: text)
        
        updateSelectedRange(range)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.modifyFontForUnderline(in: range)
        })
        
    }
    
    func modifyStrikeThrough(in range: NSRange) {

        let text = getParagraphString(range: range)
        var shouldAddStrikeThrough = true
        
        textStorage.enumerateAttribute(.strikethroughStyle, in: range) { val, range, _ in
            guard let _ = val else { return }
            shouldAddStrikeThrough = false
        }
        
        if shouldAddStrikeThrough {
            textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        } else {
            textStorage.removeAttribute(.strikethroughStyle, range: range)
        }
        
        updateSelectedRange(range)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.restoreStrikeThrough(range: range, text: text)
        })
        
    }
    
    // undo part for the Strike-Through
    func restoreStrikeThrough(range: NSRange, text: NSAttributedString) {
        
        textStorage.replaceCharacters(in: range, with: text)
        
        updateSelectedRange(range)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.modifyStrikeThrough(in: range)
        })
        
    }
    
    func updateSelectedRange(_ range: NSRange) {
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        
        updateHighlighting()
    }
    

}
