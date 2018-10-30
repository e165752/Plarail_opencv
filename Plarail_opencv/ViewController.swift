//
//  ViewController.swift
//  Plarail_opencv
//
//  Created by 小嶺愛紀菜 on 2018/10/19.
//  Copyright © 2018年 小嶺愛紀菜. All rights reserved.
//

import UIKit

/* マスク処理 */
extension UIImage {
    func mask(image: UIImage?) -> UIImage {
        if let maskRef = image?.cgImage,
            let ref = cgImage,
            let mask = CGImage(maskWidth: maskRef.width,
                               height: maskRef.height,
                               bitsPerComponent: maskRef.bitsPerComponent,
                               bitsPerPixel: maskRef.bitsPerPixel,
                               bytesPerRow: maskRef.bytesPerRow,
                               provider: maskRef.dataProvider!,
                               decode: nil,
                               shouldInterpolate: false),
            let output = ref.masking(mask) {
            return UIImage(cgImage: output)
        }
        return self
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var BeforeImage: UIImageView!
    
    @IBOutlet weak var AfterImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BeforeImage.image = UIImage(named: "train")

        // Do any additional setup after loading the view, typically from a nib.
        let image = BeforeImage.image;
        let gray = OpenCVManager.grayScale(image)
        AfterImage.image = gray;
        
        AfterImage.image = UIImage(named: "train")?.mask(image: AfterImage.image)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
