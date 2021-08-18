//
//  WebKitViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 22/7/21.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController, WKNavigationDelegate {
    private let url: URL
    private let authorize: (String)->()
    
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
        }
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    init(url: URL, title: String, authorizeUser: @escaping (String)->()){
        self.url = url
        self.authorize = authorizeUser
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        // Do any additional setup after loading the view.
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
    }
    
    @objc func didTapDone(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        webView.frame = view.bounds
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let safeUrl = navigationResponse.response.url?.absoluteString{
            if safeUrl.contains("\(SpotifyAPI.redirectURL)?code="){
                var endpoint = String(safeUrl.split(separator: "=")[1])
                if endpoint.contains("#"){
                    endpoint.removeLast(2)
                }
                print("endpoint \(endpoint)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.authorize(endpoint)
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
}
