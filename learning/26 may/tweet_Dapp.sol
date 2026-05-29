// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Twitter {

    uint16 public MAX_TWEET_LENGTH = 280;

    struct Tweet {
        uint id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Tweet[]) public tweets;


    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet too long!");

        uint tweetId = tweets[msg.sender].length;

        tweets[msg.sender].push(
            Tweet({
                id: tweetId,
                author: msg.sender,
                content: _tweet,
                timestamp: block.timestamp,
                likes: 0
            })
        );
    }

    function likeTweet(address _author, uint _id) public {
        require(_id < tweets[_author].length, "Tweet does not exist");
        tweets[_author][_id].likes++;
    }

    function dislikeTweet(address _author, uint _id) public {
        require(_id < tweets[_author].length, "Tweet does not exist");
        require(tweets[_author][_id].likes > 0, "No likes to remove");
        tweets[_author][_id].likes--;
    }

    function getAllTweets(address _owner)
        public
        view
        returns (Tweet[] memory)
    {
        return tweets[_owner];
    }
}