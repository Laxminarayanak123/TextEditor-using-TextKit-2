//
//  Keyboard.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 05/12/24.
//
import UIKit

extension TextView{
    func setUpNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShowNotification(_ notification : Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        contentInset.bottom = (keyboardScreenEndFrame.height - safeAreaInsets.bottom)
        scrollRangeToVisible(selectedRange)
    }
    
    @objc func keyboardWillHideNotification(_ : Notification) {
        contentInset.bottom = .zero
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        _ = NSTextRange(selectedRange, contentManager: textLayoutManager!.textContentManager!)
//        print("selected Text", self.selectedRange, nstextrange?.location,nstextrange?.endLocation)
//        textLayoutManager?.enumerateTextLayoutFragments(from: nstextrange?.location, using: { fragment in
//            
//            print("fragment", fragment)
//            return true
//        })
        
    }
}
