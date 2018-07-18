module shojin.atcoder;

import vibe.d;

import std.stdio;

struct atcoderUser
{
    string id;
    int acCount;

    this(string id, string str)
    {
        this.id = id;
        Json allUserInfo = parseJson(str);
        //writeln("atcoder");
        foreach (e; allUserInfo)
        {
            if (e["user_id"] == id)
            {
                auto userInfo = e;
                acCount = getACCount(userInfo);
                break;
            }
        }
    }

    static Json getAllUserInfo()
    {
        immutable string URL = "https://kenkoooo.com/atcoder/atcoder-api/info/ac";
        string ret;
        requestHTTP(URL, (scope req) { req.method = HTTPMethod.GET; }, (scope res) {
            ret = res.bodyReader.readAllUTF8();
        });
        return parseJson(ret);
    }

    static string getAllUserInfoStr()
    {
        immutable string URL = "https://kenkoooo.com/atcoder/atcoder-api/info/ac";
        string ret;
        requestHTTP(URL, (scope req) { req.method = HTTPMethod.GET; }, (scope res) {
            ret = res.bodyReader.readAllUTF8();
        });
        return ret;
    }

    static int getACCount(Json userInfo)
    {
        //writeln(userInfo["problem_count"].get!int);
        return userInfo["problem_count"].get!int;
    }
}
