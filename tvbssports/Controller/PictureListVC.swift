//
//  PictureListVC.swift
//  videoCollection
//
//  Created by darrenChiang on 2022/6/21.
//  Copyright © 2022 Eddie. All rights reserved.
//

import UIKit
#if canImport(CHTCollectionViewWaterfallLayout)
import CHTCollectionViewWaterfallLayout
#endif
import MJRefresh


class PictureListVC: UIViewController , CHTCollectionViewDelegateWaterfallLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var header: MJRefreshGifHeader!
    var pictureList : [PictureList]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        registerNibs()
        quertData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        US.setAnalyticsLogEnvent(event: "show_screen", action: "Main Page_Img", label: "開啟_圖輯列表")
    }
    
    func initView() {

        let supportView = UIView(frame: CGRect(x: 0, y: 0, width: 136, height: 40))
        let logo = UIImageView(image: .logo)
        logo.frame = CGRect(x: 0, y: 0, width: supportView.frame.size.width, height: supportView.frame.size.height)
        supportView.addSubview(logo)
        self.navigationItem.titleView = supportView
        self.navigationItem.titleView?.contentMode = .scaleAspectFit
        
        // Attach datasource and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Layout setup
        setupCollectionView()
        
        setRefresh()
        //Register nibs
        registerNibs()
    }
    
    
    func setRefresh() {
        self.header = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.header.backgroundColor = UIColor.backgroundColor
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .idle)
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .pulling)
        self.header.setImages(SM.loadingImgArr, duration: LOADING_IMGS_DURATION, for: .refreshing)
        self.header.stateLabel?.isHidden = true
        self.header.lastUpdatedTimeLabel?.isHidden = true
        self.collectionView?.mj_header = self.header
    }
    
    func registerNibs(){
        
        // attach the UI nib file for the ImageUICollectionViewCell to the collectionview
        let viewNib = UINib(nibName: "ImageUICollectionViewCell", bundle: nil)
        collectionView.register(viewNib, forCellWithReuseIdentifier: "cell")
    }


    func quertData() {
        PictureListM.shared.getPictureList { result in
            self.collectionView.mj_header?.endRefreshing()
                switch result {
                case .success(let list):
                   print(list)
                    self.pictureList = list
                    self.collectionView.reloadData()
                case .failure(let error):
                    print("error\(error.description)")
                }
       
        }
    }
    
    @objc func refresh() {
        quertData()
    }

    
    //MARK: - CollectionView UI Setup
    func setupCollectionView(){
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        
        // Collection view attributes
        collectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        collectionView.collectionViewLayout = layout
    }
    
    //MARK: business logic
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? PictureContentVC
        let picture = sender as? PictureList
        vc?.hidesBottomBarWhenPushed = true
        vc?.picture = picture
    }

/// end PictureListVC
}

extension PictureListVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageUICollectionViewCell
        cell.configureWithData(data: pictureList?[safe:indexPath.row], index:indexPath)
        return cell
    }
    
    //** Size for the cells in the Waterfall Layout */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create a cell size from the image size, and return the size
        let width = self.collectionView.bounds.width
        
        if indexPath.row % 2 == 0 {
            let half = width/2
      return      CGSize(width: half, height: half / 3 * 4 + 5)
        }else {
            let half = width/2
        return    CGSize(width: half, height: half / 4 * 3 )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let picture = self.pictureList?[safe:indexPath.row] else {
            return
        }
        self.performSegue(withIdentifier: "showPictureContent", sender: picture)
        
        let name = picture.name ?? ""
        let pid = picture.pictureId ?? 0
        let pictureID = String(pid)
        US.setAnalyticsLogEnvent(event: "click_img", action: "img_content", label: "\(name)_\(pictureID)_圖輯列表")
    }

}
