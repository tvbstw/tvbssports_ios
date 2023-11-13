//
//  WebVC.swift
//  videoCollection
//
//  Created by Woody on 2022/3/23.
//  Copyright © 2022 Eddie. All rights reserved.
//

import Foundation
import WebKit
import CocoaLumberjack


class WebVC: UIViewController {
    
    var progressView = UIProgressView(progressViewStyle: .default)
    var webView:WKWebView!
    
    var url: URL?
    
    convenience init(_ urlString: String) {
        self.init(URL(string: urlString))
    }
    
    convenience init(_ url: URL?) {
        self.init()
        self.url = url
        self.hidesBottomBarWhenPushed = true
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        resetFBCookies()
        setWebView()
        setProgressView()
        setBackButton()
        setRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if webView.isLoading {
            webView.stopLoading()
        }
    }
    
    func setBackButton() {
        self.navigationItem.hidesBackButton = true
        let btn = UIButton.customBtnForBarButtonItem("left", "", "icon_back")
        btn.addTarget(self, action: #selector(customBackItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func customBackItemClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setWebView() {
        webView = WKWebView()
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(webView)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if let unWebview = self.webView {
            self.view.addSubview(unWebview)
            unWebview.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20))
            })
        }
    }
    
    func setProgressView() {
        progressView.progressTintColor = .selectColor
        self.view.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalTo(self.view)
            }
            make.height.equalTo(2)
            make.width.equalTo(self.view)
        }
    }
    
    func setRequest() {
        guard let url = url else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        webView.load(request)
    }
    
    func resetFBCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                DDLogDebug("cookie.domain:\(cookie.domain)")
                if cookie.domain != ".facebook.com" {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }
    }
    
    //MARK: observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0.0
                }, completion: { (finished) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    
    deinit {
        if self.webView != nil {
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    /**
     open custom app with urlScheme : telprompt, sms, mailto
     
     - parameter urlScheme: telpromt, sms, mailto
     - parameter additional_info: additional info related to urlScheme
     */
    func openCustomApp(urlScheme:String, additional_info:String) {
        if let requestUrl:URL = URL(string:"\(urlScheme)"+"\(additional_info)") {
            let application:UIApplication = UIApplication.shared
            if application.canOpenURL(requestUrl) {
                if #available(iOS 10.0, *) {
                    application.open(requestUrl, options: [:], completionHandler: nil)
                } else {
                    application.openURL(requestUrl)
                }
            }
        }
    }
    
}


extension WebVC: WKNavigationDelegate  {
    
    /**
     *  1.是否允许跳转
     *  在发送请求之前，决定是否跳转
     *
     *  @param webView          实现该代理的webview
     *  @param navigationAction 当前navigation
     *  @param decisionHandler  是否调转block
     */
    //隱私權政策相關另開視窗
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let nUrl = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        guard let wUrl = webView.url else {
            decisionHandler(.cancel)
            return
        }
        
        let urlString = nUrl.absoluteString
        
        print("1.在發送請求之前，決定是否跳轉 n-> \(urlString) w-> \(wUrl)")
        
        //FB登入完後回前一頁reload
        if urlString.contains("close_popup") || urlString.contains("dialog/close_window"){
            let url = self.url
            let request = URLRequest(url: url!)
            webView.load(request)
            decisionHandler(.cancel)
            return
        }
        
        if let urlElements = URLComponents(string: urlString), let scheme = urlElements.scheme {
            //print("⭐️⭐️⭐️scheme:\(String(describing: scheme))")
            //print("⭐️⭐️⭐️host:\(String(describing: urlElements.host)))")
            //print("⭐️⭐️⭐️path:\(urlElements.path)")
            //print("⭐️⭐️⭐️query:\(String(describing: urlElements.query))")
                   
            if let wsType = webSchemeType(rawValue: scheme) {
                switch wsType {
                case .telprompt, .sms, .mailto:
                    openCustomApp(urlScheme: "\(wsType.addSlash())", additional_info: urlElements.path)
                    decisionHandler(.cancel)
                case .line:
                    if SocialKit.isInstalled(.AppLine) {
                        if let uwUrl = URL(string: urlString) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(uwUrl, options: [:], completionHandler: nil)
                                decisionHandler(.cancel)
                            } else {
                                if UIApplication.shared.canOpenURL(uwUrl) {
                                    UIApplication.shared.openURL(uwUrl)
                                    decisionHandler(.cancel)
                                } else {
                                    decisionHandler(.allow)
                                }
                            }
                        } else {
                            decisionHandler(.cancel)
                        }
                    } else {
                        SocialKit.openInAppStore(.AppLine)
                        decisionHandler(.cancel)
                    }
                case .fbMessenger:
                    if SocialKit.isInstalled(.AppMessenger) {
                        if let uwUrl = URL(string: urlString) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(uwUrl, options: [:], completionHandler: nil)
                                decisionHandler(.cancel)
                            } else {
                                if UIApplication.shared.canOpenURL(uwUrl) {
                                    UIApplication.shared.openURL(uwUrl)
                                    decisionHandler(.cancel)
                                } else {
                                    decisionHandler(.allow)
                                }
                            }
                        } else {
                            decisionHandler(.cancel)
                        }
                    } else {
                        SocialKit.openInAppStore(.AppMessenger)
                        decisionHandler(.cancel)
                    }
                default:
                    #if DEBUG
                    print("normal http request")
                    #endif
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    /**
     *  2.开始加载网页
     *  页面开始加载时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            print("2.頁面開始加載時調用 \(url)")
        }
        //loadingAIV.startAnimating()
        //程式產生的wkwebview用UIActivityIndicatorView會出現問題
        //MBProgressHUD.showAdded(to: view, animated: true)
        //EC.saveECUrl(webView: webView)
    }
    
    /**
     *  3.知道返回内容之后，是否允许加载
     *  在收到响应后，决定是否跳转
     *
     *  @param webView            实现该代理的webview
     *  @param navigationResponse 当前navigation
     *  @param decisionHandler    是否跳转block
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let nUrl = navigationResponse.response.url else {
            decisionHandler(.cancel)
            return
        }
        
        guard let wUrl = webView.url else {
            decisionHandler(.cancel)
            return
        }
        
        print("3.在收到響應之後，決定是否跳轉 n-> \(nUrl) w-> \(wUrl)")
        decisionHandler(.allow)
    }
    
    /**
     *  4.当内容开始返回时调用
     *  当内容开始返回时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url {
            print("4.當內容開始返回時調用 \(url)")
        }
    }
    
    /**
     *  5.页面加载完成之后调用
     *  页面加载完成之后调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let u = webView.url {
            print("5.加載頁面加載完成之後調用 \(u.absoluteString)")
        }
    }
    
    /**
     *  当 webview 加载内容失败时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     *  @param error      错误
     */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let url = webView.url {
            print("⭐️當webview加載內容失敗時調用 \(url.absoluteString) error:\(error)")
        }
        //網路錯誤，5秒後再重試一次
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            EC.loadEcWebView(self.webView, targetUrl: self.url!)
//        }
    }
    
    /**
     *  当跳转失败时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     *  @param error      错误
     */
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("⭐️當跳轉失敗時調用 \(error)")
    }
    
    
    /**
     *  当由服务端进行重定向时触发
     *  接收到服务器跳转请求之后调用
     *
     *  @param webView      实现该代理的webview
     *  @param navigation   当前navigation
     */
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            print("⭐️當由服務端進行重定向時觸發 \(url)")
        }
    }
    
    /*
     //进行证书验证时触发
     func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
     
     }
     */
    
    //当因为某些问题，导致webView进程终止时触发
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
        print("⭐️當因為某些問題，導致webviewV連程終止觸發")
    }
}

extension WebVC: WKUIDelegate {
    //MARK: web另開視窗(blank)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        //跳出另開視窗
        if navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
        
    }
    
    //MARK: display alert dialog
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "提醒", message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "確定", style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
}
