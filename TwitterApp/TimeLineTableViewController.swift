//
//  TimeLineTableViewController.swift
//  TwitterApp
//
//  Created by jun on 2015/09/12.
//  Copyright (c) 2015年 jun. All rights reserved.
//

import UIKit


class TimeLineTableViewController: UITableViewController {
    
    
    var dataArray:[[String:String]] = []
    var twitter:TwitterAPI = TwitterAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        twitter.loginTwitter { () -> Void in
            
            self.twitter.downloadTwitterTimeLine{ () -> Void in
                self.dataArray = self.twitter.dataArray
                println(self.dataArray)
                //追記
                dispatch_async(dispatch_get_main_queue(),{ () ->Void in
                    self.tableView.reloadData()
                })
            }

        }
        
        

        
    }
    
    
    //テーブルの件数を登録
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    //テーブルの内容を代入
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //セルを内部的にリサイクルしているのでこちらが必須になります。
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TimeLineTableViewCell
        
        if let title = dataArray[indexPath.row]["title"]{
            cell.tweetLabel.text = title
        }
        if let imageURLString = dataArray[indexPath.row]["profile_image_url"],
            let imageURL = NSURL(string: imageURLString){
                
                println(imageURLString)
                cell.iconimageView?.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "placeholderimage"))
                
        }
        

        return cell
  
    }
    
    
}
