//
//  List_Helper.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 09/01/25.
//

import UIKit

extension TextView {
    
    func getParagraphRanges(for attributedString: NSAttributedString, in range: NSRange) -> [NSRange] {
        var ranges: [NSRange] = []
        
        // Find the starting paragraph
        var startRange = getParagraphRange(range: NSRange(location: range.location, length: 0))
        ranges.append(startRange)
        
        while startRange.upperBound < range.upperBound{
            let range = getParagraphRange(range: NSRange(location: startRange.upperBound, length: 0))
            
            ranges.append(range)
            startRange = range
        }
        
        return ranges
    }
    
    
    func handleListForRange(range: NSRange, paragraphType : paragraphType) {
        
        let string = getParagraphString(range: range)
        
        let paragraphRanges = getParagraphRanges(for: string, in: range)
        
        //check if the paragraph ranges contain the paragraphType
        let containsListType = containsListType(range: range, paragraphType: paragraphType, paragraphRanges: paragraphRanges)
        
        //Remove only those paragraphs which contains this paragraphType
        if containsListType{
            for range in paragraphRanges{
                if paragraphType == .NumberedList{
                    if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? Int {
                        textStorage.removeAttribute(.listType, range: range)
                        leftIndentForListToggle(range: range)
                    }
                }
                else{
                    if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? String {
                        textStorage.removeAttribute(.listType, range: range)
                        textStorage.removeAttribute(.checkListState, range: range)
                        leftIndentForListToggle(range: range)
                    }
                }
                
            }
        }
        // add the paragraphType to all the ranges
        else{
            for range in paragraphRanges{
                if paragraphType == .NumberedList{
                    if textStorage.attribute(.listType, at: range.location, effectiveRange: nil) == nil{
                        rightIndentForListToggle(range: range)
                    }
                    
                    textStorage.addAttribute(.listType, value: 0, range: range)
                }
                else{
                    if textStorage.attribute(.listType, at: range.location, effectiveRange: nil) == nil {
                        rightIndentForListToggle(range: range)
                        
                    }
                    
                    textStorage.addAttribute(.listType, value: paragraphType.rawValue, range: range)
                    textStorage.addAttribute(.checkListState, value: false, range: range)
                }
            }
        }
        
        if let first = paragraphRanges.first{
            modifyList(currentRange: first, updateSelf: true)
        }
        
    }
    
    func containsListType(range : NSRange, paragraphType : paragraphType, paragraphRanges : [NSRange]?) -> Bool {
        
        var ranges : [NSRange] = []
        ranges = paragraphRanges ?? getParagraphRanges(for: textStorage.attributedSubstring(from: range), in: range)
        
        for range in ranges{
            if paragraphType == .NumberedList {
                if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? Int {
                    return true
                }
                
            } else {
                if let _ = textStorage.attribute(.listType, at: range.location, effectiveRange: nil) as? String {
                    return true
                }
            }
        }
        
        return false
    }
    
    //inserting new line if at the end of the document
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
            selectedRange.location = range.location
        }
        
        scrollRangeToVisible(range)

        
        undoManager?.registerUndo(withTarget: self, handler: { target in
            self.newLineAtLast(append: !append, range: range,toggle: toggle)
        })
        
        undoManager?.endUndoGrouping()
    }
}
