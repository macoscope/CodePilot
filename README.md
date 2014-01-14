What is Code Pilot?
===================

Code Pilot is a plugin for Xcode 5 that allows you to quickly find files, methods and symbols within your project without the need for your mouse. 
It uses fuzzy query matching to compute a list of results sorted by their relevancy. With just a few keystrokes you can jump to the method you're looking for.

![CodePilot Window](https://github.com/macoscope/CodePilot/raw/master/Screenshots/CodePilot_01.png "CodePilot Window")

More about original Code Pilot release [here](http://codepilot.cc/).

How to use Code Pilot?
======================

To use Code Pilot you have to build the project and copy the resulting `CodePilot3.xcplugin` file to you plugin directory - `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins`. 

Alternatively you can build the installer package and use it to install the plugin (it essentially just moves the xcplugin to the Plug-ins directory). 
To load the plugin you have to restart Xcode 5.

NOTE: In order to build a package you may need to install PackageMaker.app included in "Auxiliary tools for Xcode" [PackageMaker](https://developer.apple.com/downloads/index.action?name=PackageMaker)

When the plugin is loaded you can open the CodePilot window with CMD + SHIFT + X, and then type your query.

License
=======

Copyright 2014 Macoscope Sp. z o.o.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
