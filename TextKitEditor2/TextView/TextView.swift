//
//  TextView.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 29/11/24.
//

import UIKit

class TextView : UITextView, UITextViewDelegate, NSTextContentManagerDelegate{
    
    var textContentStorage : NSTextContentStorage!
    
    var tapGesture : UITapGestureRecognizer!
    
    var previousListParagraphRange : NSRange?
    
    var returnRange : NSRange?
    
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
            updateStrikeThroughButton()
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
    
    var bulletListButton : UIButton?
    var isBulletListEnabled : Bool = false{
        didSet{
            updateBulletListButton()
        }
    }
    
    var leftIndentButton : UIButton?
    var isLeftIndentEnabled : Bool = false{
        didSet{
            updateLeftIndentButton()
        }
    }
    
    var rightIndentButton : UIButton?
    var isRightIndentEnabled : Bool = true{
        didSet{
            updaterightIndentButton()
        }
    }
    
    var slowAnimations: Bool = false

    
    // new viewport implementation
    var renderingViews_Container: PassThroughOverlayView!
    

    var fragmentRenderingViewMap = NSMapTable<NSTextLayoutFragment, TextRenderingView>.weakToWeakObjects()

    var padding: CGFloat = 5.0
    
    let checkboxViews_Container = PassThroughOverlayView()
    
    let fragmentCheckBoxViewMap = NSMapTable<NSTextLayoutFragment, UIView>.weakToWeakObjects()
    
    var oldCheckBoxFragmentMap: [NSTextLayoutFragment : UIView] = [:]
    
    var newCheckBoxFragmentMap: [NSTextLayoutFragment : UIView] = [:]
    
    var oldRenderingViewMap: [NSTextLayoutFragment : TextRenderingView] = [:]
    
    var newRenderingViewMap: [NSTextLayoutFragment : TextRenderingView] = [:]
    
    var isDraggingCheckbox: Bool = false
    
    
    // for autosorting
    var allcheckboxes : [checkboxItem] = []

    var checkedCheckboxes : [checkboxItem] = []
    
    var uncheckedCheckboxes : [checkboxItem] = []
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
            
        super.init(frame: frame, textContainer: textContainer)
        textContainerInset.left = frame.width * 0.05
        textContainerInset.right = frame.width * 0.05
        
        textLayoutManager?.delegate = self
        textLayoutManager?.textViewportLayoutController.delegate = self
//        updateContentSizeIfNeeded()
//        updateTextContainerSize()
        layer.setNeedsLayout()

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
        
        contentInset.bottom = 400
        
        // new viewport implementation
        configureRenderingViewsContainer()

        configureCheckboxViewsContainer()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureRenderingViewsContainer() {
        guard renderingViews_Container == nil else { return }
        let view = PassThroughOverlayView()
        view.contentScaleFactor = UIScreen.main.scale
        view.clipsToBounds = true
        view.isOpaque = false
        renderingViews_Container = view
        addSubview(renderingViews_Container)
    }
    
    func configureCheckboxViewsContainer() {
        //        overlayView.backgroundColor = .green.withAlphaComponent(0.3)
        checkboxViews_Container.isUserInteractionEnabled = true
        addSubview(checkboxViews_Container)
        checkboxViews_Container.frame = bounds
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainerInset.left = frame.width * 0.05
        textContainerInset.right = frame.width * 0.05
        
        if let tlm = textLayoutManager {
            tlm.textViewportLayoutController.layoutViewport()
        }
        
        updateContentSizeIfNeeded()
        let contentFrame = CGRect(origin: .init(x: textContainerInset.left, y: textContainerInset.top), size: contentSize)
        renderingViews_Container.frame = contentFrame
        checkboxViews_Container.frame = contentFrame
    }
    
    
    private func setupTextView() {
        let font =  UIFont.systemFont(ofSize: 24)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = font.pointSize * 0.15
        
        typingAttributes = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.label
        ]

        let string1 = "When you try your best, but you don't succeed\nWhen you get what you want, but not what you need\nWhen you feel so tired, but you can't sleep\nStuck in reverse\nAnd the tears come streaming down your face\nWhen you lose something you can't replace\nWhen you love someone, but it goes to waste\nCould it be worse?\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nAnd high up above, or down below\nWhen you're too in love to let it go\nBut if you never try, you'll never know\nJust what you're worth\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nTears stream down your face\nWhen you lose something you cannot replace\nTears stream down your face, and I\nTears stream down your face\nI promise you I will learn from my mistakes\nTears stream down your face, and I\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nWhen you try your best, but you don't succeed\nWhen you get what you want, but not what you need\nWhen you feel so tired, but you can't sleep\nStuck in reverse\nAnd the tears come streaming down your face\nWhen you lose something you can't replace\nWhen you love someone, but it goes to waste\nCould it be worse?\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nAnd high up above, or down below\nWhen you're too in love to let it go\nBut if you never try, you'll never know\nJust what you're worth\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you\nTears stream down your face\nWhen you lose something you cannot replace\nTears stream down your face, and I\nTears stream down your face\nI promise you I will learn from my mistakes\nTears stream down your face, and I\nLights will guide you home\nAnd ignite your bones\nAnd I will try to fix you"
        
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
    
}

