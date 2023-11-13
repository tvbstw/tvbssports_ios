//
//  VideoIndexHeadLineCell.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/9.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import SnapKit

protocol VideoIndexHeadLineCellDelegate: NSObjectProtocol {
    func clickHeadlineCell(_ data: VideoIndexData,_ index: Int, _ cell: ColHeadLineCell)
}


class VideoIndexHeadLineCell: UITableViewCell {

    @IBOutlet weak var hlCollectionView: UICollectionView!
    weak var delegate: VideoIndexHeadLineCellDelegate?
    let identifier1 = "colHeadLineCell"
    var dataArr = [VideoIndexData]()
    var topCount = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        //TODO check video id show UI
        self.hlCollectionView.dataSource = self
        self.hlCollectionView.delegate   = self
        self.hlCollectionView.register(UINib(nibName: "ColHeadLineCell", bundle: nil), forCellWithReuseIdentifier: identifier1)
    }

    func configureWithData(_ data: [VideoIndexData]) {
        self.dataArr = data
        
        topCount = 0
        let _ = dataArr.map({
            if $0.type == "top" {
                topCount += 1
            }
        })
        
        scaleCellHeight(dataArr.isEmpty)
        
        self.hlCollectionView.reloadData()
        //更新collectionView的高度约束
        self.hlCollectionView.collectionViewLayout.invalidateLayout()
        self.hlCollectionView.layoutIfNeeded()
        self.hlCollectionView.setNeedsLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension VideoIndexHeadLineCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.dataArr[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier1, for: indexPath) as! ColHeadLineCell
        cell.tag = 001
        cell.configureWithData(data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColHeadLineCell
        let data = self.dataArr[indexPath.row]
        //self.delegate?.productClick(data, self.adTemplate)
        delegate?.clickHeadlineCell(data,indexPath.row, cell)
    }
    
}

extension VideoIndexHeadLineCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.tag == 001 {
            let data = self.dataArr[indexPath.row]
            let imageCell = cell as! ColHeadLineCell
            let imageView = imageCell.mainIV
            let topImageView = imageCell.topIV
            
            let totalIndex = dataArr.count - 1
            let topIndex = topCount - 1
            let startAddTopIcon = totalIndex - topIndex
            
            if indexPath.row >= startAddTopIcon && data.type == "top" {
                topImageView?.isHidden = false
                topImageView?.image = UIImage(named: "label_top\(indexPath.row - startAddTopIcon + 1)")
            }
            guard let image = data.image else { return }
            Util.shared.setImage(imageView, image, "headLine")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.tag == 001 {
            let imageView = (cell as! ColHeadLineCell).mainIV
            Util.shared.canelImage(imageView)
        }
    }
}

extension VideoIndexHeadLineCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 350)
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


extension VideoIndexHeadLineCell {
    func scaleCellHeight(_ isScale: Bool) {
        let content = isScale ? 5 : 350
        self.hlCollectionView?.superview?.snp.updateConstraints {
            make in
            make.height.equalTo(content)
        }
    }
}
