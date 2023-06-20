import PythonKit

let base_url = "https://isu.ifmo.ru/"
let base_cookies_url = "https://id.itmo.ru/auth/realms/itmo/protocol/openid-connect/auth?response_type=code&scope=openid&client_id=isu&redirect_uri=https://isu.ifmo.ru/api/sso/v1/public/login?apex_params="

func get_hex(username: String, password: String) {
    let requests = Python.import("requests")
    let s = requests.Session()
    let res1 = s.get(base_url, headers: ["User-Agent": "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0"])
    let cookies_for_auth_url = base_cookies_url + res1.history[2].headers["location"][2].description
    s.get(cookies_for_auth_url)
    let p_instance = cookies_for_auth_url.split(separator: ":LOGIN:")[1].description
    let auth_url = res1.content.decode().split(separator: "action=\"")[1].split(separator: "\"")[0].description.replacingOccurrences(of: "&amp;", with: "&")
    let res3 = s.post(auth_url, data: ["username": username, "password": password, "credentialId": ""])
    let get_hex_request_data = ["p_flow_id": "2437",
                                "p_flow_step_id": "121",
                                "p_instance": p_instance,
                                "p_request": "APPLICATION_PROCESS=GET_HEXCODE"]
    let hexcode = s.post("https://isu.ifmo.ru/pls/apex/wwv_flow.show", data: get_hex_request_data).content.decode().description
    print(hexcode)
}
