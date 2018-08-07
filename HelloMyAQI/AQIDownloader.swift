//struct SiteInfo :Codable{ //要遵從 Codable
//    //... 新聞內容
//
//    var SiteName:String?
//    var County:String?   //變數名稱要一樣
//    var AQI:String?
//    var Latitude:String?
//    var Longitude:String?
//
//}


import Foundation

//https://swiftcafe.io/post/codable  解釋起來太長 直接附上網址

struct SiteInfo :Codable{ //Codable是編碼與解碼的協定
    
    var siteName : String = ""
    var county : String = ""   //變數名稱要一樣
    var AQI : String = ""
    var latitude : String = ""
    var longitude : String = ""
    
    var status :String = ""
    var pm25 :String = ""
    
    //在enum 中CodingKey裡自定義要進行的內容有哪些   不在此範圍的屬性需要初始化
    //case 結構裡所代表的屬性 ： 編碼後 某格式內容中所代表的屬性（名稱）
    enum CodingKeys: String , CodingKey {       //指定屬性編碼
        case siteName = "SiteName"
        case county = "County"
        case AQI
        //case AQI   case 跟變數一樣時 直接AQI
        case latitude = "Latitude"
        case longitude = "Longitude"
        case status = "Status"
        case pm25 = "PM2.5"
    }
}
//也可用dictionry  會用在欄位不固定的時候 比較麻煩用

typealias AQIDownloadHandler = (Error? , [SiteInfo]?) -> Void
//alias 暱稱

class AQIDownloader {
    
    let targetURL:URL
    
    init(rssURL:URL) {
        targetURL = rssURL
    } //類別內 常數可以延後給初始化。fun裡面用法不一樣
    
    func download (doneHandler: @escaping AQIDownloadHandler ) {
        //這是model 就算是錯誤訊息也該回傳給 control 來顯示
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
//        let jim = session.d
        
        let task = session.dataTask(with: targetURL) { (data, respone, error) in
            
            if let error = error {
                print("Download Fail:\(error)")
                DispatchQueue.main.async { //確保後面的人下載不會用問題
                    doneHandler(error,nil)// 有任何變數從參數傳進來 會先丟進stack
                }
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                
                let error = NSError(domain: "Data is nil", code: -1, userInfo: nil)//錯誤代碼多為負的
                                                    //userInfo: nil後面也可在夾帶資訊
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            let results = try? decoder.decode([SiteInfo].self , from: data)
            
            if let results=results{
                //Parse OK
                DispatchQueue.main.async {
                    doneHandler(nil,results)
                }
                
            }else{
                //Parse Fail
                let error = NSError(domain: "Parse XML Fail", code: -1, userInfo: nil)
                
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                
            }
        }
        task.resume()
        
    }
    //手勢 一直加會會很延遲   ios中有add 的方法 都會有多開的風險 記得
}
