import UIKit

class AllMusicController: UITableViewController, HRMusicCellProtocol  {
    
    var searchController : UISearchController?
    var audiosArray = Array<HRAudioItemModel>()
    var loading = false
    var hrRefeshControl  = UIRefreshControl()
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "All Music"
        
        self.tableView.rowHeight = 70
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.refreshAudios()
        
        self.tableView.registerClass(HRAllMusicCell.self, forCellReuseIdentifier: "HRAllMusicCell")
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyle.White
        
        self.addLeftBarButton()
        
        self.hrRefeshControl.addTarget(self, action: "refreshAudios", forControlEvents: UIControlEvents.ValueChanged)
        self.hrRefeshControl.backgroundColor = UIColor ( red: 0.0732, green: 0.0728, blue: 0.0735, alpha: 1.0 )
        self.hrRefeshControl.tintColor = UIColor ( red: 0.8845, green: 0.8845, blue: 0.8845, alpha: 1.0 )
        
        self.refreshControl = self.hrRefeshControl
        
        // add search
        
        
        let searchAudioController = HRSearchAudioController()
        self.searchController = UISearchController(searchResultsController: searchAudioController)
        self.searchController?.searchResultsUpdater = searchAudioController
        self.searchController?.searchBar.sizeToFit()
        self.searchController?.searchBar.tintColor = UIColor ( red: 0.882, green: 0.8778, blue: 0.8863, alpha: 1.0 )
        self.searchController?.searchBar.backgroundColor = UIColor ( red: 0.2228, green: 0.2228, blue: 0.2228, alpha: 1.0 )
        self.searchController?.searchBar.barTintColor = UIColor ( red: 0.1221, green: 0.1215, blue: 0.1227, alpha: 1.0 )
        self.searchController?.searchBar.backgroundImage = UIImage()
        self.searchController?.searchBar.placeholder = ""
        self.searchController?.searchBar.inputAccessoryView?.backgroundColor = UIColor ( red: 0.3025, green: 0.301, blue: 0.3039, alpha: 1.0 )
        self.searchController?.searchBar.keyboardAppearance = .Dark
        self.searchController?.searchBar.translucent = false
        
        let txfSearchField = self.searchController?.searchBar.valueForKey("_searchField") as! UITextField
        txfSearchField.backgroundColor = UIColor ( red: 0.0732, green: 0.0728, blue: 0.0735, alpha: 1.0 )
        
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.tableView.backgroundColor = UIColor ( red: 0.2228, green: 0.2228, blue: 0.2228, alpha: 1.0 )
        self.tableView.separatorColor = UIColor ( red: 0.2055, green: 0.2015, blue: 0.2096, alpha: 1.0 )
        
        self.view.backgroundColor = UIColor ( red: 0.1221, green: 0.1215, blue: 0.1227, alpha: 1.0 )
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    // MARK: - load all audio
    
    func loadMoreAudios() {
        
        if loading == false {
            loading = true
            
            dispatch.async.global({ () -> Void in
                
                HRAPIManager.sharedInstance.vk_audioget(0, count: 100, offset: self.audiosArray.count, completion: { (vkAudiosArray) -> () in
                    
                    let countAudios = self.audiosArray.count
                    var counter = countAudios;
                    
                    self.audiosArray.appendContentsOf(vkAudiosArray)
                    
                    var indexPaths = [NSIndexPath]()
                    
                    for (countAudios; counter < self.audiosArray.count;counter++) {
                        
                        let indexPath = NSIndexPath(forRow: counter-1, inSection: 0)
                        indexPaths.append(indexPath)
                        
                    }
                    
                    dispatch.async.main({ () -> Void in
                        
                        //TODO: !hack! disable animations it's not good soulution for fast add cells, mb. need play with layer.speed in cell :/
                        //UIView.setAnimationsEnabled(false)
                        
                        self.tableView.beginUpdates()
                        
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                        
                        self.tableView.endUpdates()
                        
                        //UIView.setAnimationsEnabled(true)
                        
                        self.loading = false
                        
                    })
                    
                })

            })
            
        }
        
    }
    
    
    func refreshAudios() {
        
        if loading == false {
            loading = true
            HRAPIManager.sharedInstance.vk_audioget(0, count: 100, offset: 0, completion: { (vkAudiosArray) -> () in
                
                self.audiosArray = vkAudiosArray
                
                dispatch.async.main({ () -> Void in
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    self.loading = false
                })
            })
        }
        
    }
    
    // mark: - tableView delegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audiosArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let audio = self.audiosArray[indexPath.row]
        
        let cell:HRAllMusicCell = self.tableView.dequeueReusableCellWithIdentifier("HRAllMusicCell", forIndexPath: indexPath) as! HRAllMusicCell
        
        cell.audioAristLabel.text = audio.artist
        cell.audioTitleLabel.text = audio.title
        cell.audioModel = audio
        cell.audioTimeLabel.text = self.durationFormater(Double(audio.duration))
        
        cell.bitRateBackgroundImage.image = UIImage(named: "bitrate_background")?.imageWithColor2(UIColor ( red: 0.3735, green: 0.3735, blue: 0.3735, alpha: 1.0 ))
        
        if audio.downloadState == 3 {
            
            cell.downloadedImage.hidden = false
            cell.downloadedImage.image = UIImage(named: "donebutton")?.imageWithColor2(UIColor.whiteColor())
            
            // complete
            
        } else {
            
            cell.downloadedImage.hidden = true

        }
        
        if (audio.bitrate == 0) {
            
            dispatch.async.global { () -> Void in
                
                self.getBitrate(audio, completition: { (bitrate) -> () in
                    dispatch.async.main({ () -> Void in
                        cell.audioBitrate.text = "\(bitrate)"
                        
                        if (bitrate > 256) {
                            cell.bitRateBackgroundImage.image = UIImage(named: "bitrate_background")?.imageWithColor2(UIColor ( red: 0.0657, green: 0.5188, blue: 0.7167, alpha: 1.0 ))
                        }
                        
                    })
                })
                
            }
            
        } else {
            
            cell.audioBitrate.text = "\(audio.bitrate)"
            
            if (audio.bitrate > 256) {
                cell.bitRateBackgroundImage.image = UIImage(named: "bitrate_background")?.imageWithColor2(UIColor ( red: 0.0657, green: 0.5188, blue: 0.7167, alpha: 1.0 ))
            }
            
            
        }

        
        return cell
        
    }
    
    
    private func getBitrate(audio:HRAudioItemModel,completition:(Int) -> ()) {
        
        let audioURL = NSURL(string: "\(audio.audioNetworkURL)")!
        
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: audioURL)
        request1.HTTPMethod = "HEAD"
        
        var response : NSURLResponse?
        
        do {
            
            try NSURLConnection.sendSynchronousRequest(request1, returningResponse: &response)
            
            if let httpResponse = response as? NSHTTPURLResponse {
                
                let size = httpResponse.expectedContentLength
                let kbit = size/128;//calculate bytes to kbit
                let kbps = ceil(round(Double(kbit)/Double(audio.duration))/16)*16
                
                print("kbps === \(kbps)")
                
                audio.bitrate = Int(kbps)
                
                completition(Int(kbps))
            }
            
        } catch (let e) {
            print(e)
        }
    
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        dispatch.async.main { () -> Void in
            
            let audioLocalModel = self.audiosArray[indexPath.row]
            
            HRPlayerManager.sharedInstance.items = self.audiosArray
            HRPlayerManager.sharedInstance.currentPlayIndex = indexPath.row
            HRPlayerManager.sharedInstance.playItem(audioLocalModel)
            
            
            self.presentViewController(PlayerController(), animated: true, completion: nil)
    
        }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            //add code here for when you hit delete
        }
        
    }
    
    
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
        
        if indexPath.row == self.audiosArray.count - 7 {
            self.loadMoreAudios()
        }
        
    }
    
    //MARK :- stuff
    
    func downloadAudio(model:HRAudioItemModel,progressView:UIProgressView) {
        
         progressView.hidden = false
        
         HRDownloadManager.sharedInstance.downloadAudio(model) { (progress) -> () in
            
            dispatch.async.main({ () -> Void in
                
                if (Int(fabs(progress*100))) % 10 == 0 {
                    log.debug("download progress = \(progress)")
                    progressView.setProgress(Float(progress), animated: true)
                    
                    if progress*100 == 100 {
                        progressView.hidden = true

                        let objectIndex = self.audiosArray.indexOf({ (objModel) -> Bool in
                            
                            if objModel.audioID == model.audioID {
                                return true
                            } else {
                                return false
                            }
                        })
                        
                        model.downloadState = 3
                        
                        let indexPath = NSIndexPath(forRow: objectIndex!, inSection: 0)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                        
                        
                    }
                }
                
            })
            
        }
        
        
    }
    
    func durationFormater(duration:Double) -> String {

        let min = Int(floor(duration / 60))
        let sec = Int(floor(duration % 60))
        
        if (sec < 10) {
            return "\(min):0\(sec)"
        } else {
            return "\(min):\(sec)"
        }
        
    }
    
    func addLeftBarButton() {
        
        
        let button = UIBarButtonItem(image: UIImage(named: "menuHumb"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu")
        self.navigationItem.leftBarButtonItem = button
        
    }
    
    func openMenu() {
        
        HRInterfaceManager.sharedInstance.openMenu()
        
    }
    // cell action
    
//    func swipeCellActivatedAction(cell: BWSwipeCell, isActionLeft: Bool) {
//        //
//        
//        log.debug("swipeCellActivatedAction")
//        
//    }
//    
//    func swipeCellDidCompleteRelease(cell: BWSwipeCell) {
//        //
//        if cell.state == BWSwipeCellState.PastThresholdRight {
//            log.debug("swipeCellDidCompleteRelease \(cell.state)")
//            
//            let musicCell = cell as? HRAllMusicCell
//            
//            self.downloadAudio(musicCell!.audioModel, progressView: musicCell!.progressView)
//            
//            
//        }
//        
//    }
    
}
