script_name ("Auto ATM")

local lsampev, sampev = pcall(require, 'lib.samp.events') assert(lsampev, 'not found lib lib.samp.events')

function stext(text)
    sampAddChatMessage(('%s | {ffffff}%s'):format(script.this.name, text), 0xffffee)
end

--block for snyat
local snyat = false
local snyatIterations = 0

---

--block for polozshit

local polozshit = false
local polozshitIterations = 0

---

--block for autopay

local autopay = false
local autopayIterations = 0

---


function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand('snat', function(pam)
		if #pam ~= 0 then
			local money = tonumber(pam:match('(.+)'))
			snyatIterations = tonumber(pam) / 100000
			snyat = true
			stext('Будет снято '.. money ..'. Рассчитано '.. tonumber(pam) / 100000 ..' итераций. Активируйте окно банкомата.')
		else
			stext('Используйте: /snat [кол-во]')
		end
	end)
	sampRegisterChatCommand('polo', function(pam)
		if #pam ~= 0 then
			local money = tonumber(pam:match('(.+)'))
			polozshitIterations = tonumber(pam) / 100000
			polozshit = true
			stext('Будет положено '.. money ..'. Рассчитано '.. tonumber(pam) / 100000 ..' итераций. Активируйте окно банкомата.')
		else
			stext('Используйте: /polo [кол-во]')
		end
	end)
	sampRegisterChatCommand('apay', function(pam)
		if #pam ~= 0 then
			if autopay then
				stext('Передача денег была выключена.')
				autopay = false
				do return end
			end
			local id, money = pam:match('(.+) (.+)')
			if money and id then
				if sampIsPlayerConnected(tonumber(id)) then
					local nick = sampGetPlayerNickname(id)
					autopayIterations = tonumber(money) / 50000
					autopay = true
					stext('Будет переданно '.. money ..'. Находитесь в метре от '..nick..'['.. id ..']')
					sendMoneyForPlayer(id)
				else
					stext('Игрок не подключен.')
				end
			end
		else
			if not autopay then
				stext('Используйте: /apay [id] [кол-во]')
			else 
				stext('Передача денег была выключена.')
				autopay = false
			end
		end
	end)
	wait(-1)
end

function sendMoneyForPlayer(id)
    lua_thread.create(function()
        while autopay do
			if sampIsPlayerConnected(id) then
				local pPosX, pPosY, pPosZ = getCharCoordinates(playerPed)
				local res, ped = sampGetCharHandleBySampPlayerId(id)
				if doesCharExist(ped) then
					local posX, posY = getCharCoordinates(ped)
					local distance = getDistanceBetweenCoords2d(pPosX, pPosY, posX, posY)
					if distance < 2.5 then
						if autopayIterations > 1 then
							sampSendChat('/pay '.. id ..' 50000')
							autopayIterations = autopayIterations - 1
						else
							sampSendChat('/pay '.. id ..' '.. autopayIterations * 50000)
							autopayIterations = 0
							autopay = false
							stext('Процесс успешно завершен.')
						end
					end
				end
			else
				autopay = false
				stext('Операция была завершена. Объект вышел из игры.')
			end
		wait(1000) end return
	end)
end

function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
	--9100 main 9101 snat 9102 polozshit'
	if (dialogid == 9100) then
		if snyat then
			lua_thread.create(function()
				wait(200)
				sampSendDialogResponse(9100, 1, 1, _)
			end)
		end
		if polozshit then
			lua_thread.create(function()
				wait(200)
				sampSendDialogResponse(9100, 1, 2, _)
			end)
		end
	end
	if (dialogid == 9101 and snyatIterations ~= 0 and snyat) then
		if snyatIterations > 1 then
			sampSendDialogResponse(9101, 1, _, 100000)
			snyatIterations = snyatIterations - 1
		else
			sampSendDialogResponse(9101, 1, _, snyatIterations * 100000)
			stext('Операция успешно завершена.')
			snyatIterations = 0
			snyat = false
		end
	end
	if (dialogid == 9102 and polozshitIterations ~= 0 and polozshit) then
		if polozshitIterations > 1 then
			sampSendDialogResponse(9102, 1, _, 100000)
			polozshitIterations = polozshitIterations - 1
		else
			sampSendDialogResponse(9102, 1, _, polozshitIterations * 100000)
			stext('Операция успешно завершена.')
			polozshitIterations = 0
			polozshit = false
		end
	end
end