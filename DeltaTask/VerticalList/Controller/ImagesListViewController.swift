//
//  ImagesListViewController.swift
//  DeltaTask
//
//  Created by Dinesh Kumar on 27/05/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class ImagesListViewController: UIViewController {
    
    struct CustomMessages {
        static let refreshControlNoInternet = "Check your internet connection"
        static let refreshControlPullDown = "Pull Down To Refresh"
    }
    
    //Core Data
    private let entityName = "ImageDataModel"
    private let persistentContainer = NSPersistentContainer(name: "DeltaTask")
    var fetchedResultsController: NSFetchedResultsController<ImageDataModel>!
    var currentContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    //MARK: - Referencing Outlets
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    
    private let refreshControl = UIRefreshControl()
    var imageViewModel = ImageListViewModel()
    var numberOfItemsInARow : CGFloat = 2 //2 For portrait // 3 for landscape
    
    //MARK: - View Life Cycle Methods // Did Load Appear & ALL
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //Variable to be set for portrait & Landscape
        //Differently to show multiple Items in A Row
        numberOfItemsInARow = UIScreen.main.isPortrait() ? 2 : 3
        
        //Adding Referesh Control to CollectionView
        addRefereshControl()
        
        // Initializing Fetch Request with
        let fetchRequest = NSFetchRequest<ImageDataModel>(entityName: self.entityName)
        
        // Add Sort Descriptors for key Rank
        let sortDescriptor = NSSortDescriptor(key: "rank", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initializing Fetched Results Controller
         fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.currentContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        //Get All Images From Server
        activityIndicator.startAnimating()
        self.getAllImages()
        
        //Fetch Saved Images
        fetchSavedImagesData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Initialising Network Notifier
        StatusBarErrorMessage.sharedInstance.addNetWorkNotifier()
    }
    
    /// Adding Refresh Control to Collection so that List can be refereshed later
    func addRefereshControl(){
        // Add Refresh Control to Table View
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: CustomMessages.refreshControlPullDown, attributes: attributes)

        if #available(iOS 10.0, *) {
            imagesCollectionView.refreshControl = refreshControl
        } else {
            imagesCollectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshImageList(_:)), for: .valueChanged)
    }

    
    /// Refresh Control Target Method
    ///
    /// - Parameter control: <#control description#>
    @objc func refreshImageList(_ control:UIRefreshControl){
        if !APIManager.shared.isInternetConnection(){
            handleRefreshControlForNoInterConnection()
            return
        }
        self.getAllImages()
    }
    
    
    /// Change Refresh Control Title For No Internet Connection & Then Revert Back
    func handleRefreshControlForNoInterConnection(){
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: CustomMessages.refreshControlNoInternet, attributes: attributes)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.8) {[weak self] in
            guard let _self = self else {  return}
            _self.refreshControl.endRefreshing()
            _self.refreshControl.attributedTitle = NSAttributedString(string: CustomMessages.refreshControlPullDown, attributes: attributes)
        }
    }
    
    
    /// Fetching Saved Images Data from Persistent Store & Updating UI
    func fetchSavedImagesData(){
        persistentContainer.loadPersistentStores {[weak self] (persistentStoreDescription, error) in
            guard let _self = self else {  return}

            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            } else {
                do {
                    try _self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                _self.imagesCollectionView.reloadData()
            }
        }
    }
    
    //MARK: - View Transition Orientation  Changed Function Called
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {[weak self] (context) in
            guard let _self = self else {  return}
            //Setting Number of Items in A Row
            //2 for Protrait
            //3 for Landscape
            _self.numberOfItemsInARow = UIScreen.main.isPortrait() ? 2 : 3
            _self.imagesCollectionView.reloadData()
        }, completion: { _ in
        })
    }
    

    
    
    /// <#Description#>
    ///
    /// - Parameter searchText: <#searchText description#>
    private func getAllImages() {
        imageViewModel.getAllImages { [weak self](images, error) in
            guard let _self = self else {return}
            _self.refreshControl.endRefreshing()
            _self.activityIndicator.stopAnimating()
            if error == nil{
                _self.saveAllImages()
            }
        }
    }
    
    
    /// Save All Images in Core Data Using Private Concurrency Queue
    func saveAllImages(){
        //Images Array to be saved
        let array =  imageViewModel.imagesArray //JSON data to be imported into Core Data
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = self.currentContext ////Our primary context on the main queue
       
        privateMOC.perform {
            for i in 0..<array.count {
                //Managed object that matches the incoming JSON structure
                //update MO with data from the dictionary
                let newModel = array[i]
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
                // Add Predicate for key Rank
                let commitPredicate = NSPredicate(format: "rank == %d", i)
                fetchRequest.predicate = commitPredicate
                let result = try! privateMOC.fetch(fetchRequest)
                if result.count == 0 {
                    let entity =  NSEntityDescription.entity(forEntityName: self.entityName,in:privateMOC)
                    if let record = NSManagedObject(entity: entity!, insertInto: privateMOC) as? ImageDataModel {
                        self.updateModel(imageDataModel: record, newModel: newModel,rank:i)
                    }
                }else {
                    for records in result{
                        if let record = records as? ImageDataModel {
                            self.updateModel(imageDataModel: record, newModel: newModel,rank:i)
                        }
                    }
                }
            }
            do {
                try privateMOC.save()
                self.currentContext.performAndWait {
                    do {
                        try self.currentContext.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    
    /// Updating NSManaged Object Model
    ///
    /// - Parameters:
    ///   - imageDataModel: Image Data NSManaged Object Model
    ///   - newModel: new image data
    ///   - rank: <#rank description#>
    func updateModel(imageDataModel:ImageDataModel,newModel:[String:AnyObject],rank:Int){
        imageDataModel.rank = Int64(rank)
        imageDataModel.email = newModel["email"] as? String
        imageDataModel.id = newModel["id"] as? Int64 ?? 0
        imageDataModel.name = newModel["name"] as? String
        imageDataModel.image = newModel["image"] as? String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - segue: <#segue description#>
    ///   - sender: <#sender description#>
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HorizontalImageListVC,let indexPath = sender as? IndexPath{
            destination.fetchedResultsController = self.fetchedResultsController
            destination.currentImagePage = indexPath.item
        }
    }
}
