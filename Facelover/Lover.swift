//
//  Lover.swift
//  Facelover
//
//  Created by Christian Ayscue on 4/7/15.
//  Copyright (c) 2015 christianayscue. All rights reserved.
//

import UIKit
import WebKit

class Lover: NSObject,  UIWebViewDelegate{
   
    var profURL: NSURL!
    var profID: String
    var loverNum: Int
    var webView: UIWebView
    var profileImage: UIImage?
    var profPic: UIImage?
    var loaded: Bool
    
    init(ID: String, num: Int, webView: UIWebView) {
        profURL = NSURL(string: "https://m.facebook.com/\(ID)")
        profID = ID
        loverNum = num
        self.webView = webView
        self.webView.layer.zPosition = CGFloat(-1*num)
        profileImage = UIImage()
        profPic = UIImage()
        loaded = false
        super.init()
    }
}
