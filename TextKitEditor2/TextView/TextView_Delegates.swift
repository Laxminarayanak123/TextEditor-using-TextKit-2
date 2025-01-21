//
//  TextView_Delegates.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 31/12/24.
//

import UIKit

extension TextView{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            if selectedRange.location == textStorage.length && selectedRange.length == 0{
                newLineAtLast(append: true, range : range, toggle: false)
                return false
            }
            
            returnRange = paragraphRange
            
            // for maintaining the List type on return
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
                
                //1. if backspacing at the starting of a paragrapgh
                //2. if backspacing at the begining of the document
                if (range.location + 1 == textView.paragraphRange.location && range.length == 1) || (range.location == 0 && range.length == 0){
                    
                    if paragraphString.containsListAttachment{
                        
                        let prevString = getParagraphString(range: previousParagraphRange)
                        
                        //removing the List type if the previous paragraph is a different paragraphType
                        if (prevString.paragraphType != paragraphString.paragraphType) || (range.location == 0 && range.length == 0){
                            let type = paragraphString.paragraphType
                            if type == .checkList{
                                toggleCheckBox(range: paragraphRange)
                                return false
                            }
                            else if type == .numberedList{
                                toggleNumberList(range: paragraphRange)
                                return false
                            }
                        }
                        
                    }
                    
                }
                
                // backspace handling
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
    
    func textViewDidChange(_ textView: UITextView) {
        
        // for maintaining the indent level on return
        if let returnRange = returnRange{
            if let value = paragraphString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
                textStorage.addAttribute(.indentLevel, value: value, range: NSRange(location: returnRange.location, length: 1))
            }
            self.returnRange = nil
        }
        
        // for maintaining the List type on return
        if let previousParagraphRange = previousListParagraphRange {

            if let value = paragraphString.NumberedListIndex{
                textStorage.addAttribute(.listType, value: value, range: NSRange(location: previousParagraphRange.location, length: 1))
            }
            else if paragraphString.isChecklist{
                textStorage.addAttribute(.listType, value: paragraphType.checkList.rawValue, range: NSRange(location: previousParagraphRange.location, length: 1))
                if let _ = textStorage.attribute(.checkListState, at: previousParagraphRange.location, effectiveRange: nil) as? Bool{
                    textStorage.addAttribute(.checkListState, value: false, range: paragraphRange)
                }
            } else if paragraphString.isBulletlist {
                textStorage.addAttribute(.listType, value: paragraphType.bulletList.rawValue, range: NSRange(location: previousParagraphRange.location, length: 1))
            }

            modifyList(currentRange: NSRange(location: previousParagraphRange.location, length: 0), updateSelf: true)
            self.previousListParagraphRange = nil
            
        }
         
    }
    

    func textViewDidChangeSelection(_ textView: UITextView) {
        updateHighlighting()
    }
    
    // handling backspace manually
    
    func deleteRangeOfText(replaceText : NSAttributedString, replaceRange : NSRange, originalText: NSAttributedString, wholeRange : NSRange){
        undoManager?.beginUndoGrouping()
        var text : NSAttributedString = NSAttributedString(string: "")
        
        // 1. Store the text to be deleted in the range.
        // 2. Replace with empty string and register an undo with the stored text on that range.
        if replaceText.string == ""{
            
            text = textStorage.attributedSubstring(from: replaceRange)
            
            let firstParagraphRange = getParagraphRange(range: NSRange(location: replaceRange.lowerBound, length: 0))
            
            let lastParagraphRange = getParagraphRange(range: NSRange(location: replaceRange.upperBound, length: 0))
            
            // removing attributes for last paragraph, only if the range associated contains different paragraphs. if it is a single paragraph, then do not remove attributes
            if (firstParagraphRange.location != lastParagraphRange.location){
                textStorage.removeAttribute(.listType, range: lastParagraphRange)
                textStorage.removeAttribute(.indentLevel, range: lastParagraphRange)
            }
            
            // when you select the whole of first paragraph and delete, it loses the attributes also. The below code is to apply those attributes again
            let firstParagraphAttributes = textStorage.attributes(at: firstParagraphRange.location, effectiveRange: nil)
            
            let length = replaceRange.upperBound == textStorage.length ? 0 : 1
            
            textStorage.replaceCharacters(in: replaceRange, with: "")
            
            // adding attributes of first paragraph
            if firstParagraphRange.lowerBound == replaceRange.lowerBound{
                if let list = firstParagraphAttributes[.listType] {
                    textStorage.addAttribute(.listType, value: list, range: NSRange(location: replaceRange.lowerBound, length: length))
                    if let state = firstParagraphAttributes[.checkListState] {
                        textStorage.addAttribute(.checkListState, value: state, range: NSRange(location: replaceRange.lowerBound, length: length))
                    }
                }
                
                if let indentLevel = firstParagraphAttributes[.indentLevel] {
                    textStorage.addAttribute(.indentLevel, value: indentLevel, range: NSRange(location: replaceRange.lowerBound, length: length))
                }
            }
            
            selectedRange = NSRange(location: replaceRange.location, length: 0)
            scrollRangeToVisible(selectedRange)
            
            if text.string.contains("\n"){
                let range = textStorage.mutableString.paragraphRange(for: NSRange(location: replaceRange.location, length: 0))
                modifyList(currentRange: range, updateSelf: false)
            }
            
        }
        else{
            
            textStorage.insert(replaceText, at: replaceRange.location)

            textStorage.replaceCharacters(in: wholeRange, with: originalText)
            
            selectedRange = replaceRange
            scrollRangeToVisible(selectedRange)
            if replaceText.string.contains("\n") {
                let range = getParagraphRange(range: NSRange(location: replaceRange.upperBound, length: 0))
                modifyList(currentRange: range, updateSelf: false)
            }
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { target in
            self.deleteRangeOfText(replaceText: text, replaceRange: replaceRange, originalText: originalText, wholeRange: wholeRange)
        })
        
        undoManager?.endUndoGrouping()
    }
}


