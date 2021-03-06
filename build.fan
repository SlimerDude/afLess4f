using build
using compiler

class Build : BuildPod {

	new make() {
		podName = "afLess4f"
		summary = "A wrapper around Less4j - the pure Java compiler for Less"
		version = Version("0.0.3")

		meta = [	
			"proj.name"		: "less4f",
			"repo.tags"		: "app, web",
			"repo.internal"	: "true",
			"license.name"	: "Apache Licence, Version 2.0",
			"repo.public"	: "false"
		]

		depends = [
			"sys  1.0",
			"util 1.0",
		]

		srcDirs = [`fan/`, `test/`]
		resDirs = [`doc/`]
	}
	
	override Void onCompileFan(CompilerInput ci) {
		
		// create an uber.jar
		jarDir := File.createTemp("afLess4f-", "")
		jarDir.delete
		jarDir = Env.cur.tempDir.createDir(jarDir.name).normalize

		echo
		`lib/`.toFile.normalize.listFiles(Regex.glob("*.jar")).each |jar| {
			echo("Expanding ${jar.name} to ${jarDir.osPath}")
			zipIn := Zip.read(jar.in)
			File? entry
			while ((entry = zipIn.readNext) != null) {
				fileOut := jarDir.plus(entry.uri.relTo(`/`))
				entry.copyInto(fileOut.parent, ["overwrite" : true])
			}
			zipIn.close
		}

		jarFile := jarDir.parent.createFile("${jarDir.name}.jar")
		zip  := Zip.write(jarFile.out)
		parentUri := jarDir.uri
		jarDir.walk |src| {
			if (src.isDir) return
			path := src.uri.relTo(parentUri)
			out := zip.writeNext(path)
			src.in.pipe(out)					
			out.close
		}
		zip.close
		
		jarDir.delete

		echo
		echo("Created Uber Jar: ${jarFile.osPath}")
		echo
		
		ci.resFiles.add(jarFile.deleteOnExit.uri)
	}
}
