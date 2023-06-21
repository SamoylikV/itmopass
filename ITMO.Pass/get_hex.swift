import Foundation



func get_hex(username: String, password: String, completion: @escaping (Result<String?, Error>) -> Void) {
    let baseUrl = "https://isu.ifmo.ru/"
    let baseCookiesUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params="
    let baseUrl_ = URL(string: "https://isu.ifmo.ru/")!
    let session = URLSession.shared
    
    let task = session.dataTask(with: baseUrl_) { (data, response, error) in
        if let responseURL = response?.url,
           let params = responseURL.query?.components(separatedBy: ":"),
           params.count >= 3 {
            
            let p1 = params[0]
            let p2 = params[1]
            let p3 = params[2]
            
            let cookiesForAuthUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params=p=\(p1):LOGIN:\(p2):\(p3)"
            
            print("Cookies for Auth URL:", cookiesForAuthUrl)
            
            var request = URLRequest(url: URL(string: baseUrl)!)
            request.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0", forHTTPHeaderField: "User-Agent")
            
            session.dataTask(with: request) { (data, response, error) in
                if let authUrlData = data,
                   let authUrlString = String(data: authUrlData, encoding: .utf8) {
                    if let authUrl = authUrlString.split(separator: "action=\"").last?.split(separator: "\"").first {
                        let authUrlDecoded = authUrl.replacingOccurrences(of: "&amp;", with: "&")
                        
                        let authRequest = URLRequest(url: URL(string: authUrlDecoded)!)
                        session.dataTask(with: authRequest) { (data, response, error) in
                            let getHexRequestData = """
                                p_flow_id=2437&p_flow_step_id=121&p_instance=\(p3)&p_request=APPLICATION_PROCESS=GET_HEXCODE
                                """
                            print(getHexRequestData)
                            
                            var hexcodeRequest = URLRequest(url: URL(string: "https://isu.ifmo.ru/pls/apex/wwv_flow.show")!)
                            hexcodeRequest.httpMethod = "POST"
                            hexcodeRequest.httpBody = getHexRequestData.data(using: .utf8)
                            
                            session.dataTask(with: hexcodeRequest) { (data, response, error) in
                                if let hexcodeData = data,
                                   let hexcode = String(data: hexcodeData, encoding: .utf8) {
                                    completion(.success(hexcode))
                                } else {
                                    completion(.success(nil))
                                }
                            }.resume()
                        }.resume()
                    }
                }
            }.resume()
        }
    }
    
    task.resume()
}

//getHex(username: "foo", password: "bar") { result in
//    switch result {
//    case .success(let hexcode):
//        if let hexcode = hexcode {
//            print(hexcode)
//        } else {
//            print("Error: Hexcode is nil")
//        }
//    case .failure(let error):
//        print("Error:", error)
//    }
//}
