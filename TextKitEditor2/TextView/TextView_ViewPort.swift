//
//  TextView_ViewPort.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 22/11/25.
//

import UIKit

extension TextView : NSTextViewportLayoutControllerDelegate {
    
    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        
        CGRect(origin: .init(x: 0, y: contentOffset.y), size: bounds.size)
    }
    
    func textViewportLayoutControllerWillLayout(_ controller: NSTextViewportLayoutController) {
        contentLayer.sublayers = nil
        CATransaction.begin()
    }
    
    
    func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController,
                                      configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
        let (textLayoutFragmentLayer, didCreate) = findOrCreateLayer(textLayoutFragment)
        if !didCreate {
            let oldPosition = textLayoutFragmentLayer.position
            let oldBounds = textLayoutFragmentLayer.bounds
            textLayoutFragmentLayer.updateGeometry()
            if oldBounds != textLayoutFragmentLayer.bounds {
                textLayoutFragmentLayer.setNeedsDisplay()
            }
            if oldPosition != textLayoutFragmentLayer.position {
                animate(textLayoutFragmentLayer, from: oldPosition, to: textLayoutFragmentLayer.position)
            }
        }
        
        contentLayer.addSublayer(textLayoutFragmentLayer)
    }
    
    func textViewportLayoutControllerDidLayout(_ controller: NSTextViewportLayoutController) {
        CATransaction.commit()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        assert(layer == self.layer)
        if let tlm = textLayoutManager{
            tlm.textViewportLayoutController.layoutViewport()
        }
        
        contentLayer.frame = CGRect(origin: .zero, size: contentSize)
    }
    
    
    func findOrCreateLayer(_ textLayoutFragment: NSTextLayoutFragment) -> (TextLayoutFragmentLayer, Bool) {
        if let layer = fragmentLayerMap.object(forKey: textLayoutFragment) as? TextLayoutFragmentLayer {
            return (layer, false)
        } else {
            let layer = TextLayoutFragmentLayer(layoutFragment: textLayoutFragment, padding: padding)
            fragmentLayerMap.setObject(layer, forKey: textLayoutFragment)
            return (layer, true)
        }
    }
    
    
    
    func animate(_ layer: CALayer, from source: CGPoint, to destination: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = source
        animation.toValue = destination
        animation.duration = 0.6
        layer.add(animation, forKey: nil)
    }
    
}
