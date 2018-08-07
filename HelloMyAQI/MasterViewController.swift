//
//  MasterViewController.swift
//  HelloMyRSSReader
//
//  Created by Jim on 2018/6/8.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    var objects = [SiteInfo]()      //存放所有的下載資訊

    var serverReach:Reachability?
    //匯入obj-c的套件 檢察網路狀態
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreahBtn = UIBarButtonItem(barButtonSystemItem: .refresh //建立按鈕
            , target: self, action: #selector(refreahBtnPressed))
        
        navigationItem.rightBarButtonItems = [refreahBtn]  //設置按鈕
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        serverReach = Reachability.forInternetConnection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkSateusChaged), name:
            .reachabilityChanged, object: nil)
        
        serverReach?.startNotifier()//主動回報
    }
    
    @objc
    func refreahBtnPressed() {
        
        let urlString = "http://opendata2.epa.gov.tw/AQI.json" //政府open data 沒加密
        //http 沒有s 需要在info 加入app transport security =>always allow yes
        var urlc = URLComponents(string: urlString)
        urlc?.queryItems?.append(URLQueryItem(name: "123", value: "jim"))
        
        guard let url = URL(string: urlString) else {
            return assertionFailure("Invalid URl string.")
        }
        
        let downloader = AQIDownloader(rssURL: url) //要rename 前要先編譯
        downloader.download { (error, newsItems) in
            
            if let error = error {
                print("Error:\(error)")
                return
            }//Show alert to user.
           
            if let items = newsItems {
                self.objects = items
                self.tableView.reloadData()
            }else{
                //Show alert to user.
            }
        }

    }//資料來源
    
    @objc
    func networkSateusChaged() {
        guard let status = serverReach?.currentReachabilityStatus() else {
            assertionFailure("Fail ti get status of Reachability.")
            return
        }
        
        print("networkStatusChange")
        
        if status == NotReachable{
            print("NO internet connction")
        }else{
//            typedef enum : NSInteger {判斷
//                NotReachable = 0,
//                ReachableViaWiFi,
//                ReachableViaWWAN
//            } NetworkStatus;
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let item = objects[indexPath.row]
                
                //topViewController 是最上面的那層ctrl
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.detailItem = item
                
                //splitViewController 要用的 轉換 ipad
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                // 有返回紐 又加入按鈕 就要true    不然新增的會被返回鈕返回吃掉
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let site = objects[indexPath.row]
        cell.textLabel!.text = "\(site.county)-\(site.siteName)  < \(site.status) > "
        cell.detailTextLabel!.text = "AQI \(site.AQI)"
        
        
        //SHOW background color.
        let aqiValue = Int(site.AQI) ?? -1
        let bgColor : UIColor
        switch aqiValue {
        case 0...50:
            bgColor = .green
        case 51...100:
            bgColor = .yellow
        case 101...150:
            bgColor = .orange
        case 151...200:
            bgColor = .red
        case 201...300:
            bgColor = .purple
        case 301...500:
            bgColor = .brown
        default:
            bgColor = .white
        }
        
        cell.backgroundColor = bgColor
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

