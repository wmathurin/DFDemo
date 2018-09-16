/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore
import SmartStore
import SmartSync

class RootViewController : UITableViewController
{
    var dataRows = [Dictionary<String, Any>]()
    var store: SmartStore?
    var syncManager: SyncManager?
    
    // MARK: - View lifecycle
    override func loadView()
    {
        super.loadView()
        self.title = "Mobile SDK Sample App"
    
        store = SmartStore.sharedStore(name: SmartStore.defaultStoreName)
        syncManager = SyncManager.sharedInstance(store:store!)
        
        // Run (delta)sync if possible
        _ = syncManager?.reSync(syncName: "syncDownUsers") { (syncState) in
            self.loadFromStore();
        }
        self.loadFromStore();
    }
    
    // MARK: - Loading from smartstore
    func loadFromStore()
    {
        let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {User:Name} from {User}", pageSize: 100)!
        
        do {
            let records = try self.store?.query(querySpec: querySpec, pageIndex: 0)
            self.dataRows = (records as! [[NSString]]).map({ row in
                return ["Name": row[0]];
            })
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        } catch let error {
            SmartSyncLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
        }
    }

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"
        
        // Dequeue or create a cell of the appropriate type.
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier:cellIdentifier)
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // If you want to add an image to your cell, here's how.
        let image = UIImage(named: "icon.png")
        cell!.imageView?.image = image
        
        // Configure the cell to show the data.
        let obj = dataRows[indexPath.row]
        cell!.textLabel?.text = obj["Name"] as? String
        
        // This adds the arrow to the right hand side.
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
}
