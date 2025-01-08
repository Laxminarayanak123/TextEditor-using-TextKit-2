//
//  TextView_Indents.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 17/12/24.
//
import UIKit

extension TextView{
    func leftIndent(range : NSRange) {
        var indents: [(oldValue : Int, newIndent: Int, range: NSRange, minIndent : Int)] = []
        textStorage.enumerateAttributes(in: range) { attributes, range, _ in
            
            let str = textStorage.attributedSubstring(from: range)
            let minLevel = str.containsListAttachment ? 1 : 0
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? minLevel
            let newIndentValue = max(minLevel, oldValue - 1)
            indents.append((oldValue,newIndentValue, range, minLevel))
        }
        
//        undoManager?.beginUndoGrouping()

        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
            if indent.oldValue != indent.minIndent{
                undoManager?.registerUndo(withTarget: self, handler: { _ in
                    self.rightIndent(range: indent.range)
                })
            }
        }
        
//        undoManager?.endUndoGrouping()
        
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        modifyList(currentRange: paragraphRange, updateSelf: true)
    }
        
    @objc func rightIndent(range : NSRange) {
        let maxLevel = 4
        var indents: [(oldValue : Int, newIndent: Int, range: NSRange)] = []
        textStorage.enumerateAttributes(in: range) { attributes, range, _ in
            let str = textStorage.attributedSubstring(from: range)
            
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? 0
            let newIndentValue = min(maxLevel, oldValue + 1)
            indents.append((oldValue,newIndentValue, range))
        }
        
//        undoManager?.beginUndoGrouping()

        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
            if indent.oldValue != maxLevel{
                undoManager?.registerUndo(withTarget: self, handler: { _ in
                    self.leftIndent(range: indent.range)
                })
            }
        }
        
//        undoManager?.endUndoGrouping()
        let paragraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        modifyList(currentRange: paragraphRange, updateSelf: true)
    }
    
    func leftIndentForListToggle(range : NSRange) {
        var indents: [(oldValue : Int, newIndent: Int, range: NSRange)] = []
        textStorage.enumerateAttributes(in: range) { attributes, range, _ in
            
            let str = textStorage.attributedSubstring(from: range)
            let minLevel = str.containsListAttachment ? 0 : 0
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? minLevel
            let newIndentValue = max(minLevel, oldValue - 1)
            indents.append((oldValue,newIndentValue, range))
        }
        
        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
        }

    }
    
    
     func rightIndentForListToggle(range : NSRange) {
        let maxLevel = 4
        var indents: [(oldValue : Int, newIndent: Int, range: NSRange)] = []
        textStorage.enumerateAttributes(in: range) { attributes, range, _ in
            let str = textStorage.attributedSubstring(from: range)
            
            let oldValue = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? 0
            let newIndentValue = min(maxLevel, oldValue + 1)
            indents.append((oldValue,newIndentValue, range))
        }
        


        for indent in indents {
            textStorage.addAttribute(.indentLevel, value: indent.newIndent, range: indent.range)
        }
        
    }

    func newLineAtLast(append : Bool, range : NSRange, toggle : Bool){
        undoManager?.beginUndoGrouping()
        
        if append{
            textStorage.insert(NSAttributedString(string: "\n",attributes: typingAttributes), at: range.upperBound)
            if !toggle{
                selectedRange.location = range.location + 1
            }
        }
        else{
            textStorage.deleteCharacters(in: NSRange(location: range.upperBound, length: 1))
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { target in
            self.newLineAtLast(append: !append, range: range,toggle: toggle)
        })
        
        undoManager?.endUndoGrouping()
    }
}
