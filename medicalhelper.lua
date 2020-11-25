local sampev = require 'lib.samp.events'
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding'
local memory = require "memory"
local fa = require 'fAwesome5'
require "lib.moonloader"
require 'lib.sampfuncs'
local fontsize = nil
local main_window_state = imgui.ImBool(false)
local main_main_window_state = imgui.ImBool(true)
local settings_window_state = imgui.ImBool(false)
local binder_state = imgui.ImBool(false)
local keyboard_state = imgui.ImBool(false)
local command_state = imgui.ImBool(false)
local help_state = imgui.ImBool(false)
local about_state = imgui.ImBool(false)
local shpora_state = imgui.ImBool(false)
local stats_state = imgui.ImBool(true)
local text_buffer = imgui.ImBuffer(256)
local sw,sh = getScreenResolution()
local checked_radio  = imgui.ImInt(1)
local kolvomedicamentov = imgui.ImInt(0)
local kolvoreceptov = imgui.ImInt(0)
local objavleniyzavse = imgui.ImInt(0)
local objavleniyforday = imgui.ImInt(0)
local selected_theme_state = imgui.ImInt(0)
local combo_select = imgui.ImInt(0)
local vilichenovsego = imgui.ImInt(0)
local medcartzavsevremia = imgui.ImInt(0)
local receptovzavsevremia = imgui.ImInt(0)
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local textforcmd = ""
local organisationname = imgui.ImBuffer(256)
local sexname = imgui.ImBuffer(256)
local passwordshow = imgui.ImBool(true)

encoding.default = 'CP1251'    
u8 = encoding.UTF8



local directIni = "SHelper\\SHelper.ini"


local def = {
	settings = {
		nick = u8"Не установлен",
    theme = 0,
    tag = u8"Не установлен",
    sex = 0,
    post = u8"Не определена",
    organisation = u8"Не определена",
    donat = true,
    command = "shelper",
    password = "",
    passwordauto = false,
  },
}



local ini = inicfg.load(def, directIni)

local tema = imgui.ImInt(ini.settings.theme)
local nickname = imgui.ImBuffer(ini.settings.nick,100)
local command = imgui.ImBuffer(ini.settings.command,32)
local tag = imgui.ImBuffer(ini.settings.tag,256)
local sex = imgui.ImInt(ini.settings.sex)
local post = imgui.ImBuffer(ini.settings.post,256)
local organisation = imgui.ImInt(ini.settings.organisation)
local donatepizda = imgui.ImBool(ini.settings.donat)
local password = imgui.ImBuffer(ini.settings.password,50)
local enableautologin = imgui.ImBool(ini.settings.passwordauto)



local colors = {
  kick = 	{r = 255, g = 255, b = 0, color = 0},
  warn = 	{r = 255, g = 255, b = 0, color = 0},
  ban  = 	{r = 255, g = 255, b = 0, color = 0},
  mute = 	{r = 255, g = 255, b = 0, color = 0},
  jail = 	{r = 255, g = 255, b = 0, color = 0},
  rt = 	{r = 255, g = 255, b = 0, color = 0},
  dalnoboi = 	{r = 255, g = 255, b = 0, color = 0},
  razia = {r = 255, g = 255, b = 0, color = 0},
  departament = {r = 255, g = 255, b = 0, color = 0},
}


function argb_to_rgba(argb)
  local a, r, g, b = explode_argb(argb)
  return join_argb(r, g, b, a)
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end

function join_argb(a, r, g, b)
  local argb = b
  argb = bit.bor(argb, bit.lshift(g, 8))
  argb = bit.bor(argb, bit.lshift(r, 16))
  argb = bit.bor(argb, bit.lshift(a, 24))
  return argb
end

function ARGBtoRGB(color) return bit32 or require'bit'.band(color, 0xFFFFFF) end



if not doesDirectoryExist('moonloader/config') then createDirectory("moonloader/config") end

local path = 'moonloader/config/configOfColor.json'

function saveCFG()
    local saveCFG = io.open(path, "w")
    if saveCFG then
        saveCFG:write(encodeJson(colors))
        saveCFG:close()
    end
end

function loadCFG()
    local file = io.open(path, 'r')
    if file then
        local data = decodeJson(file:read('*a'))
        if not data then 
            data = colors
        end
        return data
    end
end

if not doesFileExist('moonloader/config/configOfColor.json') then
    saveCFG()
else
    colors = loadCFG('moonloader/config/configOfColor.json')
end





  

function main()


    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    

    if ini.settings.command ~= "" then
      sampAddChatMessage('[State Helper] {FFFFFF}Скрипт загружен. Активация: {F36223}/'..ini.settings.command, 0x2892D7)
    else 

      ini.settings.command = "shelper"
      sampAddChatMessage('[State Helper] {FFFFFF}Команда активации не была установлена. Была установлена команда по умолчанию: {F36223}/'..ini.settings.command, 0x2892D7)
      inicfg.save(def,directIni)
    end

   sampRegisterChatCommand(ini.settings.command,function() main_window_state.v = not main_window_state.v end)
   sampRegisterChatCommand("jobp",cmd_jobp)
   
    if ini.settings.theme == 0 then gray_theme() end
   	if ini.settings.theme == 1 then orange_theme() end
	  if ini.settings.theme == 2 then blue_theme() end
    if ini.settings.theme == 3 then pink_theme() end
    if ini.settings.theme == 4 then red_theme() end


    local table_organisations = {u8'Не установлена',u8'Правительство', u8'Центральный банк', u8'Автошкола', u8'ЛСПД', u8'СФПД', u8"РКШД", u8"ЛВПД", u8"СВАТ", u8"ЛСМЦ", u8"ЛВМЦ", u8"СФМЦ", u8"Армия ЛС", u8"Армия СФ", u8"ТСР", u8"Радио ЛС", u8"Радио ЛВ", u8"Радио СФ", u8"Страховая компания"}
    if ini.settings.organisation == 0 then organisationname.v = table_organisations[1] end 
    if ini.settings.organisation == 1 then organisationname.v = table_organisations[2] end 
    if ini.settings.organisation == 2 then organisationname.v = table_organisations[3] end 
    if ini.settings.organisation == 3 then organisationname.v = table_organisations[4] end 
    if ini.settings.organisation == 4 then organisationname.v = table_organisations[5] end 
    if ini.settings.organisation == 5 then organisationname.v = table_organisations[6] end 
    if ini.settings.organisation == 6 then organisationname.v = table_organisations[7] end 
    if ini.settings.organisation == 7 then organisationname.v = table_organisations[8] end 
    if ini.settings.organisation == 8 then organisationname.v = table_organisations[9] end 
    if ini.settings.organisation == 9 then organisationname.v = table_organisations[10] end 
    if ini.settings.organisation == 10 then organisationname.v = table_organisations[11] end 
    if ini.settings.organisation == 11 then organisationname.v = table_organisations[12] end 
    if ini.settings.organisation == 12 then organisationname.v = table_organisations[13] end 
    if ini.settings.organisation == 13 then organisationname.v = table_organisations[14] end 
    if ini.settings.organisation == 14 then organisationname.v = table_organisations[15] end 
    if ini.settings.organisation == 15 then organisationname.v = table_organisations[16] end 
    if ini.settings.organisation == 16 then organisationname.v = table_organisations[17] end 
    if ini.settings.organisation == 17 then organisationname.v = table_organisations[18] end 
    if ini.settings.organisation == 18 then organisationname.v = table_organisations[19] end 
    if ini.settings.organisation == 19 then organisationname.v = table_organisations[20] end 

   imgui.Process = true

    local table_sex = {u8'Мужской',u8'Женский',u8'Не определен'}
      if ini.settings.sex == 0 then sexname.v = table_sex[1] end
      if ini.settings.sex == 1 then sexname.v = table_sex[2] end
      if ini.settings.sex == 2 then sexname.v = table_sex[3] end
  
    
    while true do
    wait(0)

      
  
  


end



    

      

 
    



wait(-1)
end



function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end

    if fontsize == nil then
      fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
  end
end

function cmd_jobp(arg)
sampSendChat("/jobprogress ".. arg)
sampAddChatMessage("Используйте: /jobprogress [ ID игрока ]", 0x8B0000)
sampShowDialog(1999,"Успеваемость", textforcmd, "Принять", DIALOG_STYLE_MSGBOX)
end

function imgui.OnDrawFrame()


  kickcolor     	 = imgui.ImFloat3(colors.kick.r / 255, colors.kick.g / 255, colors.kick.b / 255)
  warncolor     	 = imgui.ImFloat3(colors.warn.r / 255, colors.warn.g / 255, colors.warn.b / 255)
  bancolor   		 = imgui.ImFloat3(colors.ban.r / 255, colors.ban.g / 255, colors.ban.b / 255)
  mutecolor    	 = imgui.ImFloat3(colors.mute.r / 255, colors.mute.g / 255, colors.mute.b / 255)
  jailcolor    	 = imgui.ImFloat3(colors.jail.r / 255, colors.jail.g / 255, colors.jail.b / 255)
  rt     	 = imgui.ImFloat3(colors.rt.r / 255, colors.rt.g / 255, colors.rt.b / 255)
  dalnoboi = imgui.ImFloat3(colors.dalnoboi.r / 255, colors.dalnoboi.g / 255, colors.dalnoboi.b / 255)
  raziacolor = imgui.ImFloat3(colors.razia.r / 255, colors.razia.g / 255, colors.razia.b / 255)
  departamentcolor = imgui.ImFloat3(colors.departament.r / 255, colors.departament.g / 255, colors.departament.b / 255)




  if stats_state.v then 
    imgui.ShowCursor = false
    imgui.SetNextWindowSize(imgui.ImVec2(235, 150), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.1), sh / 1.1), imgui.Cond.FirstUseEver,imgui.ImVec2(0.5,0.5))
    imgui.Begin(u8"Статистика",false,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize)
    if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_STAR_OF_LIFE ..u8" Пациентов вылечено: " .. vilichenovsego.v) end
    if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_BOOK_MEDICAL ..u8" Мед.карт выдано: " .. medcartzavsevremia.v) end
    if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_FIRST_AID ..u8" Количество медикаментов: ".. kolvomedicamentov.v) end
    if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_TABLETS ..u8" Рецептов выдано: ".. kolvoreceptov.v) end
    if organisation.v == 15 or organisation.v == 16 or organisation.v == 17 then imgui.Text(fa.ICON_FA_FILE_ALT ..u8" Объявлений отредактировано: ".. kolvoreceptov.v) end

    imgui.End()
  
  end
if main_window_state.v then
  imgui.ShowCursor = true
  imgui.SetNextWindowSize(imgui.ImVec2(900, 450), imgui.Cond.FirstUseEver)
imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver,imgui.ImVec2(0.5,0.5))



    
 imgui.Begin(fa.ICON_FA_FLAG_USA .. u8' State Helper',main_window_state,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
 imgui.BeginChild("##6526", imgui.ImVec2(160, 400), true, imgui.WindowFlags.NoScrollbar)
  

 if imgui.Button(fa.ICON_FA_CHALKBOARD .. u8' Главное', imgui.ImVec2(145, 45)) then
  main_main_window_state.v = not main_main_window_state.v


  keyboard_state.v = false
binder_state.v = false
command_state.v = false
help_state.v = false
about_state.v = false
shpora_state.v = false
settings_window_state.v = false

 end
 if imgui.Button(fa.ICON_FA_STREAM .. u8' Настройки', imgui.ImVec2(145, 45)) then
  settings_window_state.v = not settings_window_state.v

keyboard_state.v = false
binder_state.v = false
command_state.v = false
help_state.v = false
about_state.v = false
shpora_state.v = false
main_main_window_state.v = false

 end


 if imgui.Button(fa.ICON_FA_GRIP_HORIZONTAL .. u8' Биндер', imgui.ImVec2(145, 45)) then

  binder_state.v = not binder_state.v
  

settings_window_state.v = false
keyboard_state.v = false
command_state.v = false
help_state.v = false
about_state.v = false
shpora_state.v = false
main_main_window_state.v = false

 end
 if imgui.Button(fa.ICON_FA_KEYBOARD .. u8' Настройка клавиш', imgui.ImVec2(145, 45)) then
  keyboard_state.v = not keyboard_state.v


  settings_window_state.v = false
binder_state.v = false
command_state.v = false
help_state.v = false
about_state.v = false
shpora_state.v = false
main_main_window_state.v = false


 end

 imgui.Separator()
 if imgui.Button(fa.ICON_FA_PAGER .. u8' Команды', imgui.ImVec2(145, 45)) then
 command_state.v = not command_state.v


main_main_window_state.v = false
keyboard_state.v = false
binder_state.v = false
help_state.v = false
about_state.v = false
shpora_state.v = false
settings_window_state.v = false

 end
 if imgui.Button(fa.ICON_FA_QUESTION .. u8' Подсказки', imgui.ImVec2(145, 45)) then

 help_state.v = not help_state.v


 main_main_window_state.v = false
 keyboard_state.v = false
 binder_state.v = false
 command_state.v = false
 about_state.v = false
 shpora_state.v = false
 settings_window_state.v = false

 
 end
 if imgui.Button(fa.ICON_FA_CLIPBOARD .. u8' Шпоры', imgui.ImVec2(145, 45)) then
 

  shpora_state.v = not shpora_state.v


  main_main_window_state.v = false
  keyboard_state.v = false
  binder_state.v = false
  help_state.v = false
  command_state.v = false
  about_state.v = false
  settings_window_state.v = false
 
 end
 if imgui.Button(fa.ICON_FA_CODE_BRANCH .. u8' О скрипте', imgui.ImVec2(145, 45)) then

  about_state.v = not about_state.v

  main_main_window_state.v = false
  keyboard_state.v = false
  binder_state.v = false
  help_state.v = false
  command_state.v = false

  shpora_state.v = false
  settings_window_state.v = false
 end
 imgui.EndChild()
 imgui.SameLine()

if about_state.v then
  
  imgui.BeginChild("##666666", imgui.ImVec2(760, 450), true,imgui.WindowFlags.NoScrollbar)
  if imgui.CollapsingHeader(u8'Обновление скрипта') then
    imgui.Text(u8"педофил")
  end
  imgui.EndChild()

end

imgui.SameLine()

if main_main_window_state.v then

  imgui.BeginChild("##6663",imgui.ImVec2(705,400),true,imgui.WindowFlags.NoScrollbar)
  imgui.SetCursorPosX(250)
  imgui.Text(fa.ICON_FA_INFO_CIRCLE ..u8" Ваша личная статистика")


  imgui.Text(fa.ICON_FA_ID_CARD_ALT ..u8" Имя и Фамилия: ".. nickname.v)
  imgui.SameLine()
  imgui.TextDisabled('(?)')
  imgui.Hint(u8'Данный параметр можно изменить в Настройках')

  imgui.Text(fa.ICON_FA_VENUS_MARS ..u8" Пол: ".. sexname.v)

  imgui.Text(fa.ICON_FA_AMBULANCE ..u8" Организация: ".. organisationname.v)

  if organisation.v ~= 0 then imgui.Text(fa.ICON_FA_AMBULANCE ..u8" Должность: ".. post.v) end

  if organisation.v ~= 0 then  imgui.Text(fa.ICON_FA_USER_TAG ..u8" Тэг: ".. tag.v) end

  if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_FIRST_AID ..u8" Пациентов вылечено за все время: " .. vilichenovsego.v) end

  if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_BOOK_MEDICAL ..u8" Мед.карт выдано за все время: " .. medcartzavsevremia.v) end

  if organisation.v == 9 or organisation.v == 10 or organisation.v == 11 then imgui.Text(fa.ICON_FA_BOOK_MEDICAL ..u8" Рецептов выдано за все время" .. receptovzavsevremia.v) end


  
imgui.EndChild()
end
if shpora_state.v then
imgui.BeginChild("##PIZDA",imgui.ImVec2(705,400),true)

imgui.EndChild()


end



if settings_window_state.v then
  imgui.BeginChild("777", imgui.ImVec2(705, 400), true, imgui.WindowFlags.NoScrollbar)
  
  
  
  if imgui.CollapsingHeader(u8'Основные настройки') then
    local table_organisations = {u8'Не установлена',u8'Правительство', u8'Центральный банк', u8'Автошкола', u8'ЛСПД', u8'СФПД', u8"РКШД", u8"ЛВПД", u8"СВАТ", u8"ЛСМЦ", u8"ЛВМЦ", u8"СФМЦ", u8"Армия ЛС", u8"Армия СФ", u8"ТСР", u8"Радио ЛС", u8"Радио ЛВ", u8"Радио СФ", u8"Страховая компания"}
    imgui.PushItemWidth(200)
    if imgui.InputText(u8'Имя и Фамилия', nickname)  then ini.settings.nick = nickname.v inicfg.save(def,directIni) end
    imgui.SameLine()
    if imgui.InputText(u8'Пароль',password) then ini.settings.password = password.v inicfg.save(def,directIni) end
    imgui.SameLine()
    if imgui.Checkbox(fa.ICON_FA_DONATE .. u8" Авто-логин",enableautologin) then ini.settings.passwordauto = enableautologin.v inicfg.save(def,directIni) end
    if imgui.InputText(u8'Тэг', tag)  then ini.settings.tag = tag.v inicfg.save(def,directIni) end
    
    if imgui.Combo(u8'Организация', organisation, table_organisations,7) then
      

    sampAddChatMessage(organisation.v,-1)


      ini.settings.organisation = organisation.v
      
    if ini.settings.organisation == 0 then organisationname.v = table_organisations[1] end 
    if ini.settings.organisation == 1 then organisationname.v = table_organisations[2] end 
    if ini.settings.organisation == 2 then organisationname.v = table_organisations[3] end 
    if ini.settings.organisation == 3 then organisationname.v = table_organisations[4] end 
    if ini.settings.organisation == 4 then organisationname.v = table_organisations[5] end 
    if ini.settings.organisation == 5 then organisationname.v = table_organisations[6] end 
    if ini.settings.organisation == 6 then organisationname.v = table_organisations[7] end 
    if ini.settings.organisation == 7 then organisationname.v = table_organisations[8] end 
    if ini.settings.organisation == 8 then organisationname.v = table_organisations[9] end 
    if ini.settings.organisation == 9 then organisationname.v = table_organisations[10] end 
    if ini.settings.organisation == 10 then organisationname.v = table_organisations[11] end 
    if ini.settings.organisation == 11 then organisationname.v = table_organisations[12] end 
    if ini.settings.organisation == 12 then organisationname.v = table_organisations[13] end 
    if ini.settings.organisation == 13 then organisationname.v = table_organisations[14] end 
    if ini.settings.organisation == 14 then organisationname.v = table_organisations[15] end 
    if ini.settings.organisation == 15 then organisationname.v = table_organisations[16] end 
    if ini.settings.organisation == 16 then organisationname.v = table_organisations[17] end 
    if ini.settings.organisation == 17 then organisationname.v = table_organisations[18] end 
    if ini.settings.organisation == 18 then organisationname.v = table_organisations[19] end 
    if ini.settings.organisation == 19 then organisationname.v = table_organisations[20] end 

			inicfg.save(def, directIni)
       
    end

    if imgui.InputText(u8'Должность', post)  then ini.settings.post = post.v inicfg.save(def,directIni) end
    
    local table_sex = {u8'Мужской',u8'Женский',u8'Не определен'}
   
    if imgui.Combo(u8'Пол',sex,table_sex,3) then
      
     ini.settings.sex = sex.v
      if ini.settings.sex == 0 then sexname.v = table_sex[1] end
      if ini.settings.sex == 1 then sexname.v = table_sex[2] end
      if ini.settings.sex == 2 then sexname.v = table_sex[3] end
   inicfg.save(def, directIni)
  end


if imgui.InputText(u8'Команда активации',command) then ini.settings.command = command.v inicfg.save(def,directIni) end
imgui.SameLine()
imgui.TextDisabled('(?)')
imgui.Hint(u8'После установки нужной команды - нужно перезагрузить скрипт.\n[CTRL + R]')


imgui.PopItemWidth()
  end

  if imgui.CollapsingHeader(u8'Настройки чата') then
    if imgui.ColorEdit3(u8 'Рация', raziacolor) then
      colors.razia.r, colors.razia.g, colors.razia.b = raziacolor.v[1] * 255, raziacolor.v[2] * 255, raziacolor.v[3] * 255
      colors.razia.color = ARGBtoRGB(join_argb(255, raziacolor.v[1] * 255, raziacolor.v[2] * 255, raziacolor.v[3] * 255))
      saveCFG()
  end
  if imgui.Button(u8 'Пример рации##1') then sampAddChatMessage("[R] Редактор Sofie_Rave[543]: Коллеги,когда собрание?", join_argb(255, colors.razia.r, colors.razia.g, colors.razia.b)) end
  if imgui.ColorEdit3(u8 'Департамент', departamentcolor) then
    colors.departament.r, colors.departament.g, colors.departament.b = departamentcolor.v[1] * 255, departamentcolor.v[2] * 255, departamentcolor.v[3] * 255
    colors.departament.color = ARGBtoRGB(join_argb(255, departamentcolor.v[1] * 255, departamentcolor.v[2] * 255, departamentcolor.v[3] * 255))
    saveCFG()
end

  if imgui.Button(u8 'Пример департамента##1') then sampAddChatMessage("[D] Детектив Jizzy_Pain[213]: [СФПД] - [ЛСПД] Не хотите провести общую тренировку?", join_argb(255, colors.departament.r, colors.departament.g, colors.departament.b)) end
    
  if imgui.ColorEdit3(u8 'Кик', kickcolor) then
      colors.kick.r, colors.kick.g, colors.kick.b = kickcolor.v[1] * 255, kickcolor.v[2] * 255, kickcolor.v[3] * 255
      colors.kick.color = ARGBtoRGB(join_argb(255, kickcolor.v[1] * 255, kickcolor.v[2] * 255, kickcolor.v[3] * 255))
      saveCFG()
  end
  if imgui.Button(u8 'Пример кика##1') then sampAddChatMessage("Администратор Chase_Yanetto[223] кикнул игрока Sergey_Semchenko[321]. Причина: Нон-РП езда", join_argb(255, colors.kick.r, colors.kick.g, colors.kick.b)) end

  if imgui.ColorEdit3(u8 'Варн', warncolor) then
      colors.warn.r, colors.warn.g, colors.warn.b = warncolor.v[1] * 255, warncolor.v[2] * 255, warncolor.v[3] * 255
      colors.warn.color = ARGBtoRGB(join_argb(255, warncolor.v[1] * 255, warncolor.v[2] * 255, warncolor.v[3] * 255))
      saveCFG()
  end
  if imgui.Button(u8 'Пример варна##2') then sampAddChatMessage("Администратор Chase_Yanetto[223] выдал предупреждение игроку Sergey_Semchenko[321]", join_argb(255, colors.warn.r, colors.warn.g, colors.warn.b)) end

  if imgui.ColorEdit3(u8 'Бан', bancolor) then
      colors.ban.r, colors.ban.g, colors.ban.b = bancolor.v[1] * 255, bancolor.v[2] * 255, bancolor.v[3] * 255
      colors.ban.color = ARGBtoRGB(join_argb(255, bancolor.v[1] * 255, bancolor.v[2] * 255, bancolor.v[3] * 255))
      saveCFG()
  end
  if imgui.Button(u8 'Пример бана##3') then sampAddChatMessage("Администратор Chase_Yanetto[223] забанил игрока Sergey_Semchenko[321] на 10 дней. Причина: Нон-РП развод", join_argb(255, colors.ban.r, colors.ban.g, colors.ban.b)) end

  if imgui.ColorEdit3(u8 'Мут', mutecolor) then
      colors.mute.r, colors.mute.g, colors.mute.b = mutecolor.v[1] * 255, mutecolor.v[2] * 255, mutecolor.v[3] * 255
      colors.mute.color = ARGBtoRGB(join_argb(255, mutecolor.v[1] * 255, mutecolor.v[2] * 255, mutecolor.v[3] * 255))
      saveCFG()
  end
  if imgui.Button(u8 'Пример мута##4') then sampAddChatMessage("Администратор Chase_Yanetto[223] заглушил игрока Sergey_Semchenko[321] на 15 минут. Причина: Оскорбление ФБР", join_argb(255, colors.mute.r, colors.mute.g, colors.mute.b)) end

if imgui.ColorEdit3(u8 'Тюрьма', jailcolor) then
      colors.jail.r, colors.jail.g, colors.jail.b = jailcolor.v[1] * 255, jailcolor.v[2] * 255, jailcolor.v[3] * 255
      colors.jail.color = ARGBtoRGB(join_argb(255, jailcolor.v[1] * 255, jailcolor.v[2] * 255, jailcolor.v[3] * 255))
      saveCFG()
  end
  if imgui.Button(u8 'Пример тюрьмы##5') then sampAddChatMessage("Администратор Chase_Yanetto[223] посадил игрока Sergey_Semchenko[321] в деморган на 120 минут. Причина: Нападение на ФБР", join_argb(255, colors.jail.r, colors.jail.g, colors.jail.b)) end


if imgui.ColorEdit3(u8 'Сообщения таксистов', rt) then
  colors.rt.r, colors.rt.g, colors.rt.b = rt.v[1] * 255, rt.v[2] * 255, rt.v[3] * 255
  colors.rt.color = ARGBtoRGB(join_argb(255, rt.v[1] * 255, rt.v[2] * 255, rt.v[3] * 255))
  saveCFG()
end


if imgui.Button(u8 'Пример сообщения таксистов##6') then sampAddChatMessage("[Таксист] Jojo_Reference[723]: Всем привет,сколько заказов на линии?", join_argb(255, colors.rt.r, colors.rt.g, colors.rt.b)) end

if imgui.ColorEdit3(u8 'Сообщения дальнобойщиков', dalnoboi) then
colors.dalnoboi.r, colors.dalnoboi.g, colors.dalnoboi.b = dalnoboi.v[1] * 255, dalnoboi.v[2] * 255, dalnoboi.v[3] * 255
colors.dalnoboi.color = ARGBtoRGB(join_argb(255, dalnoboi.v[1] * 255, dalnoboi.v[2] * 255, dalnoboi.v[3] * 255))
saveCFG()
end

if imgui.Button(u8 'Пример сообщения дальнобоев##7') then sampAddChatMessage("[Дальнобойщик] Dio_Reference[712]: Всем привет,заказов много на АЗС?", join_argb(255, colors.dalnoboi.r, colors.dalnoboi.g, colors.dalnoboi.b)) end


if imgui.Checkbox(fa.ICON_FA_DONATE .. u8" Отключить донат-флуд",donatepizda) then ini.settings.donat = donatepizda.v inicfg.save(def,directIni) end
end
  if imgui.CollapsingHeader(u8'Настройка тем') then
    if ini.settings.theme == 0 then gray_theme() end
   	if ini.settings.theme == 1 then orange_theme() end
	  if ini.settings.theme == 2 then blue_theme() end
    if ini.settings.theme == 3 then pink_theme() end
    if ini.settings.theme == 4 then red_theme() end
  
    local table_themes = {u8'Серая', u8'Оранжевая', u8'Синяя', u8'Фиолетовая',u8'Красная'}
    imgui.PushItemWidth(200) --Устанавливаем ширину элементов listBox
    if imgui.Combo(u8'', tema, table_themes, 6) then

      ini.settings.theme = tema.v
			inicfg.save(def, directIni)
       
    end
imgui.PopItemWidth()
  end


  if imgui.CollapsingHeader(u8'Настройки статистики') then
   
  end


  if imgui.CollapsingHeader(u8'') then
    imgui.Text(u8"педофил")
  end
  imgui.EndChild()
end


imgui.End() -- конец окна

end

end






function sampev.onServerMessage(color, text)
  
  
  if text:find("Вы продали %d рецептов .+ за %d") then
    local kolvo, nick, price = text:match('Вы продали (%d+) рецептов (.+) за (%d+)')
   
    kolvoreceptov.v = kolvoreceptov.v + kolvo
    
  end
  if text:find("Вы успешно взяли 10 медикаментов для лечения больных!") then
   kolvomedicamentov.v = kolvomedicamentov.v + 10
   
 
   if kolvomedicamentov.v > 20 then
     kolvomedicamentov.v = 20
   end
   sampAddChatMessage(kolvomedicamentov.v,-1)
  end
  if text:find("Вы не можете унести больше") then
    kolvomedicamentov.v = 20
    sampAddChatMessage(kolvomedicamentov.v,-1)
    end
  if text:find("Вы вылечили .+ за $1000") then
  kolvomedicamentov.v = kolvomedicamentov.v - 1
  vilichenovsego.v = vilichenovsego.v + 1
if kolvomedicamentov.v < 0 then 

 kolvomedicamentov.v = 0
end


  end

 
  if text:match('Вы выдали .+ "Мед. Карта') then

  medcartzavsevremia.v = medcartzavsevremia.v + 1
  end


  if text == (string.format("Используйте: /jobprogress [ ID игрока ]")) then
  return false
  end








if text == ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") then
  
  if donatepizda.v then
  
    return false

  end
  
end


if text == ("- Наш сайт: arizona-rp.com (Личный кабинет/Донат)") then
if donatepizda.v then

  return false
end

end



if text == ("- Пригласи друга и получи бонус в размере $300 000!") then

if donatepizda.v then

return false
end
end


if text == ("- Основные команды сервера: /menu /help /gps /settings") then

if donatepizda.v then

return false
end
end 
 


  rtcol = argb_to_rgba(join_argb(255, colors.rt.r, colors.rt.g, colors.rt.b))
    dalnoboi = argb_to_rgba(join_argb(255, colors.dalnoboi.r, colors.dalnoboi.g, colors.dalnoboi.b))


	if text:match('Администратор .+%[%d+%] кикнул игрока .+%[%d+%]%. Причина%: .+') then color = argb_to_rgba(join_argb(255, colors.kick.r, colors.kick.g, colors.kick.b)) end
  if text:match('Администратор .+%[%d+%] выдал предупреждение игроку .+') then  color = argb_to_rgba(join_argb(255, colors.warn.r, colors.warn.g, colors.warn.b)) end
  if text:match('Администратор .+%[%d+%] забанил игрока .+%[%d+%] на .+ дней. Причина%: .+') then color = argb_to_rgba(join_argb(255, colors.ban.r, colors.ban.g, colors.ban.b)) end
	if text:match('Администратор .+%[%d+%] заглушил игрока .+%[%d+%] на .+ минут%. Причина%: .+') then color = argb_to_rgba(join_argb(255, colors.mute.r, colors.mute.g, colors.mute.b)) end
	if text:match('Администратор .+%[%d+%] посадил игрока .+%[%d+%] в деморган на .+ минут%. Причина%: .+') then color = argb_to_rgba(join_argb(255, colors.jail.r, colors.jail.g, colors.jail.b)) end
  if text:match('[R].+ .+%[%d+%]%:.+') then color = argb_to_rgba(join_argb(255, colors.razia.r, colors.razia.g, colors.razia.b)) end
  if text:match('[D].+ .+%[%d+%]%:.+') then color = argb_to_rgba(join_argb(255, colors.departament.r, colors.departament.g, colors.departament.b)) end
    
    if text:match('%[Таксист%].+%[%d+%]%: .+') then 
        local nick, id, message = text:match('%[Таксист%](.+)%[(%d+)%]%: (.+)')
        sampAddChatMessage("[Таксист] ".. nick .. "[".. id .."]: ".. message, rtcol)
        
      
      return false
    end
    
    
    if text:match('%[Дальнобойщик%].+%[%d+%]%: .+') then 
      local nick, id, message = text:match('%[Дальнобойщик%](.+)%[(%d+)%]%: (.+)')
      sampAddChatMessage("[Дальнобойщик] ".. nick .. "[".. id .."]: ".. message, dalnoboi)
      
    
    return false

    end
 

    if text:match('[R].+ .+%[%d+%]%:.+') then
     local dolzhnost, nick, id, message = text:match('%[R%](.+) (.+)%[%d+%]%:(.+)')
     
    end


    
    return { color, text }



end


function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
  


  textforcmd = text
if dialogId == 0 then
 
  local pattern = [[{FFFFFF}Статистика успеваемости сотрудника {66FF6C}Правительство LS{FFFFFF}: (.+)
  1%) Времени на постах:{FFB323}(%d+){FFFFFF}
  2%) Проверенок заявлений на перепланировку: {FFB323}(%d+){FFFFFF}
  3%) Выдано паспортов: {FFB323}(%d+){FFFFFF}
  
  Статистика успеваемости за сегодня:
  1%) Времени на постах: (%d+)
  2%) Проверенок заявлений на перепланировку: (%d+)
  3%) Выдано паспортов: (%d+)]]
local a,b,c,d,e,f,g = text:match(pattern)

sampAddChatMessage(a,-1)
sampAddChatMessage(b,-1)
sampAddChatMessage(c,-1)
sampAddChatMessage(d,-1)
sampAddChatMessage(e,-1)
sampAddChatMessage(f,-1)
sampAddChatMessage(text)
end
  
  end



  function pink_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowRounding = 2
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 3
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    style.WindowPadding = imgui.ImVec2(4.0, 4.0)
    style.FramePadding = imgui.ImVec2(3.5, 3.5)
    style.ButtonTextAlign = imgui.ImVec2(0.0, 0.5)
    colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
    colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
    colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
    colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
    colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
    colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end



  function red_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function gray_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(9, 5)
    style.WindowRounding = 10
    style.ChildWindowRounding = 10
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(9.0, 3.0)
    style.ItemInnerSpacing = imgui.ImVec2(9.0, 3.0)
    style.IndentSpacing = 21
    style.ScrollbarSize = 6.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 17.0
    style.GrabRounding = 16.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)


    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end


gray_theme()


function orange_theme()
imgui.SwitchContext()
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local ImVec2 = imgui.ImVec2

style.WindowPadding = ImVec2(15, 15)
style.WindowRounding = 6.0
style.FramePadding = ImVec2(5, 5)
style.FrameRounding = 4.0
style.ItemSpacing = ImVec2(12, 8)
style.ItemInnerSpacing = ImVec2(8, 6)
style.IndentSpacing = 25.0
style.ScrollbarSize = 15.0
style.ScrollbarRounding = 9.0
style.GrabMinSize = 5.0
style.GrabRounding = 3.0

colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)

end


function blue_theme()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4

  style.WindowRounding = 2.0
  style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
  style.ChildWindowRounding = 2.0
  style.FrameRounding = 2.0
  style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
  style.ScrollbarSize = 13.0
  style.ScrollbarRounding = 0
  style.GrabMinSize = 8.0
  style.GrabRounding = 1.0

  colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
  colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
  colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
  colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
  colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
  colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
  colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
  colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Separator]              = colors[clr.Border]
  colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
  colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
  colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
  colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
  colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
  colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
  colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
  colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
  colors[clr.ComboBg]                = colors[clr.PopupBg]
  colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
  colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
  colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
  colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
  colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
  colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
  colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
  colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end


function imgui.VerticalSeparator()
  local p = imgui.GetCursorScreenPos()
  imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function imgui.TextQuestion(text)
  imgui.TextDisabled('(?)')
  if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(450)
      imgui.TextUnformatted(text)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
  end
end







function imgui.Hint(text, delay)
  if imgui.IsItemHovered() then
      if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
      local alpha = (os.clock() - go_hint) * 5 -- скорость появления
      if os.clock() >= go_hint then
          imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
              imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
                  imgui.BeginTooltip()
                  imgui.PushTextWrapPos(450)
                  imgui.TextUnformatted(text)
                  if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                  imgui.PopTextWrapPos()
                  imgui.EndTooltip()
              imgui.PopStyleColor()
          imgui.PopStyleVar()
      end
  end
end















function imgui.Link(link)
  if status_hovered then
      local p = imgui.GetCursorScreenPos()
      imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), link)
      imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + imgui.CalcTextSize(link).y), imgui.ImVec2(p.x + imgui.CalcTextSize(link).x, p.y + imgui.CalcTextSize(link).y), imgui.GetColorU32(imgui.ImVec4(0, 0.5, 1, 1)))
  else
      imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), link)
  end
  if imgui.IsItemClicked() then os.execute('explorer '..link)
  elseif imgui.IsItemHovered() then
      status_hovered = true else status_hovered = false
  end
end






function imgui.ToggleButton(str_id, bool)

  local rBool = false

  if LastActiveTime == nil then
     LastActiveTime = {}
  end
  if LastActive == nil then
     LastActive = {}
  end

  local function ImSaturate(f)
     return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
  end

  local p = imgui.GetCursorScreenPos()
  local draw_list = imgui.GetWindowDrawList()

  local height = imgui.GetTextLineHeightWithSpacing() + (imgui.GetStyle().FramePadding.y / 2)
  local width = height * 1.55
  local radius = height * 0.50
  local ANIM_SPEED = 0.15

  if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
     bool.v = not bool.v
     rBool = true
     LastActiveTime[tostring(str_id)] = os.clock()
     LastActive[str_id] = true
  end

  local t = bool.v and 1.0 or 0.0

  if LastActive[str_id] then
     local time = os.clock() - LastActiveTime[tostring(str_id)]
     if time <= ANIM_SPEED then
        local t_anim = ImSaturate(time / ANIM_SPEED)
        t = bool.v and t_anim or 1.0 - t_anim
     else
        LastActive[str_id] = false
     end
  end

  local col_bg
  if imgui.IsItemHovered() then
     col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
  else
     col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
  end

  draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
  draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.GetStyle().Colors[imgui.Col.Button]))

  return rBool
end







function onReceiveRpc(id,bitStream)
  if id == 61 then
      dialogId = raknetBitStreamReadInt16(bitStream)
      style = raknetBitStreamReadInt8(bitStream)
      str = raknetBitStreamReadInt8(bitStream)
      title = raknetBitStreamReadString(bitStream, str)
      if enableautologin.v then if password ~= "" then if title:find("Авторизация") then sampSendDialogResponse(dialogId,1,0,ini.settings.password) end end end
  end
end