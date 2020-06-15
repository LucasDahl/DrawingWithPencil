//
//  ViewController.swift
//  DrawingWithPencil
//
//  Created by Lucas Dahl on 6/14/20.
//  Copyright © 2020 Lucas Dahl. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    //===================
    // MARK: - Properties
    //===================
    
    
    // Constants
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHight: CGFloat = 500
    
    // Variables
    var drawing = PKDrawing()
    
    // Outlets
    @IBOutlet weak var pencilToFinger: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    
    //===============
    // MARK: Override
    //===============
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            
            // Set the firstResponder and visable status
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            
            // Add an observer
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Helps reset teh canvas view when the screnn size changes
        let canvasScale = canvasView.bounds.width / canvasWidth
        
        // Set the canvasView
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        // Update the content size for the drawing
        updateContentSizeForDrawing()
        
        // Call to the top
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
        
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }
    
    //================
    // MARK: Functions
    //================
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        
        updateContentSizeForDrawing()
        
    }
    
    func updateContentSizeForDrawing() {
        
        // Function properties
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        // Check the bounds of the drawing.
        if !drawing.bounds.isNull {
            
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHight) * canvasView.zoomScale)
            
        } else {
            
            contentHeight = canvasView.bounds.height
            
        }
        
        // Set the content size
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
        
    }
  

    //=================
    // MARK: IB Actions
    //=================
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        
        // Create the image.
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        // Get the image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save the image
        if image != nil {
            
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
                
            }, completionHandler: {success, error in
                
                // Deal with sucess or error
                
            })
            
        }
        
        
    }
    
    @IBAction func toggleFingerOrPencil(_ send: Any) {
         
        // Allows the user to switch from finger to pencil drawing.
        canvasView.allowsFingerDrawing.toggle()
        
        // Switch the title of the bar button based of what the user is using
        pencilToFinger.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
         
     }
    
}

