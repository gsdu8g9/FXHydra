//
//  HRFriendsMusicController.swift
//  Hydra
//
//  Created by Evgeny Evgrafov on 9/22/15.
//  Copyright © 2015 Evgeny Evgrafov. All rights reserved.
//

import UIKit
import Nuke

class HRFriendsController: UITableViewController {
    
    
    var friendsArray = Array<HRFriendModel>()
    var loading = false
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friends"
        
        self.tableView.rowHeight = 70
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.loadFriends()
        
        self.tableView.registerClass(HRFriendsCell.self, forCellReuseIdentifier: "HRFriendsCell")
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        self.addLeftBarButton()
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    // MARK: - load all audio
    
    
    func loadFriends() {
        
        if loading == false {
            loading = true
            
            let getFriends = VKRequest(method: "friends.get", andParameters: ["order":"hints","count":100,"offset":self.friendsArray.count,"fields":"photo_100","name_case":"ins"], andHttpMethod: "GET")
            
            
            getFriends.executeWithResultBlock({ (response) -> Void in
                
                
                let json = response.json as! Dictionary<String,AnyObject>
                let items = json["items"] as! Array<Dictionary<String,AnyObject>>
                
                
                for friendDict in items {

                    print(friendDict)

                    let jsonFriendItem = JSON(friendDict)
                    let friendItemModel = HRFriendModel(json: jsonFriendItem)

                    self.friendsArray.append(friendItemModel)

                }
                
                self.tableView.reloadData()
                self.loading = false
                
                
                }, errorBlock: { (error) -> Void in
                    
                    log.error("error loading friends")
                    
            })
            
        }
    
    }
    
    // mark: - tableView delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let friend = self.friendsArray[indexPath.row]
        
        let cell:HRFriendsCell = self.tableView.dequeueReusableCellWithIdentifier("HRFriendsCell", forIndexPath: indexPath) as! HRFriendsCell
        
        
        cell.friendName.text = "\(friend.first_name!) \(friend.last_name!)"
        
        var request = ImageRequest(URL: NSURL(string: friend.photo_100)!)
        request.targetSize = CGSizeMake(cell.friendAvatar.frame.width, cell.friendAvatar.frame.height)
        request.contentMode = .AspectFill
        
        Nuke.taskWithRequest(request) {
            cell.friendAvatar.image = $0.image // Image is resized
            }.resume()
        
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let friend = self.friendsArray[indexPath.row]
        
        let friendAudioController = HRFriendAudioController()
        friendAudioController.friendModel = friend
        friendAudioController.title = "\(friend.first_name!) \(friend.last_name!)"
        
        self.navigationController?.pushViewController(friendAudioController, animated: true)
        
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
        
        if indexPath.row == self.friendsArray.count - 7 {
            self.loadFriends()
        }
        
    }
    
    //MARK :- stuff
    
    
    func addLeftBarButton() {
        
        
        let button = UIBarButtonItem(image: UIImage(named: "menuHumb"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu")
        self.navigationItem.leftBarButtonItem = button
        
    }
    
    func openMenu() {
        
        HRInterfaceManager.sharedInstance.openMenu()
        
    }

}