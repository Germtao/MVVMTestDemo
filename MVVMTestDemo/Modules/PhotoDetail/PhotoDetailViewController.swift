//
//  PhotoDetailViewController.swift
//  MVVMTestDemo
//
//  Created by QDSG on 2019/12/4.
//  Copyright © 2019 unitTao. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    var imageUrl: String?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.kf.setImage(with: URL(string: imageUrl ?? "" ), placeholder: nil, options: [.memoryCacheExpiration(.expired)], progressBlock: nil) { result in
            guard let image = try? result.get().image else { return }
            
            let scrollViewFrame = self.scrollView.frame
            let scaleWidth = scrollViewFrame.size.width / image.size.width
            let scaleHeight = scrollViewFrame.size.height / image.size.height
            let minScale = min(scaleWidth, scaleHeight)
            self.scrollView.minimumZoomScale = minScale
            DispatchQueue.main.async {
                self.scrollView.zoomScale = minScale
            }
        }
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
