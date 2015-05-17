//
//  ViewController.swift
//  FaceLover
//
//  Created by Christian Ayscue on 4/1/15.
//  Copyright (c) 2015 christianayscue. All rights reserved.
//

import UIKit
import WebKit
import iAd
import QuartzCore

var scrollList: ScrollList? = nil
var lovers: NSMutableArray = []
var currProfile: Lover? = nil
var profileLoader: ProfileLoader? = nil

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {

//CLASS VARIABLES
    var wheelView: UIImageView!
    var activityIndicator: UIImageView
    var loadingIndicationRunning: Bool
    var profilesViewFrame: CGRect
    var smallProfFrame: CGRect
    var loggedIn: Bool
    
    required init(coder aDecoder: NSCoder) {
        wheelView = UIImageView(image: UIImage(named: "loading_square.png"))
        activityIndicator = UIImageView(image: UIImage(named: "spinner.png"))
        loadingIndicationRunning = false
        profilesViewFrame = CGRect()
        smallProfFrame = CGRect()
        loggedIn = false
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bottomBar: UIToolbar!
  
    
//BUTTONS
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        //clean up the app and go to the login page
        lovers = []
        currProfile = nil
        profileLoader?.priorityQueue = NSMutableArray()
        profileLoader?.regularQueue = NSMutableArray()
        //stop all ongoing tasks
        profileLoader?.stopLoading()
        profileLoader = nil
        scrollList = nil
        loggedIn = false
        
        
        //hide toolbar and buttons
        bottomBar.hidden = true
        nextButton.userInteractionEnabled = false
        prevButton.userInteractionEnabled = false
        
        logoutButton.tintColor = UIColor.clearColor()
        logoutButton.enabled = false
        menuButton.tintColor = UIColor.clearColor()
        menuButton.enabled = false
        
        //put the webview in front and log out of FB
        webView.layer.zPosition = 1
        webView.stringByEvaluatingJavaScriptFromString("FB.logout()")
        
    }
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBAction func menuButtonClicked(sender: AnyObject) {
        scrollList!.showList()
    }
    
    
    @IBOutlet weak var prevButton: UIButton!
    @IBAction func prevButtonClicked(sender: AnyObject) {
        
        //animates the change in webviews
        var prevProfile = lovers[currProfile!.loverNum-1] as? Lover
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            //shrinks and slides current view to the right
            currProfile!.webView.frame = self.smallProfFrame
            //enlargest the incoming view and slides in the previous profile
            prevProfile!.webView.frame = self.profilesViewFrame
        })
        
        previoused()
    }
    
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func nextButtonClicked(sender: AnyObject) {
    
        //animates the change in webviews
        var nextProfile = lovers[currProfile!.loverNum+1] as? Lover
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            //shrinks and slides current view to the right
            currProfile!.webView.frame = self.smallProfFrame
            currProfile!.webView.frame.origin.x = self.profilesViewFrame.width+20
            //enlargest the incoming view
            nextProfile!.webView.frame = self.profilesViewFrame
        })
        
        nexted()
    }

    

//VIEW SETUP && RESOURCE LOADING
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
        
        //customize the nav bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 76, green: 96, blue: 150, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.redColor()]//UIColor(red: 200, green: 100, blue: 150, alpha: 1)]
        navigationItem.title = "Log In"
        
        //hide toolbar and buttons
        bottomBar.hidden = true
        nextButton.userInteractionEnabled = false
        prevButton.userInteractionEnabled = false
        
        logoutButton.tintColor = UIColor.clearColor()
        logoutButton.enabled = false
        menuButton.tintColor = UIColor.clearColor()
        menuButton.enabled = false
        
        profilesViewFrame = CGRectMake(0, navigationController!.navigationBar.frame.height, self.view.frame.width, self.view.frame.height-navigationController!.navigationBar.frame.height-navigationController!.toolbar.frame.height)
        smallProfFrame = CGRectMake(20, profilesViewFrame.origin.y+20, profilesViewFrame.width-40, profilesViewFrame.height-40)
        
        setUpLoadingIndicator()
        
        //set up the webviews
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        
        startLoadingWheel()
        
        //loads facebook loggin page
        var url = NSURL(string: "https://m.facebook.com")
        var request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//WEBVIEW
    func webViewDidFinishLoad(webView: UIWebView) {
        //if logged in, start the main part of the app, else, do nothing
        var newWebView = UIWebView()
        if (webView.stringByEvaluatingJavaScriptFromString("window.location.href")! as NSString).containsString("https://m.facebook.com/home.php") && !loggedIn{
            
            //get the content of the site
            var url = NSURL(string: "https://www.facebook.com/home.php")
            var request = NSURLRequest(URL: url!)
            var session = NSURLSession.sharedSession()
            
            //this task is run on a secondary thread
            var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                var err: NSError?
                
                var html = NSString(data: data, encoding: NSUTF8StringEncoding)!
                if html.containsString("InitialChatFriendsList\",[],{\"list\":[\""){
                    println("logged in")
                    self.loggedIn = true
                    //parse the html to retrieve the usernumbers
                    var components = html.componentsSeparatedByString("InitialChatFriendsList\",[],{\"list\":[\"")
                    var nextString = components[1] as! NSString
                    
                    //separates the id numbers
                    components = nextString.componentsSeparatedByString("\",\"")
                    
                    //creates an ordered array with all the desired lovers
                    var loverIDs: [String] = []
                    for (var i = 0; i<components.count-200 && i < 50; i++){
                        var idNumber = components[i] as! NSString
                        //cuts the -2 off the end of the id
                        let idString = idNumber.substringToIndex(idNumber.length-2)
                        
                        if !contains(loverIDs, idString) {
                            loverIDs.append(idString)
                        }
                    }
                    
                    //makes sure the list is cleared before loading again
                    lovers = []
                    
                    //sets the frame for the lover's webview
                    var loverFrame = CGRectMake(0, self.view.frame.height-self.navigationController!.navigationBar.frame.height, self.view.frame.width, self.view.frame.height-self.navigationController!.navigationBar.frame.height-self.navigationController!.toolbar.frame.height)
                    for (var i = 0; i < loverIDs.count; i++){
                        var newLover = Lover(ID: loverIDs[i] as String, num: i, webView: newWebView)
                        lovers.addObject(newLover)
                        self.view.addSubview(newLover.webView)
                    }
                    
                    //runs this opperation on the main thread
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        currProfile = lovers[0] as? Lover
                        webView.layer.zPosition = -100
                        //sets the profile loader running
                        var priorityQueue = NSMutableArray(array: [lovers[0], lovers[1], lovers[2], lovers[3]])
                        profileLoader = ProfileLoader(pQ: priorityQueue, rQ: lovers)
                        
                        //sets up the scrollList
                        scrollList = ScrollList(frame: loverFrame, viewController:self)
                        self.view.addSubview(scrollList!)
                        
                        //set up the logged in gui
                        self.bottomBar.hidden = false
                        self.nextButton.userInteractionEnabled = true
                        self.prevButton.hidden = true
                        
                        self.logoutButton.enabled = true
                        self.logoutButton.tintColor = UIColor.blueColor()
                        self.menuButton.enabled = true
                        self.menuButton.tintColor = UIColor.blueColor()
                        
                        //start the timer that checks if the currProfile is loading or not
                        var loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "loadingCurrent", userInfo: nil, repeats: true)
                        
                        self.choseFromList()

                    })
                }

            })
            
            task.resume()
            //log in succeeded
            

        }
        stopLoadingWheel()
    }
    
//PROFILE CHANGES
    //called after the deck was "nexted"
    func nexted(){
        
        //set the current lover and set the webviews
        currProfile = lovers[currProfile!.loverNum+1] as? Lover
        
        //update the interface
        navigationItem.title = "Lover #\(currProfile!.loverNum)"
        if currProfile!.loverNum == lovers.count-1{
            nextButton.hidden = true
            nextButton.userInteractionEnabled = false
        }
        
        prevButton.hidden = false
        prevButton.userInteractionEnabled = true
        
        //tells the profile loader to load the current profile and its surrounding views
        profileLoader!.loadNewQueue(currProfile!.loverNum)
    }
    
    //called after the deck was "previoused"
    func previoused(){
        
        //set the current lover and set the webviews
        currProfile = lovers[currProfile!.loverNum-1] as? Lover
        
        //update the interface
        navigationItem.title = "Lover #\(currProfile!.loverNum)"
        if currProfile!.loverNum == 1{
            prevButton.hidden = true
            prevButton.userInteractionEnabled = false
        }
        nextButton.hidden = false
        nextButton.userInteractionEnabled = true
        
        //tells the profile loader to load the current profile and its surrounding views
        profileLoader!.loadNewQueue(currProfile!.loverNum)
    }
    
    //chose profile from list view
    func choseFromList(){
        
        var currIndex = currProfile!.loverNum
        currProfile?.webView.frame = profilesViewFrame
        //push all frames above to the right
        for (var i = currIndex-1; i >= 0; i--){
            var lover = lovers[i] as! Lover
            lover.webView.frame = smallProfFrame
            lover.webView.frame.origin.x += profilesViewFrame.width
        }
        
        //minimize all frames bellow
        for (var i = currIndex+1; i < lovers.count; i++){
            var lover = lovers[i] as! Lover
            lover.webView.frame = smallProfFrame
        }
        
        //update the gui
        if currProfile!.loverNum == 1{
            prevButton.hidden = true
            prevButton.userInteractionEnabled = false
        }else if currProfile!.loverNum == lovers.count-1{
            nextButton.hidden = true
            nextButton.userInteractionEnabled = false
        }
        navigationItem.title = "Lover #\(currProfile!.loverNum)"

        profileLoader!.loadNewQueue(currIndex)
    }
    

//LOADING INDICATOR

    //sets up the loading indicator, ready to be started
    func setUpLoadingIndicator(){
        activityIndicator.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)
        activityIndicator.alpha = 0
        activityIndicator.layer.zPosition = 101
        
        wheelView.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)
        wheelView.alpha = 0
        wheelView.layer.zPosition = 100
        
        runSpinAnimationOnView(activityIndicator, duration: 2, rotations: 1, repeat: 10000)
        self.view.addSubview(wheelView)
        self.view.addSubview(activityIndicator)

    }
    
    //this function is on a timer
    func loadingCurrent(){
        //for the current profiles
        if currProfile != nil{
            if !currProfile!.loaded && !loadingIndicationRunning{
                loadingIndicationRunning = true
                self.requestInterstitialAdPresentation()
                UIViewController.prepareInterstitialAds()
                startLoadingWheel()
            }else if loadingIndicationRunning && currProfile!.loaded{
                loadingIndicationRunning = false
                stopLoadingWheel()
            }
        }
    }
    
    //starts the loading indication
    func startLoadingWheel(){
        //start the activity indication
        runSpinAnimationOnView(activityIndicator, duration: 2, rotations: 1, repeat: 1000)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.wheelView.frame = CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/2-self.view.frame.size.width/6, self.view.frame.size.width/3, self.view.frame.size.width/3)
            self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/3+30, self.view.frame.size.height/2-self.view.frame.size.width/6+30, self.view.frame.size.width/3-60, self.view.frame.size.width/3-60)
            self.wheelView.alpha = 1
            self.activityIndicator.alpha = 1
        })
    }
    
    //stops the loading indication
    func stopLoadingWheel(){
        //hide the activity indication
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)
            self.wheelView.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)
            self.wheelView.alpha = 0
            self.activityIndicator.alpha = 0
        })
    }
    
    //spins the view
    func runSpinAnimationOnView(view:UIView, duration:Double, rotations:CGFloat, repeat:Float){
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI * 2.0 * duration
        rotationAnimation.duration = duration
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = repeat;
        view.layer.addAnimation(rotationAnimation,forKey:"rotationAnimation")
    }
}


//when user first logs in, get the list of people, but also download in the background the html for all of those different users in a hidden webview, and store that in an array. this will make loading peoples profiles much faster when users swipe through
//swipe right: the view is shrunken and thrown to the side. this view is then put underneath the next view. index is incremented this next view loads the html for the given index.
//swipe left: the previous top view is brought back on top

//scroll menu: upon loading, take a snapshot of each profile. use the picture of each profile to make a long scrollview, with number of the person above the snapshot of their profile. when the button is clicked, the profile being viewed is "zoomed out" - we first take a snapshot of the screen as it is, add this snapshot to the imageScrollView, place the imageScrollView above the webview, then zoom the image view out to the view with all the people, the background to this imageScrollView is the facebook page that was just visited, but blurred, top label changes to "lovers", bottom buttons allow users to scroll left or right through the imageScrollView

//users must be able to interact with peoples profiles - make navigation buttons available
