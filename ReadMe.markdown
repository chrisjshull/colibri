#### Version 1.1.21, Current Release

Colibri what other color screen pickers cannot do.

<img src="https://github.com/cucurbita/colibri/raw/master/ReadMe/screenshot.jpg" />

###### Color history view:

1. The color you copy goes in this stack and the string representation to the pasteboard.
2. Drag and drop a color anywhere: Applications, System Color Picker or Folders. 
3. Double click on a color to remove it from the stack.

###### Global mode:

1. Added Hot key to copy. (for now read-only setting)

###### Known issue (Applies to any app using CG):

Apple Core Graphics API has a hard time with some GL Views (Apps, Games); misinterpreting the composite mask 
(anyway rare, in Radar, I was lucky to catch that, e.g randomly testing Colibri CPU usage on various views 
invalidating a lot). Syndrome: the magnifier will paint a green color (mask) you might time to time perceive 
our friend Roswell 8-) too. For any complaints you take the 101, then Exit Toward University Avenue 
(You know the Big IKEA, made for people like us(TM)), then make a left on Middlefield (... BIP ...) stop at 
the first House with (... BIP ...) on the rigth you can see (... BIP ...) with (... BIP ...) that's the # (... BIP ...) of (... BIP ...) kidding 8-).

#### Version 1.1.1

1. CPU usage and memory optimization. (maximum top noted with strong repaints e.g a video playing: 9.2% of CPU usage versus Apple (macbook pro, 12% on mac mini snow) !DigitalColor Meter: 44.8% and sometimes more).
2. Added activate/deactivate mouse moved event listener when the application is hidden (was really bad in term of CPU) or the window is miniaturized.
3. Removed discard mouse moved event when the window is miniaturized.


>
	- (oneway void)setActivatesMouseMovedEvents:(BOOL)activate {
			if (activate) {
					NSNumber *acceptEventGlobally = [[NSUserDefaults standardUserDefaults] 
							objectForKey:kColibriUserDefaultsAcceptEventGloballyKey
					];
					if ([acceptEventGlobally boolValue]) {
							[window setAcceptsMouseMovedEvents:YES global:YES receiver:self.magnifierView];
					} else {
							[window setAcceptsMouseMovedEvents:YES global:NO receiver:nil];
					}
			} else {
					[window setAcceptsMouseMovedEvents:NO global:NO receiver:nil];
			}
			return;
	}
>


#### Version 1.1.0 
	Added User Preferences option: Hexadecimal string prefixed by a hash sign when copying or saving a color.

#### Version 1.0.7
	Public release

#### Version 1.0.0
	Birth

#### Description
Colibri is a screen color picker for displaying the RGB color value of pixels on your Mac 100% Cocoa powered (e.g 
A Digital Color Meter, Colorimeter or similar to !DigitalColor Meter ©Apple, but using way far less CPU and with no bug). 
By using shorcut keys, you can display the RGB color value as percentage, absolute or hexadecimal, you can also 
save the solid color as a PNG/TIFF image on your Desktop, see bellow for available menu shortcut keys.

#### License
0. Mirroring  statistics or any author/project information of this repository is not allowed.
1. None of these following clauses apply to the Author or any other entities/persons endorsed and choosen by the Author.

###### source code:
1. New BSD License/Modified BSD License

###### build binary:
1. You cannot redistribute and claim colibri builds. 
2. You cannot host colibri builds for public downloads.
3. Hosting colibri build downloads is granted for private usage only.

#### Menu Color Keys


###### sub menu Value as:
	<command + 5> Actual Value
	<command + 6> Percentage Value
	<command + 7> Hexadecimal Value

###### main menu:
	<shift + command + C> Copy Text Value to the Clipboard
	<command + S> Save Color as a PNG/TIFF file named with its Hexadecimal Value.
	<command + J> Show System Color Picker (you can interact with it).

#### Menu View Keys


###### sub menu Position:
	<command + L> Lock/Unlock Actual X Y Position
	<command + X> Lock/Unlock Actual X Position
	<command + Y> Lock/Unlock Actual Y Position

###### main menu:
	<command + +> Zoom In Magnifier
	<command + -> Zoom Out Magnifier
	<shift + command + S> Save Magnifier as a PNG/TIFF file.

#### Menu Window Keys
	<command + M> Minimize
	<command + T> Float Top Level/Float Normal Level
	<shift + command + G> Mouse Events Globally/Window Focused Mouse Events
