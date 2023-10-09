
public type ListTopicsResponse record {|
    string[] topicArns;
    string? nextToken;
|};

public type PublishMessageResponse record {|
    string messageId;
    string sequenceNumber?;
|};

public type PublishBatchResponse record {|
    PublishBatchResultEntry[] successful;
    BatchResultErrorEntry[] failed;
|};

public type PublishBatchResultEntry record {|
    string id;  
    string messageId;
    string sequenceNumber?;
|};

public type BatchResultErrorEntry record {|
    string code;
    string id;
    boolean senderFault;
    string message?;
|};
