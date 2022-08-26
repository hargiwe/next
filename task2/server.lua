local g_MysqlHandler -- Хэнлер подключения к бд
local g_QueryCaching = {} -- Общая таблица с кэшем
local g_CountUsers = 0 -- Общие количетсов пользователей

function onResourceStart()
	g_MysqlHandler = dbConnect("mysql", "dbname=next;host=127.0.0.1;charset=utf8", "root", "", "share=1")

	if(g_MysqlHandler) then
		dbQuery(getCountRows, g_MysqlHandler, "SELECT COUNT(`ID`) AS `Count` FROM `users`")
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)


-- Получаем кол-во записей в таблице с пользователям 
function getCountRows(qh)
	local result = dbPoll(qh, 0)
	g_CountUsers = result[1]["Count"]
end

addEvent("onServerGetUsersCount", true)
function onServerGetUsersCount(elementPlayer)
	triggerLatentClientEvent(elementPlayer, "onServerReturntCountUsers", resourceRoot, g_CountUsers)
end
addEventHandler("onServerGetUsersCount", resourceRoot, onServerGetUsersCount)


--[[
	@addNewUser - добавляет нового пользователя в базу данных
		name - Имя пользователя
		family - Фамилия пользователя
		address - Адрес пользователя
--]]
addEvent("addNewUser", true)
function addNewUser(name, family, address)
	assert(type(name) == "string", "Bad Argument @addNewUser at argument 1, expected a string got "..type(name))
	assert(type(family) == "string", "Bad Argument @addNewUser at argument 2, expected a string got "..type(family))
	assert(type(address) == "string", "Bad Argument @addNewUser at argument 3, expected a string got "..type(address))

	
	dbExec(g_MysqlHandler, "INSERT INTO `users` (`Name`, `Family`, `Address`) VALUES (?, ?, ?);", name, family, address)
end
addEventHandler("addNewUser", resourceRoot, addNewUser)


--[[
	@requestSearch - ищет пользователя по любому доступному полю в базе данных
		field - текст (и/или часть) для поиска 
		requestPlayer - игрок получатель
--]]
addEvent("requestSearch", true)
function requestSearch(field, requestPlayer)
	if(field) then
		print("field", field)
		iprint(g_QueryCaching)
		for k, v in ipairs(g_QueryCaching) do
			if(v == field) then 
				triggerLatentClientEvent("onClientAnswerSearch", 500000, false, requestPlayer, result)
			end
		end

		local query_field = "%"..field.."%"
		dbQuery(searchCallback, {field, requestPlayer}, g_MysqlHandler, "SELECT * FROM `users` WHERE `Name` LIKE ? OR `Family` LIKE ? OR `Address` LIKE ? LIMIT 10", query_field, query_field, query_field)
	end
end
addEventHandler("requestSearch", resourceRoot, requestSearch)

function searchCallback(qh, field, requestPlayer)
	local result = dbPoll(qh, 0)
	if(field ~= null) then
		table.insert(g_QueryCaching, field)
	end

	triggerLatentClientEvent("onClientAnswerSearch", 500000, false, requestPlayer, result)
end


--[[
	@editUser - изменяет данные пользователя в базе данных по его ID
		user_id - ID пользователя в базе данных (AUTO_INCREMENT)
		name - Новое имя пользователя
		family - Новая фамилия пользователя
		address - Новый адресс пользователя
--]]
addEvent("editUser", true)
function editUser(user_id, name, family, address)
	assert(type(user_id) == "number", "Bad Argument @editUser at argument 1, expected a string got "..type(user_id))
	assert(type(name) == "string", "Bad Argument @editUser at argument 2, expected a string got "..type(name))
	assert(type(family) == "string", "Bad Argument @editUser at argument 3, expected a string got "..type(family))
	assert(type(address) == "string", "Bad Argument @editUser at argument 4, expected a string got "..type(address))

	
	dbExec(g_MysqlHandler, "UPDATE `users` SET `Name` = ?, `Family` = ?, `Address` = ? WHERE `ID` = ? LIMIT 1;", name, family, address, user_id)
end
addEventHandler("editUser", resourceRoot, editUser)


--[[
	@deleteUser - удаляет пользователя из базы данных
		user_id - ID пользователя в базе данных (AUTO_INCREMENT)
--]]
addEvent("deleteUser", true)
function deleteUser(user_id)
	assert(type(user_id) == "number", "Bad Argument @editUser at argument 1, expected a string got "..type(user_id))
	
	dbExec(g_MysqlHandler, "DELETE FROM `users` WHERE `ID` = ? LIMIT 1;", user_id)
end
addEventHandler("deleteUser", resourceRoot, deleteUser)


--[[
	@getListUsers - удаляет пользователя из базы данных
		page - номер страницы на клиенте
		requestPlayer - игрок получатель
--]]
addEvent("getListUsers", true)
function getListUsers(page, requestPlayer)
	local startPos = (page * 30) - 30
	dbQuery(searchCallback, {"null", requestPlayer}, g_MysqlHandler, "SELECT * FROM `users` LIMIT "..startPos..", 30")
end
addEventHandler("getListUsers", resourceRoot, getListUsers)
