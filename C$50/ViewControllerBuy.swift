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
    var number :Int = 0 // (number = number of shares owned)
    
    // interface protype
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var worthLabel: UILabel!
    @IBOutlet weak var sharesBuy: UILabel!
    @IBOutlet weak var worthBuy: UILabel!
    @IBOutlet weak var sharesStepper: UIStepper!
    @IBOutlet weak var cashLabel: UILabel!
    
    
    // buy button
    @IBAction func buyButton(sender: AnyObject) {
        
        var priceShare :Double = 0
        _ = lookup(shareSelected) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                priceShare = Double(price)!
                self.cashLabel.text = "$/(String(priceShare))"
                buy(shareSelected, number: self.wanted, price: priceShare)
            }
        }
        
        // back to previous
        navigationController?.popViewControllerAnimated(true)
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
        
        // look for price share
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                self.priceShare = price
            }
        }
        
        // initiate labels
        self.sharesBuy.text = "1"
        self.sharesStepper.value = 1
        self.worthBuy.text = "for $0"
        
        // update cashLabel
        let context = connectToCoreData()
        let requestCash = NSFetchRequest(entityName: "Users")
        requestCash.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(requestCash)
            
            for result in results as! [NSManagedObject] {
                let currentCash = result.valueForKey("cash") as! Double
                let currentCashString = String(format: "%.2f", currentCash)
                self.cashLabel.text = "$\(currentCashString) available"
            }
        } catch {
            print(error)
        }
        
        
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
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        
        // update sharesLabel
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("symbol") as! String == shareSelected {
                        number = result.valueForKey("shares")! as! Int
                        self.sharesLabel.text = String(number)
                    }
                }
            }
        } catch {
            print(error)
        }
        
        // run price() and update worthLabel
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                let worthInt :Double = price * Double(self.number)
                let worth = String(format: "%.2f", worthInt)
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
        
        wanted = Int(sender.value)
        self.sharesBuy.text = String(wanted)
        let wantedWorth = String(format: "%.2f", Double(wanted) * priceShare)
        self.worthBuy.text = "for $\(wantedWorth)"
        let nextNumber = self.number + wanted
        self.sharesLabel.text = String(nextNumber)
        let nextNumberWorth = String(format: "%.2f", Double(nextNumber) * priceShare)
        self.worthLabel.text = "$\(nextNumberWorth)"
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
