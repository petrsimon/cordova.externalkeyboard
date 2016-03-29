module.exports = function(context) {

// This hook updates Cordova MainViewController.h & MainViewController.m
// files when installing ExternalKeyboard in iOS platform project.

var rc = '';
var fs = require('fs');
var path = require('path');

var rootdir = context.opts.projectRoot; // process.argv[2];
// var cmdline = process.env.CORDOVA_CMDLINE;
if ( rootdir /* && cmdline.indexOf('cordova platform add ios') >= 0 */ ) {

	try {
		// get project name from config.xml
		var project, configfile, contents, lines, line, i, ins;
		var first = 0; last = 0;
		configfile = path.join(rootdir, "config.xml");
		contents = fs.readFileSync(configfile, {encoding: "utf8"});
		if (contents) {
			lines = contents.split(/\r?\n/);
			for (i = 0; i < lines.length; i++) {
				line = lines[i].trim();
				pos1 = line.indexOf("<name>");
				pos2 = line.indexOf("</name>");
				if (pos1 === 0 && pos2 > pos1) {
					project = line.slice(6, pos2);
					break;
				}
			}
			if (project) {
				var plugindir = path.join(rootdir, "./platforms/ios/" + project + "/Plugins/com.atuhi.externalkeyboard");
				var stats = fs.lstatSync(plugindir);
				if (stats.isDirectory()) {
					var srcfile = path.join(rootdir, "./platforms/ios/" + project + "/Classes/MainViewController.m");
					var hdrfile = path.join(rootdir, "./platforms/ios/" + project + "/Classes/MainViewController.h");
					
					contents = fs.readFileSync(hdrfile, 'utf8');
					if (contents) {
						// modify MainViewController.h
						lines = contents.split(/\r?\n/);
						for (i = 0; i < lines.length; i++) {
							line = lines[i].trim();
							if (!first && (line === "@interface MainViewController : CDVViewController")) {
								first = i;
							}
							if (first && !last && (line === "@end")) {
								last = i;
								break;
							}
						}
						if (first && last) {
							// insert setKeyCommands method
							ins = '#import "ExternalKeyboard.h"\n' +
								'@interface MainViewController : CDVViewController {\n' +
								'NSMutableArray *commands; }\n' +
								'- (void) setKeyCommands:(NSArray*) commands;\n';
							lines[first] = ins;
							contents = lines.join('\n');
							fs.writeFileSync(hdrfile, contents, {encoding: 'utf8'});
						} else {
							rc = 'unable to find MainViewController interface definition in MainViewController.h';
						}
					} else {
						rc = "unable to read '" + hdrfile + "'";
					}

					if (!rc) {
						contents = fs.readFileSync(srcfile, 'utf8');
						if (contents) {
							// modify MainViewController.m
							lines = contents.split(/\r?\n/);
							first = last = 0;
							for (i = 0; i < lines.length; i++) {
								line = lines[i].trim();
								if (!first && (line === "@implementation MainViewController")) {
									first = i;
								}
								if (first && !last && (line === "@end")) {
									last = i;
									break;
								}
							}
							if (first && last) {
								// insert ExternalKeyboard implementation
								ins = '- (BOOL)canBecomeFirstResponder {\n' +
									'return YES; }\n' +
									'- (void) setKeyCommands: (NSMutableArray*) cmds {\n' +
									'commands = cmds; }\n' +
									'- (NSArray *)keyCommands {\n' +
									'return commands; }\n' +
									'- (void) onKeyPress:(UIKeyCommand*) cmd {\n' +
									'NSString *combo = [ExternalKeyboard getCombo:cmd];\n' +
									'NSString *jsStatement = [NSString stringWithFormat:@"handleKeyCommand(\'%@\')", combo];\n' +
									'[self.commandDelegate evalJs:jsStatement]; }\n' +
									'@end'
								lines[last] = ins;
								contents = lines.join('\n');
								fs.writeFileSync(srcfile, contents, {encoding: 'utf8'});
								console.log('successfully inserted ExternalKeyboard mods in MainViewController.h & MainViewController.m');
							} else {
								rc = 'unable to find MainViewController implementation in MainViewController.m';
							}
						} else {
							rc = "unable to read '" + srcfile + "'";
						}
					}
				}	
			} else {
				rc = 'failed to locate project name in config.xml file';
			}
		} else {
			rc = "unable to read project config file '" + configfile + "'";
		}
	} catch(e) {
		rc = e;
	}
	if (rc) {
		console.log(rc);
		process.exit(1);
	}
}

}

