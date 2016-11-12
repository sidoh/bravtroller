# bravtroller
Controller for Sony Bravia KDL-50W700.

## Installing

bravtroller is available on [Rubygems](https://rubygems.org). You can install it with:

```
$ gem install bravtroller
```

You can also add it to your Gemfile:

```
gem 'bravtroller'
```

## What is it?

My Sony TV (a KDL-50W700) has an API. It's a weird combination of custom Sony JSON-over-HTTP and UPnP/SOAP. I wanted a Ruby library to control it, so I created this. I wouldn't be very surprised if other network-enabled Sony devices supported roughly the same interface.

## Authentication

#### Summary

My TV requires that a device authenticate with it before controlling it remotely. You can use `Bravtroller::Authenticator` to do that. This is what happens:

1. `Bravtroller::Authenticator` initiates an authentication request
2. The TV displays a 4 digit security code
3. A user-provided block is called to supply the security code (I just used `gets`)
4. The security code is submitted to the TV, and `Bravtroller` will then be authenticated

#### Example 

```ruby
require 'bravtroller/client'
require 'bravtroller/authenticator'

auth = Bravtroller::Authenticator.new(BRAVIA_IP_ADDRESS)

a.authorized?
# => false

# This will initiate the procedure described above. The string returned is a cookie used by the SOAP client
a.authorize { gets.strip }
# > 3
# => "auth=xxxxxxx"

a.authorized?
# => true
```

## Example usage

The below example assumes Bravtroller has already been authenticated:

#### Remote emulator 

```ruby
require 'bravtroller/client'
require 'bravtroller/remote'

remote = Bravtroller::Remote.new(BRAVIA_IP_ADDRESS)

remote.buttons
# => ["PowerOff", "Input", "GGuide", "EPG", "Favorites", "Display", "Home", "Options", "Return", "Up", "Down", "Right", "Left", "Confirm", "Red", "Green", "Yellow", "Blue", "Num1", "Num2", "Num3", "Num4", "Num5", "Num6", "Num7", "Num8", "Num9", "Num0", "Num11", "Num12", "VolumeUp", "VolumeDown", "Mute", "ChannelUp", "ChannelDown", "SubTitle", "ClosedCaption", "Enter", "DOT", "Analog", "Teletext", "Exit", "Analog2", "*AD", "Digital", "Analog?", "BS", "CS", "BSCS", "Ddata", "PicOff", "Tv_Radio", "Theater", "SEN", "InternetWidgets", "InternetVideo", "Netflix", "SceneSelect", "Mode3D", "iManual", "Audio", "Wide", "Jump", "PAP", "MyEPG", "ProgramDescription", "WriteChapter", "TrackID", "TenKey", "AppliCast", "acTVila", "DeleteVideo", "PhotoFrame", "TvPause", "KeyPad", "Media", "SyncMenu", "Forward", "Play", "Rewind", "Prev", "Stop", "Next", "Rec", "Pause", "Eject", "FlashPlus", "FlashMinus", "TopMenu", "PopUpMenu", "RakurakuStart", "OneTouchTimeRec", "OneTouchView", "OneTouchRec", "OneTouchStop", "DUX", "FootballMode", "Social"]

remote.press_button('VolumeUp')
```

#### Wake on LAN

You can also use `Bravtroller` to turn on the TV. Mine responds to the standard WOL magic packet, which is what the below method is doing. Assuming the same setup as above:

```ruby
remote.power_on
# => true
```

The caveat is that `remote` must be constructed while the TV is powered on. This is because:

1. It needs to communicate with the TV to construct the SOAP client. This is an artificial limitation. It could cache the service definition.
2. It need to determine the hardware address of the TV (necessary to construct the WOL packet). It does this by shelling out and calling `arp`. If the TV isn't in the ARP cache, it won't be able to determine the hardware address. Again -- an artificial limitation.
