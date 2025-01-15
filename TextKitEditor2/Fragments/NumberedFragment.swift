//
//  NumberedFragment.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 19/12/24.
//
import UIKit

class NumberedListTextLayoutFragment : NSTextLayoutFragment {
     let numberPadding: CGFloat = 5
     var number: Int = 0
    
    init(textElement: NSTextElement, range: NSTextRange, number: Int) {
            self.number = number
            super.init(textElement: textElement, range: range)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // increasing renderigSurfaceBounds bounds to draw checkbox
    override var renderingSurfaceBounds: CGRect {
        let bounds = super.renderingSurfaceBounds
        let rect = CGRect(origin: .init(x: -54, y: bounds.origin.y),
                          size: .init(width: bounds.size.width + 54, height: bounds.size.height))
        return rect
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        
        let font = UIFont.systemFont(ofSize: 21)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
        ]
        
        let numberString = "\(number)."
        let numberSize = numberString.size(withAttributes: attributes)
        
        let numberRect = CGRect(
            x: (renderingSurfaceBounds.origin.x) + (number > 99 ? 0.0 : 13.0), // hardCoded.
            y: renderingSurfaceBounds.origin.y + numberPadding + (font.pointSize * 0.2),
            width: 54,
            height: numberSize.height
        )
        
        // Draw the number
        context.saveGState()
        numberString.draw(
            in: numberRect,
            withAttributes: attributes
        )
        context.restoreGState()
        
        super.draw(at: point, in: context)
    }
}
