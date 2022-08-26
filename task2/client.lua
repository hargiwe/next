DGS = exports.dgs

-- Общий список
local g_ScreenW, g_ScreenH = guiGetScreenSize()
local g_Windows = DGS:dgsCreateWindow((g_ScreenW - 996) / 2, (g_ScreenH - 516) / 2, 996, 600, "CRUD", false)
local g_Edit = DGS:dgsCreateEdit(790, 30, 196, 24, "Текст для поиска", false, g_Windows)
local g_ButtonAdd = DGS:dgsCreateButton(0, 30, 196, 24, "Добавить пользователя", false, g_Windows)
local g_GridList = DGS:dgsCreateGridList(15, 64, 961, 421, false, g_Windows)
local g_ColumnID = DGS:dgsGridListAddColumn(g_GridList, "ID", 0.16)
local g_ColumnName = DGS:dgsGridListAddColumn(g_GridList, "Имя", 0.16)
local g_ColumnFamily = DGS:dgsGridListAddColumn(g_GridList, "Фамилия", 0.16)
local g_ColumnAddress = DGS:dgsGridListAddColumn(g_GridList, "Адресс", 0.16)
local g_ColumnActionDelete = DGS:dgsGridListAddColumn(g_GridList, "", 0.03)
local g_ColumnActionEdit = DGS:dgsGridListAddColumn(g_GridList, "", 0.03)
DGS:dgsSetVisible(g_Windows, false)
 

 
-- Добавления пользователя
local g_WindowsAdd = DGS:dgsCreateWindow((g_ScreenW - 237) / 2, (g_ScreenH - 186) / 2, 237, 186, "CRUD / ADD", false)
local g_EditAddName = DGS:dgsCreateEdit(26, 28, 201, 22, "Имя", false, g_WindowsAdd)
local g_EditAddFamily = DGS:dgsCreateEdit(26, 50, 201, 22, "Фамилия", false, g_WindowsAdd)
local g_EditAddAddress = DGS:dgsCreateEdit(26, 72, 201, 22, "Адресс", false, g_WindowsAdd)
local g_EditButtonSend = DGS:dgsCreateButton(48, 150, 164, 24, "Добавить", false, g_WindowsAdd) 
DGS:dgsSetVisible(g_WindowsAdd, false)

-- Редактирование пользователя
local g_WindowsEdit = DGS:dgsCreateWindow((g_ScreenW - 323) / 2, (g_ScreenH - 221) / 2, 323, 221, "CRUD / EDIT", false)
local g_WindowsEditName = DGS:dgsCreateEdit(13, 31, 226, 21, "Новое имя", false, g_WindowsEdit)
local g_WindowsEditFamily = DGS:dgsCreateEdit(13, 52, 226, 21, "Новая фамилия", false, g_WindowsEdit)
local g_WindowsEditAddress = DGS:dgsCreateEdit(13, 73, 226, 21, "Новый адресс", false, g_WindowsEdit)
local g_WindowsEditButtonSend = DGS:dgsCreateButton(98, 194, 151, 17, "Применить", false, g_WindowsEdit)   
DGS:dgsSetVisible(g_WindowsEdit, false)

-- Удалить пользователя
local g_WindowsDelete = DGS:dgsCreateWindow((g_ScreenW - 359) / 2, (g_ScreenH - 132) / 2, 359, 132, "CRUD / DELETE", false)
local g_WindowsDeleteLabel = DGS:dgsCreateLabel(12, 23, 250, 29, "Вы действительно хотите удалить пользователя", false, g_WindowsDelete)
local g_WindowsDeleteButtonSend = DGS:dgsCreateButton(62, 103, 108, 19, "Да", false, g_WindowsDelete)
local g_WindowsDeleteButtonClose = DGS:dgsCreateButton(180, 105, 108, 17, "Нет", false, g_WindowsDelete) 
DGS:dgsSetVisible(g_WindowsDelete, false)

-- Кнопки навигации 
local g_ButtonPrev = DGS:dgsCreateButton(368, 520, 113, 25, "<<", false, g_Windows)
local g_ButtonNext = DGS:dgsCreateButton(505, 520, 113, 25, ">>", false, g_Windows)
local g_ActivePage = 1 -- Страница по умолчанию
local g_TotalPage = 1

-- Статус переменные
local g_isEditFocus = false -- Активен ли фокус поля для поиска?

-- DGS:dgsGridListSetMultiSelectionEnabled(gridlist,true)

local g_TextureDelete = dxCreateTexture("icon_delete.png") -- Текстура иконки удаления
local g_TextureEdit = dxCreateTexture("icon_edit.png") -- Текстура иконки редактирования

-- Текущий ID выбранного пользователя
local g_SelectUserID = nil

-- Открывает общий список
function changeVisibility()
	local state = (not DGS:dgsGetVisible(g_Windows))
	DGS:dgsSetVisible(g_Windows, state)
	showCursor(state)

	if(state) then
		DGS:dgsGridListClearRow(g_GridList, true, true)
		triggerServerEvent("getListUsers", resourceRoot, g_ActivePage, localPlayer)
	end
end
bindKey("l", "down", changeVisibility)

-- Обработка поиска (детект ввода с клавиатуры)
function detectSearch()
	local text = DGS:dgsGetText(source)

	if(#text > 3 and text ~= "Текст для поиска") then
		triggerServerEvent("requestSearch", resourceRoot, text, localPlayer)
	end

	-- Если пользователь стер весь текст
	if(#text == 0) then 
		triggerServerEvent("getListUsers", resourceRoot, g_ActivePage, localPlayer)
	end
end
addEventHandler("onDgsTextChange", g_Edit, detectSearch) 

-- Поисковой ответ с сервера
addEvent("onClientAnswerSearch", true)
function onClientAnswerSearch(string)
	if(string) then
		DGS:dgsGridListClearRow(g_GridList, true, true)

		for k, v in pairs(string) do
			local row = DGS:dgsGridListAddRow(g_GridList)
			DGS:dgsGridListSetItemText(g_GridList, row, g_ColumnID, v["ID"])
			DGS:dgsGridListSetItemText(g_GridList, row, g_ColumnName, v["Name"])
			DGS:dgsGridListSetItemText(g_GridList, row, g_ColumnFamily, v["Family"])
			DGS:dgsGridListSetItemText(g_GridList, row, g_ColumnAddress, v["Address"])
			DGS:dgsGridListSetItemImage(g_GridList, row, g_ColumnActionDelete, g_TextureDelete)
			DGS:dgsGridListSetItemImage(g_GridList, row, g_ColumnActionEdit, g_TextureEdit)
		end
	end
end
addEventHandler("onClientAnswerSearch", localPlayer, onClientAnswerSearch)

-- Клик по полю (редактирования или удаления) в грид-листе
function onDgsGridListSelect(row, column)
	if(column == g_ColumnActionDelete) then 
		-- Скрываем общие окно, показываем окно удаления
		DGS:dgsSetVisible(g_Windows, false)
		DGS:dgsSetVisible(g_WindowsDelete, true)

		local user_name = DGS:dgsGridListGetItemText(g_GridList, row, g_ColumnName)
		DGS:dgsSetText(g_WindowsDeleteLabel, "Вы действительно хотите удалить пользователя с именем "..user_name)

		local user_id = DGS:dgsGridListGetItemText(g_GridList, row, g_ColumnID)
		g_SelectUserID = tonumber(user_id)
	elseif(column == g_ColumnActionEdit) then
		-- Скрываем общие окно, показываем окно редактирования
		DGS:dgsSetVisible(g_Windows, false)
		DGS:dgsSetVisible(g_WindowsEdit, true)

		local user_id = DGS:dgsGridListGetItemText(g_GridList, row, g_ColumnID)
		g_SelectUserID = tonumber(user_id)
	end
end
addEventHandler("onDgsGridListSelect", g_GridList, onDgsGridListSelect)


-- Получаем общие количество пользователей
function onClientResourceStart()
	-- Отправляем запрос на сервер для получения кол-ва пользователей
	triggerServerEvent("onServerGetUsersCount", resourceRoot, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)

addEvent("onServerReturntCountUsers", true)
function onServerReturntCountUsers(count)
	g_TotalPage = count / 30
end
addEventHandler("onServerReturntCountUsers", resourceRoot, onServerReturntCountUsers)

-- Постраничная навигация
function onDgsMouseClick(button, state)
	print(button, state)
	if button == 'left' and state == 'up' then
		print("button", source, g_ButtonNext)
		-- Навигация поиска
		if(source == g_ButtonPrev) then 
			if(g_ActivePage - 1 < 1) then 
				return outputChatBox("Страница не может быть меньше 1") 
			end
			
			g_ActivePage = g_ActivePage - 1
			triggerServerEvent("getListUsers", resourceRoot, g_ActivePage, localPlayer)
		elseif(source == g_ButtonNext) then
			if(g_ActivePage + 1 > g_TotalPage) then 
				return outputChatBox("Страница не может быть больше"..g_TotalPage) 
			end
			
			g_ActivePage = g_ActivePage + 1
			triggerServerEvent("getListUsers", resourceRoot, g_ActivePage, localPlayer)
		-- Окно добавления
		elseif(source == g_ButtonAdd) then
			DGS:dgsSetVisible(g_Windows, false)
			DGS:dgsSetVisible(g_WindowsAdd, true)
		elseif(source == g_EditButtonSend) then
			local name = DGS:dgsGetText(g_EditAddName)
			local family = DGS:dgsGetText(g_EditAddFamily)
			local address = DGS:dgsGetText(g_EditAddAddress)

			triggerServerEvent("addNewUser", resourceRoot, name, family, address)
			outputChatBox("Пользователь с именем "..name.." добавлен")

			-- Скрываем окно добавления
			-- Показываем общий список
			DGS:dgsSetVisible(g_Windows, true)
			DGS:dgsSetVisible(g_WindowsAdd, false)
		-- Окно редактирования
		elseif(source == g_WindowsEditButtonSend) then
			local name = DGS:dgsGetText(g_WindowsEditName)
			local family = DGS:dgsGetText(g_WindowsEditFamily)
			local address = DGS:dgsGetText(g_WindowsEditAddress)

			triggerServerEvent("editUser", resourceRoot, g_SelectUserID, name, family, address)
			outputChatBox("Имя пользователя изменено на "..name)

			-- Скрываем окно добавления
			-- Показываем общий список
			DGS:dgsSetVisible(g_WindowsEdit, false)
			changeVisibility()
		-- Окно удаления
		elseif(source == g_WindowsDeleteButtonSend) then
			triggerServerEvent("deleteUser", resourceRoot, g_SelectUserID)
			outputChatBox("Пользователь с ID "..g_SelectUserID.." удален")

			-- Скрываем окно удаления
			-- Показываем общий список
			DGS:dgsSetVisible(g_WindowsDelete, false)
			changeVisibility()
		elseif(source == g_WindowsDeleteButtonClose) then 
			-- Скрываем окно удаления
			-- Показываем общий список
			DGS:dgsSetVisible(g_WindowsDelete, false)
			changeVisibility()
		end
	end
end
addEventHandler("onDgsMouseClick", root, onDgsMouseClick)

-- Возврат текста по умолчанию для поля поиска
function onDgsFocus()
	g_isEditFocus = true
end

function onDgsBlur()
	g_isEditFocus = false
end
addEventHandler("onDgsFocus", g_Edit, onDgsFocus)
addEventHandler("onDgsBlur", g_Edit, onDgsBlur)

-- Приятная мелочь, возврат текста в окне поиска
function onClientRender()
	if(g_isEditFocus == false and #DGS:dgsGetText(g_Edit) == 0) then 
		DGS:dgsSetText(g_Edit, "Текст для поиска")
	end
end
addEventHandler("onClientRender", root, onClientRender)