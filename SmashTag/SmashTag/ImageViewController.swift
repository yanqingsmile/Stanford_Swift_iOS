//
//  ImageViewController.swift
//  SmashTag
//
//  Created by Vivian Liu on 12/23/16.
//  Copyright © 2016 Vivian Liu. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    //var imageView = UIImageView()
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tweet Image"
        updateUI()

        
    }
    
    private func updateUI() {
        imageView.image = image
        imageView.sizeToFit()
        imageScrollView.contentSize = imageView.frame.size
        imageScrollView.delegate = self
        imageScrollView.minimumZoomScale = 0.5
        imageScrollView.maximumZoomScale = 2.0
        imageScrollView?.contentSize = imageView.frame.size
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
