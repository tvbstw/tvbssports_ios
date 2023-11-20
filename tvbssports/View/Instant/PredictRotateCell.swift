//
//  PredictRotateCell.swift
//  tvbssports
//
//  Created by Oscar on 2023/11/15.
//  Copyright © 2023 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol PredictRotateCellDelegate: NSObjectProtocol {
    func clickPictureCell(_ data: PictureList, _ index: Int)
    func clickPictureEndcell()

}

class PredictRotateCell: UITableViewCell {

    @IBOutlet weak var cCollectionView: UICollectionView!
    weak var delegate: PredictRotateCellDelegate?
    
    let identifier1 = "predictRotateCollectionViewCell"
    var dataArr = [PictureList]()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cCollectionView.dataSource = self
        self.cCollectionView.delegate   = self
        self.cCollectionView.register(UINib(nibName: "PredictRotateCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier1)
    }
    
    
    func configureWithData(_ data: [PictureList]) {
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


extension PredictRotateCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.dataArr[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier1, for: indexPath) as! ColPictureCell
        cell.tag = 001
        cell.configureWithData(data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.dataArr[indexPath.row]
        if data.name == PICTURE_LIST_END_CELL {
            delegate?.clickPictureEndcell()
        } else {
            delegate?.clickPictureCell(data, indexPath.row)
        }
    }
    
}

extension PredictRotateCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.tag == 001 {
            let data = self.dataArr[indexPath.row]
            guard let image = data.cover_v else { return }
            let imageCell = cell as! ColPictureCell
            let imageView = imageCell.pictureIV
            Util.shared.setImage(imageView, image, "picture")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.tag == 001 {
            let imageView = (cell as! ColPictureCell).pictureIV
            Util.shared.canelImage(imageView)
        }
    }
}

extension PredictRotateCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}
