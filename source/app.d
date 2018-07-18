import vibe.d;
import vibe.http.server;
import vibe.web.web;

import std.process;
import std.stdio;

void main()
{
    auto router = new URLRouter;
    router.registerWebInterface(new WebInterface);
    // public以下にあるファイルをstaticなファイルとして外部からアクセス出来るようにする
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = environment.get("PORT", "8080").to!ushort;
    settings.bindAddresses = ["127.0.0.1"];
    settings.sessionStore = new MemorySessionStore;
    listenHTTP(settings, router);
    runApplication();
}

class WebInterface
{
    private
    {
        SessionVar!(bool, "authenticated") ms_authenticated;
    }

    void index()
    {
        import shojin.aoj;
        import shojin.atcoder;
        import std.algorithm;
        import std.parallelism;

        Json aojSolved = aojUser.findAllByOrderBySolved();
        auto atcoderSolvedStr = atcoderUser.getAllUserInfoStr();
        auto atcoderSolved = parseJsonString(atcoderUser.getAllUserInfoStr());
        atcoderUser[] atcoderAllUsers, atcoderUsers;
        aojUser[] aojUsers;
        uint i = 0;
        foreach (e; aojSolved["users"])
        {
            writeln(e["id"].get!string);
            if (i++ > 100)
                break;
            aojUser t;
            t.id = e["id"].get!string;
            t.acCount = e["solved"].get!int;
            aojUsers ~= t;
        }
        writeln(aojUsers);
        foreach (e; atcoderSolved)
        {
            atcoderUser t;
            t.id = e["user_id"].get!string;
            t.acCount = e["problem_count"].get!int;
            writeln(t);
            atcoderAllUsers ~= t;
        }
        partialSort!"a.acCount > b.acCount"(atcoderAllUsers, 100);
        atcoderUsers = atcoderAllUsers[0 .. 100];
        string title = "Home";

        render!("index.dt", title, aojUsers, atcoderUsers);
    }

    @method(HTTPMethod.POST) @path("/search")
    void postSearch(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto teamName = req.form["teamName"];
        writeln(teamName);
        res.redirect("/ranking/" ~ teamName);
    }

    @method(HTTPMethod.GET) @path("/ranking")
    void getRankingList()
    {
        import std.file;

        File teamJsonStr = File("./public/team.json", "r");
        char[] tmp;
        while (!teamJsonStr.eof)
            tmp ~= teamJsonStr.readln;

        auto teamJson = parseJsonString(tmp.to!string);
        string title = "チームリスト一覧";
        render!("ranking_all.dt", title, teamJson);
    }

    @method(HTTPMethod.GET) @path("/ranking/:team")
    void getRanking(HTTPServerRequest req, HTTPServerResponse res)
    {
        import shojin.user;
        import std.file;
        import std.utf;
        import std.conv;
        import std.algorithm;

        File teamJsonStr = File("./public/team.json", "r");
        char[] tmp;
        while (!teamJsonStr.eof)
            tmp ~= teamJsonStr.readln;
        auto teamJson = parseJsonString(tmp.to!string);
        auto teamName = req.params["team"];
        bool hasTeam = false;
        if (teamJson[teamName] != null)
        {
            import std.algorithm, std.range;

            auto teamData = teamJson[teamName];
            user[] users;
            hasTeam = true;
            import shojin.atcoder;

            auto atcoderJsonStr = atcoderUser.getAllUserInfoStr();
            foreach (key, value; teamData.byKeyValue)
            {
                users ~= user(key, value["aoj"].get!string,
                        value["atcoder"].get!string, atcoderJsonStr);
            }

            users.sort!"a.score > b.score";
            string title = teamName ~ " のランキング";
            render!("ranking.dt", title, hasTeam, teamData, users);
        }
        else
        {
        }
    }
}
