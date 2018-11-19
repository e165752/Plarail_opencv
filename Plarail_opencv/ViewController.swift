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
    func mask(image: UIImage) -> UIImage {
        if let maskRef = image.cgImage,
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
    
    func ResizeUIImage(width : CGFloat, height : CGFloat)-> UIImage!{
        // 引数の画像の大きさのコンテキスト作成
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        // コンテキストに画像を描く
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        // コンテキストからUIImageを作成
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // コンテキストを閉じる
        UIGraphicsEndImageContext()
        return newImage
    }
}



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var SaveImage = UIImage()
    
    //@IBOutlet weak var BeforeImage: UIImageView!
    
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var StartCamera: UIButton!
    
    @IBAction func StartCamera(_ sender: Any) {
        
        let sourceType:UIImagePickerController.SourceType =
            UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        else{
            label.text = "error"
            
        }
        
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let pickedImage = info[.originalImage]
            as? UIImage {
            
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = pickedImage
            
        }
        
        //閉じる処理
        imagePicker.dismiss(animated: true, completion: nil)
        label.text = "Tap the [Save] to save a picture"
        
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        label.text = "Canceled"

    }
    
    @IBAction func FixPicture(_ sender: Any) {
        
        var image:UIImage! = cameraView.image
       
        
        //この下の４行が勝手に画像の向きを変えるのを阻止してる
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(in:(CGRect(x:0,y:0,width:image.size.width,height:image.size.height)))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if image != nil {
            
            
            var beforeImage:UIImage = image
            //let beforeImage:UIImage? = image
            
            UIGraphicsBeginImageContextWithOptions(beforeImage.size, false, 0.0)
            beforeImage.draw(in:(CGRect(x:0,y:0,width:beforeImage.size.width,height:beforeImage.size.height)))
            beforeImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            let AfterImage:UIImage = OpenCVManager.grayScale(image)
            
//            cameraView.image = beforeImage.mask(image: AfterImage)
//            SaveImage = beforeImage.mask(image: AfterImage)
            
            
        }
        else {
            label.text = "Fix Failed !"
        }
    }
    
    
    
    
    @IBAction func SavePicture(_ sender: Any) {
        
        let image:UIImage! = cameraView.image
        
        SaveImage = SaveImage.ResizeUIImage(width: 500, height: 500)
        
        UIGraphicsBeginImageContext(SaveImage.size)
        // バッファにImageを描画。
        SaveImage.draw(at: CGPoint(x: 0.0, y: 0.0))
        // バッファからUIImageを生成。
        let nonLayerImage = UIGraphicsGetImageFromCurrentImageContext()
        // バッファを解放。
        UIGraphicsEndImageContext()
        // PNGフォーマットのNSDataをUIImageから作成。
        let data = nonLayerImage!.pngData()
        let FinishImage = UIImage(data: data!)
        //FinishImage = FinishImage!.ResizeUIImage(width: 500, height: 500)
        
        if image != nil {
            UIImageWriteToSavedPhotosAlbum(
                FinishImage!,
                self,
                #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)),
                nil)
        }
        else{
            label.text = "image Failed !"
        }
        
    }
    
    // 書き込み完了結果の受け取り
    @objc func image(_ image: UIImage,
                     didFinishSavingWithError error: NSError!,
                     contextInfo: UnsafeMutableRawPointer) {
        
        if error != nil {
            print(error.code)
            label.text = "Save Failed !"
        }
        else{
            label.text = "Save Succeeded"
        }
    }
    
    
    
    @IBAction func ShowAlbum(_ sender: Any) {
        
        let sourceType:UIImagePickerController.SourceType =
            UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
            label.text = "Tap the [Start] to save a picture"
        }
        else{
            label.text = "error"
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "push Start"
        /*
        BeforeImage.image = UIImage(named: "train")

        // Do any additional setup after loading the view, typically from a nib.
        let image = BeforeImage.image;
        let gray = OpenCVManager.grayScale(image)
        AfterImage.image = gray;
        
        AfterImage.image = UIImage(named: "train")?.mask(image: AfterImage.image)
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var cameraView : UIImageView!
    
    
    
    @IBAction func startCamera(_ sender : AnyObject) {
        
        
        
        
    }
    

}





