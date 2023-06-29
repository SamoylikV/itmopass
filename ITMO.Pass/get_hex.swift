import Foundation

func getHex(username: String, password: String) {
    let baseUrl = "https://isu.ifmo.ru/"
    let baseCookiesUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params="
    
    let baseUrl_ = URL(string: "https://isu.ifmo.ru/")!
    let session_ = URLSession(configuration: .default)
    
    var response_: URLResponse?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let task = session_.dataTask(with: baseUrl_) { (taskData, taskResponse, taskError) in
        response_ = taskResponse
        semaphore.signal()
    }
    
    task.resume()
    semaphore.wait()
    
    if let responseURL = response_?.url,
       let params = responseURL.query?.components(separatedBy: "="),
       params.count >= 1 {
        let p1 = params[6]
        let pInstance = params[6].components(separatedBy: ":")[2]
        
        let cookiesForAuthUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params=p=\(p1)"
        
        
        // Authorization start
        let session = URLSession.shared
        let res1 = session.dataTask(with: URL(string: baseUrl)!) { (data, response, error) in
            let pInstance = cookiesForAuthUrl.components(separatedBy: ":LOGIN:")[1]
            let authUrl = String(data: data ?? Data(), encoding: .utf8)?.components(separatedBy: "action=\"")[1].components(separatedBy: "\"")[0].replacingOccurrences(of: "&amp;", with: "&") ?? ""
            session.dataTask(with: URL(string: authUrl)!, completionHandler: { (data, response, error) in
                let getHexRequestData = [
                    "p_flow_id": "2437",
                    "p_flow_step_id": "121",
                    "p_instance": pInstance,
                    "p_request": "APPLICATION_PROCESS=GET_HEXCODE"
                ]
                var request = URLRequest(url: URL(string: "https://isu.ifmo.ru/pls/apex/wwv_flow.show")!)
                request.httpMethod = "POST"
                request.httpBody = try? JSONSerialization.data(withJSONObject: getHexRequestData, options: [])
                session.dataTask(with: request) { (data, response, error) in
                    if let data = data {
                        print(response)
                    }
                }.resume()
            }).resume()
        }
        
        res1.resume()
    }
}

getHex(username: "foo", password: "bar")
