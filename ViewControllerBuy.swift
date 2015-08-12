//
//  ViewControllerBuy.swift
//  C$50
//
//  Created by Edouard Jamin on 11/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerBuy: UIViewController {
    
    // protypes
    var wanted :Int = 0
    var priceShare :Double = 0
    
    // interface protype
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var worthLabel: UILabel!
    @IBOutlet weak var sharesBuy: UILabel!
    @IBOutlet weak var worthBuy: UILabel!
    @IBOutlet weak var sharesStepper: UIStepper!
    
    // buy button
    @IBAction func buyButton(sender: AnyObject) {
        
        var priceShare :Double = 0
        _ = lookup(shareSelected) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                priceShare = Double(price)!
                buy(shareSelected, number: self.wanted, price: priceShare)
            }
        }
        
        // back to home
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    // back button
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("buyToHome", sender: self)
    }
    override func viewDidLoad() {
        /**
        * Start of viewDidLoad
        **/
        super.viewDidLoad()
        
        // stepper configs
        sharesStepper.wraps = false
        sharesStepper.autorepeat = true
        sharesStepper.maximumValue = 99
        
        // run lookup and update symbol and price label
        _ = lookup(shareSelected) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.symbolLabel.text = symbol
                self.priceLabel.text = price
            }
        }
        
        // connect to Shares Entity
        let context = connectToCoreData()
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        // protype (number = number of shares owned)
        var number :Double = 0.00
        
        // update sharesLabel
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("symbol") as! String == shareSelected {
                        number = result.valueForKey("shares")! as! Double
                        self.sharesLabel.text = String(Int(number))
                    }
                }
            }
        } catch {
            print(error)
        }
        
        // run price() and update worthLabel
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                let worthInt = price * number
                let worth = String(worthInt)
                self.priceShare = price
                self.worthLabel.text = "$\(worth)"
            }
        }
        
        /**
        * End of viewDidLoad
        **/
    }
    
    // check stepper change
    @IBAction func stepperChanged(sender: UIStepper) {
        
        self.sharesBuy.text = Int(sender.value).description
        wanted = Int(sender.value)
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                let worthInt = Int(price) * self.wanted
                self.worthBuy.text = String(worthInt)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
