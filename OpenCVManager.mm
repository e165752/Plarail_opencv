//
//  OpenCVManager.mm
//  Plarail_opencv
//
//  Created by 小嶺愛紀菜 on 2018/10/19.
//  Copyright © 2018年 小嶺愛紀菜. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
//#import <opencv2/highgui/ios.h>

#import "OpenCVManager.h"
#import <ImageIO/ImageIO.h>
#include "opencv2/core.hpp"

/* 画像を読み込む関数 */
static cv::Mat loadMatFromFile(NSString *fileName)
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [resourcePath stringByAppendingPathComponent:fileName];
    const char *pathChars = [path UTF8String];
    return cv::imread(pathChars);
}
static cv::Mat loadMatFromFile(NSString *fileBaseName, NSString *type)
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileBaseName ofType:type];
    const char *pathChars = [path UTF8String];
    return cv::imread(pathChars);
}

/* UIImage -> Mat 変換 */
void UIImageToMat(const UIImage* image,
                  cv::Mat& m, bool alphaExist) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = CGImageGetWidth(image.CGImage), rows = CGImageGetHeight(image.CGImage);
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome)
    {
        m.create(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        else
            m = cv::Scalar(0);
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    else
    {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast |
            kCGBitmapByteOrderDefault;
        else
            m = cv::Scalar(0);
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows),
                       image.CGImage);
    CGContextRelease(contextRef);
}



@interface OpenCVManager ()

@end


@implementation OpenCVManager



+(UIImage *)grayScale:(UIImage *)image{
    
    // convert image to mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // convert mat to gray scale
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    // 2値化処理
    cv::Mat matThreshold; //2値化後の画像を格納
    
    //自動で閾値決定する場合
//    cv::threshold(gray, matThreshold, 200, 255, cv::THRESH_BINARY|cv::THRESH_OTSU);
//    cv::threshold(gray, matThreshold, 253, 255, cv::THRESH_BINARY);
    
    cv::threshold(gray, matThreshold, 200, 255, CV_THRESH_TOZERO_INV );
    cv::bitwise_not(gray, matThreshold); // 白黒の反転
    cv::threshold(gray, matThreshold, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
 
    
    /* 白黒反転 */
//    cv::Mat mask;
//    bitwise_not(matThreshold, mask);
//    UIImage * grayImg2 = MatToUIImage(mask);
    

    /* 元画像 */
//    cv::Mat original = loadMatFromFile(@"train2.jpg");
//    cv::Mat original_mat = loadMatFromFile(@"train2", @"jpg");

//    cv::Mat original_mat;
//    UIImage *original_img = [UIImage imageNamed:@"train.png"];
//    UIImageToMat(original_img,original_mat);
    
    UIImage * grayImg = MatToUIImage(matThreshold);
    
    return grayImg;
}
@end

