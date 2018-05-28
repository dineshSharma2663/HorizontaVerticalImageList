//
//  HorizontalImageListVC.swift
//  DeltaTask
//
//  Created by Dinesh Kumar on 28/05/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit
import CoreData

class HorizontalImageListVC: UIViewController {
    
    //MARK: - Referencing Outlets
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var pageNumberLabel : UILabel!
    
    //MARK: - Variables
    var currentImagePage : Int = 0
    var fetchedResultsController: NSFetchedResultsController<ImageDataModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //Set Page Number Text
        pageNumberLabel.text = "\(currentImagePage+1)/\(fetchedResultsController.fetchedObjects?.count ?? 0)"
        self.collectionView.reloadData()
        
        //Show Image Collection
        showImageCollectionWithFading()
    }
    
    
    /// Show Image Collection with Fading Effect & Scroll to selected Item Index
    func showImageCollectionWithFading(){
        collectionView.isHidden = true
        collectionView.alpha = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //Scroll Collection View To Selected Item Index
            self.collectionView.scrollToItem(at: IndexPath(item: self.currentImagePage, section: 0), at: .centeredHorizontally, animated: false)
            UIView.animate(withDuration: 0.3) {
                self.collectionView.isHidden = false
                self.collectionView.alpha = 1.0
            }
        }
    }
    
    //MARK: - VIEW TRANSITION ORIENTATION CHANGE FUNCTION CALLED
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {[weak self] (context) in
            UIView.animate(withDuration: 0.3, animations: {
                guard let _self = self else {  return}
                let cellWidth =  UIScreen.main.isPortrait() ? UIScreen.main.bounds.width : _self.collectionView.frame.size.width
                _self.collectionView.setContentOffset(CGPoint(x: CGFloat(_self.currentImagePage)*cellWidth, y: 0), animated: false)
                _self.collectionView.reloadData()
            })
            }, completion: { _ in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - UICollectionView Delegate & Datasource
extension HorizontalImageListVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController ==
            nil{
            return 0
        }
        guard let images = fetchedResultsController.fetchedObjects else { return 0 }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let imageDetail = fetchedResultsController.object(at: indexPath)
        cell.configImageCell(imageData: imageDetail)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.isPortrait() ? UIScreen.main.bounds.width : collectionView.frame.size.width
        return CGSize(width: width, height: width)
    }
}

//MARK: - UIScrollViewDelegate
extension HorizontalImageListVC: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cellWidth = UIScreen.main.isPortrait() ? UIScreen.main.bounds.width : self.collectionView.frame.width
        currentImagePage = Int(scrollView.contentOffset.x / cellWidth)
        pageNumberLabel.text = "\(currentImagePage+1)/\(fetchedResultsController.fetchedObjects?.count ?? 0)"
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalImageListVC : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
