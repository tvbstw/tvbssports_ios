//
//  VideoIndexPictureCell.swift
//  videoCollection
//
//  Created by Eddie on 2022/6/22.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol VideoIndexPictureCellDelegate: NSObjectProtocol {
    func clickPictureCell(_ data: PictureList, _ index: Int)
    func clickPictureEndcell()

}

class VideoIndexPictureCell: UITableViewCell {

    @IBOutlet weak var cCollectionView: UICollectionView!
    weak var delegate: VideoIndexPictureCellDelegate?
    
    let identifier1 = "colPictureCell"
    let identifier2 = "colPictureEndCell"
    var dataArr = [PictureList]()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cCollectionView.dataSource = self
        self.cCollectionView.delegate   = self
        self.cCollectionView.register(UINib(nibName: "ColPictureCell", bundle: nil), forCellWithReuseIdentifier: identifier1)
        self.cCollectionView.register(UINib(nibName: "ColPictureEndCell", bundle: nil), forCellWithReuseIdentifier: identifier2)
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


extension VideoIndexPictureCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.dataArr[indexPath.row]
        if data.name == PICTURE_LIST_END_CELL {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier2, for: indexPath) as! ColPictureEndCell
            cell.tag = 002
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier1, for: indexPath) as! ColPictureCell
            cell.tag = 001
            cell.configureWithData(data)
            return cell
        }
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

extension VideoIndexPictureCell: UICollectionViewDelegate {
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

extension VideoIndexPictureCell: UICollectionViewDelegateFlowLayout {
    
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
