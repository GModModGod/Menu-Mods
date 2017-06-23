
var menumods = {
	hook: {
		Run: function(identifier, args)
		{
			var currString = "menumods.hook.Run(\"" + identifier + "\""
			
			for(i = 0; i < args.length; i++) {
				currString += ", \"" + args[i] + "\""
			}
			
			currString += ")"
			
			lua.Run(currString)
		}
	}
}

lua.Run("local exec = CompileString(file.Read(\"lua/autorun/menu/menumods_init.lua\", \"GAME\"), \"autorun/menu/menumods_init.lua\", true); exec()")
