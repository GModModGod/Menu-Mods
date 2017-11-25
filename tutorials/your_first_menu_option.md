# Tutorial: Your First Menu Option

One of the main features this addon offers is the ability to run user-created Lua files in the main menu. In this tutorial, we will be
learning how to add custom menu options to the main menu and pause menu.

## Preparing Your Autorun File

Place a blank .lua file with a unique name into the "lua/autorun/menu" directory of your addon. This will be the file containing the code for your menu option.

## Choosing a Location for Your Menu Option

For adding an option to the Garry's Mod menu, Menu Mods offers almost every location on the screen.
The class names of these locations can be seen in the diagram below.

![Main Menu Diagram](/tutorials/images/Main_Menu_Diagram.png?raw=true "Main Menu Diagram")

Refer to the diagram for further instruction.

## Different Methods

There are three main functions used to add HTML tags to different parts of the page, the last two of which are specific to `<a>` tags. Each of these functions uses the data structure shown below.

Key | Value Type | Purpose
--- | ---------- | -------
urls | table | Determines which pages this element should be added to.
tag | string | Determines the type of HTML tag the element is. Unlike html, the tag name should be in all caps. (Ex. "A" for a `<a>` tag, "P" for a `<p>` tag, etc.)
