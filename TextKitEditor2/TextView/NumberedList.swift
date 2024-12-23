//
//  NumberedList.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 20/12/24.
//
import UIKit

extension TextView{
    
//    func getValue(currentRange : NSRange, value : Int, mainString : NSAttributedString) -> Int {
//        
//        
//        var currentParagraphIndentLevel =  0
//        
//        if let value = mainString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
//            currentParagraphIndentLevel = value
//        }
//        
//        
//        
//        let prevParagraphLocation = currentRange.location - 1
//        
//        if prevParagraphLocation > 0{
//            
//            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
//            let prevParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: prevParagraphLocation, length: 0))
//            let prevString = textStorage.attributedSubstring(from: prevParagraphRange)
//            
//            if let value = prevString.attribute(.listType, at: 0, effectiveRange: nil){
//                
//                if let indentLevel = prevString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
//                    
//                    if (indentLevel - 1) == currentParagraphIndentLevel{
//                        if let value = value as? Int{
//                            return value
//                        }
//                        else{
//                            return 0
//                        }
//                    }
//                    else if (indentLevel == currentParagraphIndentLevel){
//                        return 0
//                    }
//                    else{
//                        if let value = value as? Int{
//                            return getValue(currentRange: prevParagraphRange, value: value, mainString: mainString)
//                        }
//                        else{
//                            return 0
//                        }
//                        
//                    }
//                    
//                }
//                else{
//                    return 0
//                }
//                
//            }
//            else{
//                return value
//            }
//            
//        }
//        else{
//            return value
//        }
//        
//    }
    
    
    
    func getValue(currentRange : NSRange, value : Int, mainString : NSAttributedString) -> Int {
        
        let currentParagraphIndentLevel =  mainString.indentLevel
        
        
        let prevParagraphLocation = currentRange.location - 1
        
        if prevParagraphLocation > 0{
            
            // getting the prevString.
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let prevParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: prevParagraphLocation, length: 0))
            let prevString = textStorage.attributedSubstring(from: prevParagraphRange)
            
            
            // checking if it is a list
            if prevString.containsListAttachment{
                if ( currentParagraphIndentLevel == prevString.indentLevel - 1 ){
                    //  checking for same level
                    return prevString.NumberedListIndex ?? 0
                }
                else if (currentParagraphIndentLevel < prevString.indentLevel - 1){
                    // checking if the current level is less than prev paragraph and going upwards
                    return getValue(currentRange: prevParagraphRange, value: value, mainString: mainString)
                }
                else{
                    // if current indent level is more then start this list with 1
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
    
    func getValue2(currentRange : NSRange, value : Int, mainString : NSAttributedString) -> Int {
        
        let currentParagraphIndentLevel =  mainString.indentLevel
        
        
        let prevParagraphLocation = currentRange.location - 1
        
        if prevParagraphLocation > 0{
            
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
                    return getValue2(currentRange: prevParagraphRange, value: value, mainString: mainString)
                }
                else{
                    // if current indent level is more then start this list with 1
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
