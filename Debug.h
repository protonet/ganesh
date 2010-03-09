#ifndef _DEBUG_H
#define _DEBUG_H

#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog(format, ...) do {} while (0)
#endif

#endif /* _DEBUG_H */
