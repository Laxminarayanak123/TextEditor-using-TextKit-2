//
//  NumberList.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 13/01/25.
//

import UIKit

extension TextView {

    func toggleNumberList(range : NSRange){
        
        // adds new line when toggled at the end of document
        if (selectedRange.location == textStorage.length && selectedRange.length == 0 ) || (selectedRange.upperBound == textStorage.length){
            newLineAtLast(append: true, range : range, toggle: true)
        }
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let paraString = textStorage.attributedSubstring(from: paragraphRange)
        
        handleListForRange(range: paragraphRange, paragraphType: .NumberedList)
        
        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        
        modifyList(currentRange: firstParagraphRange, updateSelf: false)
        
        if undoManager!.isUndoing || undoManager!.isRedoing{
            selectedRange = paragraphRange
            scrollRangeToVisible(selectedRange)
        }
        
        updateHighlighting()

        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.undoToggleNumberList(range: paragraphRange, text: paraString)
        })
        
    }
    
    
    func undoToggleNumberList(range: NSRange, text: NSAttributedString) {
        
        textStorage.replaceCharacters(in: range, with: text)
        
        let firstParagraphRange = getParagraphRange(range: NSRange(location: range.upperBound, length: 0))
        
        modifyList(currentRange: firstParagraphRange, updateSelf: true)
        
        if undoManager!.isUndoing || undoManager!.isRedoing{
            selectedRange = range
            scrollRangeToVisible(selectedRange)
        }
        updateHighlighting()

        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleNumberList(range: range)
        })
        
    }
    
    // Method useful for updating the number position
    func modifyList(currentRange: NSRange, updateSelf : Bool) {
        
        var firstBool : Bool = updateSelf
        
        var nextLocation = currentRange.upperBound
        
        // if updateSelf is true, we are updating the current range value.
        if firstBool == true {
            nextLocation = currentRange.lowerBound
            firstBool = false
        }

        if nextLocation < textStorage.length {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let nextParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: nextLocation, length: 0))
            let nextString = textStorage.attributedSubstring(from: nextParagraphRange)
            
            if nextString.string.isEmpty{
                return
            }
            
            if nextString.containsListAttachment {
                if let _ = nextString.NumberedListIndex {
                    let newValue = getNumberPosition(currentRange: nextParagraphRange, value: 0, mainString: nextString)
                    if newValue == 1000{
                        //calculation is limited to 1000 iterations
                        return
                    }
                    textStorage.addAttribute(.listType, value: newValue + 1, range: nextParagraphRange)
                }
                modifyList(currentRange: nextParagraphRange, updateSelf: firstBool)
            }
            else{
                return
            }
        } else {
            return
        }
    }
    
    func getNumberPosition(currentRange : NSRange, value : Int, mainString : NSAttributedString) -> Int {
        
        let currentParagraphIndentLevel =  mainString.indentLevel
        
        
        let prevParagraphLocation = currentRange.location - 1
        
        if prevParagraphLocation >= 0{
            
            // getting the prevString.
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let prevParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: prevParagraphLocation, length: 0))
            let prevString = textStorage.attributedSubstring(from: prevParagraphRange)
            
            
            // checking if it is a list
            if prevString.containsListAttachment{
                if ( currentParagraphIndentLevel == prevString.indentLevel){
                    //  checking for same level
                    return prevString.NumberedListIndex ?? 0
                }
                else if (currentParagraphIndentLevel < prevString.indentLevel){
                    // checking if the current level is less than prev paragraph and going upwards
                    return getNumberPosition(currentRange: prevParagraphRange, value: value, mainString: mainString)
                }
                else{
                    // if current indent level is more, then start this list with 1
                    return 0
                }
            }
            else{
                return value
            }
            
        }
        else{
            return value
        }
        
    }

    
}
