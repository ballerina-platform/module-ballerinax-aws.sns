import ballerina/http;

public class TopicsStream {

    private final http:Client amazonSNSClient;
    private final (isolated function(map<string>) returns http:Request|Error) & readonly generateRequest;
    private string[] topics = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient, 
        isolated function (map<string>) returns http:Request|Error generateRequest) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
    }

    private isolated function fetchTopics() returns Error? {
        map<string> parameters = initiateRequest("ListTopics");
        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListTopicsResponse.ListTopicsResult.NextToken;
        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] topics = <json[]>(check response.ListTopicsResponse.ListTopicsResult.Topics);
            foreach json topic in topics {
                self.topics.push((check topic.TopicArn).toString());
            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|string value;|}|Error? {
        if self.topics.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchTopics();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        return {value: self.topics.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}
