//
//  OpenCVManager.m
//  Plarail_opencv
//
//  Created by 小嶺愛紀菜 on 2018/10/19.
//  Copyright © 2018年 小嶺愛紀菜. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

//#import <opencv2/highgui/ios.h>

#import "OpenCVManager.h"

@implementation OpenCVManager

+(UIImage *)grayScale:(UIImage *)image{
    // convert image to mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // convert mat to gray scale
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    // convert to image
    UIImage * grayImg = MatToUIImage(gray);
    
    return grayImg;
}

@end
