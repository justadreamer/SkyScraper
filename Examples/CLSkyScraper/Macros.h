//
//  Macros.h
//  Tests
//
//  Created by Eugene Dorfman on 10/25/14.
//
//

#ifndef Tests_Macros_h
#define Tests_Macros_h

#define QUOTED(s) [NSString stringWithFormat:@"'%@'",s]
#define RSLASH(s) ([s characterAtIndex:[s length]-1]=='/' ? s : [s stringByAppendingString:@"/"])
#endif
