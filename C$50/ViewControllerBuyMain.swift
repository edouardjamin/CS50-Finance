//
//  ViewControllerBuyMain.swift
//  C$50
//
//  Created by Edouard Jamin on 13/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerBuyMain: UIViewController {
    
    // prototype
    var shareWanted :String = ""
    var numberWanted :Int = 0
    var priceShare :Double = 0
    
    // interface
    @IBOutlet weak var symbolField: UITextField!
    @IBOutlet weak var shareDetail: UILabel!
    @IBOutlet weak var ownedLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberStepper: UIStepper!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func checkButton(sender: AnyObject) {
        
        // get symbol
        let symbolUser = symbolField.text!
        let symbol = symbolUser.uppercaseString
        shareWanted = symbol
        
        // clear textField
        self.symbolField.text = ""
        
        // update share info
        _ = lookup(symbol) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.shareDetail.text = "\(name) (\(symbol)): $\(price)"
                self.priceShare = Double(price)!
                
                // update priceLabel for the first time
                let worthInt = self.priceShare * Double(self.numberWanted)
                self.priceLabel.text = String(format: "%.2f", worthInt)
            }
        }
        
        // make buttons appears
        self.numberStepper.hidden = false
        self.buyButton.hidden = false
        self.numberStepper.hidden = false
        self.numberStepper.value = 1
        self.numberLabel.text = "1"
        self.numberWanted = 1
        
        // connect to CoreData
        let context = connectToCoreData()
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        // update how many shares are owned
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("symbol") as! String == shareWanted {
                        let ownedShares = String(result.valueForKey("shares")!)
                        self.ownedLabel.text = "Shares owned: \(ownedShares)"
                    }
                }
            }
        } catch {
            print(error)
        }
        
        // update cash label
        let requestCash = NSFetchRequest(entityName: "Users")
        requestCash.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(requestCash)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    let currentCash = String(format: "%.2f", result.valueForKey("cash") as! Double)
                    self.cashLabel.text = "$\(currentCash) available"
                }
            }
        } catch {
            print(error)
        }
        
        // close keyboard
        self.view.endEditing(true)
    }

    @IBAction func buyButton(sender: AnyObject) {
        
        // check if 0
        if numberWanted == 0
        {
            alert("Cannot buy", message: "You need to buy at least 1 share")
        }
        else
        {
            buy(shareWanted, number: numberWanted, price: priceShare)
            
            // back to previous
            navigationController?.popViewControllerAnimated(true)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // clear labels
        self.shareDetail.text = ""
        self.ownedLabel.text = ""
        self.priceLabel.text = ""
        self.cashLabel.text = ""
        self.numberLabel.text = ""
        self.numberStepper.hidden = true
        self.buyButton.hidden = true
        
        // stepper configs
        self.numberStepper.wraps = false
        self.numberStepper.autorepeat = true
        self.numberStepper.maximumValue = 99
    }
    
    @IBAction func numberStepper(sender: UIStepper) {
        self.numberLabel.text = Int(sender.value).description
        numberWanted = Int(sender.value)
                let worthInt = priceShare * Double(self.numberWanted)
                self.priceLabel.text = String(worthInt)
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
