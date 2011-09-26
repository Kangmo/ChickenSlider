#ifndef _THX_RETAIN_COUNT_TRACE_H_
#define _THX_RETAIN_COUNT_TRACE_H_ (1)

#define SYNTESIZE_TRACE(X) \
- (id)retain {\
NSUInteger oldRetainCount = [super retainCount];\
id result = [super retain];\
NSUInteger newRetainCount = [super retainCount];\
NSLog(@"%@<%@> ++retainCount: %d => %d\n", [self class] , self, oldRetainCount, newRetainCount);\
NSLog(@"%@\n", [NSThread callStackSymbols]  );\
return result;\
}\
\
- (void)release {\
NSUInteger oldRetainCount = [super retainCount];\
BOOL gonnaDealloc = oldRetainCount == 1;\
if (gonnaDealloc) {\
NSLog(@"%@<%@> --retainCount: 1 => 0 (gonna dealloc)\n", [self class] , self);\
NSLog(@"%@\n", [NSThread callStackSymbols] );\
}\
[super release];\
if (!gonnaDealloc) {\
NSUInteger newRetainCount = [super retainCount];\
NSLog(@"%@<%@> --retainCount: %d => %d\n", [self class] , self, oldRetainCount, newRetainCount);\
NSLog(@"%@\n", [NSThread callStackSymbols] );\
}\
}

#endif /* _THX_RETAIN_COUNT_TRACE_H_ */