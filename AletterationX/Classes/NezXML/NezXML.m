//
//  NezXML.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezXML.h"

@implementation NezXML {
	xmlDocPtr _doc;
	BOOL _isHTML;
}

+(instancetype)xmlDocWithData:(NSData*)data encoding:(NSString*)encoding {
	return [[self alloc] initWithXMLData:data encoding:encoding];
}

+(instancetype)xmlDocWithData:(NSData*)data {
	return [[self alloc] initWithXMLData:data];
}

+(instancetype)htmlDocWithData:(NSData*)data encoding:(NSString *)encoding {
	return [[self alloc] initWithHTMLData:data encoding:encoding];
}

+(instancetype)htmlDocWithData:(NSData*)data {
	return [[self alloc] initWithHTMLData:data];
}

-(instancetype)initWithXMLData:(NSData*)data encoding:(NSString*)encoding {
	if ((self = [super init])) {
		const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
		_doc =xmlReadMemory(data.bytes, (int)data.length, "", encoded, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	}
	return self;
}

-(instancetype)initWithXMLData:(NSData*)data {
	return [self initWithXMLData:data encoding:nil];
}

-(instancetype)initWithHTMLData:(NSData*)data encoding:(NSString *)encoding {
	if ((self = [super init])) {
		const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
		_doc = htmlReadMemory(data.bytes, (int)data.length, "", encoded, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	}
	return self;
}

-(instancetype)initWithHTMLData:(NSData*)data {
	return [self initWithHTMLData:data encoding:nil];
}

-(NSArray*)performXPathQuery:(NSString*)query {
	xmlXPathContextPtr xpathCtx;
	xmlXPathObjectPtr xpathObj;
	
	/* Create xpath evaluation context */
	xpathCtx = xmlXPathNewContext(_doc);
	if(xpathCtx == NULL) {
      NSLog(@"Unable to create XPath context.");
      return nil;
	}
	
	/* Evaluate xpath expression */
	xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
	if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		xmlXPathFreeContext(xpathCtx);
		return nil;
	}
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes) {
      xmlXPathFreeObject(xpathObj);
      xmlXPathFreeContext(xpathCtx);
      return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++) {
		[resultNodes addObject:[NezXMLElement elementWithXMLNode:nodes->nodeTab[i]]];
	}
	/* Cleanup */
	xmlXPathFreeObject(xpathObj);
	xmlXPathFreeContext(xpathCtx);
	
	return resultNodes;
}

-(void)deleteNodesWithXPathQuery:(NSString*)query {
	NSArray *elementList = [self performXPathQuery:query];
	for (NezXMLElement *element in elementList) {
		[element deleteElement];
	}
}

-(void)recursivelyDeleteAllElementsWithName:(NSString*)elementName {
	xmlNodePtr root = xmlDocGetRootElement(_doc);
	NezXMLElement *rootElement = [NezXMLElement elementWithXMLNode:root];
	[rootElement recursivelyDeleteAllElementsWithName:elementName];
}

-(void)dealloc {
	xmlFreeDoc(_doc);
}

@end
