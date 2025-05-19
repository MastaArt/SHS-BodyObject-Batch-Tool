/*  
[INFO] 
NAME=BodyObject Batch Tool
VERSION=1.0.0
AUTHOR=Vasyl Lukianenko
DEV=https://3dground.net
HELP=
CLIENT=Shestakovich

[ABOUT]
Script for batch-editing parameters of BodyObject types in 3ds Max=

[1.0.0]
* Initial release =

[UPDATE]
URL=https://raw.githubusercontent.com/MastaArt/SHS-BodyObject-Batch-Tool/main/
FILE=SHS-BodyObject-Batch-Tool.ms

[FILES]
Install.mcr=

[SCRIPT]
*/

struct utilsWrapper (
	fn maxVer  = (
		local v = (maxVersion())[1]
		v = 2000 + ((v / 1000) - 2)
		return v
	),
	fn boost = (
		windows.processPostedMessages() 
	),	
	fn formatString s v: #() tag: "$" = (
		for i in 1 to v.count  do (
			local t = v[i] as string
			s = substituteString s (tag + i as string) (t)
		)
		
		return s
	),
	fn trim s tag: " "= (
		return trimLeft (trimRight s tag) tag
	)
)

struct '@' (
	currScript = getThisScriptFileName(),
	name = getFilenameFile currScript,
	pth = getFileNamePath currScript,
	ini = pth +  sysinfo.username + "@" + sysinfo.computername + ".ini",
	--ini = (getThisScriptFileName()) + ".ini",
	sec = name,
	
	fn trim s tag: "" = (
		s as string
		return (trimLeft (trimRight s tag) tag)
	),
	
	fn add k v sec: "" = (
		if (sec == "") do sec = this.sec
		if (v == undefined) do v = ""
		setIniSetting this.ini sec k (v as string)
	),
	
	fn get k sec: "" type: #string = (
		if (sec == "") do sec = this.sec
		
		if (k == "") do return getINISetting this.ini sec
		
		local v = getIniSetting this.ini sec k
		
		case type of (
			#bool_true: return if (v == "true") then true else false
			#bool_false: return if (v == "false") then false else true
			#int: return try (v as integer) catch(0)
			#float: return try (v as float) catch(0.0)
		)
		
		return v
	),
	
	fn del k sec: "" = (
		if (sec == "") do sec = this.sec
		delIniSetting ini sec k
	),	
	
	fn delSec s = (
		delIniSetting ini s
	)
)

global '*' = '@'()	


try(closeRolloutFloater floaterBodyObjectBatchTool) catch()
global floaterBodyObjectBatchTool = newRolloutFloater "BodyObject Batch Tool" 300 405


rollout _rMain_BodyObjectBatchTool "BodyObject Batch Tools" category: 1 (
	group "Rendering Approximaiton" (
		checkbox cbxViewportMesh "Use Viewport Mesh"
	)
	
	group "Display Options" (
		radiobuttons rdoDisplayOptions "" labels: #("Curves", "Mesh", "Both")		
	)
	
	group "Mesh Quality Presets" (
		checkbutton cbxCoarse "Coarse" width: 65 across: 4
		checkbutton cbxMedium "Medium" width: 65
		checkbutton cbxFine "Fine" width: 65
		checkbutton cbxCustom "Custom" width: 65
	)
	
	group "Mesh Display" (
		label lblFaceApproxAngle "Face Approx Angle:" across: 2 align: #left
		spinner spnFaceApproxAngle "" fieldWidth: 70 align: #right
		
		label lblEdgeApproxAngle "Edge Approx Angle:" across: 2 align: #left
		spinner spnEdgeApproxAngle "" fieldWidth: 70 align: #right
		
		label lblFaceDistace "Face Distance %:" across: 2 align: #left
		spinner spnFaceDistace "" fieldWidth: 70 align: #right
		
		label lblEdgeDistace "Edge Distance %:" across: 2 align: #left
		spinner edgeEdgeDistace "" fieldWidth: 70 align: #right
		
		label lblMaxEdgeLen "Max Edge Len. %:" across: 2 align: #left
		spinner spnMaxEdgeLen "" fieldWidth: 70 align: #right
	)
	
	button btnApplyToSelected "Apply to Selected" width: 280 height: 35 offset: [0, 10]
	button btnApplyToScene "Apply to All in Scene" width: 280 offset: [0, 5]

	local meshQualityCbx = #(
		cbxCoarse,
		cbxMedium,
		cbxFine,
		cbxCustom
	)
	
	local meshDisplaySpn = #(
		#(lblFaceApproxAngle, spnFaceApproxAngle, "FaceApproxAngleVDS"),
		#(lblEdgeApproxAngle, spnEdgeApproxAngle, "EdgeApproxAngleVDS"),
		#(lblFaceDistace, spnFaceDistace, "FaceChordHeightVDS"),
		#(lblEdgeDistace, edgeEdgeDistace, "EdgeChordHeightVDS"),
		#(lblMaxEdgeLen, spnMaxEdgeLen, "MaxEdgeLengthPctVDS")
	)
	
	local presets = #(
		#(
			#("LowQualityVDS", true),
			#("MediumQualityVDS", false),
			#("HighQualityVDS", false),
			#("IsoAngleDS", 15),
			#("IsoChordHeightVDS", 0),
			#("FaceApproxAngleVDS", 30),
			#("EdgeApproxAngleVDS", 0),
			#("FaceChordHeightVDS", 1),
			#("EdgeChordHeightVDS", 0),
			#("MaxEdgeLengthPctVDS", 0)
		),
		#(
			#("LowQualityVDS", false),
			#("MediumQualityVDS", true),
			#("HighQualityVDS", false),
			#("IsoAngleDS", 7),
			#("IsoChordHeightVDS", 0),
			#("FaceApproxAngleVDS", 15),
			#("EdgeApproxAngleVDS", 0),
			#("FaceChordHeightVDS", 0.1),
			#("EdgeChordHeightVDS", 0),
			#("MaxEdgeLengthPctVDS", 0)
		),
		#(
			#("LowQualityVDS", false),
			#("MediumQualityVDS", false),
			#("HighQualityVDS", true),
			#("IsoAngleDS", 3),
			#("IsoChordHeightVDS", 0),
			#("FaceApproxAngleVDS", 10),
			#("EdgeApproxAngleVDS", 0),
			#("FaceChordHeightVDS", 0.02),
			#("EdgeChordHeightVDS", 0),
			#("MaxEdgeLengthPctVDS", 0)
		)/*,		
		#("Ultra", #(
			#("LowQualityVDS", false),
			#("MediumQualityVDS", false),
			#("HighQualityVDS", false),
			#("IsoAngleDS", 1),
			#("IsoChordHeightVDS", 0),
			#("FaceApproxAngleVDS", 5),
			#("EdgeApproxAngleVDS", 0),
			#("FaceChordHeightVDS", 0.005),
			#("EdgeChordHeightVDS", 0),
			#("MaxEdgeLengthPctVDS", 0))
		)*/
	)
	
	fn getPresetName quality = (
		return case quality of (
			1: "Coarse"
			2: "Medium"
			3: "Fine"
			default: "Custom"
		)
	)
	
	fn getQulaity = (
		local quality = '*'.get "meshQuality" type: #int		
		if (quality == 0) do quality = 4
		return quality
	)
	
	fn toggleUi quality = (
		for i in meshDisplaySpn do (
			local isEnabled = quality == 4
			i[1].enabled = isEnabled
			i[2].enabled = isEnabled
		)
	)
	
	fn loadSettings = (	
		cbxViewportMesh.checked = '*'.get "cbxViewportMesh" type: #bool_true
		
		local p1 = '*'.get "rdoDisplayOptions" type: #int
		if (p1 == 0) do p1 = 3
		rdoDisplayOptions.state = p1
	)
	
	fn loadMeshQuality = (
		for i in meshQualityCbx do i.checked = false
		local quality = getQulaity()
		
		try (meshQualityCbx[quality].checked = true) catch ()
		
		toggleUi quality
		
		if (presets[quality] != undefined) then (
			for i in meshDisplaySpn do (
				for p in presets[quality] do (
					if (p[1] == i[3]) do i[2].value = p[2]
				)
				
			)
		) else (
			spnFaceApproxAngle.value = '*'.get "spnFaceApproxAngle" type: #float
			spnEdgeApproxAngle.value = '*'.get "spnEdgeApproxAngle" type: #float
			spnFaceDistace.value = '*'.get "spnFaceDistace" type: #float			
			edgeEdgeDistace.value = '*'.get "edgeEdgeDistace" type: #float			
			spnMaxEdgeLen.value = '*'.get "spnMaxEdgeLen" type: #float
		)
		
	)
	
	fn toggleMeshQuality cbx quality = (
		for i in meshQualityCbx do i.checked = false
		if (not cbx.checked) do cbx.checked = true
		'*'.add "meshQuality" quality
		
		loadMeshQuality()
	)
	
	fn batchProcessBodyObjects entities: selection type: #selection = (
		local u = utilsWrapper()
		local objs = for i in entities where classOf i == Body_Object collect i
	
		if (objs.count == 0) do (
			case type of (
				#selection: return messageBox "No selected Body Objects objects!" title: "Warning!"
				default:  return messageBox "Not found Body Objects in scene!" title: "Warning!"
			)
		)
		
		if (type == #objects) do (
			local m = u.formatString "Do you really want to apply settings to the entire scene ($1 objects)?" v: #(objs.count)
			local q = queryBox m title: "Confirm?"
			if (not q) do return false
		)
		
		local quality = getQulaity()
		
		
		for o in objs do (
			o.RenderViewportMeshRA = cbxViewportMesh.checked
			o.DisplayRadioVDS = case rdoDisplayOptions.state of (
				1: 2
				2: 1
				3: 0
			)
			
			if (presets[quality] != undefined) then (
				for p in presets[quality] do setProperty o p[1] p[2]
			) else (				
				o.LowQualityVDS = false
				o.MediumQualityVDS = false
				o.HighQualityVDS = false
				o.FaceApproxAngleVDS = spnFaceApproxAngle.value 
				o.EdgeApproxAngleVDS = spnEdgeApproxAngle.value 
				o.FaceChordHeightVDS = spnFaceDistace.value 
				o.EdgeChordHeightVDS = edgeEdgeDistace.value 
				o.MaxEdgeLengthPctVDS = spnMaxEdgeLen.value
			)
		)
		
		local presetName = getPresetName quality
		
		local m = u.formatString "Done!\n\nPreset: $1\nProcessed Body Objects: $2" v: #(presetName, objs.count)	
		messageBox m title: "Done!"
	)
	
	on _rMain_BodyObjectBatchTool open do (
		loadSettings()
		loadMeshQuality()
	)
	
	on cbxCoarse changed v do toggleMeshQuality cbxCoarse 1
	on cbxMedium changed v do toggleMeshQuality cbxMedium 2
	on cbxFine changed v do toggleMeshQuality cbxFine 3
	on cbxCustom changed v do toggleMeshQuality cbxCustom 4
	
	on spnFaceApproxAngle changed v do '*'.add "spnFaceApproxAngle" v
	on spnEdgeApproxAngle changed v do '*'.add "spnEdgeApproxAngle" v
	on spnFaceDistace changed v do '*'.add "spnFaceDistace" v
	on edgeEdgeDistace changed v do '*'.add "edgeEdgeDistace" v
	on spnMaxEdgeLen changed v do '*'.add "spnMaxEdgeLen" v
		
	on cbxViewportMesh changed v do '*'.add "cbxViewportMesh" v
	on rdoDisplayOptions changed v do '*'.add "rdoDisplayOptions" v
	
	on btnApplyToSelected pressed do batchProcessBodyObjects entities: selection type: #selection
	on btnApplyToScene pressed do batchProcessBodyObjects entities: objects type: #objects	
)


rollout _rAbout_BodyObjectBatchTool "About" category: 999 (
	group "Description" (
		dotNetControl edtDescription "System.Windows.Forms.Textbox" align:#center height: 60
	)
	
	label lblDummy1 ""
	
	label lblName "" 
	label lblVer ""
	label lblClient ""
	
	label lblDummy2 ""
	
	label lblAuthor ""
	hyperlink lblCopy ""  align: #center color: orange
	
	label lblDummy3 ""
	
	timer tmrRestart "" active: false interval: 300
		
	fn downloadFile url dl = (
		deleteFile dl
		w = dotNetObject "System.Net.WebClient"			
		try(
			spm = dotNetClass "System.Net.ServicePointManager"
			spm.SecurityProtocol = spm.SecurityProtocol.TLS12				
			w.DownloadFile (url + "?time=" + timestamp() as string) dl				
		) catch(
			return false
		)
		
		return true
	)
	
	fn bgUpdate = (
		local this = getThisScriptFileName()
		local p = getFileNamePath (getThisScriptFileName())
		
		local url = getIniSetting this "UPDATE" "URL"
		local file = getIniSetting this "UPDATE" "FILE"
		local main = url + file
			
		if (url == "" or file == "") do return false
		
		local dl = this + ".tmp"
		local r = downloadFile main dl
		if(not r or not doesFileExist dl) do return (print ("Can't download updates for " + file + "!"))
		local vn = getIniSetting dl "INFO" "VERSION"
		local vo = getIniSetting this "INFO" "VERSION"
		local additionalFiles = getIniSetting dl "FILES"
		
		if(vn > vo) do (
			deleteFile this
			renameFile dl this
			
			for n in additionalFiles do (
				local s = getIniSetting dl "FILES" n
				if (s == "") do downloadFile (url + n) (p + n)
				if (s == "deleted") do deleteFile (p + n)
			)
			
			tmrRestart.active = true
		)
		
		deleteFile dl
	)
	
	fn updateWorker = (
		m = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"
		m.WorkerSupportsCancellation = true 
		m.CancelAsync() 
		dotNet.addEventHandler m "DoWork" bgUpdate
		m.RunWorkerAsync()	
	)
	
	fn getScriptInfo s releaseInfo: "" =  (
		if(releaseInfo != "") do (
			local r = getINISetting s releaseInfo
			return r
		)
		
		local v = getINISetting s "INFO" "VERSION"
		local a = getINISetting s "INFO" "AUTHOR"
		local n = getINISetting s "INFO" "NAME"
		local o = ""
		for i in (getINISetting s "ABOUT") do o += i + "\r\n"
		local d = getINISetting s "INFO" "DEV"
		local h = getINISetting s "INFO" "HELP"
		local c = getINISetting s "INFO" "CLIENT"
		
		struct data (version, author, name, description, developer, client, help, releases)
		
		local r = for i in (getINISetting s) where (i != "ABOUT" and i != "SCRIPT" and i != "COPY") collect i
		
		return (data version: v author: a name: n description: o developer: d client: c help: h releases: r)
	)
	
	on tmrRestart tick do (
		this = getThisScriptFileName()
		try(fileIn this) catch()
		vo = getIniSetting this "INFO" "VERSION"
		m = ("Script updated to version " + vo + "!\n\n\n")
		for c in (getIniSetting this vo) do (
			m += c + "\n"
		)
		
		--messageBox m title: "Success!" beep: false
		print "---UPDATED---"
		print m
		tmrRestart.active = false
	)

	on _rAbout_BodyObjectBatchTool open do (
		edtDescription.MultiLine = true
		edtDescription.WordWrap = true
		edtDescription.ReadOnly = true
		edtDescription.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		
		
		local i = getScriptInfo (getThisScriptFilename())
		
		lblName.caption = i.name
		lblAuthor.caption = i.author
		lblVer.caption = i.version
		lblCopy.address = lblCopy.caption = i.developer
		lblClient.caption = i.client
		edtDescription.text = i.description
		
		try (floaterBodyObjectBatchTool.title = i.name + " " + i.version) catch()
		try (_rMain_BodyObjectBatchTool.title = i.name + " v" +  i.version) catch()
		
		updateWorker()
		
		local x = '*'.get "x"
		local y = '*'.get "y"
		
		if (x != "" and y != "") do (
			x = x as integer
			y = y as integer
			floaterBodyObjectBatchTool.pos = [x, y] 
		)		
	)
	
	on _rAbout_BodyObjectBatchTool close do (
		local p = floaterBodyObjectBatchTool.pos
		
		'*'.add "x" p.x
		'*'.add "y" p.y
	)	
)

addRollout _rMain_BodyObjectBatchTool floaterBodyObjectBatchTool rolledUp: false
addRollout _rAbout_BodyObjectBatchTool floaterBodyObjectBatchTool rolledUp: true