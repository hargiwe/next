local g_ScreenWight, g_ScreenHeigth = guiGetScreenSize()
local g_LogoTexture = dxCreateTexture("dvd-logo.png")
local g_TextureWight, g_TextureHeight = dxGetMaterialSize(g_LogoTexture) -- Получаем размер png логотипа

-- Переменные под расчет левого блока
local lx, ly = 0, 0
local ldx, ldy = 3, 3
local lcolor = tocolor(255, 255, 255, 255)
-- Переменные под расчет правого блока
local rx, ry = g_ScreenWight / 2 + g_TextureWight, 0
local rdx, rdy = 3, 3
local rcolor = tocolor(255, 255, 255, 255)

function onClientRender()
    -- left
    if(lx + ldx > (g_ScreenWight / 2) - g_TextureWight or lx + ldx < 0) then 
        ldx = -ldx
        lcolor = getRandomColor()
    end
    if(ly + ldy > g_ScreenHeigth - g_TextureHeight or ly + ldy < 0) then 
        ldy = -ldy
        lcolor = getRandomColor()
    end
    print(lcolor)
    
    lx = lx + ldx
    ly = ly + ldy

    dxDrawImage(lx, ly, g_TextureWight, g_TextureHeight, "dvd-logo.png", 0, 0, 0, lcolor)

    -- right
    if(rx + rdx > g_ScreenWight - g_TextureWight or rx + rdx < g_ScreenWight / 2) then 
        rdx = -rdx
        rcolor = getRandomColor()
    end
    if(ry + rdy > g_ScreenHeigth - g_TextureHeight or ry + rdy < 0) then 
        rdy = -rdy
        rcolor = getRandomColor()
    end
    
    rx = rx + rdx
    ry = ry + rdy

    dxDrawImage(rx, ry, g_TextureWight, g_TextureHeight, "dvd-logo.png", 0, 0, 0, rcolor)
end
addEventHandler("onClientRender", root, onClientRender)
-- Рандомайзер цветов
function getRandomColor()
    return tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
end