//
//  ViewController.swift
//  Plarail_opencv
//
//  Created by 小嶺愛紀菜 on 2018/10/19.
//  Copyright © 2018年 小嶺愛紀菜. All rights reserved.
//

import UIKit

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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
