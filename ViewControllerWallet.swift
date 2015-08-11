//
//  ViewControllerWallet.swift
//  C$50
//
//  Created by Edouard Jamin on 10/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewControllerWallet: UIViewController {
    
    @IBOutlet weak var sharesList: UITableView!
    
    var sharesArray :NSMutableArray! = NSMutableArray()
    var numberArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sharesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.sharesList.dequeueReusableCellWithIdentifier("share", forIndexPath: indexPath) as! WalletCell
        cell.nameShares.text = self.sharesArray.objectAtIndex(indexPath.row) as? String
        print(numberArray[1])
        cell.numberShares.text = self.numberArray[indexPath.row] as! String
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        
        sharesArray = NSMutableArray()
        numberArray = [String]()
        
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    self.sharesArray.addObject(result.valueForKey("symbol") as! String)
                    let numberNumber :NSNumber = result.valueForKey("shares")! as! NSNumber
                    self.numberArray.append(String(numberNumber))
                }
                
                
                
                
            }
            
        } catch {
            print(error)
        }
        
        self.sharesList.reloadData()

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
