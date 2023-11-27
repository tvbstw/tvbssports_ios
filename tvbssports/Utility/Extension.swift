//
//  Extension.swift
//  youtubeCollection
//
//  Created by leon on 2020/12/17.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import AVKit
import CocoaLumberjack
import SSZipArchive
import SwiftDate

// 漸層 Key

private var gradientTopKey: Void?
private var gradientBottomKey: Void?
private var gradientLayerKey: Void?


extension UIColor {
    /**
     Make color with hex string
     - parameter hex:hex string
     - returns: transform RBG color
     */
    static func colorWithHexString (_ hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespaces).uppercased()
        
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    /**
     tabmanStyleColor
     - parameter red: default 245
     - parameter green: default 245
     - parameter blue: default 245
     - parameter alpha: default 1
     - returns: UIColor
     */
    static func tabmanStyleColor(_ red:CGFloat = 245, _ green:CGFloat = 245, _ blue:CGFloat = 245, _ alpha:CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    /**
     Node inside backgroundColor
     - parameter red: default 245
     - parameter green: default 245
     - parameter blue: default 245
     - parameter alpha: default 1
     - returns: UIColor
     */
    static func nodeBackgroundColor(_ red:CGFloat = 245, _ green:CGFloat = 245, _ blue:CGFloat = 245, _ alpha:CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    /**
     Node inside textColr
     - parameter red: default 36
     - parameter green: default 36
     - parameter blue: default 36
     - parameter alpha: default 1
     - returns: UIColor
     */
    static func nodeTextColor(_ red:CGFloat = 36, _ green:CGFloat = 36, _ blue:CGFloat = 36, _ alpha:CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    /**
    UIColor with r,g,b,a
    - Parameters:
    - r: red  0-255
    - g: green 0-255
    - b: blue 0-255
    - a: alpha 0-1
    - Returns: UIColor
    */
    class func RGB (_ r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor {
        return self.RGBA(r, g, b, 1)
    }
    
    class func RGBA (_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ a:CGFloat) -> UIColor{
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    //iv使用
    func rgbInt() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            //let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            //return rgb
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    class var backgroundColor: UIColor {return UIColor(named: "BackgroundColor")!}  // #000000
    class var textColor: UIColor {return UIColor(named: "TextColor")!}              // #FFFFFF
    class var selectColor: UIColor {return UIColor(named: "SelectColor")!}          // #0098FF
    class var videoTimeColor: UIColor {return UIColor(named: "VideoTimeColor")!}    // #999999
    class var unSelectColor: UIColor {return UIColor(named: "UnSelectColor")!}          // #0098FF
    class var tableBackgroundColor: UIColor {return UIColor(named: "TableBackgroundColor")!}          // #
}

extension UIApplication {
    
//    var keyWindow: UIWindow? {
//        if #available(iOS 13.0, *) {
//            return UIApplication
//                .shared
//                .connectedScenes
//                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
//                .first { $0.isKeyWindow }
//        } else {
//            return UIApplication.shared.keyWindow
//        }
//    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        /**
         目前先解決推播carsh問體 但要花時間研究為何inactive狀態再回來rootviewcontroller會變nil，及修改寫法
         UIApplication.shared.applicationState == .inactive
         */
        if controller == nil {
            let del = UIApplication.shared.delegate as? AppDelegate
            if  let root = del?.window?.rootViewController  {
                return topViewController(controller:  root)
            }
            
            ///如果 UIApplication.shared.delegate rootcontroller 還是nil，手動去設rootViewController
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "mainTBC") as! MainTBC
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            return topViewController(controller:  UIApplication.shared.windows.first?.rootViewController)
        }
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag
                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
            guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
            statusBar.backgroundColor = color
    }
    
    var tabViewController: MainTBC? {
        return self.preferredApplicationWindow?.rootViewController as? MainTBC
    }
    
}

extension UIButton {
    /**
    Make UIBarButtonItem with image and title
    - parameter title: title String
    - returns: UIButton
    */
    static func customBtnForBarButtonItem (_ type:String, _ title: String, _ imageName:String) -> UIButton {
        let button = UIButton.init(type:.system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.setTitleColor(UIColor.textColor, for: .normal)
        if type == "left" {
            if title == "" {
                button.setTitle("　　", for: .normal)
            } else {
                button.setTitle(title, for: .normal)
            }
        }
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.sizeToFit()
        return button
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension URL {
    
    ///有Url把參數組成dictionary
    func constructParameters() -> [String:String] {
        var dict = [String:String]()
        let arr1 = self.absoluteString.components(separatedBy: "&")
        for arrStr in arr1 {
            let arr2 = arrStr.components(separatedBy: "=")
            dict[arr2[safe:0] ?? ""] = arr2[safe:1] ?? ""
        }
        return dict
    }
}

// create an extension of AVPlayerViewController
extension AVPlayerViewController {
    // override 'viewWillDisappear'
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // now, check that this ViewController is dismissing
        if self.isBeingDismissed == false {
            return
        }

        // and then , post a simple notification and observe & handle it, where & when you need to.....
        NOTIFICATION_CENTER.post(name: NSNotification.Name("AVPlayerViewControllerDismissing"), object: nil)
    }
}

extension String {
    //根据字符串的实际内容，在固定的宽度和字体的大小下，动态的计算出实际的高度
    func textHeightFromTextString(text: String, textWidth: CGFloat, fontSize: CGFloat, isBold: Bool) -> CGFloat {
        if #available(iOS 7.0, *) {
            var dict: NSDictionary = NSDictionary()
            if (isBold) {
                dict = NSDictionary(object: UIFont.boldSystemFont(ofSize: fontSize),forKey: NSAttributedString.Key.font as NSCopying)
            } else {
                dict = NSDictionary(object: UIFont.systemFont(ofSize: fontSize),forKey: NSAttributedString.Key.font as NSCopying)
            }
            
            let rect: CGRect = (text as NSString).boundingRect(with: CGSize(width: textWidth,height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.truncatesLastVisibleLine, NSStringDrawingOptions.usesFontLeading,NSStringDrawingOptions.usesLineFragmentOrigin],attributes: dict as? [NSAttributedString.Key : Any] ,context: nil)
            return rect.size.height
        } else {
            return 0.0
        }
    }
}

extension UILabel {
    //根据宽度动态计算高度(old)
    func getLabelHeight(_ text: NSAttributedString, width: CGFloat) -> CGFloat {
        let contentHeight = text.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin], context: nil).height
        return contentHeight
    }
    
    // 根据宽度动态计算高度(new)
    func getLabelHeight(_ label: UILabel, width: CGFloat) -> CGFloat {
        return label.sizeThatFits(CGSize(width:width, height: CGFloat(MAXFLOAT))).height
    }
    
    //根据高度动态计算宽度(old)
    func getLabelWidth(_ text: NSAttributedString, height: CGFloat) -> CGFloat {
        let contentWidth = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: [.usesLineFragmentOrigin], context: nil).width
        return contentWidth
    }
    
    //根据高度动态计算宽度(new)
    func getLabelWidth(_ label: UILabel, height: CGFloat) -> CGFloat {
        return label.sizeThatFits(CGSize(width:CGFloat(MAXFLOAT), height: height)).width
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        } catch {
            DDLogError("htmlToAttributedString:\(error)")
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func strByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}

extension String {
    func stringTypeDateConversionFormat(_ format: String) -> String? {
        guard let cDate = self.toDate() else {
            return nil
        }
        return cDate.toFormat(format)
    }
}

extension UIView {
    class func fromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        else { fatalError("missing expected nib named: \(name)") }
        guard
            /// we're using `first` here because compact map chokes compiler on
            /// optimized release, so you can't use two views in one nib if you wanted to
            /// and are now looking at this
            let view = nib.first as? Self
        else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view

    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    class func navigtionItemTitleView() -> UIView {
        //TODO change width
        let supportView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 28))
        let logo = UIImageView(image: .logo)
        logo.frame = CGRect(x: 0, y: 0, width: supportView.frame.size.width, height: supportView.frame.size.height)
        supportView.addSubview(logo)
        return supportView
    }
}


// MARK: - 陰影
extension UIView {
    
    /// 陰影 位移
    @IBInspectable var shadowUIOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }

        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    /// 陰影 透明度
    @IBInspectable var shadowUIOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }

        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    /// 陰影 半徑
    @IBInspectable var shadowUIRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }

        set {
            self.layer.shadowRadius = newValue;
        }
    }

    /// 陰影 顏色
    @IBInspectable var shadowUIColor: UIColor? {
        get {
            guard let shadowColor = self.layer.shadowColor else {
                return nil
            }
            
            return UIColor(cgColor: shadowColor)
        }

        set {
            self.layer.shadowColor = newValue?.cgColor
            self.layer.masksToBounds = false
        }
    }
}

// MARK: - 外框
extension UIView {

    /// 外框 粗細
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }

        set {
            self.layer.borderWidth = newValue
        }
    }

    /// 外框 顏色
    @IBInspectable var borderColor: UIColor? {
        get {
            let cgColor = self.layer.borderColor
            
            guard let cgColor = cgColor else {
                return nil
            }
            
            return UIColor(cgColor: cgColor)
        }

        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    /// 外框 圓角半徑
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }

        set {
            self.layer.cornerRadius = newValue
            
            if (newValue != CGFloat.zero) {
                self.layer.masksToBounds = true
                self.clipsToBounds = true
            }
        }
    }

    @available(iOS 11, *)
    /// iOS 11原生切圓角
    /// - Parameters:
    ///   - corners: 可傳多個邊
    ///   - radius: 數值
    @objc func roundCorners(corners: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
    
    /// iOS 11(不含)以下切圓角
    /// - Parameters:
    ///   - corners: 可傳多個邊
    ///   - radius: 數值
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        clipsToBounds = true

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: - 漸層
extension UIView {
    
    /// 漸層 top

    @IBInspectable var gradientTop: UIColor? {
        get {
            return objc_getAssociatedObject(self, &gradientTopKey) as? UIColor
        }

        set {
            objc_setAssociatedObject(self, &gradientTopKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateGradientLayer()
        }
    }

    /// 漸層 bottom

    @IBInspectable var gradientBottom: UIColor? {
        get {
            return objc_getAssociatedObject(self, &gradientBottomKey) as? UIColor
        }

        set {
            objc_setAssociatedObject(self, &gradientBottomKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            updateGradientLayer()
        }
    }
    
    /// 0 ~ 1之間 (0, 0 左下角、1, 1右上角)
    var gradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer
        }
        
        set {
            objc_setAssociatedObject(self, &gradientLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func updateGradientLayer() {
        updateGradient(colors: [
            gradientTop,
            gradientBottom
        ])
    }

    /// 由上到下漸層色
    /// @param colors UIColor
    func updateGradient(colors: [UIColor?], bounds: CGRect) {
        
        let gradientLayer: CAGradientLayer = self.gradientLayer ?? CAGradientLayer()
        
        if self.gradientLayer == nil {
            self.layer.insertSublayer(gradientLayer, at: 0)
            self.gradientLayer = gradientLayer
        }
        
        gradientLayer.colors = colors.compactMap { (item: UIColor?) -> CGColor? in
            return item?.cgColor
        }

        gradientLayer.frame = bounds
    }

    /// 由上到下漸層色
    /// @param colors UIColor
    func updateGradient(colors: [UIColor?]) {

        setNeedsLayout()
        layoutIfNeeded()
        
        updateGradient(colors: colors, bounds: self.bounds)
    }
}


extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    var isModal: Bool {

         let presentingIsModal = presentingViewController != nil
         let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
         let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

         return presentingIsModal || presentingIsNavigation || presentingIsTabBar
     }
}

extension Util {
    func createZip(savePath: String, source: String) -> Bool {
        return SSZipArchive.createZipFile(atPath: savePath, withContentsOfDirectory: source)
    }
}

extension Date {
    static func dateFromGMT(_ date: Date) -> Date {
        let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: date))
        return date.addingTimeInterval(secondFromGMT)
    }
    
    //取得當前時間
    static func nowTime() -> Date {
        return DateInRegion(year: Date().year, month: Date().month, day: Date().day, hour: Date().hour, minute: Date().minute, second: Date().second).date

    }
}

// MARK: - Image
extension UIImage {
    // favorite
    class var iconKeep: UIImage {return UIImage(named: "icon_keep_blue")!}
    class var iconNotKeep: UIImage {return UIImage(named: "icon_keep_white")!}
    // logo
    class var logo: UIImage {return UIImage(named: "new_logo")!}
    //default
    class var defaultImage: UIImage {return UIImage(named: "img_default")!}
    class var defaultImage11: UIImage {return UIImage(named: "img_default_1_1")!}
    class var defaultImage56: UIImage {return UIImage(named: "img_default_5_6")!}
    class var defaultImage169: UIImage {return UIImage(named: "img_default_16_9")!}
    
    class var onairImage: UIImage? { return UIImage(named: "onair") }
    
    class var imgError: UIImage? {
        return UIImage(named: "img_error")
    }
}

extension Double {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat {
    static var ListTitleFontSize: CGFloat {
        let double = FONT_SIZE[USER_DEFAULT.integer(forKey: "fontSize")]["listTitle"]
        return double?.cgFloat ?? 18.0
    }
}

extension URL {
    static func youtube(_ id: String)-> URL? {
         return URL(string: "\(YOUTUBE_URL)\(id)")
    }
}

extension UIViewController {
    func addChildViewControllAndFillOut(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ExpressibleByIntegerLiteral {
    init(_ booleanLiteral: BooleanLiteralType) {
        self = booleanLiteral ? 1 : 0
    }
}

extension Bool {
    var intValue: Int {
        if self {
            return 1
        }
        return 0
    }
}


