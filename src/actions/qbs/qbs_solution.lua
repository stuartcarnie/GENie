--
-- GENie - Project generator tool
-- https://github.com/bkaradzic/GENie#license
--

local qbs = premake.qbs

function qbs.generate_solution(sln)

	_p('/*')
	_p(' * QBS project file autogenerated by GENie')
	_p(' * https://github.com/bkaradzic/GENie')
	_p(' */')
	_p('')
	_p('import qbs')
	_p('')

	_p(0, 'Project {')

	_p(1, 'references: [')
	for prj in premake.solution.eachproject(sln) do
		_p(2, '"' .. prj.name .. '.qbs",')
	end
	_p(1, ']')

	_p(0, '}')
end

local function is_app(kind)
	if kind == "ConsoleApp" or kind == "WindowedApp" then
		return true
	end

	return false
end

function qbs.generate_user(sln)

	_p(0, '<?xml version="1.0" encoding="UTF-8"?>')
	_p(0, '<!DOCTYPE QtCreatorProject>')
	_p(0, '<!-- QBS project file autogenerated by GENie https://github.com/bkaradzic/GENie -->')
	_p(0, '<qtcreator>')

	local startProject = 0
	local idx = 0

	for prj in premake.solution.eachproject(sln) do
		if is_app(prj.kind) then
			if sln.startproject == prj.name then
				startProject = idx
			end
			idx = idx + 1
		end
	end

	_p(1, '<data>')
	_p(2, '<variable>ProjectExplorer.Project.Target.0</variable>')

	_p(2, '<valuemap type="QVariantMap">')

	_p(3, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">Desktop</value>')
	_p(3, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName">Desktop</value>')

	local qbsguid    = ""
	local qbsprofile = ""

	local qtcreatordir = ""

	if _OS == "windows" then
		qtcreatordir = path.join(os.getenv("APPDATA"), "QtProject/qtcreator")
	else
		qtcreatordir = path.join(os.getenv("HOME"), ".config/QtProject/qtcreator")
	end

	local file = io.open(path.join(qtcreatordir, "qbs.conf"))
	if file == nil then
		file = io.open(path.join(qtcreatordir, "qbs/1.6.0/qbs.conf"))
		if file ~= nil then
			for line in file:lines() do
				if line == "[org]" then
					-- BK - Need to figure out how to extract kit associated profile name/guid...
					--  ~.config/QtProject/qtcreator/qbs.conf
					--
					-- [org]
					-- qt-project\qbs\preferences\qtcreator\kit\%7B9926e565-8fc0-448d-9d5d-4b0293efd443%7D=qtc_Desktop_1bffddf2
					--
					local str = 'qt-project\\qbs\\preferences\\qtcreator\\kit\\%'
					local index = string.len(str)+1
					for line in file:lines() do
						if index == string.find(line, '7B', index) then
							line = string.sub(line, index+2)
							qbsguid    = string.sub(line, 1, 36)
							qbsprofile = string.sub(line, 41)
							--print(qbsguid, qbsprofile)
							break
						end
					end
				else
					-- ~/.config/QtProject/qtcreator/qbs/1.6.0/qbs.conf
					--
					-- <key>org.qt-project.qbs.preferences.qtcreator.kit.{d67ae030-7a33-43e0-850a-afe9e47fe5e1}</key>
					-- <string>qtc_Desktop_ee88281c</string>

					local str = '\t<key>org.qt-project.qbs.preferences.qtcreator.kit.'
					local index = string.len(str)+1
					for line in file:lines() do
						if qbsguid == "" and index == string.find(line, '{', index) then
							line = string.sub(line, index+1)
							qbsguid = string.sub(line, 1, 36)
						elseif qbsguid ~= "" then
							qbsprofile = string.sub(line, 10, 29)
							--print(qbsguid, qbsprofile)
							break
						end
					end
				end

				break
			end
			io.close(file)
		end
	end

	_p(3, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">{%s}</value>', qbsguid)

	_p(3, '<value type="int" key="ProjectExplorer.Target.ActiveBuildConfiguration">0</value>')
	_p(3, '<value type="int" key="ProjectExplorer.Target.ActiveDeployConfiguration">0</value>')
	_p(3, '<value type="int" key="ProjectExplorer.Target.ActiveRunConfiguration">%d</value>', startProject)

	-- BuildConfiguration
	idx = 0
	for _, cfgname in ipairs(sln.configurations) do
		-- cfg.objectsdir
		_p(3, '<valuemap type="QVariantMap" key="ProjectExplorer.Target.BuildConfiguration.%d">', idx)
		_p(4, '<value type="QString" key="ProjectExplorer.BuildConfiguration.BuildDirectory">build</value>')
		_p(4, '<valuemap type="QVariantMap" key="ProjectExplorer.BuildConfiguration.BuildStepList.0">')
		_p(5, '<valuemap type="QVariantMap" key="ProjectExplorer.BuildStepList.Step.0">')
		_p(6, '<value type="bool" key="ProjectExplorer.BuildStep.Enabled">true</value>')
		_p(6, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName"></value>')
		_p(6, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName">Qbs Build</value>')
		_p(6, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">Qbs.BuildStep</value>')
		_p(6, '<value type="bool" key="Qbs.CleanInstallRoot">false</value>')
		_p(6, '<valuemap type="QVariantMap" key="Qbs.Configuration">')
		_p(7, '<value type="QString" key="qbs.buildVariant">%s</value>', cfgname:lower())
		_p(7, '<value type="QString" key="qbs.profile">%s</value>', qbsprofile)
		_p(6, '</valuemap>')
		_p(5, '</valuemap>')
		_p(5, '<value type="int" key="ProjectExplorer.BuildStepList.StepsCount">1</value>')
		_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">Build</value>')
		_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName"></value>')
		_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">ProjectExplorer.BuildSteps.Build</value>')
		_p(4, '</valuemap>')
		_p(4, '<valuemap type="QVariantMap" key="ProjectExplorer.BuildConfiguration.BuildStepList.1">')
		_p(5, '<valuemap type="QVariantMap" key="ProjectExplorer.BuildStepList.Step.0">')
		_p(6, '<value type="bool" key="ProjectExplorer.BuildStep.Enabled">true</value>')
		_p(6, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName"></value>')
		_p(6, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName">Qbs Clean</value>')
		_p(6, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">Qbs.CleanStep</value>')
		_p(6, '<value type="bool" key="Qbs.CleanAll">true</value>')
		_p(6, '<value type="bool" key="Qbs.DryKeepGoing">false</value>')
		_p(6, '<value type="bool" key="Qbs.DryRun">false</value>')
		_p(5, '</valuemap>')
		_p(5, '<value type="int" key="ProjectExplorer.BuildStepList.StepsCount">1</value>')
		_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">Clean</value>')
		_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName"></value>')
		_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">ProjectExplorer.BuildSteps.Clean</value>')
		_p(4, '</valuemap>')
		_p(4, '<value type="int" key="ProjectExplorer.BuildConfiguration.BuildStepListCount">2</value>')
		_p(4, '<value type="bool" key="ProjectExplorer.BuildConfiguration.ClearSystemEnvironment">false</value>')
		_p(4, '<valuelist type="QVariantList" key="ProjectExplorer.BuildConfiguration.UserEnvironmentChanges"/>')
		_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">%s</value>', cfgname)
		_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName"></value>')
		_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">Qbs.QbsBuildConfiguration</value>')
		_p(3, '</valuemap>')

		idx = idx + 1
	end

	_p(3, '<value type="int" key="ProjectExplorer.Target.BuildConfigurationCount">%d</value>', idx)

	-- DeployConfiguration
	_p(3, '<valuemap type="QVariantMap" key="ProjectExplorer.Target.DeployConfiguration.0">')
	_p(4, '<valuemap type="QVariantMap" key="ProjectExplorer.BuildConfiguration.BuildStepList.0">')
	_p(5, '<value type="int" key="ProjectExplorer.BuildStepList.StepsCount">0</value>')
	_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">Deploy</value>')
	_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName"></value>')
	_p(5, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">ProjectExplorer.BuildSteps.Deploy</value>')
	_p(4, '</valuemap>')
	_p(4, '<value type="int" key="ProjectExplorer.BuildConfiguration.BuildStepListCount">1</value>')
	_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">Deploy locally</value>')
	_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName">Qbs Install</value>')
	_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">Qbs.Deploy</value>')
	_p(3, '</valuemap>')
	_p(3, '<value type="int" key="ProjectExplorer.Target.DeployConfigurationCount">1</value>')

	-- PluginSettings
--	_p(3, '<valuemap type="QVariantMap" key="ProjectExplorer.Target.PluginSettings"/>')

	-- RunConfiguration
	idx = 0
	for prj in premake.solution.eachproject(sln) do

		if is_app(prj.kind) then
--			_p(3, '<variable>ProjectExplorer.Project.Target.%d</variable>', idx)

			_p(3, '<valuemap type="QVariantMap" key="ProjectExplorer.Target.RunConfiguration.%d">', idx)

			if idx == startProject then
				_p(4, '<value type="int" key="PE.EnvironmentAspect.Base">2</value>')
			else
				_p(4, '<value type="int" key="PE.EnvironmentAspect.Base">-1</value>')
			end
			_p(4, '<valuelist type="QVariantList" key="PE.EnvironmentAspect.Changes"/>')
			_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DefaultDisplayName">%s</value>', prj.name)
			_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.DisplayName"></value>')
			_p(4, '<value type="QString" key="ProjectExplorer.ProjectConfiguration.Id">Qbs.RunConfiguration:%s.%s---Qbs.RC.NameSeparator---%s</value>', prj.name, qbsprofile, prj.name)

			_p(4, '<value type="QString" key="Qbs.RunConfiguration.CommandLineArguments"></value>')

			local cfg = premake.getconfig(prj, nil, nil)
			if cfg.debugdir ~= nil then
				_p(4, '<value type="QString" key="Qbs.RunConfiguration.WorkingDirectory">%s</value>', cfg.debugdir)
			else
				_p(4, '<value type="QString" key="Qbs.RunConfiguration.WorkingDirectory"></value>')
			end

			_p(3, '</valuemap>')

			idx = idx + 1
		end
	end

	_p(3, '<value type="int" key="ProjectExplorer.Target.RunConfigurationCount">%d</value>', idx)

	_p(2, '</valuemap>')
	_p(1, '</data>')

	_p(1, '<data>')
	_p(2, '<variable>ProjectExplorer.Project.TargetCount</variable>')
	_p(2, '<value type="int">1</value>')
	_p(1, '</data>')

	_p(1, '<data>')
	_p(2, '<variable>Version</variable>')
	_p(2, '<value type="int">18</value>')
	_p(1, '</data>')

	_p(0, '</qtcreator>')

end
