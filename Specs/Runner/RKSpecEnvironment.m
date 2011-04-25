//
//  RKSpecEnvironment.m
//  RestKit
//
//  Created by Blake Watters on 3/14/11.
//  Copyright 2011 Two Toasters. All rights reserved.
//

#import "RKSpecEnvironment.h"

NSString* RKSpecGetBaseURL() {
    char* ipAddress = getenv("RESTKIT_IP_ADDRESS");
    if (NULL == ipAddress) {
        ipAddress = "localhost";
    }
    
    return [NSString stringWithFormat:@"http://%s:4567", ipAddress];
}

void RKSpecStubNetworkAvailability(BOOL isNetworkAvailable) {
    RKClient* client = [RKClient sharedClient];
    if (client) {
        id mockClient = [OCMockObject partialMockForObject:client];
        [[[mockClient stub] andReturnValue:OCMOCK_VALUE(isNetworkAvailable)] isNetworkAvailable];
    }
}
