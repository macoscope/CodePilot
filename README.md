What is Code Pilot?
===================

Read the [full story](http://macoscope.com/blog/the-story-of-code-pilot/) of Code Pilot.

Code Pilot is a plugin for Xcode 5 that allows you to quickly find files, methods and symbols within your project without the need for your mouse. 
It uses fuzzy query matching to compute a list of results sorted by their relevancy. With just a few keystrokes you can jump to the method you're looking for.

![CodePilot Window](https://github.com/macoscope/CodePilot/raw/master/Screenshots/CodePilot_01.png "CodePilot Window")

More about original Code Pilot release [here](http://codepilot.cc/).

How to use Code Pilot?
======================

To use Code Pilot you have to build the CodePilot target and copy the resulting `CodePilot3.xcplugin` file to you plugin directory - `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins`. 

After that you need to install [update_xcode_plugins](https://github.com/inket/update_xcode_plugins)(which unsign Xcode and allow plugins to be installed again), and simply run: 

```shell
$ update_xcode_plugins
```

The you are all set!

Xcode 10 changes:
=================
First removed 
* libssl.dylib 
* libcrypto.dylib
from Linked Frameworks and Libraries

Then removed 
````
- (void)setupIndexingProgressIndicatorTimer
{
	if (nil == self.indexingProgressIndicatorTimer) {
		self.indexingProgressIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:[[self.indexingProgressIndicator cell] animationDelay]
                                                                           target:self
                                                                         selector:@selector(animateIndexingProgressIndicator:)
                                                                         userInfo:NULL
                                                                          repeats:YES];
    
		[[NSRunLoop currentRunLoop] addTimer:self.indexingProgressIndicatorTimer
                                 forMode:NSEventTrackingRunLoopMode];
	}
}
````
from `CPSearchController.m`.

License
=======

Copyright 2014 Macoscope Sp. z o.o.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
