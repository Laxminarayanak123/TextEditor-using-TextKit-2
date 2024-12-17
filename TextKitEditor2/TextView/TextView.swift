//
//  TextView.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 29/11/24.
//

import UIKit

class TextView : UITextView, UITextViewDelegate, NSTextContentManagerDelegate, UIGestureRecognizerDelegate{
    
    var textContentStorage : NSTextContentStorage!
        
    var tapToggle : Bool = false
    
    var tapGesture : UITapGestureRecognizer!
    
    var previousParagraphIsChecklist : Bool = false
    var previousCheckListParagraphRange : NSRange?
    var AddListAttrOnBackSpace : Bool = false
    
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {

        super.init(frame: frame, textContainer: textContainer)
        
        textLayoutManager?.delegate = self
        textStorage.delegate = self
        textLayoutManager?.textContentManager?.delegate = self
        setupTextView()
        inputAccessoryView = createToolbar()
        keyboardDismissMode = .interactiveWithAccessory
        alwaysBounceVertical = true
        delegate = self
//        textLayoutManager?.textViewportLayoutController.delegate = self
        isEditable = true
        isScrollEnabled = true
        backgroundColor = UIColor.systemBackground
        setUpNotifications()
        checkListTapGesture()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupTextView() {
        // Create the NSTextStorage with styled text
        let styledText = NSMutableAttributedString(
            string: "Welcome to TextKit customization! This is an example of using textContainer, layoutManager, and textStorage. \n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
        )

        styledText.addAttribute(
            .foregroundColor,
            value: UIColor.systemBlue,
            range: NSRange(location: 0, length: 7)
        )
        
      
        
        let font = UIFont(name: "Noteworthy-Bold", size: 24) ?? .systemFont(ofSize: 24)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = font.pointSize * 0.15
//        paragraphStyle.headIndent = 30
//        paragraphStyle.firstLineHeadIndent = 30
        
        typingAttributes = [
            .font: font,
            .paragraphStyle: paragraphStyle,
        ]
        
        
        let string1 = "When you try your best, but you don't succeed\nWhen you get what you want, but not what you need\nWhen you feel so tired, but you can't sleep\nStuck in reverse\nAnd the tears come streaming down your face\nWhen you lose something you can't replace\nWhen you love someone, but it goes to waste\nCould it be worse?\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nAnd high up above, or down below\nWhen you're too in love to let it go\nBut if you never try, you'll never know\nJust what you're worth\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nTears stream down your face\nWhen you lose something you cannot replace\nTears stream down your face, and I\nTears stream down your face\nI promise you I will learn from my mistakes\nTears stream down your face, and I\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nWhen you try your best, but you don't succeed\nWhen you get what you want, but not what you need\nWhen you feel so tired, but you can't sleep\nStuck in reverse\nAnd the tears come streaming down your face\nWhen you lose something you can't replace\nWhen you love someone, but it goes to waste\nCould it be worse?\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nAnd high up above, or down below\nWhen you're too in love to let it go\nBut if you never try, you'll never know\nJust what you're worth\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nTears stream down your face\nWhen you lose something you cannot replace\nTears stream down your face, and I\nTears stream down your face\nI promise you I will learn from my mistakes\nTears stream down your face, and I\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you"
        
        let _ = ""
        
        let attributedString = NSMutableAttributedString(
            string: string1,
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        textStorage.setAttributedString(attributedString)
        
        }
    

    private func createToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.items = [
                UIBarButtonItem(title: "ToggleSelected", style: .plain, target: self, action: #selector(toggleSelected)),
                UIBarButtonItem(title: "Tap Gest", style: .plain, target: self, action: #selector(toggleTap)),
            ]
            toolbar.sizeToFit()
            return toolbar
        }
    
    @objc func toggleSelected(){
        
        if selectedRange.location == textStorage.length && selectedRange.length == 0{
            textStorage.append(NSAttributedString(string: "\n", attributes: typingAttributes))
        }
        
        let attrString = paragraphString
        var mutableAttributedString = NSMutableAttributedString(attributedString: attrString)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 50
        paragraphStyle.firstLineHeadIndent = 50
       
        
        if attrString.string == "\n" || attrString.string == ""{
//            mutableAttributedString = NSMutableAttributedString(string: "\n",attributes: typingAttributes)
        }
        
        if let _ = mutableAttributedString.attribute(.customCase, at: 0, effectiveRange: nil) as? String{
            textStorage.removeAttribute(.customCase, range: paragraphRange)

        }
        else{
            textStorage.addAttribute(.customCase, value: "checkList", range: paragraphRange)
        }

    }
    
    @objc func toggleTap(){
        tapToggle.toggle()
        if tapToggle{
            self.addGestureRecognizer(tapGesture)
        }
        else{
            self.removeGestureRecognizer(tapGesture)
        }
    }
                                
    func checkListTapGesture(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        tapGesture.delegate = self
    }
    
    @objc func handleTap(_ gesture : UITapGestureRecognizer){
        let location = gesture.location(in: self)
        print("location for gesture", location)
        
        // getting the closest UITextPosition
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
                        
                        if(location.x <= fragX && location.x >= fragX - 42 && location.y >= fragY && location.y <= fragY + lineHeight){
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let previousParagraphRange = previousCheckListParagraphRange, previousParagraphIsChecklist{
            if previousParagraphIsChecklist{
                textStorage.addAttribute(.customCase, value: "checkList", range: previousParagraphRange)
            }

            previousParagraphIsChecklist = false
            self.previousCheckListParagraphRange = nil
        }
        
        if AddListAttrOnBackSpace{
                textStorage.addAttribute(.customCase, value: "checkList", range: paragraphRange)
            AddListAttrOnBackSpace = false
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            if selectedRange.location == textStorage.length && selectedRange.length == 0{
                textStorage.append(NSAttributedString(string: "\n", attributes: typingAttributes))
            }
            
            if paragraphString.containsListAttachment{

                if(paragraphString.string == "\n"){
                    previousParagraphIsChecklist = true
                    
                    previousCheckListParagraphRange = paragraphRange
                }
                return true
            }

            return true
        }
        
        //for backspaces
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                
                if !paragraphString.containsListAttachment{
                    return true
                }
                
                // removing attribute for the selected range first.
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                let paragraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: selectedRange.location + selectedRange.length, length: 0))
                
                if selectedRange.length >= paragraphRange.length{
                    textStorage.removeAttribute(.customCase, range: paragraphRange)
                    return true
                }
                
                // removing attribute if the caret is at first position
                if textView.selectedRange.location == textView.paragraphRange.location,
                   textView.selectedRange.length == 0 {
                    if textView.paragraphString.containsListAttachment{
                        textStorage.removeAttribute(.customCase, range: paragraphRange)
                        return false
                    }
                }
                
                // prev paragraph
                let range = paragraphRange.location - 1
                if range >= 0{
                    let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range, length: 0))
                    let prevParagraph = attributedText.attributedSubstring(from: prevParagraphRange)
                    
                        if prevParagraph.containsListAttachment{
                            AddListAttrOnBackSpace = true
                            return true
                        }
                }
                return true
        
            }
        }
       
        return true
        
        
    }
    
    

}



extension NSTextParagraph{
    
}
extension TextView : NSTextLayoutManagerDelegate{
    
    
    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: any NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
        
        
        if(textStorage.length == 0){
            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        }
        
        if let textElement = textElement as? NSTextParagraph{
            let attrString = textElement.attributedString
            
            if let _ = attrString.attribute(.customCase, at: 0, effectiveRange: nil) as? String{
                let fragment = CheckboxTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
                return fragment
            }
            
        }
    
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
    
    
}


extension TextView : NSTextContentStorageDelegate{
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        
            let attrString = textContentStorage.textStorage?.attributedSubstring(from: range)
            let mutableString = NSMutableAttributedString(attributedString: attrString!)
        

            let paragraphStyle = NSMutableParagraphStyle()
            if let ogParagraphStyle = mutableString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle{
                paragraphStyle.setParagraphStyle(ogParagraphStyle)

            }
        


        if let _ = mutableString.attribute(.customCase, at: 0, effectiveRange: nil) as? String{
            paragraphStyle.headIndent = 52.0
            paragraphStyle.firstLineHeadIndent = 50.0
        }
                
        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableString.length))
        

            
        return NSTextParagraph(attributedString: mutableString)
        
    }
    
}


