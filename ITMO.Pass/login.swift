import Foundation

func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
    let baseUrl = "https://isu.ifmo.ru/"
    let baseCookiesUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params="

    let session = URLSession.shared
    let res1Task: URLSessionDataTask

    res1Task = session.dataTask(with: URL(string: baseUrl)!) { (data, _, _) in
        guard let res1Data = data,
              let res1Url = res1Task.originalRequest?.url else {
            completion(false)
            return
        }

        let cookiesForAuthUrl = baseCookiesUrl + (URL(string: res1Url.absoluteString)?.pathComponents[2] ?? "")
        session.dataTask(with: URL(string: cookiesForAuthUrl)!) { (_, _, _) in
            let pInstance = cookiesForAuthUrl.components(separatedBy: ":LOGIN:")[1]
            let authUrl = String(data: res1Data, encoding: .utf8)?.components(separatedBy: "action=\"")[1].components(separatedBy: "\"")[0].replacingOccurrences(of: "&amp;", with: "&")
            let postData = ["username": username, "password": password, "credentialId": ""]
            let res3Task = session.dataTask(with: URL(string: authUrl!)!) { (data, _, _) in
                guard let res3Data = data else {
                    completion(false)
                    return
                }
                
                let res3String = String(data: res3Data, encoding: .utf8) ?? ""
                let success = !res3String.contains("Invalid username or password")
                completion(success)
            }
            res3Task.resume()
        }.resume()
    }
    res1Task.resume()
}

