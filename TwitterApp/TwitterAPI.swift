//
//  TwitteAPI.swift
//  TwitterApp
//
//  Created by jun on 2015/09/13.
//  Copyright (c) 2015年 jun. All rights reserved.
//

import UIKit
import Foundation
import Social
import Accounts



class TwitterAPI{
    
    var twitterAccount:ACAccount?
    var dataArray:[[String:String]] = []
    var test = "test"
    
    func tapTweetButton(viewController:UIViewController) {
        //twitterアカウントが登録されているか
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            //CancelもしくはPostを押した際に呼ばれ、投稿画面を閉じる処理を行っています。
            vc.completionHandler = {(result:SLComposeViewControllerResult) -> () in
                vc.dismissViewControllerAnimated(true, completion:nil)
            }
            
            ////投稿画面の初期値設定
            //vc.setInitialText("初期テキストを設定できます。")
            //vc.addURL(NSURL(string:"シェアURLを設定できます。"))
            viewController.presentViewController(vc, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "エラー", message: "Twitterアカウントが登録されていません。設定アプリを開きますか？", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                if let URL = NSURL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.sharedApplication().openURL(URL)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertActionStyle.Default, handler:nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
    /*
    *   Twitterのアクセストークンを取得
    */
    
    func loginTwitter(callback:() -> Void){
        
        //Twitterが登録されていないケース
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            return
        }
        
        let store = ACAccountStore();
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if granted == false{
                //アカウントは登録されているが認証が拒否されたケース
                return;
            }
            
            let accounts = store.accountsWithAccountType(type);
            
            if accounts.count == 0{
                return;
            }
            
            if let account = accounts[0] as? ACAccount{
                println("自分のアカウント名：「\(account.username)」\n")
                
                //アカウントをメモリに保持
                self.twitterAccount = account
                
                callback()
                //タイムラインを取得する
                //self.downloadTwitterTimeLine()
                
                
            }
        }
        
        println("loginTwitter finish?")
        
    }
    
    /*
    Twitterのタイムラインを取得する
    */
    
    func downloadTwitterTimeLine(callback:() -> Void){
        
        //自分の投稿一覧は「user_timeline.json」で取得可能
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = twitterAccount
        request.performRequestWithHandler { (responseData, responseURL, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if let res = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as? [NSDictionary]{
                
                //データ配列を一度空にする
                self.dataArray = []
                
                for entry in res{
                    
                    if let user = entry["user"] as? NSDictionary, let name = user["name"] as? String,
                        let text = entry["text"] as? String,
                        let url = user["profile_image_url"] as? String{
                            //println("ユーザー名：「\(name)」")
                            //println(text)
                            //println(url)
                            let timeline = ["title":text, "profile_image_url":url]
                            self.dataArray.append(timeline)
                            println(self.dataArray)
                            
                    }
                    /*
                    //dataArrayの配列内に連想配列["titel":text]
                    if let text = entry["text"] as? String,
                    let url = user["profile_image_url"] as? String{
                    //dataArrayの配列内に連想配列["title":text]
                    let timeline = ["title":text, "image":url]
                    self.dataArray.append(timeline)
                    println(text)
                    println(url)
                    }
                    println("------------------------")
                    */
                    
                }
                callback()
            }
        }
        
    }

    
}