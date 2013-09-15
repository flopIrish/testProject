//
//  XMLToObjectParser.m
//

#import "XMLToObjectParser.h"

@implementation XMLToObjectParser

@synthesize elementCount, currentNodeContent, currentNodeName, items, className, trainCode, trainDirection;

-(id)init {
    self = [super init];
    if(self) {
        self.items = nil;
        self.trainCode = nil;
    }
    return self;
}

- (NSMutableArray *)items {
	return items;
}

- (id)parseXMLAtURL:(NSURL *)url toObject:(NSString *)aClassName parseError:(NSError **)error {
    
    //NSLog(@"XMLToObjectParser url=%@",url);
    
	self.items = [[NSMutableArray alloc] init];
    if(aClassName != nil) {
        self.className = [NSString stringWithString:aClassName];
    } else {
        self.className = nil;
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	
	if([parser parserError] && error) {
		*error = [parser parserError];
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
    
    //NSLog(@"START-------- didStartElement : elementName=<%@> self.currentNodeName<%@>, currentNodeContent=<%@>", elementName, self.currentNodeName, currentNodeContent);
    
	if(self.className != nil && [elementName isEqualToString:self.className]) {
        // create an instance of a class on run-time 
		item = [[NSClassFromString(self.className) alloc] init];
        elementCount++; //compte le nombre de réponses dans xml. 
	} else {
		self.currentNodeName = [elementName copy];
		self.currentNodeContent = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    //NSLog(@"END ---- didEndElement : elementName=<%@> self.currentNodeName<%@>, self.currentNodeContent=<%@>", elementName, self.currentNodeName, self.currentNodeContent);
    if(self.className != nil) {
        
        if([elementName isEqualToString:self.className]) {
            //////NSLog(@"self.className=%@",self.className);
            [self.items addObject:item];
            //[item release];
            item = nil;
        } else if([elementName isEqualToString:self.currentNodeName]) {
            // use key-value coding
            if([item respondsToSelector:NSSelectorFromString(elementName)]) {
                [item setValue:self.currentNodeContent forKey:elementName];
            } else {
                ////NSLog(@"this class %@ is not key value coding-compliant for the key %@",self.className, elementName);
            }
            
            self.currentNodeContent = nil;
            self.currentNodeName = nil;
        }
    } else {
        if([elementName isEqualToString:@"Traincode"]) {
            self.trainCode = [NSString stringWithString:self.currentNodeContent];
        }
        
        if([elementName isEqualToString:@"Direction"]) {
            self.trainDirection = [NSString stringWithString:self.currentNodeContent];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //////NSLog(@"XMLToObjectParser : foundChar string=<%@>",string);
	[self.currentNodeContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    NSString *errorString = [NSString stringWithFormat:@"Error code %i", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
    
    errorParsing=YES;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (errorParsing == NO) {
        //NSLog(@"XML processing done! elementCount = <%d>", elementCount);
    } else {
        //NSLog(@"Error occurred during XML processing");
    }
    
}


@end
