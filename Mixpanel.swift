// This script has been updated from Sam Soffes'
// original version located at
// https://gist.github.com/soffes/dda0f842d1aa0547293e

import Foundation
import UIKit

struct Mixpanel {
    
    // MARK: - Types
    
    typealias Completion = (success: Bool) -> ()
    
    
    // MARK: - Properties
    
    private var token: String
    private var URLSession: NSURLSession
    private let endpoint = "http://api.mixpanel.com/track/"
    
    // MARK: - Initializers
    
    init(token: String, URLSession: NSURLSession = NSURLSession.sharedSession()) {
        self.token = token
        self.URLSession = URLSession
    }
    
    
    // MARK: - Events
    
    func track(event: String, parameters: [String: AnyObject]? = nil, time: NSDate = NSDate(), completion: Completion? = nil) {
        var properties: [String: AnyObject] = parameters ?? [String: AnyObject]()
        properties["token"] = token
        properties["time"] = time.timeIntervalSince1970
        properties["$os"] = "iPhone OS"
        properties["$manufacturer"] = "Apple"
        properties["$os_version"] = UIDevice.currentDevice().systemVersion;
        //properties["$model"] = UIDevice.currentDevice().modelName
        properties["$app_version"] = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
        properties["$app_release"] = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        let json = [
            "event": event,
            "properties": properties
        ]
        
        if let jsonData = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil) {
            let data = jsonData.base64EncodedStringWithOptions(nil).stringByReplacingOccurrencesOfString("\n", withString: "")
            if let url = NSURL(string: "\(endpoint)?data=\(data)") {
                let request = NSURLRequest(URL: url)
                let task = URLSession.dataTaskWithRequest(request, completionHandler: { data, response, error in
                    if let completion = completion, string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        completion(success: string == "1")
                    }
                })
                task.resume()
            }
        }
    }
}


let mpToken = "YOUR-TOKEN"
let mixpanel = Mixpanel(token: mpToken)
