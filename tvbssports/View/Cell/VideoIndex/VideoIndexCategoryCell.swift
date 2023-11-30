//
//  VideoIndexCategoryCell.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/9.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol VideoIndexCategoryCellDelegate: NSObjectProtocol {
    func clickCategoryCell(_ data: CategoryData, _ index: Int)

}

class VideoIndexCategoryCell: UITableViewCell {

    @IBOutlet weak var cCollectionView: UICollectionView!
    weak var delegate: VideoIndexCategoryCellDelegate?
    
    let identifier1 = "colCategoryCell"
    var dataArr = [CategoryData]()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cCollectionView.dataSource = self
        self.cCollectionView.delegate   = self
        self.cCollectionView.register(UINib(nibName: "ColCategoryCell", bundle: nil), forCellWithReuseIdentifier: identifier1)
    }
    
    
    func configureWithData(_ data: [CategoryData]) {
        self.dataArr = data
        self.cCollectionView.reloadData()
        //更新collectionView的高度约束
        //self.pCollectionView.backgroundColor = UIColor.RGBA(223, 225, 225, 0.2)
        self.cCollectionView.collectionViewLayout.invalidateLayout()
        self.cCollectionView.layoutIfNeeded()
        self.cCollectionView.setNeedsLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}


extension VideoIndexCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.dataArr[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier1, for: indexPath) as! ColCategoryCell
        cell.tag = 001
        cell.configureWithData(data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.dataArr[indexPath.row]
        delegate?.clickCategoryCell(data, indexPath.row)
    }
    
}

extension VideoIndexCategoryCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.tag == 001 {
            let data = self.dataArr[indexPath.row]
            guard let image = data.image else { return }
            let imageCell = cell as! ColCategoryCell
            let imageView = imageCell.categoryIV
            Util.shared.setImage(imageView, image, "category")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.tag == 001 {
            let imageView = (cell as! ColCategoryCell).categoryIV
            Util.shared.canelImage(imageView)
        }
    }
}

extension VideoIndexCategoryCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /*
        if self.adTemplate == .portrait {
            return UIEdgeInsetsMake(0, 0, SPACE_HEIGHT, 0)
        } else if self.adTemplate == .landscape {
            return UIEdgeInsetsMake(LANDSCAPE_SPACE_HEIGHT, 18, LANDSCAPE_SPACE_HEIGHT, 18)
        }
        */
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}
