//
//  TextView.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 29/11/24.
//

import UIKit

class TextView : UITextView, UITextViewDelegate, NSTextContentManagerDelegate{
    
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
    
    var checkListButton : UIButton?
    var isCheckListEnabled : Bool = false{
        didSet{
            updateCheckListButton()
        }
    }
    
    var numberedListButton : UIButton?
    var isNumberedListEnabled : Bool = false{
        didSet{
            updateNumberedListButton()
        }
    }
    
    var leftIndentButton : UIButton?
    var leftIndentEnabled : Bool = false{
        didSet{
            updateLeftIndentButton()
        }
    }
    
    var rightIndentButton : UIButton?
    var rightIndentEnabled : Bool = true{
        didSet{
            updaterightIndentButton()
        }
    }
    
    var returnRange : NSRange?
    
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
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else {
            print("Cannot undo")
        }
        undoManager?.undo()
        
    }
    
    @objc func redoAction() {
        if undoManager?.canRedo == true {
            print("Can redo")
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else {
            print("Cannot redo")
        }
        undoManager?.redo()
        
    }
    
    override func becomeFirstResponder() -> Bool {
//        isKeyboardActive = true
        isEditable = true
        return super.becomeFirstResponder()
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

}

