kicktable = {}
do
local function history_link(extra, suc, result)
  for i=1, #result do
    delete_msg(result[i].id, ok_cb, false)
	end
		return "test "..#result.. ""
  end
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "<b>Promote me to admin first!</b>")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
		set_name = string.gsub(msg.to.title, '_', ' '),
		lock_link = "Lock",
		lock_tgservice = 'Lock',
		lock_member = 'Open',
		lock_bots = 'Open',
		lock_spam = 'Lock',
		lock_cmd = "Off",
		kick_lock = "Del",
		flood = 'Lock',
		group_type = "Supergroup",
		max_char = 7000,
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = '<i>گروه به سیستم مدیریتی اضافه شد</i>'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local text = '<i>گروه از سیستم مدیریتی پاک شد</i>'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

local function callback_clean_bots(extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="مشخصات گروه: ["..result.title.."]\n\n"
local admin_num = "👤 تعداد ادمین : "..result.admins_count.."\n"
local user_num = "👥 تعدا دکاربران: "..result.participants_count.."\n"
local kicked_num = "🚫 تعداد اخراج شدگان "..result.kicked_count.."\n"
local channel_id = "🆔 شناسه: "..result.peer_id.."\n"
local text = title..admin_num..user_num..kicked_num..channel_id
    send_large_msg(cb_extra.receiver, text)
end
--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'Lock' then
    return 'ارسال لینک قفل میباشد\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_link'] = 'Lock'
    save_data(_config.moderation.data, data)
    return 'ارسال لینک قفل شد'
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'Open' then
    return 'ارسال لینک مجاز است\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_link'] = 'Open'
    save_data(_config.moderation.data, data)
    return 'ارسال لینک مجاز شد'
  end
end
local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'Lock' then
    return 'پیام ورود و خروج کاربران به گروه پاک میشوند\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'Lock'
    save_data(_config.moderation.data, data)
    return 'پیام های ورود و خروج کاربران به گروه از این پس پاک میشوند'
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'Open' then
    return 'پیام های ورود و خروج کاربران به گروه پاک نمیشود\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'Open'
    save_data(_config.moderation.data, data)
    return 'پیام های ورود و خروج کاربران به گروه از این پس پاک خواهد شد'
  end
end
local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return 
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'Lock' then
    return 'پیام های طولانی حذف میشوند\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'Lock'
    save_data(_config.moderation.data, data)
    return 'پیام های طولانی از این پس پاک خواهد شد'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'Open' then
    return 'پیام های طولانی پاک نمیشود\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'Open'
    save_data(_config.moderation.data, data)
    return 'پیام های طولانی پاک خواهد شد'
  end
end

local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_bots']
  if group_sticker_lock == 'Lock' then
    return 'ورود ربات ها مجاز نیست\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'Lock'
    save_data(_config.moderation.data, data)
    return 'ورود ربات ها از این پس مجاز نمیباشد'
  end
end

local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_bots']
  if group_sticker_lock == 'Open' then
    return 'ورود ربات ها مجاز است\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'Open'
    save_data(_config.moderation.data, data)
    return 'ورود ربات های از این پس مجاز است'
  end
end


local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'Lock' then
    return 'پیام های رگباری پاک میشوند\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['flood'] = 'Lock'
    save_data(_config.moderation.data, data)
    return 'پیام های رگباری از این پس پاک خواهند شد'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'Open' then
    return 'پیام رگباری آزاد است\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['flood'] = 'Open'
    save_data(_config.moderation.data, data)
    return 'پیام های رگباری از این پس پاک نخواهد شد'
  end
end
----------------
local function kick_on(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local kick_on = data[tostring(target)]['settings']['kick_lock']
  if kick_on == 'Kick' then
    return "تبلیغات در حالت (حذف پیام و کاربر) میباشد\n\nلطفا دوباره تلاش نفرمایید"
  else
    data[tostring(target)]['settings']['kick_lock'] = 'Kick'
    save_data(_config.moderation.data, data)
    return 'تبلیغات به حالت (حذف پیام و کاربر) تغییر یافت'
  end
end
local function kick_off(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local kick_off = data[tostring(target)]['settings']['kick_lock']
  if kick_off == 'Del' then
    return 'تبلیغات در حالت (حذف پیام) میباشد\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['kick_lock'] = 'Del'
    save_data(_config.moderation.data, data)
    return 'تبلیغات به حالت (حذف یپام) تغییر یافت'
  end
end
local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'Lock' then
    return 'عضوگیری بسته است\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_member'] = 'Lock'
    save_data(_config.moderation.data, data)
  end
  return 'عضوگیری گروه بسته شد'
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'Open' then
    return 'عضوگیری گروه آزاد است\n\nلطفا دوباره تلاش نفرمایید'
  else
    data[tostring(target)]['settings']['lock_member'] = 'Open'
    save_data(_config.moderation.data, data)
    return 'عضوگیری گروه باز شد'
  end
end
--End supergroup locks
--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return nil
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'قوانین جدید تنظیم شد\n---------------------------------------\n'..rules..'\n----------------------------------------\n'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'قانونی تنظیم نشده است'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
 local rules = 'قوانین گروه : \n---------------------------------------\n'..rules:gsub("/n", " ")  
 return rules
end



--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
      	else
        	NUM_MSG_MAX = 5
      	end
    end
	    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['max_char'] then
        	max_char = tonumber(data[tostring(target)]['settings']['max_char'])
      	else
        	max_char = 7000
      	end
    end
	if data[tostring(target)]['settings'] then
  		if not data[tostring(target)]['settings']['lock_link'] then
			data[tostring(target)]['settings']['lock_link'] = 'Open'
		end
	end
    if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'Open'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'Open'
		end
	end	
		if data[tostring(target)]['settings'] then
	if not data[tostring(target)]['settings']['lock_bots'] then
			data[tostring(target)]['settings']['lock_bots'] = 'Open'
		end
	end	
	if data[tostring(target)]['settings'] then
	if not data[tostring(target)]['settings']['lock_spam'] then
			data[tostring(target)]['settings']['lock_spam'] = 'Open'
		end
	end	
	if data[tostring(target)]['settings'] then
    if not data[tostring(target)]['settings']['welcome'] then
			data[tostring(target)]['settings']['welcome'] = 'Off'
		end
	end
		if data[tostring(target)]['settings'] then
    if not data[tostring(target)]['settings']['kick_lock'] then
			data[tostring(target)]['settings']['kick_lock'] = 'Del'
		end
	end
	gp_type =data[tostring(msg.to.id)]['group_type']
	if data[tostring(target)]['settings'] then
    if not data[tostring(msg.to.id)]['group_type'] then
             data[tostring(target)]['settings']['group_type'] = 'Not Set'
         end
    end
      local user_info = redis:hget("owner:group:",msg.to.id)
	  if user_info then 
	  gpowner = "@"..user_info
	  else 
	  gpowner = "یافت نشد"
end
  local expiretime = redis:hget('expiretime', target) 
    local expire = ''
  if not expiretime then
  expire = expire..'تنظیم نشده'
  else
   local now = tonumber(os.time())
   expire =  expire..math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
   expire = expire.." روز دیگر"
 end
  local settings = data[tostring(target)]['settings']
local text = "تنظیمات گروه :\n--------------\n"
	.."\nوضعیت لینک ها > "..settings.lock_link
	.."\nوضعیت عضوگیری > "..settings.lock_member
	.."\nورود ربات > "..settings.lock_bots
	.."\nپیام طولانی > "..settings.lock_spam
	.."\nپیام رگباری > "..settings.flood
	.."\nحساسیت پیام طولانی > "..max_char
	.."\nحساسیت پیام رگباری > "..NUM_MSG_MAX
	.."\nخوش آمد > "..settings.welcome
	.."\nتبلیغات > "..settings.kick_lock
	.."\n--------------\n"
	.."\nصاحب گروه > "..gpowner
	.."\nزبان > فارسی"
	.."\nنوع > سوپرگروه"
	.."\nتاریخ انقضا > "..expire
	text = string.gsub(text,"Lock","قفل")
	text = string.gsub(text,"Open","آزاد")
	text = string.gsub(text,"On","روشن")
	text = string.gsub(text,"Off","روشن")
	text = string.gsub(text,"Del","حذف پیام")
	text = string.gsub(text,"Kick","حذف پیام و شخص")
  return text
end
local function silentuser_by_reply(extra, success, result)
   local user_id = result.from.peer_id
  local receiver = extra.receiver
  local chat_id = result.to.peer_id
    if is_momod2(user_id, chat_id) and not is_admin2(result.from.id) then
			   return send_large_msg("channel#id"..chat_id, "You can't silent mods/owner/admins")
    end
    if is_admin2(result.from.id) then
         return send_large_msg("channel#id"..chat_id, "You can't silent other admins")
    end
  if is_muted_user(chat_id, user_id) then
   return send_large_msg(receiver, " ["..user_id.."] هم اکنون در سکوت است")
  end
   mute_user(chat_id, user_id)
  return  send_large_msg(receiver, " ["..user_id.."] به لیست سکوت اضافه شد")
end

local function silentuser_by_username(extra, success, result)
  local user_id = result.peer_id
  local receiver = extra.receiver
  local chat_id = string.gsub(receiver, 'channel#id', '')
    if is_momod2(user_id, chat_id) and not is_admin2(result.id) then
	 return send_large_msg("channel#id"..chat_id, "You can't silent mods/owner/admins")
    end
    if is_admin2(result.id) then
    return send_large_msg("channel#id"..chat_id, "You can't silent other admins")
    end
  if is_muted_user(chat_id, user_id) then
   return send_large_msg(receiver, " ["..user_id.."] هم اکنون در سکوت است")
  end
   mute_user(chat_id, user_id)
  return send_large_msg(receiver, " ["..user_id.."] به لیست سکوت اضافه شد")
end

--unsilent_user By @SoLiD021
function unsilentuser_by_reply(extra, success, result)
  local user_id = result.from.peer_id
  local receiver = extra.receiver
  local chat_id = result.to.peer_id
  if is_muted_user(chat_id, user_id) then
   unmute_user(chat_id, user_id)
   send_large_msg(receiver, "["..user_id.."] از لیست سکوت حذف شد")
else
   send_large_msg(receiver, "["..user_id.."] در لیست سکوت نیست")
  end
 end
local function unsilentuser_by_username(extra, success, result)
  local user_id = result.peer_id
  local receiver = extra.receiver
  local chat_id = string.gsub(receiver, 'channel#id', '')
  if is_muted_user(chat_id, user_id) then
   unmute_user(chat_id, user_id)
   send_large_msg(receiver, "["..user_id.."] از لیست سکوت حذف شد")
else
   send_large_msg(receiver, "["..user_id.."] در لیست سکوت نیست")
  end
 end
local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = member_username
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' هم اکنون مدیر است')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' مدیر نیست')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = member_username
  if not data[group] then
    return send_large_msg(receiver, 'گروه به سیستم اضافه شد')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' از قبل مدیر بود')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' مدیر شد')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه به سیستم اضافه نشده')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' مدیر نیست')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' از مدیریت برکنار شد')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'گروه به سیستم اضافه نشده است'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return 'مدیری در گروه نیست'
  end
  local i = 1
  local message = '\nلیست مدیران :\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	if get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			if result.from.username then 
			redis:hset("owner:group:",dmdmd,result.from.username)
			else 
			redis:hset("owner:group:",dmdmd,result.from.peer_id)
			end
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] \nبه عنوان سرپرست شناخته شد"
			else
				text = "[ "..result.from.peer_id.." ] به عنوان سرپرست شناخته شد"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] removed from the muted user list")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] added to the muted user list")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	if get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			if result.username then 
			redis:hset("owner:group:",dmdmd,result.username)
			else 
			redis:hset("owner:group:",dmdmd,result.peer_id)
			end
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] \nبه عنوان سرپرست شناخته شد"
		else
			text = "[ "..result.peer_id.." ] به عنوان سرپرست شناخته شد"
		end
		send_large_msg(receiver, text)
  end
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'کاربر [ @'..member..'] در اینجا نیست'
  else
    text = 'کاربر ['..memberid..'] در اینجا نیست'
  end

 if get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
			if v.username then 
			redis:hset("owner:group:",dmdmd,v.username)
			else 
			redis:hset("owner:group:",dmdmd,v.peer_id)
			end		
			channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
				if result.username then
					text = member_username.." ["..v.peer_id.."] \nبه عنوان سرپرست شناخته شد"
				else
					text = "["..v.peer_id.."] به عنوان سرپرست شناخته شد"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				text = "["..memberid.."] به عنوان سرپرست شناخته شد"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    os.rename(result, file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'عکس ذخیره شد', ok_cb, false)
  else
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end
-------------------------------------------------------------------------------------------------------------------------
function pre_process(msg)
  if msg.service then
    return msg
  end
  if msg.from.id == our_id then
    return msg
  end
  -- Save stats on Redis
  if msg.to.type == 'channel' then
    local hash = 'channel:'..msg.to.id..':users'
    redis:sadd(hash, msg.from.id)
  end
  if msg.to.type == 'user' then
    local hash = 'PM:'..msg.from.id
    redis:sadd(hash, msg.from.id)
  end
  local hash = 'msgs:'..msg.from.id..':'..msg.to.id
  redis:incr(hash)
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['settings']['flood'] == 'Open' then
      return msg
    end
  end
  if msg.from.type == 'user' then
    local hash = 'user:'..msg.from.id..':msgs'
    local msgs = tonumber(redis:get(hash) or 0)
    local data = load_data(_config.moderation.data)
    local NUM_MSG_MAX = 6
    if data[tostring(msg.to.id)] then
      if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
        NUM_MSG_MAX = tonumber(data[tostring(msg.to.id)]['settings']['flood_msg_max'])--Obtain group flood sensitivity
      end
    end
    local max_msg = NUM_MSG_MAX - 1
    if msgs > max_msg then
	  local user = msg.from.id
	  local chat = msg.to.id
      if is_momod(msg) then 
        return msg
      end
	  local receiver = get_receiver(msg)
	  if msg.to.type == 'user' then
		local max_msg = 7 
		if msgs >= max_msg then
			send_large_msg("user#id"..msg.from.id, "بدلیل اسپم بلاک میشوید!")
			block_user("user#id"..msg.from.id,ok_cb,false)
		end
      end
	  if kicktable[user] == true then
		return
	  end
	  delete_msg(msg.id, ok_cb, false)
	  kick_user(user, chat)
	  local username = msg.from.username
	  local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name_log = print_name:gsub("_", "")
	  local data = load_data(_config.moderation.data)
	  if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
	  floood = data[tostring(msg.to.id)]['settings']['flood_msg_max']
	  else 
	  floood = 7
	  end
	  if msg.to.type == 'chat' or msg.to.type == 'channel' then
		if username then
			send_large_msg(receiver , "<i>ارسال پیام رگباری مجاز نیست</i>\nکاربر خاطی : \n@"..username.." ["..msg.from.id.."]\nوضعیت: از گروه حذف شد")
			get_history(msg.to.peer_id, floood , history_link )

		else
			send_large_msg(receiver , "<i>ارسال پیام رگباری مجاز نیست</i>\nکاربر خاطی : \n"..name_log.." ["..msg.from.id.."]\nوضعیت: از گروه حذف شد")
			get_history(msg.to.peer_id, floood , history_link )
		end
	  end
      -- incr it on redis
      local gbanspam = 'gban:spam'..msg.from.id
      redis:incr(gbanspam)
      local gbanspam = 'gban:spam'..msg.from.id
      local gbanspamonredis = redis:get(gbanspam)
      if gbanspamonredis then
        if tonumber(gbanspamonredis) ==  4 and not is_owner(msg) then
          banall_user(msg.from.id)
          local gbanspam = 'gban:spam'..msg.from.id
          redis:set(gbanspam, 0)
          if msg.from.username ~= nil then
            username = msg.from.username
		  else 
			username = "---"
          end
          local print_name = user_print_name(msg.from):gsub("‮", "")
		  local name = print_name:gsub("_", "")
		  send_large_msg("channel#id"..msg.to.id, "User [ "..name.." ]"..msg.from.id.." globally banned (spamming)")
		  gban_text = "User [ "..name.." ] ( @"..username.." )"..msg.from.id.." Globally banned from ( "..msg.to.print_name.." ) [ "..msg.to.id.." ] (spamming)"
		  send_large_msg('channel#id1085540553', gban_text)
        end
      end
      kicktable[user] = true
      msg = nil
    end
    redis:setex(hash, 1, msgs+1)
  end
  muteredis = redis:get('muteall:'..msg.to.id)
if muteredis and msg.to.type == 'channel' and not is_momod(msg)  then
	delete_msg(msg.id, ok_cb, false)
		end
	if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
	end
	local user_infoo = redis:hget("owner:group:",msg.to.id)
	if user_infoo then 
		gpownere = "@"..user_infoo
	else 
		gpownere = "Not Found!"
	end
		link = redis:hget("group_links",msg.to.id)
	if link then 
		llink = link
	else 
		llink = "Not Found!"
	end
 local timetoexpire = 'تنظیم نشده'
 local expiretime = redis:hget('expiretime',msg.to.id)
 local now = tonumber(os.time())
 if expiretime then    
  timetoexpire = math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
		if tonumber("0") > tonumber(timetoexpire) and not is_sudo(msg) then
  if msg.text:match('/') or msg.text:match('!') or msg.text:match('#') or msg.text:match('(.*)') then
   return   send_large_msg("channel#id"..msg.to.id, 'مدت زمان شارژ گروه به اتمام رسید\n\nربات غیر فعال شده و به هیچ دستوری جواب نمیدهد\nبرای تمدید از راه های زیر اقدام کنید \n------------\nمراجعه به ساپورت \nادمین : @HEXTOR \nپیام رسان ادمین : @ReZa_HEXTOR_Bot\n\nکانال : @HEXTOR_CH')
  end
 end
 if tonumber(timetoexpire) == 0 then
  if redis:hget('expires0',get_receiver(msg)) then return msg end
   send_large_msg(get_receiver(msg), 'مدت زمان شارژ گروه به اتمام رسید\n\n ربات غیر فعال شده و دیگر به هیچ دستوری جواب نخواهد داد \nبرای تمدید از راه های زیر اقدام کنید \n------------\nمراجعه به ساپورت \nادمین : @HEXTOR \nپیام رسان ادمین :\n@ReZa_HEXTOR_Bot\n\nکانال : @HEXTOR_CH')
  send_large_msg("user#id184413821","<i>a Group Has Bene Expired</i>\n➖➖➖➖➖➖➖\n<b>Group Name : </b> "..msg.to.title.."\n<b>Group ID : </b> ["..msg.to.id.."]\n<b>Group Onwer : </b> "..gpownere.."\n<b>Group Link : </b> "..llink.."\n➖➖➖➖➖➖➖\n<code>To Exit The Bot submit Command : </code>\n/leave"..msg.to.id.."\n➖➖➖➖➖➖➖\n<i>To charge a month : </i>\n/charge"..msg.to.id.." 1\n<i>To charge two months :</i>\n/charge"..msg.to.id.." 2\n<i>To Charge The Desired Day :</i>\n/charge"..msg.to.id.." <Number Day>\n\n<i>For unlimited charge :</i>\n/charge"..msg.to.id.." unlimit\n------------------\n")
  redis:hset('expires0',msg.to.id,'5')
 end
 if tonumber(timetoexpire) == 1 then
  if redis:hget('expires1',msg.to.id) then return msg end
  send_large_msg(get_receiver(msg), 'تنها یک روز تا پایان مدت زمان گروه باقی مانده است\n\n نسبت به تمدید اقدام کنید')
  redis:hset('expires1',msg.to.id,'5')
 end
 if tonumber(timetoexpire) == 2 then
  if redis:hget('expires2',msg.to.id) then return msg end
  send_large_msg(get_receiver(msg), 'تنها دو روز تا پایان مدت زمان گروه باقی مانده است\n\n نسبت به تمدید اقدام کنید')
  redis:hset('expires2',msg.to.id,'5')
 end
 if tonumber(timetoexpire) == 3 then
  if redis:hget('expires3',msg.to.id) then return msg end
  send_large_msg(get_receiver(msg), 'تنها سه روز تا پایان مدت زمان گروه باقی مانده است\n\n نسبت به تمدید اقدام کنید')
  redis:hset('expires3',msg.to.id,'5')
 end
end

-----------------
  if msg.action and msg.action.type then
    local action = msg.action.type
    if action == 'chat_add_user_link' then
      local user_id = msg.from.id
      local banned = is_banned(user_id, msg.to.id)
      if banned or is_gbanned(user_id) then -- Check it with redis
      kick_user(user_id, msg.to.id)
      end
    end
    if action == 'chat_add_user' then
      local user_id = msg.action.user.id
      local banned = is_banned(user_id, msg.to.id)
      if banned or is_gbanned(user_id) then -- Check it with redis
        kick_user(user_id, msg.to.id)
        local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
        redis:incr(banhash)
        local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
        local banaddredis = redis:get(banhash) 
        if banaddredis then 
          if tonumber(banaddredis) == 4 and not is_owner(msg) then 
            kick_user(msg.from.id, msg.to.id)-- Kick user who adds ban ppl more than 3 times
          end
          if tonumber(banaddredis) ==  8 and not is_owner(msg) then 
            ban_user(msg.from.id, msg.to.id)-- Kick user who adds ban ppl more than 7 times
            local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
            redis:set(banhash, 0)-- Reset the Counter
          end
        end
      end
end 
end
-----------------
if is_chat_msg(msg) or is_super_group(msg) then
	if msg and not is_momod(msg) and not is_whitelisted(msg.from.id) then 
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
		settings = data[tostring(msg.to.id)]['settings']
if msg and not msg.service and is_muted(msg.to.id, 'All: yes') or is_muted_user(msg.to.id, msg.from.id) and not msg.service then
			delete_msg(msg.id, ok_cb, false)
			return false
			end
	if data[tostring(msg.to.id)] and data[tostring(msg.to.id)]['settings'] then
		settings = data[tostring(msg.to.id)]['settings']
	else
		return
	end
	if settings.lock_bots then
		lock_bots = settings.lock_bots
	else
		lock_bots = 'Open'
	end
		if settings.kick_lock then
		kick_lock = settings.kick_lock
	else
		kick_lock = 'Del'
	end
	if settings.lock_arabic then
		lock_arabic = settings.lock_arabic
	else
		lock_arabic = 'Open'
	end	
	if settings.lock_rtl then
		lock_rtl = settings.lock_rtl
	else
		lock_rtl = 'Open'
	end
		if settings.lock_tgservice then
		lock_tgservice = settings.lock_tgservice
	else
		lock_tgservice = 'Open'
	end
	if settings.lock_link then
		lock_link = settings.lock_link
	else
		lock_link = 'Open'
	end
	if settings.lock_member then
		lock_member = settings.lock_member
	else
		lock_member = 'Open'
	end
	if settings.lock_spam then
		lock_spam = settings.lock_spam
	else
		lock_spam = 'Open'
	end
	if settings.lock_sticker then
		lock_sticker = settings.lock_sticker
	else
		lock_sticker = 'no'
	end
	if settings.lock_contacts then
		lock_contacts = settings.lock_contacts
	else
		lock_contacts = 'no'
	end
	if settings.max_char then 
	max_char = settings.max_char
	else 
	max_char = 7000
	end
		if msg and not msg.service and is_muted(msg.to.id, 'All: yes') or is_muted_user(msg.to.id, msg.from.id) and not msg.service then
	  if msg.text:match('/') or msg.text:match('!') or msg.text:match('#') or msg.text:match('(.*)') then
				delete_msg(msg.id, ok_cb, false)
			return false
					end 
				end
		if msg.text then -- msg.text checks
			local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
			 local _nl, real_digits = string.gsub(msg.text, '%d', '')
			if lock_spam == "Lock" and string.len(msg.text) > max_char or ctrl_chars > 70 or real_digits > 3000 then
				delete_msg(msg.id, ok_cb, false)
			end
			local is_link_msg = msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/(.*)") or msg.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee](.*)") or msg.text:match("[Ww][Ww][Ww].(.*)")or msg.text:match("(.*).[cC][oO][mM]")or msg.text:match("(.*).[Ii][Rr]")or msg.text:match("[Hh][Tt][Tt][Pp][Ss](.*)")
			local is_bot = msg.text:match("?[Ss][Tt][Aa][Rr][Tt]=")
			if is_link_msg and lock_link == "Lock" and not is_bot then
				delete_msg(msg.id, ok_cb, false)
				if is_link_msg and kick_lock == "Kick" then 
				delete_msg(msg.id, ok_cb, false)
				kick_user(msg.from.id, msg.to.id)
		end
end
		if msg.service then 
			if lock_tgservice == "Lock" then
				delete_msg(msg.id, ok_cb, false)
			end
		end
			local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
			if is_squig_msg and lock_arabic == "Lock" then
				delete_msg(msg.id, ok_cb, false)

			end
			local print_name = msg.from.print_name
			local is_rtl = print_name:match("‮") or msg.text:match("‮")
			if is_rtl and lock_rtl == "Lock" then
				delete_msg(msg.id, ok_cb, false)
			end
			if is_muted(msg.to.id, "Text: yes") and msg.text and not msg.media and not msg.service then
				delete_msg(msg.id, ok_cb, false)
			end
		end
		if msg.media then -- msg.media checks
			if msg.media.title then
			local is_link_title = msg.title:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/(.*)") or msg.title:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee](.*)") or msg.title:match("[Ww][Ww][Ww].(.*)")or msg.title:match("(.*).[cC][oO][mM]")or msg.title:match("(.*).[Ii][Rr]") or msg.title:match("[Hh][Tt][Tt][Pp][Ss](.*)")
			if is_link_title and lock_link == "Lock" then
				delete_msg(msg.id, ok_cb, false)
			if is_link_msg and kick_lock == "Kick" then 
				delete_msg(msg.id, ok_cb, false)
				kick_user(msg.from.id, msg.to.id)
end
				end
				local is_squig_title = msg.media.title:match("[\216-\219][\128-\191]")
				if is_squig_title and lock_arabic == "Lock" then
					delete_msg(msg.id, ok_cb, false)

				end
			end
			if msg.media.description then
						local is_link_desc = msg.media.description:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/(.*)") or msg.media.description:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee](.*)") or msg.media.description:match("[Ww][Ww][Ww].(.*)")or msg.media.description:match("(.*).[cC][oO][mM]")or msg.media.description:match("(.*).[Ii][Rr]") or msg.media.description:match("[Hh][Tt][Tt][Pp][Ss](.*)")
				if is_link_desc and lock_link == "Lock" then
					delete_msg(msg.id, ok_cb, false)
				if is_link_msg and kick_lock == "Kick" then 
				delete_msg(msg.id, ok_cb, false)
				kick_user(msg.from.id, msg.to.id)
				end
				end
				local is_squig_desc = msg.media.description:match("[\216-\219][\128-\191]")
				if is_squig_desc and lock_arabic == "Lock" then
					delete_msg(msg.id, ok_cb, false)

				end
			end
			if msg.media.caption then -- msg.media.caption checks
						local is_link_caption = msg.media.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/(.*)") or msg.media.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee](.*)") or msg.media.caption:match("[Ww][Ww][Ww].(.*)")or msg.media.caption:match("(.*).[cC][oO][mM]")or msg.media.caption:match("(.*).[Ii][Rr]")or msg.media.caption:match("[Hh][Tt][Tt][Pp][Ss](.*)")
				if is_link_caption and lock_link == "Lock" then
					delete_msg(msg.id, ok_cb, false)
				if is_link_msg and kick_lock == "Kick" then 
				delete_msg(msg.id, ok_cb, false)
				kick_user(msg.from.id, msg.to.id)
				end
				end
				local is_squig_caption = msg.media.caption:match("[\216-\219][\128-\191]")
					if is_squig_caption and lock_arabic == "Lock" then
						delete_msg(msg.id, ok_cb, false)

					end
				local is_username_caption = msg.media.caption:match("^@[%a%d]")
				if is_username_caption and lock_link == "Lock" then
					delete_msg(msg.id, ok_cb, false)
				end
				if lock_sticker == "Lock" and msg.media.caption:match("sticker.webp") then
					delete_msg(msg.id, ok_cb, false)
				end
			end
			if msg.media.type:match("contact") and lock_contacts == "Lock" then
				delete_msg(msg.id, ok_cb, false)
			end
			local is_photo_caption =  msg.media.caption and msg.media.caption:match("photo")--".jpg",
			if is_muted(msg.to.id, 'Photo: yes') and msg.media.type:match("photo") or is_photo_caption and not msg.service then
				delete_msg(msg.id, ok_cb, false)
			end
			local is_gif_caption =  msg.media.caption and msg.media.caption:match(".mp4")
			if is_muted(msg.to.id, 'Gifs: yes') and is_gif_caption and msg.media.type:match("document") and not msg.service then
				delete_msg(msg.id, ok_cb, false)
			end
			if is_muted(msg.to.id, 'Audio: yes') and msg.media.type:match("audio") and not msg.service then
				delete_msg(msg.id, ok_cb, false)
			end
			local is_video_caption = msg.media.caption and msg.media.caption:lower(".mp4","video")
			if  is_muted(msg.to.id, 'Video: yes') and msg.media.type:match("video") and not msg.service then
				delete_msg(msg.id, ok_cb, false)
			end
			if is_muted(msg.to.id, 'Documents: yes') and msg.media.type:match("document") and not msg.service then
				delete_msg(msg.id, ok_cb, false)
			end
		end
		if msg.fwd_from then
			if msg.fwd_from.title then
						local is_link_title = msg.fwd_from.title:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/(.*)") or msg.fwd_from.title:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee](.*)") or msg.fwd_from.title:match("[Ww][Ww][Ww].(.*)")or msg.fwd_from.title:match("(.*).[cC][oO][mM]")or msg.fwd_from.title:match("(.*).[Ii][Rr]")or msg.fwd_from.title:match("[Hh][Tt][Tt][Pp][Ss](.*)")
				if is_link_title and lock_link == "Lock" then
					delete_msg(msg.id, ok_cb, false)
				if is_link_msg and kick_lock == "Kick" then 
				delete_msg(msg.id, ok_cb, false)
				kick_user(msg.from.id, msg.to.id)
				end
				end
				local is_squig_title = msg.fwd_from.title:match("[\216-\219][\128-\191]")
				if is_squig_title and lock_arabic == "Lock" then
					delete_msg(msg.id, ok_cb, false)
				end
			end
			if is_muted_user(msg.to.id, msg.fwd_from.peer_id) then
			if msg.text:match('/') or msg.text:match('!') or msg.text:match('#') or msg.text:match('(.*)') then
				delete_msg(msg.id, ok_cb, false)
			return false
				end
			end
		end
		if msg.service then -- msg.service checks
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				local user_id = msg.from.id
				local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
				if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 and lock_group_spam == 'Lock' then
					delete_msg(msg.id, ok_cb, false)
				end
				local print_name = msg.from.print_name
				local is_rtl_name = print_name:match("‮")
				if is_rtl_name and lock_rtl == "Lock" then
					kick_user(user_id, msg.to.id)
				end
				if lock_member == 'Lock' then
					kick_user(user_id, msg.to.id)
					delete_msg(msg.id, ok_cb, false)
				end
			end
			if action == 'chat_add_user' and not is_momod2(msg.from.id, msg.to.id) then
				local user_id = msg.action.user.id
			if string.sub(msg.action.user.username:lower(), -3) == 'bot' then 
			kick_user(msg.action.user.id, msg.to.id)
			send_large_msg(get_receiver(msg), "Bot Add Not Allowed Here!")

end
				if string.len(msg.action.user.print_name) > 70 and lock_group_spam == 'Lock' then
					delete_msg(msg.id, ok_cb, false)
				end
				local print_name = msg.action.user.print_name
				local is_rtl_name = print_name:match("‮")
				if is_rtl_name and lock_rtl == "Lock" then
					kick_user(user_id, msg.to.id)
				end
				if msg.to.type == 'channel' and lock_member == 'Lock' then
					kick_user(user_id, msg.to.id)
					delete_msg(msg.id, ok_cb, false)
				end
			end
		end
	end
end
return msg
end
------------------------------------------
local function kick_ban_res(extra, success, result)
--vardump(result)
--vardump(extra)
      local member_id = result.id
      local user_id = member_id
      local member = result.username
      local chat_id = extra.chat_id
      local from_id = extra.from_id
      local get_cmd = extra.get_cmd
      local receiver = "chat#id"..chat_id
       if get_cmd == "kick" then
         if member_id == from_id then
             return send_large_msg(receiver, "You can't kick yourself")
         end
         if is_momod2(member_id, chat_id) and not is_admin2(sender) then
            return send_large_msg(receiver, "You can't kick mods/owner/admins")
         end
         return kick_user(member_id, chat_id)
      elseif get_cmd == 'ban' then
        if is_momod2(member_id, chat_id) and not is_admin2(sender) then
          return send_large_msg(receiver, "You can't ban mods/owner/admins")
        end
        send_large_msg(receiver, 'User @'..member..' ['..member_id..'] banned')
        return ban_user(member_id, chat_id)
      elseif get_cmd == 'unban' then
        send_large_msg(receiver, 'User @'..member..' ['..member_id..'] unbanned')
        local hash =  'banned:'..chat_id
        redis:srem(hash, member_id)
        return 'User '..user_id..' unbanned'
      elseif get_cmd == 'banall' then
        send_large_msg(receiver, 'User @'..member..' ['..member_id..'] globally banned')
        return banall_user(member_id, chat_id)
      elseif get_cmd == 'unbanall' then
        send_large_msg(receiver, 'User @'..member..' ['..member_id..'] un-globally banned')
        return unbanall_user(member_id, chat_id)
      end
end

------------------------------------------
local function admin_list(msg)
    local data = load_data(_config.moderation.data)
	local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end
	local message = 'لیست ادمینان گلوبال:\n'
	for k,v in pairs(data[tostring(admins)]) do
		message = message .. '- (at)' .. v .. ' [' .. k .. '] ' ..'\n'
	end
	return message
end

local function groups_list(msg)
	local data = load_data(_config.moderation.data)
	local groups = 'groups'
	if not data[tostring(groups)] then
		return 'No groups at the moment'
	end
	local message = 'List of groups:\n'
	for k,v in pairs(data[tostring(groups)]) do
		if data[tostring(v)] then
			if data[tostring(v)]['settings'] then
			local settings = data[tostring(v)]['settings']
				for m,n in pairs(settings) do
					if m == 'set_name' then
						name = n
					end
				end
                local group_owner = "No owner"
                if data[tostring(v)]['set_owner'] then
                        group_owner = tostring(data[tostring(v)]['set_owner'])
                end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
					group_link = data[tostring(v)]['settings']['set_link']
				end
				message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
			end
		end
	end
	m = json.encode(message)
    local file = io.open("./data/groups/lists/groups.txt", "w")
	file:write(m)
	file:flush()
	file:close()
    return message
end
local function admin_user_promote(receiver, member_username, member_id)
        local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
            save_data(_config.moderation.data, data)
        end
        if data['admins'][tostring(member_id)] then
            return send_large_msg(receiver, '@'..member_username..' هم اکنون گلوبال ادمین است')
        end
        data['admins'][tostring(member_id)] = member_username
        save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' به عنوان گلوبال ادمین شناخته شد')
end

local function admin_user_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    if not data['admins'] then
		data['admins'] = {}
        save_data(_config.moderation.data, data)
	end
	if not data['admins'][tostring(member_id)] then
		send_large_msg(receiver, "@"..member_username..' ادمین گلوبال نیست')
		return
    end
	data['admins'][tostring(member_id)] = nil
	save_data(_config.moderation.data, data)
	send_large_msg(receiver, '@'..member_username..' از ادمین گلوبالی نتزل یافت')
end

local function res_user_support(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local get_cmd = cb_extra.get_cmd
   local support_id = result.peer_id
	if get_cmd == 'addsupport' then
		support_add(support_id)
		send_large_msg(receiver, "["..support_id.."] به تیم پشتیبانی ربات اضافه گردید")
	elseif get_cmd == 'removesupport' then
		support_remove(support_id)
		send_large_msg(receiver, "["..support_id.."] از تیم پشتیبانی ربات حذف گردید")
	end
end

------------------------------------------
local function parsed_url(link)
  local parsed_link = URL.parse(link)
  local parsed_path = URL.parse_path(parsed_link.path)
  return parsed_path[2]
end
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  return false
end
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end
local function reload_plugins( )
	plugins = {}
  return load_plugins()
end
------------------------------------------
local function id_username(extra, success, result)
        if success == 1 then
 if result.username then
   Username = '@'..result.username
   else
   Username = "یافت نشد"
   end
    		if result.phone then
	numberorg = string.sub(result.phone, 3)
   number = "0"..string.sub(numberorg, 0,6).."****"
else
   number =  "یافت نشد"
   end
    local text = 'نام : '..(result.first_name or '')..' '..(result.last_name or '')..'\n'
               ..'نام کاربری : '..Username..'\n'
               ..'شناسه : '..result.peer_id..'\n\n'
               ..'شماره تلفن : '..number
  send_msg(extra.receiver, text, ok_cb,  true)
  else
	send_msg(extra.receiver, extra.user..' یافت نشد\nبا شناسه جست و جو کنید',k_cb, false)
end 
end
-------------------------------------------
local function id_id(extra, success, result)  -- /info <ID> function
 if success == 1 then
 if result.username then
   Username = '@'..result.username
   else
   Username =  "یافت نشد"
   end
    		if result.phone then
	numberorg = string.sub(result.phone, 3)
   number = "0"..string.sub(numberorg, 0,6).."****"
else
   number = "یافت نشد"
   end
    local text = 'نام : '..(result.first_name or '')..' '..(result.last_name or '')..'\n'
               ..'نام کاربری : '..Username..'\n'
               ..'شناسه : '..result.peer_id..'\n\n'
               ..'شماره تلفن : '..number

  send_msg(extra.receiver, text, ok_cb,  true)
  else
  send_msg(extra.receiver, 'یافت نشد\nبا نام کاربری جست و جو کنید', ok_cb, false)
  end
end
local function id_reply(extra, success, result)-- (reply) /info  function
		if result.from.username then
		   Username = '@'..result.from.username
		   else
   Username = "یافت نشد"
	 end
    		if result.from.phone then
	numberorg = string.sub(result.from.phone, 3)
   number = "0"..string.sub(numberorg, 0,6).."****"
else
   number = "یافت نشد"
   end
    local text = 'نام '..(result.from.first_name or '')..' '..(result.from.last_name or '')..'\n'
               ..'نام کاربری : '..Username..'\n'
               ..'شناسه : '..result.from.peer_id..'\n\n'
               ..'شماره تماس : '..number
               
  reply_msg(extra.Reply, text, ok_cb, false)
end

------------------------------------------
local function history(extra, suc, result)
  for i=1, #result do
    delete_msg(result[i].id, ok_cb, false)
	end
  if tonumber(extra.con) >= #result then
    send_msg(extra.chatid, '"'..#result..'" پیام اخیر سوپر گروه حذف شد', ok_cb, false)
	end
  end
---------------------------------
local function addword(msg, name)
    local hash = 'chat:'..msg.to.id..':badword'
    redis:hset(hash, name, 'newword')
    return "کلمه جدید به فیلتر کلمات اضافه شد\n>"..name
end
local function get_variables_hash(msg)
    return 'chat:'..msg.to.id..':badword'
end 
local function list_variablesbad(msg)
  local hash = get_variables_hash(msg)
  if hash then
    local names = redis:hkeys(hash)
    local text = 'لیست کلمات غیرمجاز :\n\n'
    for i=1, #names do
      text = text..'> '..names[i]..'\n'
    end
    return text
	else
	return 
  end
end
function clear_commandbad(msg, var_name)
  --Save on redis  
  local hash = get_variables_hash(msg)
  redis:del(hash, var_name)
  return 'پاک شدند'
end
local function list_variables2(msg, value)
  local hash = get_variables_hash(msg)
    if hash then
    local names = redis:hkeys(hash)
    local text = ''
    for i=1, #names do
	if string.match(value, names[i]) and not is_momod(msg) then
	delete_msg(msg.id,ok_cb,false)
	else
	kick_user(msg.from.id, msg.to.id)
	end
return 
end
      --text = text..names[i]..'\n'
    end
  end
local function get_valuebad(msg, var_name)
  local hash = get_variables_hash(msg)
  if hash then
    local value = redis:hget(hash, var_name)
    if not value then
      return
    else
      return value
    end
  end
end
function clear_commandsbad(msg, cmd_name)
  --Save on redis  
  local hash = get_variables_hash(msg)
  redis:hdel(hash, cmd_name)
  return ''..cmd_name..' پاک شد'
end

local function run(msg, matches)
		if matches[1] == 'clean' and msg.to.type == "channel" and is_owner(msg) then
      if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 5 then
        return "حداقل تعداد 5 و حداکثر تعداد حذف 100 میباشد"
      end
      get_history(msg.to.peer_id, matches[2] + 1 , history , {chatid = msg.to.peer_id, con = matches[2]})
	end 


 if matches[1] == 'mutegp' and is_momod(msg) then
       local hash = 'muteall:'..msg.to.id
       if not matches[2] then
		redis:set(hash, true)
		return "گروه تا اطلاع ثانوی به حالت سکوت تغییر کرد\nلطفا از ارسال مطلب خودداری کنید"
	else
	local num1 = tonumber(matches[2]) * 3600
	local num2 = tonumber(matches[3]) * 60
	local num4 = (num1 + num2)
	redis:setex(hash, num4, true)
	return "گروه به مدت "..matches[2].." ساعت و "..matches[3].." دقیقه به حالت سکوت رفت\n\nتا زمان تایین شده تمامی مطالب حذف خواهند شد\nاز ارسال مطلب خودداری کنید"
	end
 end
 	if matches[1] == 'unmutegp' and is_momod(msg) then
		local hash = 'muteall:'..msg.to.id
		redis:del(hash)
		return "حالت سکوت گروه غیرفعال شد\nاز این پس چت مجاز است"
		end
----------HASH ID-----------------------
if matches[1] == "hash" and matches[2] == "id" and is_owner(msg) then
		num = ''
		is_id =	redis:hget('hash_id::',msg.to.id)
 for i=1,15 do
	if i == 1 then
		num = num..math.random(1,9)
	else
		num = num..math.random(0,9)
	end
end
	if is_id then 
		return is_id
	else 
		redis:hset('hash_id::',msg.to.id,"HEXTOR("..num..")")
		redis:hset("HEXTOR("..num..")","Group_Log",msg.to.id)
		send_large_msg(get_receiver(msg),"کد جدید تنظیم شد!\n\nکد : HEXTOR("..num..")")
	end
end
------------------HASH Rem---------------------
	if matches[1] == "hash" and matches[2] == "rem" and is_sudo(msg) then 
		redis:hdel('hash_id::',msg.to.id)
		return "کد اختصاصی حذف شد"
	end
	------------------------------------
		if matches[1] == 'leave' and not matches[2] and is_admin1(msg) then
		chat_del_user("chat#id"..msg.to.id, 'user#id'..our_id, ok_cb, false)
		leave_channel(get_receiver(msg), ok_cb, false)
				end
	if matches[1] == "leave" and matches[2] and is_sudo(msg) then
			send_large_msg("channel#id"..matches[2],"ربات به دلایلی(انقضا,صلاحیت گپ,دستور مدیر)از گروه خارج میشود\n\nارتباط با ما\n<code>مدیر ربات :</code> @HEXTOR\n<code>پیام رسان افراد ریپورت :</code> @ReZa_HEXTOR_Bot\n<code>کانال اطلاع رسانی :</code> @HEXTOR_CH")
      chat_del_user("chat#id"..matches[2], 'user#id'..our_id, ok_cb, false)
      leave_channel("channel#id"..matches[2], ok_cb, false)
			return "خروج از گروه["..matches[2].."] موفقیت امیز بود"
				end
	if msg.service and msg.action.type == "chat_add_user" and msg.action.user.id == tonumber(our_id) and not is_admin1(msg) then
		send_large_msg(get_receiver(msg), 'تنها مدیران اجازه افزودن من به گروهی را دارند\n\nمدیر : @HEXTOR', ok_cb, false)
		chat_del_user(get_receiver(msg), 'user#id'..our_id, ok_cb, false)
		leave_channel(get_receiver(msg), ok_cb, false)
   		 end
	---------------------------
	 if matches[1]:lower() == 'charge' and is_sudo(msg) then
	 if matches[2] and not matches[3] then 
    local time = os.time()
    local buytime = tonumber(os.time())
    local timeexpire = tonumber(buytime) + (tonumber(matches[2] * 86400))
    redis:hset('expiretime',msg.to.id,timeexpire)
    send_large_msg("channel#id"..msg.to.id,"گروه به مدت ("..matches[2].." روز) فعال شد")
    end
  if matches[3] == "1" then
  local time = os.time()
  local buytime = tonumber(os.time())
  local timeexpire = tonumber(buytime) + 30 * 86400
  redis:hset('expiretime',matches[2],timeexpire)
    send_large_msg("channel#id"..matches[2],"گروه به مدت (30 روز) فعال شد")
    return "Group ["..matches[2].."] Expiry date was extended to (30 Day)"
    end
  if matches[3] == "2" then
  local time = os.time()
  local buytime = tonumber(os.time())
  local timeexpire = tonumber(buytime) + 60 * 86400
  redis:hset('expiretime',matches[2],timeexpire)
    send_large_msg("channel#id"..matches[2],"گروه به مدت (60 روز) فعال شد")
    return "Group ["..matches[2].."] Expiry date was extended to (60 Day)"
end
    if matches[3] == "unlimit" then
  local time = os.time()
  local buytime = tonumber(os.time())
  local timeexpire = tonumber(buytime) + 730 * 86400
  redis:hset('expiretime',matches[2],timeexpire)
    send_large_msg("channel#id"..matches[2],"گروه به مدت (نامحدود) فعال شد")
    return "Group ["..matches[2].."] Expiry date was extended to (Unlimite)"  
  end 
    if matches[3]:match("%d+") then
  local time = os.time()
  local buytime = tonumber(os.time())
  local timeexpire = tonumber(buytime) + (tonumber(matches[3] * 86400))
  redis:hset('expiretime',matches[2],timeexpire)
    send_large_msg("channel#id"..matches[2],"گروه به مدت ("..matches[3].." روز) فعال شد")
    return "Group ["..matches[2].."] Expiry date was extended to ("..matches[3].." Day)"
end
  end
 -----------		
	if matches[1]:lower() == 'charge' then
		local expiretime = redis:hget ('expiretime', msg.to.id)
	if not expiretime then
		return 'Not Setted'
	else
		local now = tonumber(os.time())
		local text = math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
		return text.." روز بعد"
		end
	end
	----------------------------
	  if matches[1]:lower() == "banlist" and is_momod(msg) then -- Ban list !
    local chat_id = msg.to.id
    if matches[2] and is_admin(msg) then
      chat_id = matches[2] 
    end
    return ban_list(chat_id)
  end
  if matches[1]:lower() == 'ban' and is_momod(msg) then-- /ban 
    if type(msg.reply_id)~="nil" and is_momod(msg) then
      if is_admin(msg) then
        local msgr = get_message(msg.reply_id,ban_by_reply_admins, false)
      else
        msgr = get_message(msg.reply_id,ban_by_reply, false)
      end
    end
      local user_id = matches[2]
      local chat_id = msg.to.id
      if string.match(matches[2], '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then 
         	return
        end
        if not is_admin(msg) and is_momod2(matches[2], msg.to.id) then
          	return "you can't ban mods/owner/admins"
        end
        if tonumber(matches[2]) == tonumber(msg.from.id) then
          	return "You can't ban your self !"
        end
        local name = user_print_name(msg.from)
        ban_user(user_id, chat_id)
      else
		local cbres_extra = {
		chat_id = msg.to.id,
		get_cmd = 'ban',
		from_id = msg.from.id
		}
		local username = matches[2]
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
    	end
  end
  if matches[1]:lower() == 'unban' and is_momod(msg) then -- /unban 
    if type(msg.reply_id)~="nil" and is_momod(msg) then
      local msgr = get_message(msg.reply_id,unban_by_reply, false)
    end
      local user_id = matches[2]
      local chat_id = msg.to.id
      local targetuser = matches[2]
      if string.match(targetuser, '^%d+$') then
        	local user_id = targetuser
        	local hash =  'banned:'..chat_id
        	redis:srem(hash, user_id)
        	local name = user_print_name(msg.from)
        	return 'User '..user_id..' unbanned'
      else
		local cbres_extra = {
			chat_id = msg.to.id,
			get_cmd = 'unban',
			from_id = msg.from.id
		}
		local username = matches[2]
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
	end
 end
if matches[1]:lower() == 'kick' and is_momod(msg) then
    if type(msg.reply_id)~="nil" and is_momod(msg) then
      if is_admin1(msg) then
        local msgr = get_message(msg.reply_id,Kick_by_reply_admins, false)
      else
        msgr = get_message(msg.reply_id,Kick_by_reply, false)
      end
    end
	if string.match(matches[2], '^%d+$') then
		if tonumber(matches[2]) == tonumber(our_id) then 
			return
		end
		if not is_admin2(msg) and is_momod2(matches[2], msg.to.id) then
			return "you can't kick mods/owner/admins"
		end
		if tonumber(matches[2]) == tonumber(msg.from.id) then
			return "You can't kick your self !"
		end
      		local user_id = matches[2]
      		local chat_id = msg.to.id
		name = user_print_name(msg.from)
		kick_user(user_id, chat_id)
	else
		local cbres_extra = {
			chat_id = msg.to.id,
			get_cmd = 'kick',
			from_id = msg.from.id
		}
		local username = matches[2]
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
	end
end
  if matches[1]:lower() == 'banall' and is_sudo(msg) then -- Global ban
    if type(msg.reply_id) ~="nil" and is_admin(msg) then
      return get_message(msg.reply_id,banall_by_reply, false)
    end
    local user_id = matches[2]
    local chat_id = msg.to.id
      local targetuser = matches[2]
      if string.match(targetuser, '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then
         	return false 
        end
        	banall_user(targetuser)
       		return 'User ['..user_id..' ] globally banned'
      else
	local cbres_extra = {
		chat_id = msg.to.id,
		get_cmd = 'banall',
		from_id = msg.from.id
	}
		local username = matches[2]
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
      	end
  end
  if matches[1]:lower() == 'unbanall' and is_sudo(msg) then -- Global unban
    local user_id = matches[2]
    local chat_id = msg.to.id
      if string.match(matches[2], '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then 
          	return false 
        end
       		unbanall_user(user_id)
        	return 'User ['..user_id..' ] removed from global ban list'
      else
	local cbres_extra = {
		chat_id = msg.to.id,
		get_cmd = 'unbanall',
		from_id = msg.from.id
	}
		local username = matches[2]
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
      end
  end
  if matches[1]:lower() == "gbanlist" and is_sudo(msg) then -- Global ban list
    return banall_list()
  end
	----------------------------
	  if matches[1] == "markread" and is_admin1(msg) then
    	if matches[2] == "on" then
    		redis:set("bot:markread", "on")
    		return "Mark read > on"
    	end
    	if matches[2] == "off" then
    		redis:del("bot:markread")
    		return "Mark read > off"
    	end
    	return
    end
    if matches[1] == "pmblock"and is_admin1(msg)  then
    	if is_admin2(matches[2]) then
    		return "نمیتوانید ادمین گلوبال هارا بن کنید"
    	end
    	block_user("user#id"..matches[2],ok_cb,false)
    	return "مسدود شد"
    end
    if matches[1] == "pmunblock" and is_admin1(msg) then
    	unblock_user("user#id"..matches[2],ok_cb,false)
    	return "از مسدودی خارج شد"
    end
    if matches[1] == "import" and is_admin1(msg)  then
    	local hash = parsed_url(matches[2])
    	import_chat_link(hash,ok_cb,false)
    end
    if matches[1] == "addcontact" and is_sudo(msg) then
    phone = matches[2]
    first_name = matches[3]
    last_name = matches[4]
    add_contact(phone, first_name, last_name, ok_cb, false)
   return "کاربر با شماره  ["..matches[2].."] به لیست مخاطبین اضافه شد"
end
	if matches[1] == 'reload' and is_admin1(msg)  then
		receiver = get_receiver(msg)
		reload_plugins(true)
		return "<b>Bot Has Been Reloaded</b>"
	end
	if matches[1] == "vardump" and is_admin1(msg) then
		local text = serpent.block(msg, {comment=false})
		send_large_msg("channel#id"..msg.to.id, text)
	end
	
	--------------------------
			if matches[1] == 'rem' and matches[2] and is_sudo(msg) then
		    local data = load_data(_config.moderation.data)

			data[tostring(matches[2])] = nil
			save_data(_config.moderation.data, data)
			local groups = 'groups'
			if not data[tostring(groups)] then
				data[tostring(groups)] = nil
				save_data(_config.moderation.data, data)
			end
			data[tostring(groups)][tostring(matches[2])] = nil
			save_data(_config.moderation.data, data)
			send_large_msg(get_receiver(msg), 'گروه ['..matches[2]..'] ا ز سیستم پاک شد')
		end
		if matches[1] == 'support' and matches[2] and is_sudo(msg) then
			if string.match(matches[2], '^%d+$') then
				local support_id = matches[2]
				support_add(support_id)
				return "User ["..support_id.."] has been added to the support team"
			else
				local member = string.gsub(matches[2], "@", "")
				local receiver = get_receiver(msg)
				local get_cmd = "addsupport"
				resolve_username(member, res_user_support, {get_cmd = get_cmd, receiver = receiver})
			end
		end
		if matches[1] == '-support' and is_sudo(msg) then
			if string.match(matches[2], '^%d+$') then
				local support_id = matches[2]
				support_remove(support_id)
				return "User ["..support_id.."] has been removed from the support team"
			else
				local member = string.gsub(matches[2], "@", "")
				local receiver = get_receiver(msg)
				local get_cmd = "removesupport"
				resolve_username(member, res_user_support, {get_cmd = get_cmd, receiver = receiver})
			end
		end
		if matches[1] == 'list' and is_sudo(msg) then
			if matches[2] == 'admins' then
				return admin_list(msg)
			end
		end
		if matches[1] == 'list' and matches[2] == 'groups' and is_sudo(msg) then
				groups_list(msg)
				send_document("channel#id"..msg.to.id, "./data/groups/lists/groups.txt", ok_cb, false)
				return "در حال ارسال..." 
		end
	--------------------------
if matches[1]:lower() == 'id' and not matches[2] then
  local receiver = get_receiver(msg)
  local Reply = msg.reply_id
  if msg.reply_id then
    msgr = get_message(msg.reply_id, id_reply, {receiver=receiver, Reply=Reply})
  else
  if msg.from.username then
   Username = '@'..msg.from.username
   else
   Username = 'یافت نشد'
end
   		if msg.from.phone then
	numberorg = string.sub(msg.from.phone, 3)
   number = "0"..string.sub(numberorg, 0,6).."****"
else
   number = "یافت نشد"
end

   local text = 'نام '..(msg.from.first_name or '')..' '..(msg.from.last_name or '')..'\n'
   local text = text..'نام کاربری : '..Username..'\n'
   local text = text..'شناسه : '..msg.from.id..'\n'
   local text = text..'شماره تلفن : '..number..'\n'
    return reply_msg(msg['id'], text, ok_cb, true)
end
end
  if matches[1]:lower() == 'id' and matches[2] then
   local user = matches[2]
   local chat2 = msg.to.id
   local receiver = get_receiver(msg)
   if string.match(user, '^%d+$') then
	  user_info('user#id'..user, id_id, {receiver=receiver, user=user, text=text, chat2=chat2})
       elseif string.match(user, '^@.+$') then
      username = string.gsub(user, '@', '')
      msgr = resolve_username(username, id_username, {receiver=receiver, user=user, text=text, chat2=chat2})
   end
  end
  -------------------------SUPERGROUP.LUA RUN-------------------------
  		if matches[1] == 'tosuper' then
			if not is_admin1(msg) then
				return
			end
			chat_upgrade(get_receiver(msg), ok_cb, false)
			return "گروه با موفقیت به سوپرگپ ارتقا یافت"
		end
			local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == 'add' and not matches[2] then
	if msg.from.username then 
		uu = "@"..msg.from.username..""
		else 
		uu = "یافت نشد"
		end
	if msg.from.last_name then 
		name = msg.from.first_name.." "..msg.from.last_name
		else 
		name = ""..msg.from.first_name
		end
		
	if not is_admin1(msg) and not is_support(support_id) then
		return 
			end
	if is_super_group(msg) then
			return reply_msg(msg.id, '<i>در حال حاضر گروه در سیستم مدیریتی ثبت شده است</i>', ok_cb, false)
			end
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
			send_large_msg("channel#id1085540553","گروه جدید در سیستم افزوده شد :\n➖➖➖➖\n<code>مشخصات اضافه کننده :</code>\n\nنام : "..name.."\nنام کاربری : "..uu.."\nشناسه : "..msg.from.id.."\n➖➖➖➖\n<code>مشخصات گروه :</code>\nنام : "..msg.to.title.."\nشناسه : "..msg.to.id.."\n\n<code>برای خروج ربات از گپ از دستور زیر استفاده کنید :</code>\n/leave"..msg.to.id.."\n➖➖➖➖➖➖➖\n<code>شارژ یکماهه :</code> \n/charge"..msg.to.id.."_1\n<code>شارژ دوماهه :</code>\n/charge"..msg.to.id.."_2\n<code>شارژ به میزان روز دلخواه:</code>\n/charge"..msg.to.id.." [Number Day]\n\n<code>شارژ نامحدود :</code>\n/charge"..msg.to.id.."_unlimit\n------------------\n")
		end

		if matches[1] == 'rem' and is_admin1(msg) and not matches[2] then
	if msg.from.username then 
		uu = "@"..msg.from.username..""
		else 
		uu = "Not Found"
		end
	if msg.from.last_name then 
		name = msg.from.first_name.." "..msg.from.last_name
		else 
		name = ""..msg.from.first_name
		end
			if not is_super_group(msg) then
				return reply_msg(msg.id, '<i>گروه به سیستم مدیریتی اضافه نشده است</i>.', ok_cb, false)
			end
			superrem(msg)
			rem_mutes(msg.to.id)
			send_large_msg("channel#id1085540553","گروهی از سیستم پاک شد :\n➖➖➖➖\n<code>مشخصات حذف کننده :</code>\nنام : "..name.."\nنام کاربری : "..uu.."\nشناسه : "..msg.from.id.."\n➖➖➖➖\n<code>مشخصات گروه :</code>\nنام : "..msg.to.title.."\nشناسه : "..msg.to.id.."\n➖➖➖➖\nHEXTOR Team")

		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "info" then
			if not is_owner(msg) then
				return
			end
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "admins" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "owner" then
					local group_owner = data[tostring(msg.to.id)]['set_owner']
	gpowner = redis:hget("owner:group:",msg.to.id)
	if  gpowner then 
	textt = "صاحب گروه :  @"..gpowner
	else 
	textt ="صاحب گروه : ["..group_owner..']'
	end
			if not group_owner then
				return "صاحبی یافت نشد\n با مراجعه به ادمین (@HEXTOR) یک صاحب برای گروه تایین کنید"
			end
			return textt
		end

		if matches[1] == "modlist" then
			return modlist(msg)
		end

		if matches[1] == "bots" and is_momod(msg) then
			member_type = 'Bots'
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == 'del' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end
		if matches[1] == 'kickme' then
			if msg.to.type == 'channel' then
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
				return "کاربر ["..msg.from.id.."] با دستور kickme از گروه خارج شد"
			end
		end

		if matches[1] == 'newlink' and not matches[2] and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, 'لینکی ثبت نشده است\nبا دستور/setlink لینک گروه را تنظیم کنید')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "Created a new link")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
				redis:hset("group_links",msg.to.id,result)
					save_data(_config.moderation.data, data)
				end
			end
			export_channel_link(receiver, callback_link, false)
		end
		if matches[1] == 'newlink' and matches[2] == "pv" and is_owner(msg)then
			local function callback_link_pv (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, 'لینکی ثبت نشده است\nبا دستور/setlink لینک گروه را تنظیم کنید')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "لینک جدید ساخته و به خصوصی ارسال شد")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					send_large_msg('user#id'..msg.from.id, "لینک جدید :\n"..result)
					redis:hset("group_links",msg.to.id,result)
					save_data(_config.moderation.data, data)
				end
			end
			export_channel_link(receiver, callback_link_pv, false)
		end
		
		if matches[1] == 'setlink' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'..msg.from.id
			save_data(_config.moderation.data, data)
			return 'لینک فعلی گروه را ارسال کنید'
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting'..msg.from.id and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				redis:hset("group_links",msg.to.id,msg.text)
				save_data(_config.moderation.data, data)
				return "لینک جدید تنظیم شد\n\nبا دستور /link میتوان لینک تنظیم شده را دریافت کرد"
			end
		end

		if matches[1] == 'link' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return "لینک موجود نیست\nبا دستور /setlink لینک جدید را تنظیم کنید"
			end
			return "لینک گروه : \n "..group_link
		end

		if matches[1] == 'setowner' and is_owner(msg) then
				dmdmd = msg.to.id
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setowner' and matches[2] and string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				dmdmd = msg.to.id
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setowner' and matches[2] and not string.match(matches[2], '^%d+$') then
			dmdmd = msg.to.id
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'promote' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'promote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'promote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

--By @SoLiD021
  if matches[1]:lower() == "silent" and not matches[2] and is_momod(msg) then
   local chat_id = msg.to.id
   local hash = "silent_user"..chat_id
   local user_id = ""
   if type(msg.reply_id) ~= "nil" then
    local receiver = get_receiver(msg)
    muteuser = get_message(msg.reply_id, silentuser_by_reply, {receiver = receiver, msg = msg})
   elseif matches[1]:lower() == "silent" and is_momod(msg) and string.match(matches[2], '^%d+$') then
    local user_id = matches[2]
    if is_momod2(msg.from.id, chat_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..chat_id, "You can't silent mods/owner/admins")
    end
    if is_admin2(msg.from.id) then
         return send_large_msg("channel#id"..chat_id, "You can't silent other admins")
    end
    if is_muted_user(chat_id, user_id) then
     return "["..user_id.."] هم اکنون در لیست سکوت است"
      end
     mute_user(chat_id, user_id)
     return "["..user_id.."] به لیست سکوت اضافه شد"
    
   elseif matches[1]:lower() == "silent" and not string.match(matches[2], '^%d+$') and is_momod(msg) then
    local receiver = get_receiver(msg)
    local username = matches[2]
    local username = string.gsub(matches[2], '@', '')
    resolve_username(username, silentuser_by_username, {receiver = receiver, msg=msg})
   end
  end

--By @SoLiD021
  if matches[1]:lower() == "unsilent" and is_momod(msg) then
   local chat_id = msg.to.id
   local hash = "silent_user"..chat_id
   local user_id = ""
   if type(msg.reply_id) ~= "nil" then
    local receiver = get_receiver(msg)
    muteuser = get_message(msg.reply_id, unsilentuser_by_reply, {receiver = receiver, msg = msg})
   elseif matches[1]:lower() == "unsilent" and string.match(matches[2], '^%d+$') and is_momod(msg) then
    local user_id = matches[2]
    if is_muted_user(chat_id, user_id) then
     unmute_user(chat_id, user_id)
     return "["..user_id.."] از لیست سکوت حذف شد"
    else
     return "["..user_id.."] در لیست سکوت نیست"
    end
   elseif matches[1]:lower() == "unsilent" and not string.match(matches[2], '^%d+$') and is_momod(msg) then
    local receiver = get_receiver(msg)
    local username = matches[2]
    local username = string.gsub(matches[2], '@', '')
    resolve_username(username, unsilentuser_by_username, {receiver = receiver, msg=msg})
   end
  end
     if matches[1] == 'silentlist' and is_sudo(msg) then
   local chat_id = msg.to.id
     return muted_user_list(chat_id)
    end

		if matches[1] == 'demote' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/support/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "setname" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "setabout" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "توضیحات ثبت شد : \n---------------------------\n"..about_text.."\n---------------------------\n"
		end

		if matches[1] == 'setrules' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			return set_rulesmod(msg, data, target)
		end
		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting'..msg.from.id and is_momod(msg) then
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'setphoto' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'..msg.from.id
			save_data(_config.moderation.data, data)
			return 'عکسی که میخواهید به عنوان پروفایل گروه تنظیم شود را ارسال کنید'
		end

		if matches[1] == 'clean' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "Only owner can clean"
			end
			if matches[2] == 'modlist' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return 'هیچ مدیری یافت نشد'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				return 'پاک شد'
			end
			if matches[2] == 'rules' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "متنی ست نشده است"
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				return "پاک شد"
			end
			if matches[2] == 'about' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return 'متنی تنظیم نشده است'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				channel_set_about(receiver, about_text, ok_cb, false)
				return "پاک شد"
			end
			if matches[2] == "bots" and is_momod(msg) then
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end

	if matches[1] == "ads" and  is_momod(msg) then 
	local target = msg.to.id
		if matches[2]:lower() == 'kick' then
			return kick_on(msg, data, target)
			end
		if matches[2]:lower()  == 'del' then
			return kick_off(msg, data, target)
			end
			end
		if matches[1] == 'lock' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'link' then
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'spam' then
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood' then
				return lock_group_flood(msg, data, target)
			end			
			if matches[2] == 'bots' then
				return lock_group_bots(msg, data, target)
			end
			if matches[2] == 'member' then
				return lock_group_membermod(msg, data, target)
			end
			if matches[2] == 'tg' then
				return lock_group_tgservice(msg, data, target)
		end
end
		if matches[1] == 'unlock' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'link' then
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'spam' then
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood' then
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'bots' then
				return unlock_group_bots(msg, data, target)
			end
			if matches[2] == 'member' then
				return unlock_group_membermod(msg, data, target)
			end
				if matches[2] == 'tg' then
				return unlock_group_tgservice(msg, data, target)
		end 
			end
		if matches[1] == 'flood' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 3 or tonumber(matches[2]) > 30 then
				return "عدد نامعتبر است\nمحدودیت اعداد بین 3 تا 30 است"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			return 'حساسیت اسپم به ('..matches[2]..') تنظیم شد'
		end
		--------------
		if matches[1] == 'maxchar' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 50000 then
				return "عدد نامعتبر است\nمحدودیت اعداد بین 5 تا 50000 است"
			end
			local max_char = matches[2]
			data[tostring(msg.to.id)]['settings']['max_char'] = max_char
			save_data(_config.moderation.data, data)
			return 'حداکثر تعداد مجاز کاراکتر ارسالی به ('..matches[2]..') تنظیم شد'
		end
if matches[1] == 'mute' and is_owner(msg) then
		local chat_id = msg.to.id	
		if matches[2] == 'contact' then
			local msg_type = 'Contact'
			if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'audio' then
			local msg_type = 'Audio'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'photo' then
			local msg_type = 'Photo'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'video' then
			local msg_type = 'Video'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'gifs' then
			local msg_type = 'Gifs'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'doc' then
			local msg_type = 'Documents'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'text' then
			local msg_type = 'Text'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
	if matches[2] == 'all' then
			local msg_type = 'All'
		if not is_muted(chat_id, msg_type..': yes') then
			mute(chat_id, msg_type)
			return "<b>"..msg_type.."</b> <code>قفل شد</code>"
			else
			return "<b>"..msg_type.."</b> <code>قفل است</code>"
			end
			end
			end
			--------------------------------------
		if matches[1] == 'unmute' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <code>آزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>قفل نیست</code>"
				end
			end
			if matches[2] == 'photo' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <code>آزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>قفل نیست</code>"
				end
			end
			if matches[2] == 'video' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <code>آزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>قفل نیست</code>"
				end
			end
			if matches[2] == 'gifs' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <code>آزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>قفل نیست</code>"
				end
			end
			if matches[2] == 'doc' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <code>آزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>قفل نیست</code>"
				end
			end
			if matches[2] == 'text' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <codeآزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>iقفل نیست</code>"
				end
			end
			if matches[2] == 'all' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
					return "<b>"..msg_type.."</b> <code>آزاد شد</code>"
				else
					return "<b>"..msg_type.."</b> <code>قفل نیست</code>"
				end
			end
		end

		if matches[1] == "muteslist" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			return mutes_list(chat_id)
		end
		if matches[1] == "mutelist" and is_momod(msg) then
			local chat_id = msg.to.id
			return muted_user_list(chat_id)
		end

		if matches[1] == 'settings' and is_momod(msg) then
			local target = msg.to.id
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'rules' then
			return get_rules(msg, data)
		end
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
	-------------------------
  if matches[1] == 'addword' then
  if not is_momod(msg) then
   return 'شما مجاز نیستید'
  end
  local name = string.sub(matches[2], 1, 50)
  local text = addword(msg, name)
  return text
  end
  if matches[1] == 'badwords' then
  return list_variablesbad(msg)
  elseif matches[2] == 'clearbadwords' then
if not is_momod(msg) then return '_|_' end
  local asd = '1'
    return clear_commandbad(msg, asd)
  elseif matches[1] == 'remword' then
   if not is_momod(msg) then return '_|_' end
    return clear_commandsbad(msg, matches[2])
  else
    local name = user_print_name(msg.from)
  
    return list_variables2(msg, matches[1])
  end
end


--------------
local function cron()
	kicktable = {}
end
return {
  patterns = {
	'^[!/#](clean) (%d*)$',
	'^[/!#](mutegp)$',
	'^[/!#](unmutegp)$',
	'^[/!#](mutegp) (%d+) (%d+)$',
	"^[!/#]([Hh]ash) ([Ii]d)$",
	"^[!/#]([Hh]ash) ([Rr]em)$",
	"^[!/]([Cc]harge) (%d+)$",
	"^[!/]([Cc]harge)(%d+) (%d+)$",
	"^[!/]([Cc]harge)(%d+)_(1)$",
	"^[!/]([Cc]harge)(%d+)_(2)$",
	"^[!/]([Cc]harge)(%d+)_(unlimit)$",
	"^[!/]([Cc]harge)$",
	"^[/!]([Ii][Dd])$",
	"^[/!]([Ii][Dd]) (.*)$",
	"^[#!/](pm) (%d+) (.*)$",
	"^[#!/](import) (.*)$",
	"^[#!/](pmunblock) (%d+)$",
	"^[#!/](pmblock) (%d+)$",
	"^[#!/](markread) (on)$",
	"^[#!/](markread) (off)$",
	"^[#!/](vardump)$",
	"^[#!/](addcontact) (.*) (.*) (.*)$", 
	"^[#/!](reload)$",
	"^[#!/](creategroup) (.*)$",
	"^[#!/](rem) (%d+)$",
    "^[#!/](addadmin) (.*)$", 
    "^[#!/](removeadmin) (.*)$", 
	"[#!/](support)$",
	"^[#!/](support) (.*)$",
    "^[#!/](-support) (.*)$",
    "^[#!/](list) (.*)$",
	"^[!/]([Bb]anall) (.*)$",
    "^[!/]([Bb]anall)$",
    "^[!/]([Bb]anlist) (.*)$",
    "^[!/]([Bb]anlist)$",
    "^[!/]([Gg]banlist)$",
    "^[!/]([Bb]an) (.*)$",
    "^[!/]([Kk]ick)$",
    "^[!/]([Uu]nban) (.*)$",
    "^[!/]([Uu]nbanall) (.*)$",
    "^[!/]([Uu]nbanall)$",
    "^[!/]([Kk]ick) (.*)$",
    "^[!/]([Kk]ickme)$",
    "^[!/]([Bb]an)$",
    "^[!/]([Uu]nban)$",
	----------------souperGroup.lua-------------------
		"^[#!/]([Aa]dd)$",
	"^[#!/]([Rr]em)$",
	"^[#!/]([Mm]ove) (.*)$",
	"^[#!/]([Ii]nfo)$",
	"^[#!/]([Aa]dmins)$",
	"^[#!/]([Oo]wner)$",
	"^[#!/]([Mm]odlist)$",
	"^[#!/]([Bb]ots)$",
	"^[#!/]([Ww]ho)$",
	"^[#!/]([Kk]icked)$",
	"^[#!/]([Tt]osuper)$",
	"^[#!/]([Kk]ickme)$",
	"^[#!/]([Nn]ewlink)$",
	"^[#!/]([Nn]ewlink)(pv)$",
	"^[#!/]([Nn]ewlink) (pv)$",
	"^[#!/]([Ss]etlink)$",
	"^[#!/]([Ll]ink)$",
	"^[#!/]([Rr]es) (.*)$",
	"^[#!/]([Ss]etowner) (.*)$",
	"^[#!/]([Ss]etowner)$",
	"^[#!/]([Pp]romote) (.*)$",
	"^[#!/]([Pp]romote)",
	"^[#!/]([Dd]emote) (.*)$",
	"^[#!/]([Dd]emote)",
	"^[#!/]([Ss]etname) (.*)$",
	"^[#!/]([Ss]etabout) (.*)$",
	"^[#!/]([Ss]etrules) (.*)$",
	"^[#!/]([Ss]etphoto)$",
	"^[#!/]([Dd]el)$",
	"^[#!/]([Ll]ock) (.*)$",
	"^[#!/]([Uu]nlock) (.*)$",
	"^[#!/]([Aa]ds) ([Dd][Ee][Ll])$",
	"^[#!/]([Aa]ds) ([kK][Ii][Cc][Kk])$",
	"^[#!/]([Ww]elcome) ([Oo][Nn])$",
	"^[#!/]([Ww]elcome) ([Oo][Ff][Ff])$",
	"^[#!/]([Mm]ute) ([^%s]+)$",
	"^[#!/]([Uu]nmute) ([^%s]+)$",
	"^[#!/]([Ss]ettings)$",
	"^[#!/]([Rr]ules)$",
	"^[#!/]([Ff]lood) (%d+)$",
    "^[#!/]([Mm]axchar) (%d+)$",
	"^[#!/]([Cc]lean) (.*)$",
	"^[!/#]([Ss]ilent)$",
	"^[!/#]([Ss]ilent) (.*)$",
	"^[!/#]([Uu]nsilent)$",
	"^[!/#]([Uu]nsilent) (.*)$",
	"^[!/#]([Ss]ilentlist)$",
	"^[!/#]([Cc]lean) (.*)$",
-----------------------------
	"^[!/](addword) (.*)$",
	"^[!/](remword) (.*)$",
	"^[!/](badwords)$",
	"^(https://telegram.me/joinchat/%S+)$",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
	"^(.+)$",
	  },
	run = run,
	pre_process = pre_process,
	cron = cron,
	}
end
