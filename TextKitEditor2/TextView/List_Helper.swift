//
//  List_Helper.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 09/01/25.
//

import UIKit

extension TextView {
    
    func toggleSelected(range : NSRange){
        
        if (selectedRange.location == textStorage.length && selectedRange.length == 0 ) || (selectedRange.upperBound == textStorage.length){
            newLineAtLast(append: true, range : range, toggle: true)
        }
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let paraString = textStorage.attributedSubstring(from: paragraphRange)
        
//        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.lowerBound, length: 0))
//        let lastParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.upperBound, length: 0))

        //
//        if (firstParagraphRange.location != lastParagraphRange.location) && (firstParagraphRange.upperBound != lastParagraphRange.upperBound){
            handleListForRange(range: paragraphRange, ListType: "checkList", isString: true)
            
//            return
//        }
        
       
        

//        if let _ = paraString.attribute(.listType, at: 0, effectiveRange: nil) as? String{
//            
//            textStorage.removeAttribute(.listType, range: paragraphRange)
//
//            leftIndentForListToggle(range: paragraphRange)
//        }
//        else{
//            if let _ = paragraphString.NumberedListIndex{
//                toggleNumberList(range: range)
//            }
//            
//            textStorage.addAttribute(.listType, value: "checkList", range: paragraphRange)
//           
//            rightIndentForListToggle(range: paragraphRange)
//        }
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
//            self.toggleSelected(range: paragraphRange)
            self.undoToggleSelected(range: paragraphRange, text: paraString)
        })
        
        undoManager?.setActionName("From Toggle")
        
        

    }
    
    
    
    func toggleNumberList(range : NSRange){
        if (selectedRange.location == textStorage.length && selectedRange.length == 0 ) || (selectedRange.upperBound == textStorage.length){
            newLineAtLast(append: true, range : range, toggle: true)
        }
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let paraString = textStorage.attributedSubstring(from: paragraphRange)
        
        handleListForRange(range: paragraphRange, ListType: "", isString: false)
        
//        if let _ = paraString.attribute(.listType, at: 0, effectiveRange: nil) as? Int{
//            // if it is already a numbered list
//            leftIndentForListToggle(range: paragraphRange)
//            textStorage.removeAttribute(.listType, range: paragraphRange)
//            
//            modifyList(currentRange: paragraphRange, updateSelf: false)
//        }
//        else{
//           // if it is not a numbered list
//            if paraString.containsListAttachment && paraString.NumberedListIndex == nil{
//                toggleSelected(range: range)
//            }
//            rightIndentForListToggle(range: paragraphRange)
//            
//            textStorage.addAttribute(.listType, value: 0, range: paragraphRange)
//            
//            modifyList(currentRange: paragraphRange, updateSelf: true)
//        }
        
        
        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        
        modifyList(currentRange: firstParagraphRange, updateSelf: false)
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.undoToggleNumberList(range: paragraphRange, text: paraString)
        })
        
        undoManager?.setActionName("From number Toggle")
        
    }
    
    func modifyList(currentRange: NSRange, updateSelf : Bool) {
        
        var firstBool : Bool = updateSelf
        
        var nextLocation = currentRange.upperBound
        
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
                    let newValue = getValue2(currentRange: nextParagraphRange, value: 0, mainString: nextString)
                    if newValue == 1000{
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
    
    func paragraphRanges(for attributedString: NSAttributedString, in range: NSRange) -> [NSRange] {
        var ranges: [NSRange] = []
//        let string = attributedString.string as NSString

        // Find the starting paragraph
        var startRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        ranges.append(startRange)
        
        while startRange.upperBound < range.upperBound{
            let range = textStorage.mutableString.paragraphRange(for: NSRange(location: startRange.upperBound, length: 0))
            
            ranges.append(range)
            
            startRange = range
        }
        
        return ranges
    }
    
    func undoToggleSelected(range: NSRange, text: NSAttributedString) {
        undoManager?.beginUndoGrouping()
        
        textStorage.replaceCharacters(in: range, with: text)
        
        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        
        modifyList(currentRange: firstParagraphRange, updateSelf: true)
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleSelected(range: range)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func undoToggleNumberList(range: NSRange, text: NSAttributedString) {
        undoManager?.beginUndoGrouping()
        
        textStorage.replaceCharacters(in: range, with: text)
        
        let firstParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range.location, length: 0))
        
        modifyList(currentRange: firstParagraphRange, updateSelf: true)
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleNumberList(range: range)
        })
        
        undoManager?.endUndoGrouping()
    }
    
    func handleListForRange(range: NSRange, ListType: String, isString : Bool) {
        
        let string = textStorage.attributedSubstring(from: range)
        
        let paragraphRanges = paragraphRanges(for: string, in: range)
        
        var containsListType : Bool = false
        
        for range in paragraphRanges{
            if isString {
                if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? String {
                    containsListType = true
                }
            } else {
                if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? Int {
                    containsListType = true
                }
            }
        }
        
        if containsListType{
            for range in paragraphRanges{
                if isString {
                    if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? String {
                        textStorage.removeAttribute(.listType, range: range)
                        leftIndentForListToggle(range: range)
                    }
                } else {
                    if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? Int {
                        textStorage.removeAttribute(.listType, range: range)
                        leftIndentForListToggle(range: range)
                    }
                }
            }
        }
        else{
            for range in paragraphRanges{
                if isString{
                    if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil){
                        
                    }
                    else{
                        rightIndentForListToggle(range: range)
                    }
                    textStorage.addAttribute(.listType, value: ListType, range: range)
                    
                }
                else{
                    if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil){
                        
                    }
                    else{
                        rightIndentForListToggle(range: range)
                    }
                    textStorage.addAttribute(.listType, value: 0, range: range)
                }
            }
        }
        
        if let first = paragraphRanges.first{
            modifyList(currentRange: first, updateSelf: true)
        }
        
 
        
    }
}
