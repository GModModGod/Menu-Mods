
var menumods = 
{
	string: {
		escChars: [["\b", "b"], ["\f", "f"], ["\n", "n"], ["\r", "r"], ["\t", "t"], ["\v", "v"], ["\"", "\""], ["\'", "\'"]],
		regExpChars: [[/\-/g, "\\-"], [/\[/g, "\\["], [/\]/g, "\\]"], [/\//g, "\\/"], [/\{/g, "\\{"], [/\}/g, "\\}"], [/\(/g, "\\("], [/\)/g, "\\)"], [/\*/g, "\\*"], [/\+/g, "\\+"], [/\?/g, "\\?"], [/\./g, "\\."], [/\^/g, "\\^"], [/\$/g, "\\$"], [/\|/g, "\\|"]],
		patternSafe: function(str)
		{
			var newString = ("" + str);
			
			newString = newString.replace(/\\/g, "\\\\");
			
			var k;
			var regExpChars = menumods.string.regExpChars;
			
			for (k in regExpChars) {
				newString = newString.replace(regExpChars[k][0], regExpChars[k][1]);
			}
			
			return newString;
		},
		levelPush: function(str, numLevels, noOuterQuotes)
		{
			var numLevels_new = numLevels;
			
			if (numLevels_new == undefined) {
				numLevels_new = 1;
			}
			
			var newString = ("" + str);
			var i;
			
			for (i = 0; i < numLevels_new; i++) {
				newString = newString.replace(/\\/g, "\\\\");
				
				var k;
				var escChars = menumods.string.escChars;
				
				for (k in escChars) {
					var pattern1 = new RegExp(menumods.string.patternSafe(escChars[k][0]), "g")
					var pattern2 = "\\" + menumods.string.patternSafe(escChars[k][1])
					
					newString = newString.replace(pattern1, pattern2);
				}
				
				if (!noOuterQuotes) {
					newString = ("\"" + newString + "\"");
				}
			}
			
			return newString;
		},
		levelPop: function(str, numLevels)
		{
			var numLevels_new = numLevels;
			
			if (numLevels_new == undefined) {
				numLevels_new = 1;
			}
			
			var newString = ("" + str);
			var i;
			
			for (i = 0; i < numLevels_new; i++) {
				var k;
				var escChars = menumods.string.escChars;
				
				for (k in escChars) {
					var currStr = menumods.string.patternSafe(escChars[k][0])
					
					var pattern1 = new RegExp(("^" + currStr), "g");
					var pattern2 = new RegExp(("([^\\\\])" + currStr), "g");
					var pattern3 = new RegExp(("\\\\" + menumods.string.patternSafe(escChars[k][1])), "g");
					
					newString = newString.replace(pattern1, "");
					newString = newString.replace(pattern2, "$1");
					newString = newString.replace(pattern3, currStr);
				}
				
				newString = newString.replace(/\\\\/g, "\\");
			}
			
			return newString;
		}
	}
}

lua.Run("local exec = CompileString(file.Read(\"lua/autorun/menu/menumods_init.lua\", \"GAME\"), \"autorun/menu/menumods_init.lua\", true); exec()")
