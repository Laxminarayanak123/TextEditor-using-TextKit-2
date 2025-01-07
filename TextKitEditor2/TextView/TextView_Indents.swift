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
        
        
//        modifyList(currentRange: previousParagraphRange)
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
        
//        modifyList(currentRange: previousParagraphRange)
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

    func backspaceAtStart(range : NSRange){
        undoManager?.beginUndoGrouping()

        let string = textStorage.attributedSubstring(from: textStorage.mutableString.paragraphRange(for: NSRange(location: range.location + 1, length: 1)))
        
        let attributes = string.attributes(at: 0, effectiveRange: nil)
        
        let prevString = textStorage.attributedSubstring(from: textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 1)))
        
        let indentLevel = prevString.indentLevel
        
        
        // if the prevParagraph don't have .indentlevel, then give 0
        textStorage.addAttribute(.indentLevel, value: indentLevel, range: NSRange(location: range.location, length: 1))
        
//        let prevAttributes = prevString.attributes(at: 0, effectiveRange: nil)
        
        textStorage.replaceCharacters(in: NSRange(location: range.location, length: range.length), with: NSAttributedString(string: ""))
        
        textStorage.addAttribute(.indentLevel, value: indentLevel, range: NSRange(location: range.location, length: 1))
        
        selectedRange.location = range.location
        
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.returnBack(range: range, attributes: attributes)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func returnBack(range : NSRange, attributes : [NSAttributedString.Key : Any]){
        undoManager?.beginUndoGrouping()
        
        let prevAttributes = textStorage.attributes(at: range.location, effectiveRange: nil)
        
        textStorage.insert(NSAttributedString(string: "\n"), at: range.location)
        
        let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location + 1, length: 0))
        
        textStorage.removeAttribute(.listType, range: paragraphRange)
        textStorage.removeAttribute(.indentLevel, range: paragraphRange)
        
        textStorage.addAttributes(attributes, range: paragraphRange)
        
        textStorage.addAttributes(prevAttributes, range: prevParagraphRange)
        
        selectedRange.location = range.location + 1
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.backspaceAtStart(range: range)
        })
        
        undoManager?.endUndoGrouping()
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
