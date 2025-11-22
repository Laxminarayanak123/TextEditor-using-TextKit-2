//
//  TextView_Layers.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 22/11/25.
//

import UIKit
typealias Color = UIColor

import CoreGraphics

class TextLayoutFragmentLayer: CALayer {
    var layoutFragment: NSTextLayoutFragment!
    var padding: CGFloat
    var showLayerFrames: Bool
    
    let strokeWidth: CGFloat = 2
    
    override class func defaultAction(forKey: String) -> CAAction? {
        // Suppress default opacity animations.
        return NSNull()
    }

    func updateGeometry() {
        bounds = layoutFragment.renderingSurfaceBounds
        if showLayerFrames {
            var typographicBounds = layoutFragment.layoutFragmentFrame
            typographicBounds.origin = .zero
            bounds = bounds.union(typographicBounds)
        }
        // The (0, 0) point in layer space should be the anchor point.
        anchorPoint = CGPoint(x: -bounds.origin.x / bounds.size.width, y: -bounds.origin.y / bounds.size.height)
        position = layoutFragment.layoutFragmentFrame.origin
//        var newBounds = bounds
//
//        // On macOS 14 and iOS 17, NSTextLayoutFragment.renderingSurfaceBounds is properly relative to the NSTextLayoutFragment's
//        // interior coordinate system, and so this sample no longer needs the inconsistent x origin adjustment.
//        if #unavailable(iOS 17, macOS 14) {
//            newBounds.origin.x += position.x
//        }
//        bounds = newBounds
//        position.x += padding
    }
    
    init(layoutFragment: NSTextLayoutFragment, padding: CGFloat) {
        self.layoutFragment = layoutFragment
        self.padding = padding
        showLayerFrames = false
        super.init()
        contentsScale = 2
        updateGeometry()
        setNeedsDisplay()
    }
    
    override init(layer: Any) {
        guard let tlfLayer = layer as? TextLayoutFragmentLayer else {
            fatalError("The type of `layer` needs to be TextLayoutFragmentLayer.")
        }
        layoutFragment = tlfLayer.layoutFragment
        padding = tlfLayer.padding
        showLayerFrames = tlfLayer.showLayerFrames
        super.init(layer: layer)
        updateGeometry()
        setNeedsDisplay()
    }
    
    required init?(coder: NSCoder) {
        layoutFragment = nil
        padding = 0
        showLayerFrames = false
        super.init(coder: coder)
    }
    
    
    override func draw(in ctx: CGContext) {
        layoutFragment.draw(at: /*.init(x: -5, y: 5)*/.zero, in: ctx)
        
        
//        ctx.saveGState()
        
//        ctx.setFillColor(UIColor.blue.cgColor)
//
//        ctx.fill(frame)
        
//        ctx.restoreGState()
        
        if showLayerFrames {
            let inset = 0.5 * strokeWidth
            // Draw rendering surface bounds.
            ctx.setLineWidth(strokeWidth)
            ctx.setStrokeColor(renderingSurfaceBoundsStrokeColor.cgColor)
            ctx.setLineDash(phase: 0, lengths: []) // Solid line.
            ctx.stroke(layoutFragment.renderingSurfaceBounds.insetBy(dx: inset, dy: inset))
            
            // Draw typographic bounds.
            ctx.setStrokeColor(typographicBoundsStrokeColor.cgColor)
            ctx.setLineDash(phase: 0, lengths: [strokeWidth, strokeWidth]) // Square dashes.
            var typographicBounds = layoutFragment.layoutFragmentFrame
            typographicBounds.origin = .zero
            ctx.stroke(typographicBounds.insetBy(dx: inset, dy: inset))
        }
    }
    
    var renderingSurfaceBoundsStrokeColor: Color { return .systemOrange }
    var typographicBoundsStrokeColor: Color { return .systemPurple }
}


class TextDocumentLayer: CALayer {
    override class func defaultAction(forKey event: String) -> CAAction? {
        // Suppress default animation of opacity when adding comment bubbles.
        return NSNull()
    }
}
