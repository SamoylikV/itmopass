//
//  File.swift
//  ITMO.Pass
//
//  Created by Samoylik on 20.06.2023.
//

import Foundation

func login(username: String, password: String) -> Bool {
    let baseUrl = "https://isu.ifmo.ru/"
    let baseCookiesUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params="

    let session = URLSession.shared
    var request = URLRequest(url: URL(string: baseUrl)!)
    request.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0", forHTTPHeaderField: "User-Agent")
    let res1 = try! session.data(for: request)

    let cookiesForAuthUrl = baseCookiesUrl + (res1.response?.url?.pathComponents[2] ?? "")
    try! session.data(for: URL(string: cookiesForAuthUrl)!)

    let pInstance = cookiesForAuthUrl.components(separatedBy: ":LOGIN:")[1]
    let authUrl = res1.data?.string(encoding: .utf8)?.components(separatedBy: "action=\"")[1].components(separatedBy: "\"")[0].replacingOccurrences(of: "&amp;", with: "&") ?? ""
    let res3 = try! session.data(for: URL(string: authUrl)!, method: .post, body: ["username": username, "password": password, "credentialId": ""])

    if let res3String = res3.data?.string(encoding: .utf8),
        res3String.contains("Invalid username or password") {
        return false
    } else {
        return true
    }
}
