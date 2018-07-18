module shojin.user;

struct user
{
    import shojin.aoj;
    import shojin.atcoder;

    string name, aojId, atcoderId;
    aojUser aojInfo;
    atcoderUser atcoderInfo;
    int score;

    this(string name, string aojId, string atcoderId, string atcoderAllUserInfoStr)
    {
        this.name = name;
        this.aojId = aojId;
        this.atcoderId = atcoderId;
        aojInfo = aojUser(aojId);
        atcoderInfo = atcoderUser(atcoderId, atcoderAllUserInfoStr);
        score = getScore();
    }

    int getScore()
    {
        return atcoderInfo.acCount + aojInfo.acCount;
    }

}
