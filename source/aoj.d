module shojin.aoj;

import vibe.d;
import std.stdio;

struct aojUser {
    string id;
    int acCount;

    this(string id) {
        this.id = id;
        Json userInfo = getUserInfo(id);
        //writeln("AOJ");
        acCount = getACCount(userInfo);
    }

    static Json getUserInfo(string id) {
        immutable string ENDPOINT = "https://judgeapi.u-aizu.ac.jp";
        string ret;
        immutable string URI = "/users/";
        requestHTTP(ENDPOINT ~ URI ~ id, 
        (scope req) {
            req.method = HTTPMethod.GET;
        },
        (scope res) {
            ret = res.bodyReader.readAllUTF8();
        });
        
        return parseJson(ret);
    }

    static Json findAllByOrderBySolved() {
        immutable string ENDPOINT = "https://judgeapi.u-aizu.ac.jp";
        string ret;
        immutable string URI = "/users/ranking/solved?page=1&size=100";
        requestHTTP(ENDPOINT ~ URI, 
        (scope req) {
            req.method = HTTPMethod.GET;
        },
        (scope res) {
            ret = res.bodyReader.readAllUTF8();
        });
        
        return parseJson(ret); 
    }

    static int getACCount(Json userInfo) {
        return userInfo["status"]["solved"].get!int;
    }
}