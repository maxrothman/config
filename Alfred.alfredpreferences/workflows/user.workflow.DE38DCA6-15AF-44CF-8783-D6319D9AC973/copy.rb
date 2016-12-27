#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
require 'osx/cocoa'
include OSX

arg = NSString.stringWithString(ARGV[0])
paths = arg.componentsSeparatedByString("\t")

pb = NSPasteboard.generalPasteboard
pb.clearContents

pb.declareTypes_owner(NSArray.arrayWithObject(NSFilenamesPboardType), nil)
pb.setPropertyList_forType(paths, NSFilenamesPboardType)