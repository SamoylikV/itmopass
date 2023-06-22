import Foundation

let baseUrl = "https://isu.ifmo.ru/"
let baseCookiesUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params="

func getHex(username: String, password: String){
    let baseUrl_ = URL(string: "https://isu.ifmo.ru/")!
    let session = URLSession(configuration: .default)

    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let task = session.dataTask(with: baseUrl_) { (taskData, taskResponse, taskError) in
        data = taskData
        response = taskResponse
        error = taskError
        semaphore.signal()
    }
    
    task.resume()
    semaphore.wait()
    
    if let responseURL = response?.url,
       let params = responseURL.query?.components(separatedBy: "="),
       params.count >= 1 {
        let p1 = params[6]
        let p3 = params[6].components(separatedBy: ":")[2]
        
        let cookiesForAuthUrl = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params=p=\(p1)"
        print("Cookies for Auth URL:", cookiesForAuthUrl)
        
        var request = URLRequest(url: URL(string: baseUrl)!)
        request.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0", forHTTPHeaderField: "User-Agent")
        
        data = nil
        response = nil
        error = nil
        
        let task = session.dataTask(with: request) { (taskData, taskResponse, taskError) in
            data = taskData
            response = taskResponse
            error = taskError
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        if let authUrlData = data,
           let authUrlString = String(data: authUrlData, encoding: .utf8) {
            if let authUrl = authUrlString.split(separator: "action=\"").last?.split(separator: "\"").first {
                let authUrlDecoded = authUrl.replacingOccurrences(of: "&amp;", with: "&")
                
                let authRequest = URLRequest(url: URL(string: authUrlDecoded)!)
                
                data = nil
                response = nil
                error = nil
                
                var task = session.dataTask(with: authRequest) { (taskData, taskResponse, taskError) in
                    data = taskData
                    response = taskResponse
                    error = taskError
                    semaphore.signal()
                }
                
                task.resume()
                semaphore.wait()
                
                let getHexRequestData = """
                    p_flow_id=2437&p_flow_step_id=121&p_instance=\(p3)&p_request=APPLICATION_PROCESS=GET_HEXCODE
                    """
                print(getHexRequestData)
                
                var hexcodeRequest = URLRequest(url: URL(string: "https://isu.ifmo.ru/pls/apex/wwv_flow.show")!)
                hexcodeRequest.httpMethod = "POST"
                hexcodeRequest.httpBody = getHexRequestData.data(using: .utf8)
                
                data = nil
                response = nil
                error = nil
                
                let task2 = session.dataTask(with: hexcodeRequest) { (taskData, taskResponse, taskError) in
                    data = taskData
                    response = taskResponse
                    error = taskError
                    semaphore.signal()
                }
                
                task2.resume()
                semaphore.wait()
                
                if let hexcodeData = data,
                   let hexcode = String(data: hexcodeData, encoding: .utf8) {
                    print(hexcode)
                } else {
                    print("hexcode")
                }
            }
        }
    }
}

getHex(username: "foo", password: "bar")
