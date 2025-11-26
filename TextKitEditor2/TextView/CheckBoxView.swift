//
//  FragmentView.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 25/11/25.
//

import UIKit

class PassThroughOverlayView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        
        return view == self ? nil : view
    }
}


class CheckBoxView: UIView, UIDragInteractionDelegate {
    weak var textLayoutFragment: NSTextLayoutFragment?
    weak var textView: TextView?
    
    var isChecked: Bool = false
    
    let boxLayer = CAShapeLayer()
    let checkLayer = CAShapeLayer()


    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        setupLayers()
    }
    
    var tapGesture: UITapGestureRecognizer!
    
    let checkboxSize: CGSize = CGSize(width: 32, height: 32)

     func commonInit() {
        backgroundColor = .clear
        
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        addInteraction(dragInteraction)
        isUserInteractionEnabled = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {

        if let textview = textView, let fragment = textLayoutFragment as? CheckboxTextLayoutFragment, let element = fragment.textElement, let textRange = element.elementRange {
            let range = NSRange(textRange, contentManager: textview.textContentStorage)

            self.isChecked = !fragment.isChecked
            animateCheckmarkChange()

            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ){
                textview.toggleCheckBoxState(paragraphRange: range)
            }
        }
    }
    
    private func setupLayers() {
        backgroundColor = .clear
        
        // BOX
        boxLayer.strokeColor = UIColor.label.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor
        boxLayer.lineWidth = 2
        layer.addSublayer(boxLayer)
        
        // CHECKMARK
        checkLayer.strokeColor = UIColor.yellow.cgColor
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.lineWidth = 5
        checkLayer.lineCap = .round
        checkLayer.lineJoin = .round
        checkLayer.strokeEnd = 0          // hidden initially
        layer.addSublayer(checkLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boxRect = CGRect(origin: bounds.origin, size: checkboxSize)
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 4)
        boxLayer.path = path.cgPath
        boxLayer.frame = bounds
        
        // CHECKMARK PATH (✓)
        let p1 = CGPoint(x: boxRect.minX + boxRect.width * 0.20,
                         y: boxRect.midY)
        let p2 = CGPoint(x: boxRect.midX - 2,
                         y: boxRect.maxY - boxRect.height * 0.22)
        let p3 = CGPoint(x: boxRect.maxX - boxRect.width * 0.18,
                         y: boxRect.minY - 5)
        
        let checkPath = UIBezierPath()
        checkPath.move(to: p1)
        checkPath.addLine(to: p2)
        checkPath.addLine(to: p3)
        
        checkLayer.path = checkPath.cgPath
        checkLayer.frame = bounds
    }
    
    // MARK: - Animation
    
    func animateCheckmarkChange() {
        let target = isChecked ? 1.0 : 0.0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = checkLayer.presentation()?.strokeEnd ?? checkLayer.strokeEnd
        animation.toValue = target
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        checkLayer.add(animation, forKey: "strokeEndAnim")
        
        checkLayer.strokeEnd = target   // important to keep the final state
    }
    
    func check(){
        checkLayer.strokeEnd = 1.0
    }
    
    func unCheck(){
        checkLayer.strokeEnd = 0.0
    }

    // MARK: - UIDragInteractionDelegate
    
    // Called when user long-presses to start a drag
    func dragInteraction(_ interaction: UIDragInteraction,
                         itemsForBeginning session: UIDragSession) -> [UIDragItem] {

        
        guard let textview = textView, let fragment = textLayoutFragment as? CheckboxTextLayoutFragment, let element = fragment.textElement, let textRange = element.elementRange else{ return [] }
        
        let range = NSRange(textRange, contentManager: textview.textContentStorage)
        
        let attrString = textview.textStorage.attributedSubstring(from: range)
        
//        let string = "Hello"
        let provider = NSItemProvider(object: attrString as NSAttributedString)

        
        let item = UIDragItem(itemProvider: provider)

        
        item.localObject = attrString.string

        return [item]
    }

    // Optional: custom preview
    func dragInteraction(_ interaction: UIDragInteraction,
                         previewForLifting item: UIDragItem,
                         session: UIDragSession) -> UITargetedDragPreview? {

        let parameters = UIDragPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)

        return UITargetedDragPreview(view: self, parameters: parameters)
    }
    
    
    func dragInteraction(_ interaction: UIDragInteraction, session: any UIDragSession, didEndWith operation: UIDropOperation) {
        textView?.isDraggingCheckbox = false
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: any UIDragSession) {
        textView?.isDraggingCheckbox = true
    }
    
}
