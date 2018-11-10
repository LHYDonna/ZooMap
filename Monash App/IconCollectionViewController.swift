//
//  IconCollectionViewController.swift
//  Monash App
//
//  Created by 林洪钰 on 4/9/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit

class IconCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "imageCell"
    private let sectionInsets = UIEdgeInsets(top:50.0, left:20.0, bottom:50.0, right:20.0)
    private let itemsPerRow: CGFloat = 3
    
    var animalInfoDelegate: AnimalInfoDelegate?
    var iconNameList = [String]()
    var filteredNameList = [String]()
    var animalType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconNameList = [String]()
        setIconNameList()
        setFilteredIconList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // Initialize the icon images to the iconNameList
    func setIconNameList(){
        self.iconNameList.append("default")
        self.iconNameList.append("sheep")
        self.iconNameList.append("cat_black")
        self.iconNameList.append("dog_black")
        self.iconNameList.append("snake_black")
        self.iconNameList.append("cat_yellow")
        self.iconNameList.append("dog_yellow")
        self.iconNameList.append("snake_yellow")
        self.iconNameList.append("kangroo")
    }
    
    // Get an filtered iconNameList filtering all the icon names by animal name
    // If no fit results than record "default" icon
    func setFilteredIconList(){
        for icon in iconNameList{
            if ((icon.range(of: animalType!.lowercased())) != nil){
                filteredNameList.append(icon)
            }
        }
        if (filteredNameList.count == 0){
            filteredNameList.append("default")
        }
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // return number of filtered icons
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredNameList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IconCollectionViewCell
        cell.backgroundColor = UIColor.white
        let animalIcon:String = filteredNameList[indexPath.row]
        cell.imageView.image = UIImage(named:animalIcon.lowercased())
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animalInfoDelegate?.setIconName(filteredNameList[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width:widthPerItem, height:widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
}
