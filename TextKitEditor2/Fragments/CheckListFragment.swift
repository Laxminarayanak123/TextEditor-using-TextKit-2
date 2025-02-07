//
//  CustomLayoutManager.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 04/12/24.
//
import UIKit


class CheckboxTextLayoutFragment: NSTextLayoutFragment {
    let checkboxSize: CGSize = CGSize(width: 24, height: 24)
    let checkBoxStrokeWidth : CGFloat = 2
    var isChecked: Bool = false
    
//    init(textElement: NSTextElement, range: NSTextRange, container: NSTextContainer, offset: CGFloat) {
//        self.offset = offset
//        super.init(textElement: textElement, range: range)
//    }
//    
//    // Required initializer (if applicable)
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    // increasing renderigSurfaceBounds bounds to draw checkbox
    override var renderingSurfaceBounds: CGRect{
        let bounds = super.renderingSurfaceBounds
        
        let rect = CGRect(origin: .init(x: -54, y: bounds.origin.y), size: .init(width: bounds.size.width + 54, height: bounds.size.height))
        
        return rect
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        
        // Draw checkbox
        let checkboxRect = CGRect(
            x: renderingSurfaceBounds.origin.x + 13,
            y:renderingSurfaceBounds.minY + 5 + (24 * 0.2),
            width: checkboxSize.width,
            height: checkboxSize.height
        )
        
        context.saveGState()
        context.setStrokeColor(UIColor.label.cgColor)
        context.setLineWidth(checkBoxStrokeWidth)
        context.stroke(checkboxRect)
        context.restoreGState()
        
        if isChecked {
            let checkmarkPath = UIBezierPath()
            let checkmarkStart = CGPoint(
                x: checkboxRect.origin.x + 4,
                y: checkboxRect.midY
            )
            let checkmarkMiddle = CGPoint(
                x: checkboxRect.midX - 2,
                y: checkboxRect.maxY - 4
            )
            let checkmarkEnd = CGPoint(
                x: checkboxRect.maxX - 4,
                y: checkboxRect.minY + 4
            )
            
            checkmarkPath.move(to: checkmarkStart)
            checkmarkPath.addLine(to: checkmarkMiddle)
            checkmarkPath.addLine(to: checkmarkEnd)
            
            context.saveGState()
            context.setStrokeColor(UIColor.label.cgColor)
            context.setLineWidth(5.0)
            context.addPath(checkmarkPath.cgPath)
            context.strokePath()
            context.restoreGState()
        }
        
        super.draw(at: point, in: context)

    }
}


