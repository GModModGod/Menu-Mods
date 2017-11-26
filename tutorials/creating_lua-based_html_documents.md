# Tutorial: Creating Lua-Based HTML Documents

In this tutorial, we will be learning how to create Lua-Based HTML Documents that can be opened in any lua browser.

## Preparing your File

Place a blank .lua file with a unique name into the "lua/htmldocs" directory of your addon. This will be the file containing the code for your HTML document.

## Setting the Base Class

If you would not like to start from scratch, type `LUA_HTML.Base = "BASE NAME HERE"` in your file to set the desired base for your document.

## Creating the Head and Body

For the head of your document, type `LUA_HTML.Head = [[HTML HEAD HERE]]`.
Next, type `LUA_HTML.Body = [[HTML BODY HERE]]` to set the body of your document.

## Optional Custom Functions

