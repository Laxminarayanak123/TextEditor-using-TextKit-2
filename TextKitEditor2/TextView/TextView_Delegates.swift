//
//  TextView_Delegates.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 31/12/24.
//

import UIKit


extension TextView{
    func textViewDidChange(_ textView: UITextView) {
        
        // using values that are assigned in "shouldChangeTextIn", managing checkbox for previous paragraph and indent for current paragraph based on previous paragraph
        if let returnRange = returnRange{
            if let value = paragraphString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
                textStorage.addAttribute(.indentLevel, value: value, range: NSRange(location: returnRange.location, length: 1))
            }
            self.returnRange = nil
        }
        
        if let previousParagraphRange = previousListParagraphRange {

            if let value = paragraphString.NumberedListIndex{
                textStorage.addAttribute(.listType, value: value, range: NSRange(location: previousParagraphRange.location, length: 1))
            }
            else{
                textStorage.addAttribute(.listType, value: "checkList", range: NSRange(location: previousParagraphRange.location, length: 1))
                if let _ = textStorage.attribute(.checkListState, at: previousParagraphRange.location, effectiveRange: nil) as? Bool{
                    textStorage.addAttribute(.checkListState, value: false, range: paragraphRange)
                }
            }

            modifyList(currentRange: NSRange(location: previousParagraphRange.location, length: 0), updateSelf: true)
            self.previousListParagraphRange = nil
            
        }
         
        
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            if selectedRange.location == textStorage.length && selectedRange.length == 0{
                newLineAtLast(append: true, range : range, toggle: false)
                return false
            }
            
            returnRange = paragraphRange
            
//             if the current paragraph is a checkbox and you are trying to return at the starting location of paragraph then create a checkbox above it
            if paragraphString.containsListAttachment{

                previousListParagraphRange = paragraphRange
                
                return true
                
            }

            return true
        }
        
        //for backspaces
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                
                if (range.location + 1 == textView.paragraphRange.location && range.length == 1) || (range.location == 0 && range.length == 0){
                                    
                    if paragraphString.containsListAttachment{
                        
                        
                        
                        let prevString = textStorage.attributedSubstring(from: previousParagraphRange)
                                                
                        if (prevString.paragraphType != paragraphString.paragraphType) || (range.location == 0 && range.length == 0){
                            let type = paragraphString.paragraphType
                            if type == .checkList{
                                toggleSelected(range: paragraphRange)
                                return false
                            }
                            else if type == .NumberedList{
                                toggleNumberList(range: paragraphRange)
                                return false
                            }
                        }
                        
                    }

                }
                
                //handling selectedRange backspace in apple way
//                if !undoManager!.isUndoing && !undoManager!.isRedoing{
                    if range.length > 0{
                        let startingPoint = range.location
                        let endingPoint = range.upperBound
                        
                        let startingParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: startingPoint, length: 0))
                        let endingParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: endingPoint, length: 0))
                        
                        let replaceRange = range
                        
                        let wholeRange = NSRange(location: startingParagraphRange.location, length: endingParagraphRange.upperBound - startingParagraphRange.lowerBound)
                        
                        let oldText = textStorage.attributedSubstring(from: wholeRange)
                        
                        deleteRangeOfText(replaceText: NSAttributedString(string: ""), replaceRange: replaceRange, originalText: oldText, wholeRange: wholeRange)
                        
                        return false
                    }

            }
        }
       
        return true
        
        
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {

        updateHighlighting()
        
    }
    
    
    
    func deleteRangeOfText(replaceText : NSAttributedString, replaceRange : NSRange, originalText: NSAttributedString, wholeRange : NSRange){
        undoManager?.beginUndoGrouping()
        var text : NSAttributedString = NSAttributedString(string: "")
        
        if replaceText.string == ""{
            
            text = textStorage.attributedSubstring(from: replaceRange)
            
            let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: replaceRange.lowerBound, length: 0))
            
            let lastParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: replaceRange.upperBound, length: 0))
            
            let paragraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: replaceRange.location, length: 0))
            
            
            if (paragraphRange.location != lastParagraphRange.location) /*|| (paragraphRange.length != lastParagraphRange.length)*/{
                textStorage.removeAttribute(.listType, range: lastParagraphRange)
                textStorage.removeAttribute(.indentLevel, range: lastParagraphRange)
            }
            
            let firstParagraphAttributes = textStorage.attributes(at: firstParagraphRange.location, effectiveRange: nil)
            
            let length = replaceRange.upperBound == textStorage.length ? 0 : 1
            
            textStorage.replaceCharacters(in: replaceRange, with: "")
            
            // adding attributes of first paragraph
            if firstParagraphRange.lowerBound == replaceRange.lowerBound{
                if let list = firstParagraphAttributes[.listType] {
                    textStorage.addAttribute(.listType, value: list, range: NSRange(location: replaceRange.lowerBound, length: length))
                }
                if let indentLevel = firstParagraphAttributes[.indentLevel] {
                    textStorage.addAttribute(.indentLevel, value: indentLevel, range: NSRange(location: replaceRange.lowerBound, length: length))
                }
            }
            
            selectedRange = NSRange(location: replaceRange.location, length: 0)
            scrollRangeToVisible(selectedRange)
            
            let range = textStorage.mutableString.paragraphRange(for: NSRange(location: replaceRange.location, length: 0))
            modifyList(currentRange: range, updateSelf: true)
        }
        else{
            
            textStorage.insert(replaceText, at: replaceRange.location)
//            
//            let wholeString = textStorage.attributedSubstring(from: wholeRange)
//            
            textStorage.replaceCharacters(in: wholeRange, with: originalText)
            
            selectedRange = replaceRange
            scrollRangeToVisible(selectedRange)
            
            let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: replaceRange.location, length: 0))
            modifyList(currentRange: firstParagraphRange, updateSelf: true)
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { target in
            self.deleteRangeOfText(replaceText: text, replaceRange: replaceRange, originalText: originalText, wholeRange: wholeRange)
        })
        undoManager?.endUndoGrouping()
    }
}


