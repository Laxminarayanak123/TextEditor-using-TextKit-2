//
//  CheckList.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 13/01/25.
//

import UIKit

extension TextView {
    
    func toggleCheckBox(range : NSRange){
        
        // adds new line when toggled at the end of document
        if (selectedRange.location == textStorage.length && selectedRange.length == 0 ) || (selectedRange.upperBound == textStorage.length){
            newLineAtLast(append: true, range : range, toggle: true)
        }
        
        let paragraphRange = getParagraphRange(range: range)
        let paraString = getParagraphString(range: paragraphRange)
        
        handleListForRange(range: paragraphRange, paragraphType: .checkList)

        updateHighlighting()
        if undoManager!.isUndoing || undoManager!.isRedoing{
            selectedRange = paragraphRange
            scrollRangeToVisible(selectedRange)
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.undoToggleCheckBox(range: paragraphRange, text: paraString)
        })
        
    }
    
    
    func undoToggleCheckBox(range: NSRange, text: NSAttributedString) {
        
        textStorage.replaceCharacters(in: range, with: text)
        
        let firstParagraphRange = getParagraphRange(range: NSRange(location: range.location, length: 0))
        
        modifyList(currentRange: firstParagraphRange, updateSelf: true)
        
        if undoManager!.isUndoing || undoManager!.isRedoing{
            selectedRange = range
            scrollRangeToVisible(selectedRange)
        }
        updateHighlighting()
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleCheckBox(range: range)
        })
        
    }
    
}
