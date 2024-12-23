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
    
    var indentLevelForPrevious : Int?
    
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
                UIBarButtonItem(title: "left", style: .plain, target: self, action: #selector(leftIndent)),
                UIBarButtonItem(title: "Tap Gest", style: .plain, target: self, action: #selector(toggleTap)),
                UIBarButtonItem(title: "right", style: .plain, target: self, action: #selector(rightIndent)),
                UIBarButtonItem(title: "number", style: .plain, target: self, action: #selector(toggleNumberList)),
            ]
            toolbar.sizeToFit()
            return toolbar
        }
    
    @objc func toggleSelected(){
        
        if selectedRange.location == textStorage.length && selectedRange.length == 0{
            textStorage.append(NSAttributedString(string: "\n", attributes: typingAttributes))
        }
        
        if let _ = paragraphString.attribute(.listType, at: 0, effectiveRange: nil) as? String{
            textStorage.removeAttribute(.listType, range: paragraphRange)
            leftIndent()

        }
        else{
            textStorage.addAttribute(.listType, value: "checkList", range: paragraphRange)
            rightIndent()
        }

    }
    
    @objc func toggleNumberList(){
        if selectedRange.location == textStorage.length && selectedRange.length == 0{
            textStorage.append(NSAttributedString(string: "\n", attributes: typingAttributes))
        }
        
        if let _ = paragraphString.attribute(.listType, at: 0, effectiveRange: nil) as? Int{
            // if it is already a numbered list
            textStorage.removeAttribute(.listType, range: paragraphRange)
            leftIndent()
            
            modifyList(currentRange: paragraphRange)
        }
        else{
           // if it is not a numbered list
            let index = getValue(currentRange: paragraphRange, value: 0, mainString : paragraphString)
            textStorage.addAttribute(.listType, value: index + 1, range: paragraphRange)
            rightIndent()
            
            modifyList(currentRange: paragraphRange)
        }
        
    }
    
    func modifyList(currentRange: NSRange) {
        let nextLocation = currentRange.upperBound
        
        if nextLocation <= textStorage.length {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let nextParagraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: nextLocation, length: 0))
            let nextString = textStorage.attributedSubstring(from: nextParagraphRange)
            
            if nextString.containsListAttachment {
                if let _ = nextString.NumberedListIndex {
                    let newValue = getValue2(currentRange: nextParagraphRange, value: 0, mainString: nextString)
                    textStorage.addAttribute(.listType, value: newValue + 1, range: nextParagraphRange)
                }
                modifyList(currentRange: nextParagraphRange)
            }
        } else {
            return
        }
    }
    
    @objc func toggleTap() {
//        textStorage.setAttributedString(attributedText)
//        tapToggle.toggle()
//        if tapToggle{
//            self.addGestureRecognizer(tapGesture)
//        }
//        else{
//            self.removeGestureRecognizer(tapGesture)
//        }
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
        
        // using values that are assigned in "shouldChangeTextIn", managing checkbox for previous paragraph and indent for current paragraph based on previous paragraph
        if let previousParagraphRange = previousCheckListParagraphRange, previousParagraphIsChecklist{
            if previousParagraphIsChecklist{
                textStorage.addAttribute(.listType, value: "checkList", range: previousParagraphRange)
            }
            
            if let value = paragraphString.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
                textStorage.addAttribute(.indentLevel, value: value, range: previousParagraphRange)
            }

            previousParagraphIsChecklist = false
            self.previousCheckListParagraphRange = nil
        }
        
        
        // this is for previous paragraph, based on the values in "shouldChangeTextIn" for backspacing
        if AddListAttrOnBackSpace{
            textStorage.addAttribute(.listType, value: "checkList", range: paragraphRange)
            if let val = indentLevelForPrevious{
                textStorage.addAttribute(.indentLevel, value: val, range: paragraphRange)
            }
            indentLevelForPrevious = nil
            AddListAttrOnBackSpace = false
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            if selectedRange.location == textStorage.length && selectedRange.length == 0{
                textStorage.append(NSAttributedString(string: "\n", attributes: typingAttributes))
            }
            
            // if the current paragraph is a checkbox and you are trying to return at the starting location of paragraph then create a checkbox above it
            if paragraphString.containsListAttachment{
                if textView.selectedRange.location == textView.paragraphRange.location,
                   textView.selectedRange.length == 0{
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
                
                
                // ( the scenario where holding the backspace and deleting text. here we are removing the attributes of the down most paragraph, otherwise the attributes will affect the paragraph above it )
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                let paragraphRange = mutableAttributedText.mutableString.paragraphRange(for: NSRange(location: selectedRange.location + selectedRange.length, length: 0))
                
                if selectedRange.length >= paragraphRange.length{
                    textStorage.removeAttribute(.listType, range: paragraphRange)
                    textStorage.removeAttribute(.indentLevel, range: paragraphRange)
                    return true
                }
                
                // removing attribute if the caret is at starting position of a paragraph
                if textView.selectedRange.location == textView.paragraphRange.location,
                   textView.selectedRange.length == 0 {

                    if textView.paragraphString.containsListAttachment{
                        textStorage.removeAttribute(.listType, range: paragraphRange)
                        leftIndent()
                        modifyList(currentRange: paragraphRange)
                        return false
                    }
                    else{
                        
                        // Paragraphs defaultly won't have this .indentLevel, so when backspacing, the above paragraph gets the indent level of current paragraph. so for the paragraphs which don't have the .indent level, we are ging a value 0 to prevent from getting overriden.
                        let range = paragraphRange.location - 1
                        if range >= 0{
                            let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range, length: 0))
                            let prevParagraph = attributedText.attributedSubstring(from: prevParagraphRange)
                            if let _ = prevParagraph.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
//                                textStorage.removeAttribute(.indentLevel, range: paragraphRange)
                            }
                            else{
                                textStorage.addAttribute(.indentLevel, value: 0, range: prevParagraphRange)
                            }
                        }
                    }
                }
                
                
                // if the previous paragraph is a checklist and empty string, then on backspacing on current paragraph(empty string), prev paragraph needs to retain its checklist.
                let range = paragraphRange.location - 1
                if range >= 0{
                    let prevParagraphRange = textStorage.mutableString.paragraphRange(for: NSRange(location: range, length: 0))
                    let prevParagraph = attributedText.attributedSubstring(from: prevParagraphRange)
                    
                    if textView.selectedRange.location == textView.paragraphRange.location,
                    textView.selectedRange.length == 0{
                        if prevParagraph.containsListAttachment && prevParagraph.string == "\n"{
                            AddListAttrOnBackSpace = true
                            
                            if let value = prevParagraph.attribute(.indentLevel, at: 0, effectiveRange: nil) as? Int{
                                indentLevelForPrevious = value
                            }
                            
                            return true
                        }
                    }

                }
                return true
                
        
            }
        }
       
        return true
        
        
    }
    
    

}

