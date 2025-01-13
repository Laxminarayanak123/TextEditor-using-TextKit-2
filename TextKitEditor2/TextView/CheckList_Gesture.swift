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
//        print("location for gesture", location)
        if let tapPosition = closestPosition(to: location),
           let range = textRange(from: tapPosition, to: tapPosition){
            
            let loc = offset(from: beginningOfDocument, to: tapPosition)
            let length = offset(from: range.start, to: range.end)
            
            let range = NSRange(location: loc, length: length)
            let paraRange = textStorage.mutableString.paragraphRange(for: range)
            // getting the closest UITextPosition
            let didTapOnTheCheckbox = checkIfTappedOnCheckbox(location: location)
            if didTapOnTheCheckbox {
                toggleCheckBoxState(paraRange: paraRange)
                return
            }
            
            let _ = becomeFirstResponder()
//            selectedRange = range
        }
    }
    
    func checkIfTappedOnCheckbox(location: CGPoint) -> Bool {
        if let tapPosition = closestPosition(to: location),
           let range = textRange(from: tapPosition, to: tapPosition){
            
            let loc = offset(from: beginningOfDocument, to: tapPosition)
            let length = offset(from: range.start, to: range.end)
            
            let range = NSRange(location: loc, length: length)
            
            let nsTextRange = NSTextRange(range, contentManager: textLayoutManager!.textContentManager!)
            
            let paraRange = textStorage.mutableString.paragraphRange(for: range)
            
            if paraRange.length > 0{
                let paraString = textStorage.attributedSubstring(from: paraRange)

                if let fragment = textLayoutManager?.textLayoutFragment(for: nsTextRange!.location){
                    
                    print("fragment.layoutFragmentFrame",fragment.layoutFragmentFrame)
                    
                    if let firstLineFragment = fragment.textLineFragments.first{
                        let lineHeight = firstLineFragment.typographicBounds.height
                        
                        let fragX = fragment.layoutFragmentFrame.origin.x
                        let fragY = fragment.layoutFragmentFrame.origin.y
                        
                        if(location.x <= fragX && location.x >= fragX - 42 - 10 && location.y >= fragY && location.y <= fragY + lineHeight), paraString.paragraphType == .checkList {
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
    
    func toggleCheckBoxState(paraRange : NSRange){
        if let state = textStorage.attribute(.checkListState, at: paraRange.location, effectiveRange: nil) as? Bool {
            textStorage.addAttribute(.checkListState, value: !state, range: paraRange)
        } else {
            textStorage.addAttribute(.checkListState, value: true, range: paraRange)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleCheckBoxState(paraRange: paraRange)
            self.selectedRange = paraRange
            self.scrollRangeToVisible(paraRange)
        })
    }
}
