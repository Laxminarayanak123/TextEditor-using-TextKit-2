//
//  CheckList_Gesture.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 13/01/25.
//

import UIKit

extension TextView : UIGestureRecognizerDelegate {
    func checkListTapGesture(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.name = "checkbox"
        tapGesture.delegate = self
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture : UITapGestureRecognizer){
        let location = gesture.location(in: self)
        
        // getting the paragraphRange of the checkbox that is tapped
        if let tapPosition = closestPosition(to: location),
           let textRange = textRange(from: tapPosition, to: tapPosition){
            
            let loc = offset(from: beginningOfDocument, to: tapPosition)
            let length = offset(from: textRange.start, to: textRange.end)
            
            let range = NSRange(location: loc, length: length)
            let paragraphRange = getParagraphRange(range: range)
            
            toggleCheckBoxState(paragraphRange: paragraphRange)
            
            return
        }
    }
    
    func checkIfTappedOnCheckbox(location: CGPoint) -> Bool {
        if let tapPosition = closestPosition(to: location),
           let textRange = textRange(from: tapPosition, to: tapPosition){
            
            let loc = offset(from: beginningOfDocument, to: tapPosition)
            let length = offset(from: textRange.start, to: textRange.end)
            
            let range = NSRange(location: loc, length: length)
            
            let nsTextRange = NSTextRange(range, contentManager: textLayoutManager!.textContentManager!)
            
            let paragraphRange = getParagraphRange(range: range)
            
            if paragraphRange.length > 0{
                let paragraphString = getParagraphString(range: paragraphRange)
                
                if let fragment = textLayoutManager?.textLayoutFragment(for: nsTextRange!.location){
                    
                    if let firstLineFragment = fragment.textLineFragments.first{
                        let lineHeight = firstLineFragment.typographicBounds.height
                        
                        let fragX = fragment.layoutFragmentFrame.origin.x
                        let fragY = fragment.layoutFragmentFrame.origin.y
                        let isInXBounds = location.x <= fragX  && location.x >= fragX + fragment.renderingSurfaceBounds.origin.x
                        // (24 * 0.2) for paragraph spacing
                        let isInYBounds = location.y >= fragY && location.y <= fragY + lineHeight + (24 * 0.2)
                        
                        if(isInXBounds && isInYBounds), paragraphString.paragraphType == .checkList {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UITapGestureRecognizer,
           gesture.name == "checkbox" {
            let location = gesture.location(in: gesture.view)
            
            let shouldBegin = checkIfTappedOnCheckbox(location: location)
            
            return shouldBegin
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UITapGestureRecognizer,
           gesture.name == "checkbox" {
            let location = gesture.location(in: gesture.view)
            
            return checkIfTappedOnCheckbox(location: location)
        }
        
        return false
    }
    
    func toggleCheckBoxState(paragraphRange : NSRange){
        if let state = textStorage.attribute(.checkListState, at: paragraphRange.location, effectiveRange: nil) as? Bool {
            textStorage.addAttribute(.checkListState, value: !state, range: paragraphRange)
        } else {
            textStorage.addAttribute(.checkListState, value: true, range: paragraphRange)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        
        if undoManager!.isUndoing || undoManager!.isRedoing{
            self.selectedRange = paragraphRange
            self.scrollRangeToVisible(selectedRange)
        }
        else{
            if !paragraphRange.contains(selectedRange.location){
                
                self.selectedRange = NSRange(location: paragraphRange.upperBound - 1, length: 0)
                self.scrollRangeToVisible(selectedRange)
            }
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleCheckBoxState(paragraphRange: paragraphRange)
            
        })
    }
}
