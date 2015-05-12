/*
* Copyright 2015 Robert Theis
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may not
* use this file except in compliance with the License. You may obtain a copy of
* the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations under
* the License.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var plays: NSMutableArray?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Pass the plays to the table view controller
        var navigationController: UINavigationController = self.window?.rootViewController as! UINavigationController
        var tableViewController = navigationController.topViewController as! RMTTableViewController
        tableViewController.plays = loadPlays()

        return true
    }
    
    func loadPlays() -> NSArray {

        if plays == nil {
            var url = NSBundle.mainBundle().URLForResource("PlaysAndQuotations", withExtension: "plist")
            var playDictionariesArray = NSArray(contentsOfURL: url!)
            plays = NSMutableArray(capacity: playDictionariesArray!.count)

            for playDictionary in playDictionariesArray! {

                var play = RMTPlay()
                play.name = playDictionary["playName"] as! String

                if let quotationDictionaries = playDictionary["quotations"] as? NSArray {

                    var quotations = NSMutableArray(capacity: quotationDictionaries.count)
                    for dictionary in quotationDictionaries {

                        var quotationDictionary: NSDictionary = dictionary as! NSDictionary
                        var quotation = RMTQuotation()
                        quotation.setValuesForKeysWithDictionary(quotationDictionary as [NSObject : AnyObject])

                        quotations.addObject(quotation)
                    }
                    play.quotations = quotations

                    self.plays!.addObject(play)
                }

            }
        }

        return plays!
    }
}

