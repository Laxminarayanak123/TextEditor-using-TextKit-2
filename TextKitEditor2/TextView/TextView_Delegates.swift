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
        if let previousParagraphRange = previousListParagraphRange{
                      
    //            textStorage.removeAttribute(.listType, range: paragraphRange)
//            textStorage.insert(NSAttributedString(string: "\n"), at: selectedRange.location)

    //            toggleTest(range: selectedRange)
            
            if let value = paragraphString.NumberedListIndex{
                textStorage.addAttribute(.listType, value: value, range: NSRange(location: previousParagraphRange.location, length: 1))
                textStorage.addAttribute(.indentLevel, value: paragraphString.indentLevel, range: NSRange(location: previousParagraphRange.location, length: 1))
            }
            else{
                textStorage.addAttribute(.listType, value: "checkList", range: NSRange(location: previousParagraphRange.location, length: 1))
            }

                if let value = paragraphString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
                    textStorage.addAttribute(.indentLevel, value: value, range: NSRange(location: previousParagraphRange.location, length: 1))
                }

            
//            modifyList(currentRange: NSRange(location: previousParagraphRange.location, length: 0))
            self.previousListParagraphRange = nil
            
            

        }
        
       
        
        // this is for previous paragraph, based on the values in "shouldChangeTextIn" for backspacing
        if AddListAttrOnBackSpace{
            if let numberedListValue = numberedListValue{
                textStorage.addAttribute(.listType, value: numberedListValue, range: paragraphRange)
            }
            else{
//                textStorage.addAttribute(.listType, value: "checkList", range: paragraphRange)
            }
            
            if let val = indentLevelForPrevious{
                textStorage.addAttribute(.indentLevel, value: val, range: paragraphRange)
            }
            
            modifyList(currentRange: paragraphRange)
            indentLevelForPrevious = nil
            AddListAttrOnBackSpace = false
            numberedListValue = nil
        }
        
        if modifyListOnBackSpace{
            if paragraphRange.location == 0, paragraphString.NumberedListIndex != nil {
                textStorage.addAttribute(.listType, value: 1, range: previousParagraphRange)
            }
            modifyList(currentRange: paragraphRange)
            modifyListOnBackSpace = false
            flag1 = true
        }
        
        if modifyListOnBackSpace2{
            if paragraphRange.location == 0, paragraphString.NumberedListIndex != nil  {
                textStorage.addAttribute(.listType, value: 1, range: paragraphRange)
            }
            modifyList(currentRange: previousParagraphRange)
            modifyListOnBackSpace2 = false
        }
        
        if flag{
    //            modifyList(currentRange: previousParagraphRange)
            newFlag = true
            flag = false
        }
    //        modifyList(currentRange: paragraphRange)
        
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if returnedFlag{
//            returnedFlag = false
//            return false
//        }
        
        if text == "\n" {
            
            if selectedRange.location == textStorage.length && selectedRange.length == 0{
                newLineAtLast(append: true, range : range, toggle: false)
//                textStorage.append(NSAttributedString(string: "\n", attributes: typingAttributes))
                return false
            }
            
            // if the current paragraph is a checkbox and you are trying to return at the starting location of paragraph then create a checkbox above it
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
                
                
                
                
//                // ( the scenario where holding the backspace and deleting text. here we are removing the attributes of the down most paragraph, otherwise the attributes will affect the paragraph above it )
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                let paragraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: selectedRange.location + selectedRange.length, length: 0))
                
                let startingParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: selectedRange.location, length: 0))
                
                
                if (selectedRange.length >= paragraphRange.length) && ((selectedRange.upperBound + 1) == paragraphRange.upperBound){
                    let string = textStorage.attributedSubstring(from: paragraphRange)
//                        let startingParagraph = textStorage.attributedSubstring(from: startingParagraphRange)
                    
                    if let _ = string.NumberedListIndex{
                        flag = true
                    }
                    
                    if startingParagraphRange.location != selectedRange.location{
                        toggleSelected(range: paragraphRange)
//                        textStorage.removeAttribute(.listType, range: paragraphRange)
//                        textStorage.removeAttribute(.indentLevel, range: paragraphRange)
                    }
                    modifyListOnBackSpace = true
                    
//                    textStorage.replaceCharacters(in: NSRange(location: paragraphRange.location, length: paragraphRange.length - 1), with: "")
////                    selectedRange.location = selectedRange.location -  paragraphRange.location
//                    selectedRange.location = paragraphRange.location
//                    return false
                }
                
//                bool = true
//                ranger = paragraphRange
                if (range.location + 1 == textView.paragraphRange.location && range.length == 1) || (range.location == 0 && range.length == 0){
                    
                    let paragraphString = textView.paragraphString
                    let paragraphRange = textView.paragraphRange
                    
                    if paragraphString.containsListAttachment{
                        
                        
                        
                        let prevString = textStorage.attributedSubstring(from: previousParagraphRange)
                                                
                        if prevString.paragraphType != paragraphString.paragraphType{
                            let type = paragraphString.paragraphType
                            if type == .checkList{
                                toggleSelected(range: paragraphRange)
                                return false
                            }
                        }
                        
                        // starting point of document
//                        if range.location == 0{
//                            let type = paragraphString.paragraphType
//                            if type == .checkList{
//                                toggleSelected(range: paragraphRange)
//                                return false
//                            }
//                        }
                    }
                    
//                    if selectedRange.location != 0{
                        if !undoManager!.isUndoing && !undoManager!.isRedoing{
                            backspaceAtStart(range: range)
                            return false
                        }
//                    }

                    
            
                    return true
                    
                }
//                if range.location == textView.paragraphRange.location, range.length == 0{
//                    AddListAttrOnBackSpace = true
//                    indentLevelForPrevious = textStorage.attributedSubstring(from: previousParagraphRange).indentLevel
//                }
//
//                if selectedRange.length > 0 {
//                    modifyListOnBackSpace2 = true
//                }
//
                // removing attribute if the caret is at starting position of a paragraph
//                if textView.selectedRange.location == textView.paragraphRange.location,
//                   textView.selectedRange.length == 0 {

//                    if textView.paragraphString.containsListAttachment{
////                        textStorage.removeAttribute(.listType, range: paragraphRange)
////                        toggleSelected(range: paragraphRange)
//    //                        leftIndent()
//                        if (undoManager!.isUndoing || undoManager!.isRedoing) && (undoManager!.redoActionName != "From Toggle" || undoManager!.undoActionName != "From Toggle"){
//                            return true
//                        }
//                        else{
//                            toggleSelected(range: paragraphRange)
//                            return false
//                        }
////                        modifyList(currentRange: paragraphRange)
////                        if undoManager?.undoActionName == "From Toggle" {
////                            return false
////                        }
////                        if range.length == 1{
////                            toggleSelected(range: paragraphRange)
////                            return false
////                        }
////                        return true
//                    }
//                    else{
//                        
////                        // Paragraphs defaultly won't have this .indentLevel, so when backspacing, the above paragraph gets the indent level of current paragraph. so for the paragraphs which don't have the .indent level, we are giving a value 0 to prevent from getting overriden.
//                        let range = paragraphRange.location - 1
//                        if range >= 0{
//                            let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range, length: 0))
//                            let prevParagraph = attributedText.attributedSubstring(from: prevParagraphRange)
//                            if let _ = prevParagraph.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
//    //                                textStorage.removeAttribute(.indentLevel, range: paragraphRange)
//                            }
//                            else{
//                                textStorage.addAttribute(.indentLevel, value: 0, range: prevParagraphRange)
//                            }
//                            
//                            modifyList(currentRange: prevParagraphRange)
//                        }
//                    }
//                }
//                
//                
//                // if the previous paragraph is a checklist and empty string, then on backspacing on current paragraph(empty string), prev paragraph needs to retain its checklist.
//                let range = paragraphRange.location - 1
//                if range >= 0{
//                    let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range, length: 0))
//                    let prevParagraph = attributedText.attributedSubstring(from: prevParagraphRange)
//                    
//                    if textView.selectedRange.location == textView.paragraphRange.location,
//                    textView.selectedRange.length == 0{
//                        if prevParagraph.containsListAttachment && prevParagraph.string == "\n"{
//                            AddListAttrOnBackSpace = true
//                            
//                            if let value = prevParagraph.NumberedListIndex{
//                                numberedListValue = value
//                            }
//                            
//                            if let value = prevParagraph.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
//                                indentLevelForPrevious = value
//                            }
//                            
//                            return true
//                        }
//                        
//                        
//                        modifyListOnBackSpace = true
//                    }
//
//                }
//                return true
//                
//        
            }
        }
       
        return true
        
        
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        guard let font = textView.typingAttributes[.font] as? UIFont else {
            isBoldEnabled = false
            isItalicEnabled = false
            isUnderlineEnabled = false
            isStrikeThroughEnabled = false
            return
        }
        
        
        isBoldEnabled = font.fontDescriptor.symbolicTraits.contains(.traitBold)
        isItalicEnabled = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        
        if let underlineStyle = textView.typingAttributes[.underlineStyle] as? Int {
            isUnderlineEnabled = underlineStyle != 0
        } else {
            isUnderlineEnabled = false
        }
        
        if let strike = textView.typingAttributes[.strikethroughStyle] as? Int {
            isStrikeThroughEnabled = strike != 0
        } else {
            isStrikeThroughEnabled = false
        }
    }
    
    
}


