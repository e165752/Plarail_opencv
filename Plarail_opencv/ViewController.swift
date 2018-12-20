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
    
    func cropping(to: CGRect) -> UIImage? {
        var opaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(to.size, opaque, scale)
        draw(at: CGPoint(x: -to.origin.x, y: -to.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func flipImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let bitmap = UIGraphicsGetCurrentContext()!
        
        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        bitmap.scaleBy(x: -1.0, y: -1.0)
        
        bitmap.translateBy(x: -size.width / 2, y: -size.height / 2)
        bitmap.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var SaveImage = UIImage()
    var nextImage2 = UIImage()
    //画面サイズ
    let mainBoundSize: CGSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var returnButton: UIButton!
    
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
        
        
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func FixPicture(_ sender: Any) {
        
        startIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
         self.fix()
        }
    }
    
    @objc func fix() {
        
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
            
            //            cameraView.image = AfterImage
            cameraView.image = beforeImage.mask(image: AfterImage)
            //            SaveImage = beforeImage.mask(image: AfterImage)
            
            stopIndicator()
            // アラート
            let actionSheet = UIAlertController(title: "加工完了", message: "この画像を保存しますか？", preferredStyle: UIAlertController.Style.actionSheet)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "保存", style: UIAlertAction.Style.default, handler: {
                
                (action: UIAlertAction!) -> Void in
                self.SaveImage = beforeImage.mask(image: AfterImage)
                self.SavePicture()
            })
            
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.destructive, handler: {
                (action: UIAlertAction!) -> Void in
                print("キャンセル")
                self.dismiss(animated: true, completion: nil)
                
            })
            
            
            actionSheet.addAction(defaultAction)
            actionSheet.addAction(cancelAction)
            
            
            // iPadでは必須！
            actionSheet.popoverPresentationController?.sourceView = self.view
            
            
            let screenSize = UIScreen.main.bounds
            // ここで表示位置を調整
            // xは画面中央、yは画面下部になる様に指定
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            
            self.present(actionSheet, animated: true, completion: nil)
            //            ここまで
            
            
        }
        
    }
    
    func SavePicture() {
        
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
        
    }
    
    // 書き込み完了結果の受け取り
    @objc func image(_ image: UIImage,
                     didFinishSavingWithError error: NSError!,
                     contextInfo: UnsafeMutableRawPointer) {
    
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
            
        }
        
    }
    
    @IBAction func returnButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.frame = CGRect(x: mainBoundSize.width/10,y: mainBoundSize.height/6,width: (mainBoundSize.width/5)*4,height: (mainBoundSize.height/5)*3)
        //画像のリサイズ
        nextImage2 = nextImage2.ResizeUIImage(width: 1668, height: 2224)
        //画像の切り取り
        nextImage2 = nextImage2.cropping(to: CGRect(x: 166,y: 600,width: 1328,height: 1034))!
        cameraView.image = nextImage2
        
        selectButton.layer.borderWidth = 1.0                                              // 枠線の幅
        selectButton.layer.borderColor = UIColor.blue.cgColor                            // 枠線の色
        selectButton.layer.cornerRadius = 5.0
        let rgba = UIColor(red: 255/255, green: 160/255, blue: 0/255, alpha: 0.2
        ) // ボタン背景色設定
        selectButton.backgroundColor = rgba
        
        returnButton.layer.borderWidth = 1.0                                              // 枠線の幅
        returnButton.layer.borderColor = UIColor.blue.cgColor                            // 枠線の色
        returnButton.layer.cornerRadius = 5.0
    
        returnButton.backgroundColor = rgba
        
        
        // indicatorのframeを作成
        indicator.frame = CGRect(x:0, y:0, width:200, height:200)
        
        // frameを角丸にする場合は数値調整
        indicator.layer.cornerRadius = 8
        
        // indicatorのstyle（color）を設定
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        
        // indicatorのbackgroundColorを設定
        indicator.backgroundColor = UIColor.black
        
        // indicatorの配置を設定
        indicator.layer.position = CGPoint(x: self.view.bounds.width/2, y: mainBoundSize.height/2)
        
        // indicatorのアニメーションが終了したら自動的にindicatorを非表示にするか否かの設定
        indicator.hidesWhenStopped = true
        
        // viewにindicatorを追加
        self.view.addSubview(indicator)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startIndicator() {
        
        // indicatorのアニメーションを開始
        indicator.startAnimating()
        
        // viewにindicatorを追加
        self.view.addSubview(indicator)
        //self.view.bringSubviewToFront(indicator)
        
    }
    
    @objc func stopIndicator() {
        // indicatorのアニメーションを終了
        indicator.stopAnimating()
    }
    
    
    @IBOutlet weak var cameraView : UIImageView!
    
    @IBAction func startCamera(_ sender : AnyObject) {
        
    }
    

}
