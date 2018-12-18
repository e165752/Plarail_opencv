//
//  CameraViewController.swift
//  Plarail_opencv
//
//  Created by  岩永　竜也 on 2018/12/16.
//  Copyright © 2018 小嶺愛紀菜. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController,AVCapturePhotoCaptureDelegate {

    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let mainBoundSize: CGSize = UIScreen.main.bounds.size
    let mainNativeBoundSize: CGSize = UIScreen.main.nativeBounds.size
    let camera_image:UIImage = UIImage(named: "button.png")!
    
    @IBOutlet weak var CameraView: UIImageView!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var textBorder: UITextField!
    @IBOutlet weak var CameraLabel: UILabel!
    @IBOutlet weak var text2: UITextField!
    
    
    //画面遷移する際に画像を保存する変数
    var nextImage1 = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CameraView.frame = CGRect(x:0,y:20,width:834,height:1092)
        //カメラの枠の色とサイズ設定
        textBorder.layer.borderWidth = 5.0
        textBorder.layer.borderColor = UIColor.green.cgColor
        //textBorder.frame = CGRect(x: 57,y: 196,width: 721,height: 721)
        textBorder.frame = CGRect(x: mainBoundSize.width/10,y: mainBoundSize.height/5,width: (mainBoundSize.width/5)*4,height: (mainBoundSize.height/5)*3)
        textBorder.isEnabled = false;
        //進行方向を教えるテキスト
        text2.frame = CGRect(x: (mainBoundSize.width/2)-50, y:150, width: 100, height: 60)
        text2.text = "前　 ⬅︎ "
        text2.textColor = UIColor.blue
        text2.font = UIFont.systemFont(ofSize: 36)
        text2.textAlignment = NSTextAlignment.center
        
        //ラベルのスタイル設定
        CameraLabel.frame = CGRect(x: mainBoundSize.width/4, y: 50, width: 450, height: 80)
        CameraLabel.text = "枠の中に絵を入れてください"
        CameraLabel.textColor = UIColor.black
        CameraLabel.font = UIFont.systemFont(ofSize: 36)
        CameraLabel.backgroundColor = UIColor.white
        CameraLabel.textAlignment = NSTextAlignment.center
        CameraLabel.layer.cornerRadius = 3
        CameraLabel.clipsToBounds = true
        
        //カメラボタンのスタイル設定
        /*
        CameraButton.layer.borderColor = UIColor.white.cgColor
        CameraButton.layer.borderWidth = 5
        CameraButton.clipsToBounds = true
        */
        CameraButton.setImage(camera_image, for: .normal)
        CameraButton.frame = CGRect(x: (mainBoundSize.width/2)-40, y: mainBoundSize.height-85, width: 80, height: 80)
        
        //CameraButton.backgroundColor = UIColor.init(
            //red:1, green: 1, blue: 1, alpha: 1)
        //CameraButton.layer.cornerRadius = min(CameraButton.frame.width, CameraButton.frame.height) / 2
        self.view.sendSubviewToBack(CameraView)
        
        CameraView.frame = CGRect(x: 0, y: 0, width: mainBoundSize.width, height: mainBoundSize.height)
        
        captureSesssion = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        
        // 解像度の設定
        //captureSesssion.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            
            // 入力
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                
                // 出力
                if (captureSesssion.canAddOutput(stillImageOutput!)) {
                    
                    // カメラ起動
                    captureSesssion.addOutput(stillImageOutput!)
                    captureSesssion.startRunning()
                    
                    // アスペクト比、カメラの向き(縦)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill// アスペクトフィット
                    previewLayer?.contentsGravity = CALayerContentsGravity(rawValue: AVLayerVideoGravity.resizeAspectFill .rawValue)
                    //previewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
                    
                    CameraView.layer.addSublayer(previewLayer!)
                    
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.CameraView.frame.width/2, y: self.CameraView.frame.height/2)
                    //previewLayer?.bounds = CameraView.frame
                    previewLayer?.frame = CameraView.bounds
                    
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    
    @IBAction func CameraButton(_ sender: Any) {
        // カメラの設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        
        
        // フラッシュの設定
        settingsForMonitoring.flashMode = .auto
        // カメラの手ぶれ補正
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        // 撮影
        stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        
    }
    
    /// カメラで撮影完了時にフォトライブラリに保存
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            nextImage1 = UIImage(data: photoData!)!
            
            //画面遷移先と画像を選択
            performSegue(withIdentifier: "next",sender: nextImage1)

        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "next") {
            let ViewController:ViewController = segue.destination as! ViewController
            ViewController.nextImage2 = nextImage1
        }
    }
    
    
    
    


}
