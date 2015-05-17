//
//  ScrollList.swift
//  Facelover
//
//  Created by Christian Ayscue on 4/8/15.
//  Copyright (c) 2015 christianayscue. All rights reserved.
//

import UIKit

class ScrollList: UIView, UIScrollViewDelegate {

    var bgSV: UIScrollView
    var profileSV: UIScrollView
    var shaddowSV: UIScrollView
    var interactionEnabled: Bool
    var appViewController: ViewController
    
    init(frame: CGRect, viewController: ViewController){
        
        //gives class access to the apps view controller
        appViewController = viewController
        
        //sets up the background scroll view
        bgSV = UIScrollView(frame: frame)
        bgSV.layer.zPosition = 1
        bgSV.showsVerticalScrollIndicator = false
        bgSV.showsHorizontalScrollIndicator = false
        bgSV.userInteractionEnabled = false
        var bgImage = UIImageView(image: UIImage(named: "scroll_background.png"))

        //content is 1/3 the size of the profileSV
        bgSV.contentSize = CGSizeMake(frame.size.height, (CGFloat(60)+CGFloat(frame.size.width+30)*CGFloat(lovers.count))/3)
        
        //sets up shaddowSV
        shaddowSV = UIScrollView(frame: frame)
        shaddowSV.layer.zPosition = 2
        shaddowSV.showsVerticalScrollIndicator = false
        shaddowSV.showsHorizontalScrollIndicator = false
        shaddowSV.userInteractionEnabled = false
        shaddowSV.contentSize = CGSizeMake(frame.size.height, CGFloat(90)+CGFloat(frame.size.width+30)*CGFloat(lovers.count))
        shaddowSV.contentOffset.y = -70
        shaddowSV.zoomScale = 0.7

        
        //sets up the profile scroll view
        profileSV = UIScrollView(frame: frame)
        profileSV.layer.zPosition = 3
        profileSV.showsHorizontalScrollIndicator = false
        profileSV.showsVerticalScrollIndicator = false
        profileSV.contentSize = CGSizeMake(frame.size.height, CGFloat(90)+CGFloat(frame.size.width+30)*CGFloat(lovers.count))
        
        
        //add labels to the profileSV && shaddowSV
        var offset: CGFloat = 60
        for (var i = 0; i < lovers.count; i++) {
            
            //labels for profileSV
            var numLabel = UILabel(frame: CGRectMake(offset, -50, frame.width, 50))
            numLabel.text = "\(i)"
            numLabel.textAlignment = NSTextAlignment.Center
            numLabel.textColor = UIColor(red: 220, green: 99, blue: 146, alpha: 1)
            profileSV.addSubview(numLabel)
            
            //adds blank square for profileSV
            var blankLabel = UILabel(frame: CGRectMake(offset, 0, frame.width, frame.height))
            blankLabel.backgroundColor = UIColor.whiteColor()
            profileSV.addSubview(blankLabel)
            
            //shaddows for shaddowSV
            var shaddowLabel = UILabel(frame: CGRectMake(offset+30, 15, frame.width, frame.height))
            shaddowLabel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            shaddowSV.addSubview(shaddowLabel)
            
            offset += frame.size.width+30
        }
        
        
        interactionEnabled = false

        super.init(frame: frame)
        
        //add the subviews
        self.addSubview(bgSV)
        self.addSubview(shaddowSV)
        self.addSubview(profileSV)
        
        //set up the profileSV so it can be tapped
        profileSV.delegate = self
        var touchDownGRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        profileSV.addGestureRecognizer(touchDownGRecognizer)
        
        
    }

    required init(coder aDecoder: NSCoder) {
        //sets up the background scroll view
        bgSV = UIScrollView(coder: aDecoder)
        bgSV.showsVerticalScrollIndicator = false
        bgSV.showsHorizontalScrollIndicator = false
        var bgImage = UIImageView(image: UIImage(named: "scroll_background.png"))
        
        
        //sets up shaddowSV
        shaddowSV = UIScrollView(coder: aDecoder)
        shaddowSV.layer.zPosition = 2
        shaddowSV.showsVerticalScrollIndicator = false
        shaddowSV.showsHorizontalScrollIndicator = false
        shaddowSV.userInteractionEnabled = false
        
        //sets up the profile scroll view
        profileSV = UIScrollView(coder: aDecoder)
        profileSV.showsHorizontalScrollIndicator = false
        profileSV.showsVerticalScrollIndicator = false
        profileSV.backgroundColor = UIColor.clearColor()
        
        self.interactionEnabled = false
        appViewController = ViewController(coder: aDecoder)
        
        super.init(coder: aDecoder)
        
        //add the subviews
        self.addSubview(bgSV)
        self.addSubview(shaddowSV)
        self.addSubview(profileSV)

        //set up the profile SV so that it can be tapped
        profileSV.delegate = self
        var touchDownGRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        profileSV.addGestureRecognizer(touchDownGRecognizer)
    }
    
    func addProfileImage(lover: Lover){
        //creates the view to add, adds it
        var addView = UIImageView(image: lover.profileImage)
        var xPos = Int(60) + Int(profileSV.frame.width+30)*Int(lover.loverNum-1)
        addView.frame = CGRectMake(CGFloat(xPos), 0, profileSV.frame.width, profileSV.frame.height)
        profileSV.addSubview(addView)
        
        //add the profile picture to the background
        //https://graph.facebook.com/chris.keating.39/picture?type=large&width=300&height=300
//        var url = NSURL(string: "https://graph.facebook.com/ID/picture?type=large&width=300&height=300")
//        var image = UIImage(data: NSData(contentsOfURL: url!)!)
//        var imageView = UIImageView(image: image)
        
    }
    
    //show list
    func showList(){
        //puts this view at the front
        self.layer.zPosition = 0
        
        //set appropriate content offset for before the animation
        var profIndex = currProfile!.loverNum - 1
        var xPos = CGFloat(Int(60) + Int(profileSV.frame.width+30)*profIndex)
        profileSV.contentOffset.x = xPos
        shaddowSV.contentOffset.x = xPos - 20
        shaddowSV.contentOffset.y = -60
        
        //animate the views appropriately
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.profileSV.zoomScale = 0.7
            self.profileSV.contentOffset.y = -70
            self.shaddowSV.contentOffset = self.profileSV.contentOffset
        }) { (bunk) -> Void in
            self.interactionEnabled = true
            self.profileSV.userInteractionEnabled = true
        }
        
        
    }
    
    //tapped list
    func tapped(tap: UITapGestureRecognizer){
        //if user tapped within the x range of one of the profiles, get that profile
        var tappedLover: Lover
        var point = tap.locationInView(self)
        
        //optimizes search by starting at the first profile index possible
        var viewOffset = self.profileSV.contentOffset.x
        var profInt = (Int(viewOffset)-Int(60))/Int(profileSV.frame.width+30) - 1
        
        //searches for which profile the user tapped, if any
        for (var i = profInt; i < lovers.count && i < profInt + 4; i++){
            var xPos = CGFloat(Int(60) + Int(profileSV.frame.width+30)*i)
            var rect = CGRectMake(CGFloat(xPos), 0, profileSV.frame.width, profileSV.frame.height)
            if CGRectContainsPoint(rect, tap.locationInView(profileSV)){
                //set the current profile and load it
                currProfile = lovers[i] as? Lover

                profileLoader!.loadNewQueue(i)
                
                //tell the view controller to rearange the profile webviews
                appViewController.choseFromList()
                
                //animate the list view to zoom in
                self.profileSV.userInteractionEnabled = false
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.profileSV.zoomScale = 1
                    self.profileSV.contentOffset.x = xPos
                    //the +20 and +10 adds the moveing shaddow effect
                    self.shaddowSV.contentOffset.x = xPos - 20
                    self.shaddowSV.contentOffset.y += 10
                }, completion: { (bunk) -> Void in
                    //sends this view to the back of the apps views
                    self.layer.zPosition = -200
                })
                
                break
            }
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //keeps scroll view from scrolling up vertically
        if profileSV.contentOffset.y != -70 && interactionEnabled{
            profileSV.contentOffset.y = -70
        }
        bgSV.contentOffset.x = profileSV.contentOffset.x/3
        
        //keep the shaddow offset equal to the profile's
        if (interactionEnabled){
            shaddowSV.contentOffset = profileSV.contentOffset
        }
                
        
    }
}





