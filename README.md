# DFDemo
Basic Mobile SDK Swift template modified to be offline first.
The application was generated with:
```shell
forceios create --apptype= --appname=DFDemo --packagename=com.acme --organization=Acme --outputdir=
```
**You can see the application at that stage by checking out tag `1_START`.**

## To get started do the following from the root directory
``` shell
node ./install.js
```
## To run the application
* Open `DFDemo.xcworkspace` in XCode

## Demo steps

### Add schema and sync config
Add `userstore.json` file (make sure its target membership includes `DFDemo`)
```json
{
  "soups": [
    {
      "soupName": "User",
      "indexes": [
        { "path": "Id", "type": "string"},
        { "path": "Name", "type": "string"},
        { "path": "__local__", "type": "string"}
      ]
    }
  ]
}
```
Add `usersyncs.json` file (make sure its target membership includes `DFDemo`)
```json
{
  "syncs": [
    {
      "syncName": "syncDownUsers",
      "syncType": "syncDown",
      "soupName": "User",
      "target": {"type":"soql", "query":"SELECT Name FROM User LIMIT 100"},
      "options": {"mergeMode":"OVERWRITE"}
    }
  ]
}
```

In `AppDelegate.swift`:
- replace `SalesforceSDK.initializeSDK()` with `SmartSyncSDKManager.initializeSDK()`
- add following lines in `AuthHelper.loginIfRequired` block 
```swift
SmartSyncSDKManager.shared().setupUserStoreFromDefaultConfig()
SmartSyncSDKManager.shared().setupUserSyncsFromDefaultConfig()
```

**You can see the application at that stage by checking out tag `2_CONFIGS`.**

### Run sync at startup 
Replace `loadView()` with following lines in `RootViewController.swift`
```swift
    var store: SmartStore?
    var syncManager: SyncManager?

    override func loadView()
    {
        super.loadView()
        self.title = "Mobile SDK Sample App"
    
        store = SmartStore.sharedStore(name: SmartStore.defaultStoreName)
        syncManager = SyncManager.sharedInstance(store:store!)
        
        // Run (delta)sync if possible
        _ = syncManager?.reSync(syncName: "syncDownUsers") { (syncState) in
            // TBD
        }
    }
```

**You can see the application at that stage by checking out tag `3_SYNC`.**

### Load data from store

In `loadView()`, call `self.loadFromStore()`  at startup and when sync completes.

```swift
        // Run (delta)sync if possible
        _ = syncManager?.reSync(syncName: "syncDownUsers") { (syncState) in
            if (syncState.isDone()) {
                self.loadFromStore()
            }
        }
        self.loadFromStore()
```

Add the `loadFromStore()` method.

```swift
    // MARK: - Loading from smartstore
    func loadFromStore()
    {
        let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {User:Name} from {User}", pageSize: 100)!
        
        do {
            let records = try self.store?.query(querySpec: querySpec, pageIndex: 0)
            self.dataRows = (records as! [[NSString]]).map({ row in
                return ["Name": row[0]]
            })
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        } catch let error {
            SmartSyncLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
        }
    }
```

**You can see the application at that stage by checking out tag `4_OFFLINE`.**
