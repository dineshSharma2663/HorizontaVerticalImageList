//
//  ImageListVCExtension.swift
//  DeltaTask
//
//  Created by Dinesh Kumar 16 on 5/29/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit
import CoreData

extension ImagesListViewController : NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.imagesCollectionView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.imagesCollectionView.reloadData()
    }
}

//MARK: - UICollection View Delegates & DataSource
extension ImagesListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController == nil{
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Show Horizontal List
        self.performSegue(withIdentifier: "ShowHoriZontalList", sender: indexPath)
    }
    
    ///UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - (numberOfItemsInARow-1)*10) / numberOfItemsInARow
        return CGSize(width: width, height: width)
    }
}
