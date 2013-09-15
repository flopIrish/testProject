//
//  XMLToObjectParser.h
//

#import <Foundation/Foundation.h>

@interface XMLToObjectParser : NSObject <NSXMLParserDelegate> {
	NSString *className;
	NSMutableArray *items;
	NSObject *item; // stands for any class   
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
    
    NSString *trainCode;
    NSString *trainDirection;
    
    BOOL errorParsing;
    int elementCount;
}

@property (nonatomic) int elementCount;
@property (nonatomic, retain) NSMutableString *currentNodeContent;
@property (nonatomic, retain) NSString *currentNodeName;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSString *className;
@property (nonatomic, retain) NSString *trainCode;
@property (nonatomic, retain) NSString *trainDirection;

- (NSMutableArray *)items;
- (id)parseXMLAtURL:(NSURL *)url
		   toObject:(NSString *)aClassName
		 parseError:(NSError **)error;


@end
