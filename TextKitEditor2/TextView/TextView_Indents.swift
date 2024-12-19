//
//  TextView_Indents.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 17/12/24.
//
import UIKit

extension TextView{
    @objc func leftIndent() {
            var indents: [(value: Int, range: NSRange)] = []
            textStorage.enumerateAttributes(in: paragraphRange) { attributes, range, _ in
                
                let str = textStorage.attributedSubstring(from: range)
                let minLevel = str.containsListAttachment ? 1 : 0
                let currentIndent = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? minLevel
                let newIndentValue = max(minLevel, currentIndent - 1)
                indents.append((newIndentValue, range))
            }
            
            for indent in indents {
                textStorage.addAttribute(.indentLevel, value: indent.value, range: indent.range)
            }
        }
        
        @objc func rightIndent() {
            let maxLevel = 6
            var indents: [(value: Int, range: NSRange)] = []
            textStorage.enumerateAttributes(in: paragraphRange) { attributes, range, _ in
                let str = textStorage.attributedSubstring(from: range)
                
                let currentIndent = str.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int ?? 0
                let newIndentValue = min(maxLevel, currentIndent + 1)
                indents.append((newIndentValue, range))
            }
            
            for indent in indents {
                textStorage.addAttribute(.indentLevel, value: indent.value, range: indent.range)
            }
        }
}
