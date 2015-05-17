//
//  ViewLoader.swift
//  Facelover
//
//  Created by Christian Ayscue on 4/8/15.
//  Copyright (c) 2015 christianayscue. All rights reserved.
//

import UIKit

//where we load all profiles
class ProfileLoader: NSObject, UIWebViewDelegate, UIScrollViewDelegate {
    var currLoadingLover: Lover?
    var loading: Bool
    var loadingTimer: NSTimer
    
    //structure for the loading queues
    var priorityQueue: NSMutableArray
    var regularQueue: NSMutableArray
    var time: NSTimeInterval
    
    init(pQ: NSMutableArray, rQ: NSMutableArray){
        loading = false
        currLoadingLover = nil
        priorityQueue = pQ
        regularQueue = rQ
        self.loadingTimer = NSTimer()
        time = 0
        super.init()
        //timer will run indefinitely
        loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "loadProfileQueues", userInfo: nil, repeats: true)
    }
    
    //loads a new queue given the index of the lover
    func loadNewQueue(loverIndex: Int){
        var newQueue = NSMutableArray()
        newQueue.addObject(lovers[loverIndex])
        if loverIndex+1 >= 0 {
            newQueue.addObject(lovers[loverIndex+1])
        }
        if loverIndex+2 >= 0 {
            newQueue.addObject(lovers[loverIndex+2])
        }
        if loverIndex-1 >= 0 {
            newQueue.addObject(lovers[loverIndex-1])
        }
        newQueue.addObject(lovers[loverIndex+3])
        if loverIndex-2 >= 0 {
            newQueue.addObject(lovers[loverIndex-2])
        }
        profileLoader!.priorityQueue = newQueue
        println(priorityQueue[0])
        if currLoadingLover != nil{
            if priorityQueue[0] as? Lover != currLoadingLover{
                currLoadingLover!.webView.stopLoading()
                loading = false
            }
        }

    }
    
    func loadProfileQueues(){
        time += 0.1
        if(!loading){
            if priorityQueue.count != 0{
                loadProfile(priorityQueue[0] as! Lover)
            }else if regularQueue.count != 0{
                loadProfile(regularQueue[0] as! Lover)
            }else{
                //stop this loop indefinitely because all profiles have been loaded
                println("Loaded all profiles! Took: \(time) seconds")
                loadingTimer.invalidate()
            }
        }
    }
    
    func loadProfile(profile: Lover){
        //if profile hasnt been loaded before, load it now
        if !profile.loaded{
            currLoadingLover = profile
            profile.webView.delegate = self
            profile.webView.scrollView.delegate = self
            var request = NSURLRequest(URL: profile.profURL)
            profile.webView.loadRequest(request)
            loading = true
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        //generate profile image
        var image = imageWithView(webView)
        image.applyTintEffectWithColor(UIColor.clearColor())
        currLoadingLover!.profileImage = image
        
        //add image to scrollList
        scrollList!.addProfileImage(currLoadingLover!)
        
        //take lover out of queues
        if priorityQueue.containsObject(currLoadingLover!){
            priorityQueue.removeObject(currLoadingLover!)
        }
        if regularQueue.containsObject(currLoadingLover!){
            regularQueue.removeObject(currLoadingLover!)
        }
        
        //set necessary variables to indicate end of loading
        webView.delegate = nil
        currLoadingLover!.loaded = true
        loading = false
        
        println("loaded \(currLoadingLover!.loverNum)")
    }
    
    func stopLoading(){
        currLoadingLover?.webView.stopLoading()
        loadingTimer.invalidate()
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //the webview hides the facebook menu bar
        if scrollView.contentOffset.y <= 45{
            scrollView.contentOffset.y = 45
        }
    }
    
    //make an image with the view
    func imageWithView(view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
   
}
