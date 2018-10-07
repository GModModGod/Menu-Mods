Follow the tutorial below (from [this](http://wiki.garrysmod.com/page/Panel_Customization) Garry's Mod Wiki page), but instead of placing the source code in the usual folder ("lua/vgui"), place it in the folder "lua/vgui_menu".

# Panel Customization

Sometimes you may wish to create a custom VGUI Panel for an addon or gamemode.
## Create a Table

The first step in creating a custom VGUI Panel is to create a table.
```
local PANEL = {}
```
## Then Add Functions

We can give our table a function so Garry's Mod knows what to do to it when it's initialized.
```
function PANEL:Init()
	self:SetSize( 100, 100 )
	self:Center()
end
```
We use `self:SetSize( 100, 100 )` to set the size of our panel to 100 pixels wide and 100 pixels tall. `self:Center()` centers our panel in the middle of our parent (if no parent is given it will center the panel in the middle of the screen).

We can also give our table a function to tell Garry's Mod what we should do when we want to paint the panel on the screen.
```
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
end
```
In this function we call `draw.RoundedBox(..)` to draw our panel with the dimensions defined in `self:SetSize()`. We start at 0,0 because this is the top-most-left-most point in our panel.
Finally We Register

The final step in creating a custom VGUI Panel is to register the table.

vgui.Register( "MyFirstPanel", PANEL, "Panel" )

Where; _"MyFirstPanel"_ is the desired name of your panel to be used when you wish to create it. _PANEL_ is the table we have created and _"Panel"_ is the type of element you wish to use as a base.
## Result

You can now create your custom panel by using
```
local pnl = vgui.Create( "MyFirstPanel", parentpanel )
```
or
```
local pnl = parentpanel:Add( "MyFirstPanel" )
```
## Complete Code
```
local PANEL = {}

function PANEL:Init()
	self:SetSize( 100, 100 )
	self:Center()
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
end

vgui.Register( "MyFirstPanel", PANEL, "Panel" )
```
