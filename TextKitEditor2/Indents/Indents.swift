//
//  TextView_Indents.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 17/12/24.
//
import UIKit

extension TextView{
    func leftIndent(range : NSRange) {
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let text = textStorage.attributedSubstring(from: paragraphRange)
        
        var indents: [(oldValue : Int, newIndent: Int, range: NSRange, minIndent : Int)] = []
        textStorage.enumerateAttributes(in: paragraphRange) { attributes, range, _ in
            
            let str = textStorage.attributedSubstring(from: range)
            let minLevel = str.containsListAttachment ? 1 : 0
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? minLevel
            let newIndentValue = max(minLevel, oldValue - 1)
            indents.append((oldValue,newIndentValue, range, minLevel))
        }
        
        if canIndent(range: paragraphRange, left: true, right: false) {
            undoManager?.registerUndo(withTarget: self, handler: { _ in
                self.undoIndent(left: true, text: text, range: paragraphRange)
            })
        }
    
        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
           
        }
        
        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        modifyList(currentRange: firstParagraphRange, updateSelf: true)
        
        if undoManager!.isUndoing || undoManager!.isRedoing{
            selectedRange = range
            scrollRangeToVisible(selectedRange)
        }
        updateHighlighting()
    }
        
     func rightIndent(range : NSRange) {
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let text = textStorage.attributedSubstring(from: paragraphRange)
        
        let maxLevel = 4
        var indents: [(oldValue : Int, newIndent: Int, range: NSRange)] = []
         textStorage.enumerateAttributes(in: paragraphRange) { attributes, range, _ in
            let str = textStorage.attributedSubstring(from: range)
            
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? 0
            let newIndentValue = min(maxLevel, oldValue + 1)
            indents.append((oldValue,newIndentValue, range))
        }
        
        if canIndent(range: paragraphRange, left: false, right: true) {
            undoManager?.registerUndo(withTarget: self, handler: { _ in
                self.undoIndent(left: false, text: text, range: paragraphRange)
            })
        }

        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
            
        }
                
        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        modifyList(currentRange: firstParagraphRange, updateSelf: true)
        
        if undoManager!.isUndoing || undoManager!.isRedoing{
            selectedRange = range
            scrollRangeToVisible(selectedRange)
        }
        updateHighlighting()
    }
    
    func undoIndent(left:Bool, text: NSAttributedString, range: NSRange) {
        textStorage.replaceCharacters(in: range, with: text)
        selectedRange = range
        scrollRangeToVisible(selectedRange)
        updateHighlighting()
        modifyList(currentRange: range, updateSelf: true)
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            if left {
                self.leftIndent(range: range)
            } else {
                self.rightIndent(range: range)
            }
        })
    }
    
    // indents for toggling lists
    // here these are used for toggling lists, But the undo for indent is not registered.
    func leftIndentForListToggle(range : NSRange) {
        var indents: [(newIndent: Int, range: NSRange)] = []
        textStorage.enumerateAttributes(in: range) { attributes, range, _ in
            
            let str = textStorage.attributedSubstring(from: range)
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? 0
            let newIndentValue = oldValue - 1
            indents.append((newIndentValue, range))
        }
        
        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
        }

    }
    
    
     func rightIndentForListToggle(range : NSRange) {
        let maxLevel = 4
        var indents: [(newIndent: Int, range: NSRange)] = []
        textStorage.enumerateAttributes(in: range) { attributes, range, _ in
            let str = textStorage.attributedSubstring(from: range)
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? 0
            let newIndentValue = min(maxLevel, oldValue + 1)
            indents.append((newIndentValue, range))
        }
        
        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
        }
    }

    func canIndent(range: NSRange,left: Bool, right: Bool) -> Bool {
        let paragraphRanges = getParagraphRanges(for: textStorage.attributedSubstring(from: range), in: range)
        
        for range in paragraphRanges {
            let str = textStorage.attributedSubstring(from: range)
            let minlevel = str.containsListAttachment ? 1 : 0
            if let indent = textStorage.attribute(.indentLevel, at: range.location, effectiveRange: nil) as? Int {
                if ((indent > minlevel) && left) ||  ((indent < 4) && right){
                    return true
                }
            } else {
                if right {
                    return true
                }
            }
        }
        return false
    }
    
}
