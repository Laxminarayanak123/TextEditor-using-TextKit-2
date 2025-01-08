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
        
    var previousListParagraphRange : NSRange?
    
    var boldButton: UIButton?
    var isBoldEnabled: Bool = false {
        didSet {
            updateBoldButton()
        }
    }
    
    var italicButton: UIButton?
    var isItalicEnabled: Bool = false {
        didSet {
            updateItalicButton()
        }
    }
    
    var underlineButton: UIButton?
    var isUnderlineEnabled: Bool = false {
        didSet {
            updateUnderlineButton()
        }
    }
    
    var strikeThroughButton: UIButton?
    var isStrikeThroughEnabled : Bool = false {
        didSet {
            updateStrikeButton()
        }
    }
    
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
        let font =  UIFont.systemFont(ofSize: 24)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = font.pointSize * 0.15
//        paragraphStyle.headIndent = 30
//        paragraphStyle.firstLineHeadIndent = 30
        
        typingAttributes = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.label
        ]
        
        
        let string1 = "When you try your best, but you don't succeed\nWhen you get what you want, but not what you need\nWhen you feel so tired, but you can't sleep\nStuck in reverse\nAnd the tears come streaming down your face\nWhen you lose something you can't replace\nWhen you love someone, but it goes to waste\nCould it be worse?\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nAnd high up above, or down below\nWhen you're too in love to let it go\nBut if you never try, you'll never know\nJust what you're worth\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nTears stream down your face\nWhen you lose something you cannot replace\nTears stream down your face, and I\nTears stream down your face\nI promise you I will learn from my mistakes\nTears stream down your face, and I\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nWhen you try your best, but you don't succeed\nWhen you get what you want, but not what you need\nWhen you feel so tired, but you can't sleep\nStuck in reverse\nAnd the tears come streaming down your face\nWhen you lose something you can't replace\nWhen you love someone, but it goes to waste\nCould it be worse?\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nAnd high up above, or down below\nWhen you're too in love to let it go\nBut if you never try, you'll never know\nJust what you're worth\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nTears stream down your face\nWhen you lose something you cannot replace\nTears stream down your face, and I\nTears stream down your face\nI promise you I will learn from my mistakes\nTears stream down your face, and I\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you"
        
        let _ = ""
        
        let attributedString = NSMutableAttributedString(
            string: string1,
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
        )
        
        textStorage.setAttributedString(attributedString)
        
        }
    

//    private func createToolbar() -> UIToolbar {
//            let toolbar = UIToolbar()
//            toolbar.items = [
//                UIBarButtonItem(title: "ToggleSelected", style: .plain, target: self, action: #selector(toggleSelected)),
//                UIBarButtonItem(title: "left", style: .plain, target: self, action: #selector(leftIndent)),
//                UIBarButtonItem(title: "Tap Gest", style: .plain, target: self, action: #selector(toggleTap)),
//                UIBarButtonItem(title: "right", style: .plain, target: self, action: #selector(rightIndent)),
//                UIBarButtonItem(title: "number", style: .plain, target: self, action: #selector(toggleNumberList)),
//            ]
//            toolbar.sizeToFit()
//            return toolbar
//        }
    
    @objc func undoAction() {
        if undoManager?.canUndo == true {
            print("Can undo")
        } else {
            print("Cannot undo")
        }
        undoManager?.undo()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc func redoAction() {
        if undoManager?.canRedo == true {
            print("Can redo")
        } else {
            print("Cannot redo")
        }
        undoManager?.redo()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    
//    func setMyObjectTitle(_ newTitle: String) {
//        let currentTitle = o1.title
//        if newTitle != currentTitle {
//            undoManager?.registerUndo(withTarget: self) { target in
//                target.setMyObjectTitle(currentTitle)
//            }
//            undoManager?.setActionName(NSLocalizedString("Title Change", comment: "title undo"))
//            o1.title = newTitle
//        }
//    }
   

    func toggleSelected(range : NSRange){
        
        if (selectedRange.location == textStorage.length && selectedRange.length == 0 ) || (selectedRange.upperBound == textStorage.length){
            newLineAtLast(append: true, range : range, toggle: true)
        }
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let paraString = textStorage.attributedSubstring(from: paragraphRange)
        

        if let _ = paraString.attribute(.listType, at: 0, effectiveRange: nil) as? String{
            
            textStorage.removeAttribute(.listType, range: paragraphRange)

            leftIndentForListToggle(range: paragraphRange)
        }
        else{
            if let _ = paragraphString.NumberedListIndex{
                toggleNumberList(range: range)
            }
            textStorage.addAttribute(.listType, value: "checkList", range: paragraphRange)
           
            rightIndentForListToggle(range: paragraphRange)
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleSelected(range: paragraphRange)
        })
        
        undoManager?.setActionName("From Toggle")
        
        

    }
    
    func toggleNumberList(range : NSRange){
        if (selectedRange.location == textStorage.length && selectedRange.length == 0 ) || (selectedRange.upperBound == textStorage.length){
            newLineAtLast(append: true, range : range, toggle: true)
        }
        
        let paragraphRange = textStorage.mutableString.paragraphRange(for: range)
        let paraString = textStorage.attributedSubstring(from: paragraphRange)
        
        if let _ = paraString.attribute(.listType, at: 0, effectiveRange: nil) as? Int{
            // if it is already a numbered list
            leftIndentForListToggle(range: paragraphRange)
            textStorage.removeAttribute(.listType, range: paragraphRange)
            
            modifyList(currentRange: paragraphRange, updateSelf: false)
        }
        else{
           // if it is not a numbered list
            if paraString.containsListAttachment && paraString.NumberedListIndex == nil{
                toggleSelected(range: range)
            }
            rightIndentForListToggle(range: paragraphRange)
            
            textStorage.addAttribute(.listType, value: 0, range: paragraphRange)
            
            modifyList(currentRange: paragraphRange, updateSelf: true)
        }
        
        

        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.toggleNumberList(range: paragraphRange)
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
    
   
    

}

